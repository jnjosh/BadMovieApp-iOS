//
//  JJBadMovieDownloadsViewController.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/22/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieDownloadsViewController.h"
#import "JJBadMovieDownloadManager.h"

@interface JJBadMovieDownloadsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JJBadMovieDownloadsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:CGRectZero];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.view setAutoresizesSubviews:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Downloads";
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
	[self.tableView setAutoresizingMask:self.view.autoresizingMask];
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"com.jnjosh.downloadcell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (! cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	return cell;
}

@end
