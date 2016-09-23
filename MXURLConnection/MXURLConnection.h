//
//  MXURLConnection.h
//
//  Created by eric on 14-9-16.
//  Copyright (c) 2014年 Eric Lung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXURLConnectionQueue.h"

@interface MXURLConnection : NSObject

typedef void (^MXConnectionBlock)(MXURLConnection *connection, NSData *responseData, NSError *error);
typedef void (^MXConnectionDownloadingBlock)(MXURLConnection *connection, long long currentBytes, long long totalBytes, NSError *error);

///the connection request, must be set
@property (nonatomic, strong) NSMutableURLRequest *request;

/**
 *  init with connection request
 *
 *  @param request  the connection request
 */
- (instancetype)initWithRequest:(NSMutableURLRequest *)request;

/**
 *  set response block
 *  It will call the block when the connection finished, whether successed or failed
 *
 *  @param responseBlock  the block will be call
 */
- (void)setResponseBlock:(MXConnectionBlock)responseBlock;

/**
 *  set donloading block
 *
 *  @param downloadingBlock  the block will be call
 */
- (void)setDownloadingBlock:(MXConnectionDownloadingBlock)downloadingBlock;

/**
 *  start the connection
 */
- (void)start;

    
/**
 *  cancel the connection
 */
- (void)cancel;

@end

@interface MXURLConnection (Queue)

/**
 *  connection queue
 *  always be nil unless the connection start in queue
 */
@property (nonatomic, weak, readonly) MXURLConnectionQueue *queue;

/**
 *  start the connection in a queue
 *
 *  @param queue  the queue
 */
- (void)startInQueue:(MXURLConnectionQueue *)queue;

/**
 *  start the connection in a queue
 *
 *  @param queue  the queue
 *  @param index  the index
 */
- (void)startInQueue:(MXURLConnectionQueue *)queue index:(NSInteger)index;

    
/**
 *  start the connection in the global queue
 *
 */
- (void)startInGlobalQueue;
    
/**
 *  start the connection in the global queue
 *
 *  @param index  the index
 */
- (void)startInglobalQueueWithIndex:(NSInteger)index;

@end

@interface MXURLConnection (Static)

/**
 *  check did connected to network
 */
+ (BOOL)didConnectedToNetwork;

/**
 *  format the URL and GET params with URLEncode
 *
 *  @param url      URL string
 *  @param params   GET request params
 */
+ (NSString *)formatURL:(NSString *)url params:(NSDictionary *)params;

@end
