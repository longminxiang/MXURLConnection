//
//  MXURLConnection.h
//
//  Created by longminxiang on 14-9-16.
//  Copyright (c) 2014年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXURLConnectionQueue.h"

@interface MXURLConnection : NSObject

typedef void (^MXConnectionBlock)(MXURLConnection *connection, NSData *responseData, NSError *error);
typedef void (^MXConnectionDownloadingBlock)(MXURLConnection *connection, long long currentBytes, long long totalBytes, NSError *error);

@property (nonatomic, strong) NSMutableURLRequest *request;

@property (nonatomic, copy) NSString *key;

- (instancetype)initWithRequest:(NSMutableURLRequest *)request;

- (void)setResponseBlock:(MXConnectionBlock)responseBlock;

- (void)setDownloadingBlock:(MXConnectionDownloadingBlock)downloadingBlock;

- (void)start;

/**
 *  队列
 */

@property (nonatomic, weak, readonly) MXURLConnectionQueue *queue;

- (void)startInQueue:(MXURLConnectionQueue *)queue;
- (void)startInQueue:(MXURLConnectionQueue *)queue index:(NSInteger)index;

- (void)startInSharedQueue;
- (void)startInSharedQueueWithIndex:(NSInteger)index;

@end

@interface MXURLConnection (Static)

+ (BOOL)didConnectedToNetwork;

+ (NSString *)formatURL:(NSString *)url params:(NSDictionary *)params;

@end