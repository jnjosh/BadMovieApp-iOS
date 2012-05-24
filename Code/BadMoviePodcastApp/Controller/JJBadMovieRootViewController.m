//
//  JJBadMovieRootViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/23/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieRootViewController.h"

@interface JJBadMovieRootViewController ()

@end

@implementation JJBadMovieRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIViewController *viewController in [self childViewControllers]) {
        [self.view addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL shouldRotate = NO;
    for (UIViewController *viewController in [self childViewControllers]) {
        shouldRotate = [viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
        if (shouldRotate) break;
    }
    return shouldRotate;
}

@end
