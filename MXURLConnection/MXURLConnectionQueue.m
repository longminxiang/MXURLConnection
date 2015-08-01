//
//  MXURLConnectionQueue.m
//
//  Created by eric on 15/4/13.
//  Copyright (c) 2015年 eric. All rights reserved.
//

#import "MXURLConnectionQueue.h"
#import "MXURLConnection.h"

@interface MXURLConnectionQueue ()

@property (nonatomic, readonly) NSMutableArray *allConnection;
@property (nonatomic, readonly) NSMutableArray *cntConnections;

@end

@implementation MXURLConnectionQueue

+ (instancetype)sharedQueue
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
        _allConnection = [NSMutableArray new];
        _cntConnections = [NSMutableArray new];
        self.maxCount = 5;
    }
    return self;
}

- (void)setMaxCount:(NSInteger)maxCount
{
    if (maxCount <= 0) maxCount = 5;
    _maxCount = maxCount;
}

- (void)addConnection:(MXURLConnection *)connection index:(NSInteger)index
{
    if ([self containsConnection:connection]) return;
    NSInteger count = self.allConnection.count;
    index = MAX(0, index);
    if (index >= count - 1) {
        index = count - 1;
        [self.allConnection addObject:connection];
    }
    else {
        [self.allConnection insertObject:connection atIndex:index];
    }
}

- (BOOL)containsConnection:(MXURLConnection *)connection
{
    for (MXURLConnection *cnnt in self.allConnection) {
        if ([cnnt.key isEqualToString:connection.key]) {
            return YES;
        }
    }
    for (MXURLConnection *cnnt in self.cntConnections) {
        if ([cnnt.key isEqualToString:connection.key]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeConnection:(MXURLConnection *)connection
{
    [self.cntConnections removeObject:connection];
}

- (void)startQueue
{
    NSInteger cntCount = self.cntConnections.count;
    NSInteger allCount = self.allConnection.count;
    
    while (allCount && cntCount < self.maxCount) {
        MXURLConnection *cnnt = self.allConnection[0];
        [self.cntConnections addObject:cnnt];
        [self.allConnection removeObject:cnnt];
        [cnnt start];
        cntCount = self.cntConnections.count;
        allCount = self.allConnection.count;
    }
}

- (NSInteger)queueCount
{
    return self.allConnection.count;
}

- (BOOL)hasConnection
{
    return self.allConnection.count || self.cntConnections.count;
}

@end

