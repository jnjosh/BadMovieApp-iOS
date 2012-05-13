//
//  JJBadMovieWindowController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieWindowController.h"
#import "JJBadMoviePlayerViewController.h"
#import "JJBadMovieEpisodesViewController.h"

@implementation JJBadMovieWindowController

#pragma mark - synth

@synthesize navigationController = _navigationController, playerController = _playerController, window = _window;

#pragma mark - lifecycle

- (id)init
{
    if (self = [super init]) {
        [[self class] configureAppearance];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[[JJBadMovieEpisodesViewController alloc] initWithStyle:UITableViewStylePlain]];
        _playerController = [[JJBadMoviePlayerViewController alloc] initWithNibName:nil bundle:nil];
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.window.png"]];
        _window.rootViewController = _navigationController;
    }
    return self;
}

#pragma mark - class methods

+ (void)configureAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ui.navigationbar.background.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor blackColor]];
}

@end
