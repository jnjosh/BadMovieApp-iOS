//
//  JJBadMovieNetwork.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/21/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieNetwork.h"
#import "Reachability.h"
#import "JJBadMovieEnvironment.h"

@implementation JJBadMovieNetwork

+ (id)sharedNetwork
{
	static dispatch_once_t onceToken;
	static id jj_networkReachability = nil;
	dispatch_once(&onceToken, ^{
		jj_networkReachability = [[self alloc] init];
	});
	return jj_networkReachability;
}

- (void)executeNetworkActivity:(void (^)(void))activity failed:(void (^)(void))failed
{
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
		if (activity) {
			activity();
		}
	} else {
		if (failed) {
			failed();
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationGlobalNotification object:kJJBadMovieNetworkErrorMessage];
		}
	}
}

@end
