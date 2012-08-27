//
//  JJBadMovieDownloadsViewController.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/22/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieDownloadsViewController.h"
#import "JJBadMovie.h"
#import "JJBadMovieDownloadManager.h"
#import "JJBadMovieDownloadOperation.h"
#import "JJBadMovieDownloadObserver.h"
#import "JJBadMovieEpisodeDownloadCell.h"

@interface JJBadMovieDownloadsViewController () <UITableViewDelegate, UITableViewDataSource, JJBadMovieDownloadObserver>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *downloadingEpisodes;

- (void)fetchDownloadingEpisodes;
- (void)cancelAllDownloads;

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
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel All" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAllDownloads)];
	[self.navigationItem setRightBarButtonItem:cancelItem];
	
	[self fetchDownloadingEpisodes];
	[[JJBadMovieDownloadManager sharedManager] addDownloadObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
	
	[[JJBadMovieDownloadManager sharedManager] removeDownloadObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Episode Observations

- (void)fetchDownloadingEpisodes
{
	NSMutableArray *downloads = [NSMutableArray array];
	NSArray *operations = [[JJBadMovieDownloadManager sharedManager] episodesDownloading];
	for (JJBadMovieDownloadOperation *operation in operations) {
		[downloads addObject:[operation badMovie]];
	}
	self.downloadingEpisodes = downloads;
}

- (void)cancelAllDownloads
{
	[[JJBadMovieDownloadManager sharedManager] cancelAllDownloadOperations];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.downloadingEpisodes count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"com.jnjosh.downloadcell";
	JJBadMovieEpisodeDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (! cell) {
		cell = [[JJBadMovieEpisodeDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	JJBadMovie *episode = [self.downloadingEpisodes objectAtIndex:indexPath.row];
	[cell setEpisode:episode];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 64.0f;
}

#pragma mark - JJBadMovieDownloadObserver

- (void)movieDidFinishDownloading
{
	[self fetchDownloadingEpisodes];
	[self.tableView reloadData];
}

- (void)movieDidCancelDownloading
{
	[self fetchDownloadingEpisodes];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didCompleteDownloading
{
	self.downloadingEpisodes = nil;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

@end
