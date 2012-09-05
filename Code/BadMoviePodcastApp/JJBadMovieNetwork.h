//
//  JJBadMovieNetwork.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/21/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJBadMovieNetwork : NSObject

+ (id)sharedNetwork;

- (void)executeNetworkActivity:(void (^)(void))activity failed:(void (^)(void))failed;

@end
