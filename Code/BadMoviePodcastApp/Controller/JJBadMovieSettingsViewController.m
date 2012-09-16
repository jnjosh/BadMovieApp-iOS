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
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSArray *tools;
@property (nonatomic, strong) NSArray *toolURLs;
@property (nonatomic, strong) UITableView *tableView;

- (void)closeSettings;
- (void)followOnTwitter;
- (void)openURL:(NSString *)url;

@end

@implementation JJBadMovieSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _settings = @[@"Follow @BadMoviePodcast"];
		_messages = @[@"Bad Movie Podcast is a weekly podcast reviewing the worst in cinema hosted by Jim and Josh. We suffer so you don't have to.", @"This app was built with the help of the following libraries:"];

		_tools = @[@"Icons from Pictos", @"AFNetworking", @"MBProgressHUD", @"SDURLCache", @"SDWebImage", @"SSPullToRefresh"];
		_toolURLs = @[@"http://pictos.cc/", @"https://github.com/AFNetworking/AFNetworking", @"https://github.com/jdg/MBProgressHUD", @"https://github.com/rs/SDURLCache", @"https://github.com/rs/SDWebImage", @"https://github.com/samsoffes/sspulltorefresh"];
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
    self.title = @"The App";
    
    self.footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
    [self.footerView setAutoresizesSubviews:YES];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:self.footerView.bounds];
    [footerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [footerLabel setNumberOfLines:2];
    [footerLabel setText:@"Bad Movie Podcast: The App 1.1 (223)\nDesigned and Developed by Josh Johnson"];
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [footerLabel setTextColor:[UIColor grayColor]];
    [footerLabel setShadowColor:[UIColor whiteColor]];
    [footerLabel setShadowOffset:(CGSize){0,1}];
    [footerLabel setTextAlignment:UITextAlignmentCenter];
    [footerLabel setBackgroundColor:[UIColor clearColor]];
    [self.footerView addSubview:footerLabel];
    
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[self.tableView setAutoresizingMask:self.view.autoresizingMask];
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return self.settings.count;
	} else if (section == 1) {
		return self.messages.count;
	} else if (section == 2) {
		return self.tools.count;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = nil;
	if (indexPath.section == 0) {
		cellIdentifier = @"com.jnjosh.settingsCell";
	} else if (indexPath.section == 1) {
		cellIdentifier = @"com.jnjosh.messageCell";
	} else if (indexPath.section == 2) {
		cellIdentifier = @"com.jnjosh.toolCell";
	} else {
		cellIdentifier = @"com.jnjosh.cell";
	}
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		[cell.textLabel setShadowColor:[UIColor whiteColor]];
		[cell.textLabel setShadowOffset:(CGSize){ 0, 1 }];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

		if (indexPath.section == 0) {
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
			[cell.textLabel setTextAlignment:UITextAlignmentCenter];
			[cell.textLabel setTextColor:[UIColor darkGrayColor]];
		} else if (indexPath.section == 1) {
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
			[cell.textLabel setTextColor:[UIColor grayColor]];
			[cell.textLabel setNumberOfLines:10];
			[cell.textLabel setTextAlignment:UITextAlignmentLeft];
		} else if (indexPath.section == 2) {
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
			[cell.textLabel setTextColor:[UIColor grayColor]];
			[cell.textLabel setTextAlignment:UITextAlignmentCenter];
		}
	}

	if (indexPath.section == 0) {
		cell.textLabel.text = [self.settings objectAtIndex:indexPath.row ];
    } else if (indexPath.section == 1) {
		cell.textLabel.text = [self.messages objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
		cell.textLabel.text = [self.tools objectAtIndex:indexPath.row];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		return 64.0f;
	}
	if (indexPath.section == 1) {
		return 72.0f;
	}
	return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        [self followOnTwitter];
    } else if (indexPath.section == 2) {
		[self openURL:[self.toolURLs objectAtIndex:indexPath.row]];
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

- (void)openURL:(NSString *)url
{
	NSURL *weburl = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:weburl]) {
        [[UIApplication sharedApplication] openURL:weburl];
        return;
    }
}

@end
