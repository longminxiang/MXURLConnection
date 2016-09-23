//
//  MXURLConnectionQueue.m
//
//  Created by eric on 15/4/13.
//  Copyright (c) 2015年 Eric Lung. All rights reserved.
//

#import "MXURLConnectionQueue.h"
#import "MXURLConnection.h"

#define DEFAULT_QUEUE_COUNT     8

@interface MXURLConnectionQueue ()

@property (nonatomic, readonly) NSMutableArray *waitingConnections;
@property (nonatomic, readonly) NSMutableArray *currentConnections;

@end

@implementation MXURLConnectionQueue

+ (instancetype)globalQueue
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [self new];
    });
    return obj;
}

- (id)init
{
    if (self = [super init]) {
        _waitingConnections = [NSMutableArray new];
        _currentConnections = [NSMutableArray new];
        self.maxCount = DEFAULT_QUEUE_COUNT;
    }
    return self;
}

- (void)setMaxCount:(NSInteger)maxCount
{
    if (maxCount <= 0) maxCount = DEFAULT_QUEUE_COUNT;
    _maxCount = maxCount;
}

- (void)addConnection:(MXURLConnection *)connection index:(NSInteger)index
{
    if ([self containsConnection:connection]) return;
    NSInteger count = self.waitingConnections.count;
    index = MAX(0, index);
    if (index >= count - 1) {
        [self.waitingConnections addObject:connection];
    }
    else {
        [self.waitingConnections insertObject:connection atIndex:index];
    }
}

- (BOOL)containsConnection:(MXURLConnection *)connection
{
    return [self.waitingConnections containsObject:connection] || [self.currentConnections containsObject:connection];
}

- (void)removeConnection:(MXURLConnection *)connection
{
    [connection cancel];
    [self.waitingConnections removeObject:connection];
    [self.currentConnections removeObject:connection];
}

- (void)removeAllConnection
{
    [self.waitingConnections makeObjectsPerformSelector:@selector(cancel)];
    [self.waitingConnections removeAllObjects];
    [self.currentConnections makeObjectsPerformSelector:@selector(cancel)];
    [self.currentConnections removeAllObjects];
}

- (void)startQueue
{
    NSInteger currentCount = self.currentConnections.count;
    NSInteger waitingCount = self.waitingConnections.count;
    
    while (waitingCount && currentCount < self.maxCount) {
        MXURLConnection *cnnt = self.waitingConnections[0];
        [self.currentConnections addObject:cnnt];
        [self.waitingConnections removeObject:cnnt];
        [cnnt start];
        currentCount = self.currentConnections.count;
        waitingCount = self.waitingConnections.count;
    }
}

- (NSInteger)waitingConnectionsCount
{
    return self.waitingConnections.count;
}

- (BOOL)hasConnection
{
    return self.waitingConnections.count || self.currentConnections.count;
}

@end

