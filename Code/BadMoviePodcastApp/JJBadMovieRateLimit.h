//
//  JJBadMovieRateLimit.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/20/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJBadMovieRateLimit : NSObject

+ (id)sharedLimiter;

- (void)executeBlock:(void (^)(void))block key:(NSString *)key limit:(NSTimeInterval)limit;
- (void)clearLimitForKey:(NSString *)key;

@end
