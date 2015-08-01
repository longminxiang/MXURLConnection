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

+ (instancetype)sharedQueue;

- (void)addConnection:(MXURLConnection *)connection index:(NSInteger)index;

- (void)removeConnection:(MXURLConnection *)connection;

- (void)startQueue;

- (NSInteger)queueCount;

- (BOOL)hasConnection;

@end
