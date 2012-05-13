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
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"

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
        for (id episode in JSON) {
            JJBadMovie *badMovie = [JJBadMovie instanceFromDictionary:episode];
            if (badMovie) {
                [episodeList addObject:badMovie];
            }
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
    static NSString *CellIdentifier = @"BadMovieCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setShadowColor:[UIColor whiteColor]];
        [cell.textLabel setShadowOffset:(CGSize){0, 1}];
        [cell.detailTextLabel setNumberOfLines:2];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
        
        [cell.imageView setFrame:(CGRect){cell.imageView.frame.origin, { 60, 60 }}];
    }
    JJBadMovie *movie = [self.episodes objectAtIndex:indexPath.row];
    [cell.textLabel setText:movie.name];
    [cell.detailTextLabel setText:movie.descriptionText];
    [cell.imageView setImageWithURL:[NSURL URLWithString:movie.photo] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
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
