//
//  JJBadMovieSettingsViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieSettingsViewController.h"
#import "JJBadMovieWebViewController.h"

@interface JJBadMovieSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) UITableView *tableView;

- (void)closeSettings;
- (void)followOnTwitter;

@end

@implementation JJBadMovieSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _settings = [NSArray arrayWithObjects:@"Follow @BadMoviePodcast", @"About Bad Movie Podcast App", nil];
    }
    return self;
}

- (void)closeSettings {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeSettings)];
    [self.navigationItem setLeftBarButtonItem:doneButton];
    
    self.footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
    [self.footerView setAutoresizesSubviews:YES];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:self.footerView.bounds];
    [footerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [footerLabel setNumberOfLines:2];
    [footerLabel setText:@"Bad Movie Podcast App 1.1 (223)\nDesigned and Developed by Josh Johnson"];
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [footerLabel setTextColor:[UIColor grayColor]];
    [footerLabel setShadowColor:[UIColor whiteColor]];
    [footerLabel setShadowOffset:(CGSize){0,1}];
    [footerLabel setTextAlignment:UITextAlignmentCenter];
    [footerLabel setBackgroundColor:[UIColor clearColor]];
    [self.footerView addSubview:footerLabel];
    
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.tableView setTableFooterView:self.footerView];
	
	[self.view addSubview:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    cell.textLabel.text = [self.settings objectAtIndex:indexPath.section];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        [self followOnTwitter];
    } else if (indexPath.section == 1) {
        JJBadMovieWebViewController *webViewController = [[JJBadMovieWebViewController alloc] initWithLocalHTML:@"about"];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
}

#pragma mark - settings methods

- (void)followOnTwitter {
    NSURL *tweetbotURL = [NSURL URLWithString:@"tweetbot:///user_profile/BadMoviePodcast"];
    if ([[UIApplication sharedApplication] canOpenURL:tweetbotURL]) {
        [[UIApplication sharedApplication] openURL:tweetbotURL];
        return;
    }
    
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=BadMoviePodcast"];
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
        return;
    }
    
    NSURL *twitURL = [NSURL URLWithString:@"twit:///user?screen_name=BadMoviePodcast"];
    if ([[UIApplication sharedApplication] canOpenURL:twitURL]) {
        [[UIApplication sharedApplication] openURL:twitURL];
        return;
    }

    NSURL *twitterWebURL = [NSURL URLWithString:@"http://www.twitter.com/BadMoviePodcast"];
    [[UIApplication sharedApplication] openURL:twitterWebURL];
}


@end
