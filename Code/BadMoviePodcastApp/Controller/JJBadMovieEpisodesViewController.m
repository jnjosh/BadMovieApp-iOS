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

static NSString *jj_episodeCellIdentifier = @"com.jnjosh.BadMovieCell";

@interface JJBadMovieEpisodesViewController ()

@property (nonatomic, strong) JJBadMovieEpisodeDataSource *dataSource;

- (void)showSettings;
- (void)downloadImageInView;

@end

@implementation JJBadMovieEpisodesViewController

#pragma mark - synth

@synthesize dataSource = _dataSource;

#pragma mark - lifecycle

- (id)initWithEpisodeDataSource:(JJBadMovieEpisodeDataSource *)dataSource {
    if (self = [self initWithStyle:UITableViewStylePlain]) {
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - view loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsVerticalScrollIndicator:NO];

    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.navigationbar.title.png"]];
    [self.navigationItem setTitleView:titleImage];
    
    UIBarButtonItem *settingsGear = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui.button.settings.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
    [self.navigationItem setLeftBarButtonItem:settingsGear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.dataSource) {
        [self.dataSource loadEpisodesWithCompletionHandler:^{
            [self.tableView reloadData]; 
        }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - methods

- (void)showSettings {
    JJBadMovieSettingsViewController *settingsView = [[JJBadMovieSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNavigation = [[UINavigationController alloc] initWithRootViewController:settingsView];
    [self presentModalViewController:settingsNavigation animated:YES];
}

- (void)downloadImageInView {
    for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
        [self.dataSource downloadImageForIndexPath:path completionHandler:^{
            if ([[self.tableView indexPathsForVisibleRows] containsObject:path]) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone]; 
            }
        }];
    }
}

#pragma mark - scroll delegates

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (! decelerate) {
        [self downloadImageInView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self downloadImageInView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.episodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovieEpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:jj_episodeCellIdentifier];
    if (! cell) {
        cell = [[JJBadMovieEpisodeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:jj_episodeCellIdentifier];
    }
    JJBadMovie *movie = [self.dataSource episodeForIndexPath:indexPath];
    [cell setEpisode:movie];
    
    [self.dataSource downloadImageForIndexPath:indexPath completionHandler:^{
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone]; 
    }];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovie *movie = [self.dataSource episodeForIndexPath:indexPath];
    JJBadMovieViewController *detailViewController = [[JJBadMovieViewController alloc] initWithBadMovie:movie];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
