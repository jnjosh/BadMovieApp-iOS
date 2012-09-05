//
//  JJAppDelegate.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJAppDelegate.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadMovieWindowController.h"

@interface JJAppDelegate ()

@property (nonatomic, strong) NSNumber *episodeNumber;

@end

@implementation JJAppDelegate

@synthesize windowController = _windowController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.windowController = [[JJBadMovieWindowController alloc] init];
    [self.windowController.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if (self.episodeNumber) {
		[self.windowController presentControllerForEpisodeNumber:self.episodeNumber];
		self.episodeNumber = nil;
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	self.episodeNumber = [[notification userInfo] objectForKey:kJJBadMovieNotificationKey];
}

@end
