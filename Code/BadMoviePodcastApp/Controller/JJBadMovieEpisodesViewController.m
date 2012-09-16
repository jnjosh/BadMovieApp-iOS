//
//  JJBadMovieEpisodesViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieEpisodesViewController.h"
#import "JJBadMovieSettingsViewController.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadMovie.h"
#import "JJBadMovieViewController.h"
#import "JJBadMovieEpisodeCell.h"
#import "JJBadMovieEpisodeDataSource.h"
#import "JJBadMovieRateLimit.h"
#import "JJBadMovieDownloadManager.h"
#import "JJBadMovieDownloadsViewController.h"

static NSString *jj_episodeCellIdentifier = @"com.jnjosh.BadMovieCell";
static const CGFloat kJJBadMovieCellHeight = 86.0f;

@interface JJBadMovieEpisodesViewController () <JJBadMovieDownloadObserver>

@property (nonatomic, strong) JJBadMovieEpisodeDataSource *dataSource;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIBarButtonItem *downloadsBarButtonItem;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) NSMutableSet *updatedMovies;

- (void)showSettings;
- (void)showDownloads;
- (void)downloadImageInView;
- (void)refreshCurrentCells;

@end

@implementation JJBadMovieEpisodesViewController

#pragma mark - lifecycle

- (id)initWithEpisodeDataSource:(JJBadMovieEpisodeDataSource *)dataSource
{
    if (self = [self initWithNibName:nil bundle:nil]) {
        _dataSource = dataSource;
		_updatedMovies = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc
{
	[[JJBadMovieDownloadManager sharedManager] removeDownloadObserver:self];
}

#pragma mark - view loading

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView setAutoresizingMask:self.view.autoresizingMask];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    SSPullToRefreshSimpleContentView *contentView = [[SSPullToRefreshSimpleContentView alloc] init];
    [[contentView statusLabel] setTextColor:[UIColor grayColor]];
    [self.pullToRefreshView setContentView:contentView];
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.navigationbar.title.png"]];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettings)];
	[tapGesture setNumberOfTapsRequired:2];
	[titleImage setUserInteractionEnabled:YES];
	[titleImage addGestureRecognizer:tapGesture];
    [self.navigationItem setTitleView:titleImage];
    
	self.downloadsBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui.button.downloads.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showDownloads)];
	
	[[JJBadMovieDownloadManager sharedManager] addDownloadObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[[JJBadMovieRateLimit sharedLimiter] executeBlock:^{
		if (self.dataSource) {
			[self.dataSource loadEpisodesWithCompletionHandler:^{
				[self.tableView reloadData];
			}];
		}
	} key:@"fetch-episodes" limit:3600.0];
	
	if (! [[JJBadMovieDownloadManager sharedManager] completedDownloadRequests]) {
		[self.navigationItem setLeftBarButtonItem:self.downloadsBarButtonItem];
	} else {
		[self.navigationItem setLeftBarButtonItem:nil animated:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self refreshCurrentCells];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView = nil;
	self.downloadsBarButtonItem = nil;
	self.pullToRefreshView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - methods

- (void)refreshCurrentCells
{
	for (JJBadMovie *movie in self.updatedMovies) {
		NSIndexPath *path = [self.dataSource indexPathForEpisode:movie];
		if ([[self.tableView indexPathsForVisibleRows] containsObject:path]) {
			[self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
		}
	}
	[self.updatedMovies removeAllObjects];
}

- (void)showSettings
{
	JJBadMovieSettingsViewController *settingsView = [[JJBadMovieSettingsViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:settingsView animated:YES];
}

- (void)showDownloads
{
	JJBadMovieDownloadsViewController *downloadsView = [[JJBadMovieDownloadsViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:downloadsView animated:YES];
}

- (void)downloadImageInView
{
    for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
        [self.dataSource downloadImageForIndexPath:path completionHandler:^{
            if ([[self.tableView indexPathsForVisibleRows] containsObject:path]) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone]; 
            }
        }];
    }
}

#pragma mark - scroll delegates

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (! decelerate) {
        [self downloadImageInView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self downloadImageInView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.episodes count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.dataSource downloadImageForIndexPath:indexPath completionHandler:^{
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovieEpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:jj_episodeCellIdentifier];
    if (! cell) {
        cell = [[JJBadMovieEpisodeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:jj_episodeCellIdentifier];
    }
    JJBadMovie *movie = [self.dataSource episodeForIndexPath:indexPath];
    [cell setEpisode:movie];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kJJBadMovieCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovie *movie = [self.dataSource episodeForIndexPath:indexPath];
    JJBadMovieViewController *detailViewController = [[JJBadMovieViewController alloc] initWithBadMovie:movie];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - SSPullToRefreshDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self.pullToRefreshView startLoading];
    [self.dataSource loadEpisodesWithCompletionHandler:^{
        [self.tableView reloadData];
        [self.pullToRefreshView finishLoading];
    }];
}

#pragma mark - JJBadMovieDownloadObserver

- (void)didCompleteDownloading
{
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)movieDidFinishDownloadingEpisode:(JJBadMovie *)badmovie
{
	[self.updatedMovies addObject:badmovie];
	if ([self.navigationController topViewController] == self) {
		[self refreshCurrentCells];
	}
}

- (void)didDeleteEpisode:(JJBadMovie *)episode
{
	[self.updatedMovies addObject:episode];
	if ([self.navigationController topViewController] == self) {
		[self refreshCurrentCells];
	}
}

@end
