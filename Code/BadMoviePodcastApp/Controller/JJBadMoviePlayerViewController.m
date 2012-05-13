//
//  JJBadMoviePlayerViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMoviePlayerViewController.h"

@interface JJBadMoviePlayerViewController ()

@end

@implementation JJBadMoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
