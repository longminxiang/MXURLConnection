//
//  MXURLConnectionQueue.h
//
//  Created by eric on 15/4/13.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXURLConnection;

@interface MXURLConnectionQueue : NSObject

@property (nonatomic, assign) NSInteger maxCount;

+ (instancetype)globalQueue;

- (void)addConnection:(MXURLConnection *)connection index:(NSInteger)index;

- (void)removeConnection:(MXURLConnection *)connection;

- (void)removeAllConnection;

- (void)startQueue;

- (NSInteger)waitingConnectionsCount;

- (BOOL)hasConnection;

@end
