//
//  MXURLConnection.m
//
//  Created by eric on 14-9-16.
//  Copyright (c) 2014年 Eric Lung. All rights reserved.
//

#import "MXURLConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <objc/runtime.h>
#include "netdb.h"

@interface MXURLConnection ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, copy) MXConnectionBlock responseBlock;

@property (nonatomic, copy) MXConnectionDownloadingBlock downloadingBlock;

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

- (void)start
{
    if (self.didStart) return;
    self.didStart = YES;
    if (![MXURLConnection didConnectedToNetwork]) {
        NSString *msg = @"无网络连接";
        NSDictionary *dic = @{NSLocalizedFailureReasonErrorKey: msg};
        NSError *error = [NSError errorWithDomain:msg code:-1999 userInfo:dic];
        [self performResponseBlockWithError:error];
    }
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    self.connection = connection;
    dispatch_async(dispatch_get_main_queue(), ^{
        [connection start];
    });
}

- (void)cancel
{
    [self.connection cancel];
}

- (void)performResponseBlockWithError:(NSError *)error
{
    self.didStart = NO;
    [self.queue removeConnection:self];
    NSData *data = !error ? self.responseData : nil;
    if(self.responseBlock) self.responseBlock(self, data, error);
    if (self.downloadingBlock) self.downloadingBlock(self, self.responseData.length, self.response.expectedContentLength, error);
    if (self.queue) [self.queue startQueue];
}

#pragma mark
#pragma mark === delegate ===

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self performResponseBlockWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.responseData) self.responseData = [NSMutableData new];
    [self.responseData appendData:data];
    long long totalLength = self.response.expectedContentLength;
    if (totalLength > 0) {
        if (self.downloadingBlock) self.downloadingBlock(self, self.responseData.length, totalLength, nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1009) {
        NSString *msg = @"无网络连接";
        NSDictionary *dic = @{NSLocalizedFailureReasonErrorKey: msg};
        error = [NSError errorWithDomain:msg code:error.code userInfo:dic];
    }
    else {
        NSString *msg = @"网络异常";
        NSDictionary *dic = @{NSLocalizedFailureReasonErrorKey: msg};
        error = [NSError errorWithDomain:msg code:error.code userInfo:dic];
    }
    [self performResponseBlockWithError:error];
}
    
@end

#pragma mark
#pragma mark === Queue ===

@implementation MXURLConnection (Queue)

- (MXURLConnectionQueue *)queue
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)startInGlobalQueue
{
    [self startInQueue:[MXURLConnectionQueue globalQueue]];
}

- (void)startInglobalQueueWithIndex:(NSInteger)index
{
    [self startInQueue:[MXURLConnectionQueue globalQueue] index:index];
}

- (void)startInQueue:(MXURLConnectionQueue *)queue
{
    [self startInQueue:queue index:MAXFLOAT];
}

- (void)startInQueue:(MXURLConnectionQueue *)queue index:(NSInteger)index
{
    objc_setAssociatedObject(self, @selector(queue), queue, OBJC_ASSOCIATION_ASSIGN);
    [queue addConnection:self index:index];
    [queue startQueue];
}

@end

#pragma mark
#pragma mark === static method ===

@implementation MXURLConnection (Static)

+ (BOOL)didConnectedToNetwork
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flagsn");
        return NO;
    }
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
