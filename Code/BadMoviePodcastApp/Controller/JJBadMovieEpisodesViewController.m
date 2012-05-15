//
//  JJBadMovieEpisodesViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieEpisodesViewController.h"
#import "JJBadMovieSettingsViewController.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadMovie.h"
#import "JJBadMovieViewController.h"
#import "JJBadMovieEpisodeCell.h"
#import "AFJSONRequestOperation.h"

#import "SDWebImageManager.h"

static NSString *jj_episodeCellIdentifier = @"com.jnjosh.BadMovieCell";

@interface JJBadMovieEpisodesViewController ()

@property (nonatomic, strong) NSArray *episodes;
- (void)showSettings;

@end

@implementation JJBadMovieEpisodesViewController

#pragma mark - synth

@synthesize episodes = _episodes;

#pragma mark - lifecycle

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
    
    NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:episodeURL];
    AFJSONRequestOperation *jsonRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *episodeList = [NSMutableArray array];
        NSUInteger rowIndex = 0;
        for (id episode in JSON) {
            JJBadMovie *badMovie = [JJBadMovie instanceFromDictionary:episode];
            if (badMovie) {
                [episodeList addObject:badMovie];
                if (! [badMovie cachedImage]) {
                    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:badMovie.photo] delegate:self options:SDWebImageProgressiveDownload success:^(UIImage *image) {
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    } failure:nil];
                }
            }
            rowIndex++;
        }
        self.episodes = [NSArray arrayWithArray:episodeList];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: %@", error);
    }];
    [jsonRequest start];
}

- (void)viewDidUnload
{
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovieEpisodeCell *cell = [tableView dequeueReusableCellWithIdentifier:jj_episodeCellIdentifier];
    if (! cell) {
        cell = [[JJBadMovieEpisodeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:jj_episodeCellIdentifier];
    }
    JJBadMovie *movie = [self.episodes objectAtIndex:indexPath.row];
    [cell setEpisode:movie];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovie *movie = [self.episodes objectAtIndex:indexPath.row];
    JJBadMovieViewController *detailViewController = [[JJBadMovieViewController alloc] initWithBadMovie:movie];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
