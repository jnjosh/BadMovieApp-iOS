//
//  JJBadMovieRateLimit.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/20/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieRateLimit.h"

@interface JJBadMovieRateLimit ()

@property (nonatomic, strong) NSCache *limitCache;

@end

@implementation JJBadMovieRateLimit

#pragma mark - Singleton

+ (id)sharedLimiter
{
    static dispatch_once_t onceToken;
    static id jj_sharedLimiter = nil;
    dispatch_once(&onceToken, ^{
        jj_sharedLimiter = [[self alloc] init];
    });
    return jj_sharedLimiter;
}

#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init]) {
        _limitCache = [[NSCache alloc] init];
        [_limitCache setCountLimit:30];
    }
    return self;
}

- (void)executeBlock:(void (^)(void))block key:(NSString *)key limit:(NSTimeInterval)limit
{
    if (! block) return;
    
    NSDate *lastAttempted = [[self limitCache] objectForKey:key];
    NSTimeInterval lastAttemptedInterval = [lastAttempted timeIntervalSinceNow];
    float timeInterval = fabsf(lastAttemptedInterval);
	
    if ((timeInterval == 0) || (timeInterval > limit)) {
        block();
        [[self limitCache] setObject:[NSDate date] forKey:key];
    }
}

- (void)clearLimitForKey:(NSString *)key
{
    [[self limitCache] removeObjectForKey:key];
}

@end
