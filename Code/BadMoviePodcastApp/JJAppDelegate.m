//
//  JJAppDelegate.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJAppDelegate.h"
#import "JJBadMovieWindowController.h"

@implementation JJAppDelegate

@synthesize windowController = _windowController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.windowController = [[JJBadMovieWindowController alloc] init];
    [self.windowController.window makeKeyAndVisible];
    return YES;
}

@end
