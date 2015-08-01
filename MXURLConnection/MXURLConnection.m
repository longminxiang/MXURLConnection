//
//  MXURLConnection.m
//
//  Created by longminxiang on 14-9-16.
//  Copyright (c) 2014年 eric. All rights reserved.
//

#import "MXURLConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include "netdb.h"

@interface MXURLConnection ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *resData;

@property (nonatomic, copy) MXConnectionBlock responseBlock;

@property (nonatomic, assign) BOOL didStart;

@end

@implementation MXURLConnection

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
{
    if (self = [super init]) {
        self.request = request;
    }
    return self;
}

- (void)setRequest:(NSMutableURLRequest *)request
{
    _request = request;
    
    self.key = request.URL.absoluteString;
}

- (void)start
{
    if (self.didStart) return;
    self.didStart = YES;
    if (![MXURLConnection didConnectedToNetwork]) {
        NSError *error = [NSError errorWithDomain:@"无网络连接" code:-1999 userInfo:nil];
        [self performResponseBlockWithError:error];
    }
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [connection start];
    });
}

- (void)performResponseBlockWithError:(NSError *)error
{
    self.didStart = NO;
    [self.queue removeConnection:self];
    NSData *data = !error ? self.resData : nil;
    if(self.responseBlock) self.responseBlock(self, data, error);
    if (self.queue) [self.queue startQueue];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self performResponseBlockWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.resData) self.resData = [NSMutableData new];
    [self.resData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1009) {
        error = [NSError errorWithDomain:@"无网络连接" code:error.code userInfo:error.userInfo];
    }
    else if (error.code == -1005) {
        error = [NSError errorWithDomain:@"网络异常" code:error.code userInfo:error.userInfo];
    }
    [self performResponseBlockWithError:error];
}

#pragma mark
#pragma mark === 队列 ===

- (void)startInSharedQueue
{
    [self startInQueue:[MXURLConnectionQueue sharedQueue]];
}

- (void)startInSharedQueueWithIndex:(NSInteger)index
{
    [self startInQueue:[MXURLConnectionQueue sharedQueue] index:index];
}

- (void)startInQueue:(MXURLConnectionQueue *)queue
{
    [self startInQueue:queue index:MAXFLOAT];
}

- (void)startInQueue:(MXURLConnectionQueue *)queue index:(NSInteger)index
{
    _queue = queue;
    [queue addConnection:self index:index];
    [queue startQueue];
}

- (void)dealloc
{
//    NSLog(@"%@ dealloc",[[self class] description]);
}

@end

@implementation MXURLConnection (Static)

+ (BOOL)didConnectedToNetwork
{
    // 创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    /**
     *  SCNetworkReachabilityRef: 用来保存创建测试连接返回的引用
     *
     *  SCNetworkReachabilityCreateWithAddress: 根据传入的地址测试连接.
     *  第一个参数可以为NULL或kCFAllocatorDefault
     *  第二个参数为需要测试连接的IP地址,当为0.0.0.0时则可以查询本机的网络连接状态.
     *  同时返回一个引用必须在用完后释放.
     *  PS: SCNetworkReachabilityCreateWithName: 这个是根据传入的网址测试连接,
     *  第二个参数比如为"www.2cto.com",其他和上一个一样.
     *
     *  SCNetworkReachabilityGetFlags: 这个函数用来获得测试连接的状态,
     *  第一个参数为之前建立的测试连接的引用,
     *  第二个参数用来保存获得的状态,
     *  如果能获得状态则返回TRUE，否则返回FALSE
     *
     */
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flagsn");
        return NO;
    }
    
    /**
     *  kSCNetworkReachabilityFlagsReachable: 能够连接网络
     *  kSCNetworkReachabilityFlagsConnectionRequired: 能够连接网络,但是首先得建立连接过程
     *  kSCNetworkReachabilityFlagsIsWWAN: 判断是否通过蜂窝网覆盖的连接,
     *  比如EDGE,GPRS或者目前的3G.主要是区别通过WiFi的连接.
     *
     */
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSString *)formatURL:(NSString *)url params:(NSDictionary *)params
{
    NSArray *allKeys = [params allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        NSString *flag = i == 0 ? @"?" : @"&";
        id value = params[key];
        url = [url stringByAppendingFormat:@"%@%@=%@", flag, key, value];
    }
    CFStringRef unescaped = (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]";
    CFStringRef ref = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, unescaped, NULL, kCFStringEncodingUTF8);
    url = (NSString *)CFBridgingRelease(ref);
    return url;
}

@end