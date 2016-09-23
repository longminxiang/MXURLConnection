//
//  MXURLConnectionQueue.h
//
//  Created by eric on 15/4/13.
//  Copyright (c) 2015年 Eric Lung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXURLConnection;

@interface MXURLConnectionQueue : NSObject

/**
 *  the max request count in one time
 *  default is 8
 */
@property (nonatomic, assign) NSInteger maxCount;

/**
 *  the global queue
 */
+ (instancetype)globalQueue;

/**
 *  add a connection to the queue
 *
 *  @param connection   the connection
 *  @param index        the connection index
 */
- (void)addConnection:(MXURLConnection *)connection index:(NSInteger)index;

/**
 *  remove a connection from the queue
 *  @param connection   the connection
 */
- (void)removeConnection:(MXURLConnection *)connection;

/**
 *  remove all the connection from the queue
 */
- (void)removeAllConnection;

/**
 *  start the queue
 */
- (void)startQueue;

/**
 *  return how many connections is waiting to request
 */
- (NSInteger)waitingConnectionsCount;

/**
 *  return the queue has connection or not
 */
- (BOOL)hasConnection;

@end
