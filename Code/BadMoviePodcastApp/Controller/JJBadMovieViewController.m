//
//  JJBadMovieViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "JJBadMovieViewController.h"
#import "JJBadMovieWebViewController.h"
#import "JJBadMoviePlayerViewController.h"
#import "JJBadMovie.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadmovieDownloadManager.h"
#import "JJBadMovieDownloadObserver.h"
#import "SDImageCache.h"
#import "MBProgressHUD.h"
#import "JJBadMovieNetwork.h"

const NSUInteger kJJBadMovieCellRowHeader = 0;
const NSUInteger kJJBadMovieCellRowDescription = 1;

const NSUInteger kJJBadMovieShareSheet = 2;
const NSUInteger kJJBadMovieDeleteSheet = 3;

//const CGFloat kJJBadMovieToolbarItemVerticalOffset = 373;

@interface JJBadMovieViewController () <JJBadMovieDownloadObserver>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign, getter = isPlaying) BOOL playing;
@property (nonatomic, assign, getter = isPlayerStarting) BOOL playerStarting;

@property (nonatomic, strong) UIButton *episodeButton;
@property (nonatomic, strong) UIButton *shareEpisodeButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIImageView *episodeImageView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableViewCell *sectionHeaderView;

@property (nonatomic, strong) UIView *downloadingView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *toolbarView;
@property (nonatomic, strong) UILabel *downloadProgressLabel;

- (void)swipeBack;

- (void)startPlayingEpisode;
- (void)launchPlayerWithEpisode;

- (void)togglePlayerState;
- (void)playTrailer;
- (void)showMovieInfo;
- (void)downloadPodcast;
- (void)displayShareSheet;
- (void)displayDeleteSheet;

- (UITableViewCell *)cellForDescriptionRow;
- (void)copyEpisodeURL;
- (void)tweetEpisode;
- (void)openInSafari;
- (void)setupOfflineButton;
- (void)removeDownloadedFile;

- (void)showDownloadView:(BOOL)animated;

@end

@implementation JJBadMovieViewController

#pragma mark - lifecycle

- (id)initWithBadMovie:(JJBadMovie *)badMovie {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.movie = badMovie;
    }
    return self;
}

#pragma mark - view

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.movie.name;
	
	UIImage *toolbarImage = [UIImage imageNamed:@"ui.toolbar.png"];
	CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
	CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
	CGFloat tableTop = 97.0f;
	CGFloat tableHeight = self.view.frame.size.height - toolbarImage.size.height - navHeight - statusHeight - tableTop;
	
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){ 0, tableTop, 320, tableHeight } style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.view addSubview:self.tableView];

    self.headerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {320, 97}}];
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.background.moviedetail.png"]]];
    [self.headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.headerView setAutoresizesSubviews:YES];
    [self.headerView setClipsToBounds:YES];
    [self.view addSubview:self.headerView];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:self.movie.photo fromDisk:YES];
	if (! image) {
		image = [UIImage imageNamed:@"ui.placeholder.png"];
	}
	
    self.episodeImageView = [[UIImageView alloc] initWithFrame:(CGRect){5, 5, 65, 65}];
    [self.episodeImageView setContentMode:UIViewContentModeScaleToFill];
    [self.episodeImageView setBackgroundColor:[UIColor whiteColor]];
    [self.episodeImageView setImage:image];
    UIView *episodeImageContainer = [[UIView alloc] initWithFrame:(CGRect){10,10,75,75}];
    [episodeImageContainer setBackgroundColor:[UIColor whiteColor]];
    [episodeImageContainer setClipsToBounds:YES];
    [episodeImageContainer addSubview:self.episodeImageView];
    [self.headerView addSubview:episodeImageContainer];
    
    UIImage *episodeButtonImage = [UIImage imageNamed:@"ui.buttons.episode.png"];
    UIImage *episodeButtonImageHighlighted = [UIImage imageNamed:@"ui.buttons.episode.highlighted.png"];
    self.episodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.episodeButton setFrame:(CGRect){ 173, 28, 137, 39 }];
    [self.episodeButton setShowsTouchWhenHighlighted:NO];
    [self.episodeButton setBackgroundImage:episodeButtonImage forState:UIControlStateNormal];
    [self.episodeButton setBackgroundImage:episodeButtonImageHighlighted forState:UIControlStateHighlighted];
	[self.episodeButton setTitle:@"Listen" forState:UIControlStateNormal];
	[self.episodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.episodeButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[self.episodeButton.titleLabel setShadowOffset:(CGSize){ 0, 1 }];
	[self.episodeButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]];
    [self.episodeButton addTarget:self action:@selector(togglePlayerState) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.episodeButton];

    UIImageView *fadeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.tableview.fade.png"]];
    [fadeView setFrame:(CGRect){{0, self.headerView.frame.size.height},fadeView.frame.size}];
    [self.view insertSubview:fadeView aboveSubview:self.tableView];
    
	self.toolbarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.toolbar.png"]];
    [self.toolbarView setFrame:(CGRect){{0, self.tableView.frame.origin.y + self.tableView.frame.size.height}, self.toolbarView.frame.size}];
    [self.view insertSubview:self.toolbarView aboveSubview:self.tableView];
	
	self.downloadingView = [[UIView alloc] initWithFrame:self.toolbarView.frame];
	UIImageView *downloadingImageView = [[UIImageView alloc] initWithImage:toolbarImage];
	[self.downloadingView addSubview:downloadingImageView];
	self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	[self.progressView setFrame:(CGRect){10.0f, 18.0f, 220.0f, self.progressView.frame.size.height }];
	[self.progressView setTrackTintColor:[UIColor darkGrayColor]];
	self.downloadProgressLabel = [[UILabel alloc] initWithFrame:(CGRect) { 240.0f, 13.0f, 40.0f, 20.0f }];
	[self.downloadProgressLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
	[self.downloadProgressLabel setTextColor:[UIColor grayColor]];
	[self.downloadProgressLabel setShadowColor:[UIColor whiteColor]];
	[self.downloadProgressLabel setShadowOffset:(CGSize){ 0, 1 }];
	[self.downloadProgressLabel setBackgroundColor:[UIColor clearColor]];
	[self.downloadingView addSubview:self.downloadProgressLabel];
	[self.downloadProgressLabel setText:@"0%"];
	[self.downloadingView addSubview:self.progressView];
	[self.downloadingView addSubview:self.downloadProgressLabel];
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cancelButton setTitle:@"X" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[[cancelButton titleLabel] setShadowOffset:(CGSize){ 0, 1 }];
	[[cancelButton titleLabel] setFont:[UIFont fontWithName:@"GillSans-Bold" size:14.0f]];
	[cancelButton setFrame:(CGRect){ 275.0f, 8.0f, 40.0f, 30.0f }];
	[self.downloadingView addSubview:cancelButton];
	
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveButton setFrame:(CGRect){ 29, self.toolbarView.frame.origin.y, 44, 44 }];
    [self.saveButton addTarget:self action:@selector(downloadPodcast) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setShowsTouchWhenHighlighted:NO];
	[self setupOfflineButton];
    [self.view addSubview:self.saveButton];

    UIButton *imdbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imdbButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.imdb.png"] forState:UIControlStateNormal];
    [imdbButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.imdb.pressed.png"] forState:UIControlStateHighlighted];
    [imdbButton setFrame:(CGRect){ 101, self.toolbarView.frame.origin.y, 44, 44 }];
    [imdbButton setShowsTouchWhenHighlighted:NO];
    [imdbButton addTarget:self action:@selector(showMovieInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imdbButton];

    UIButton *youtubeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.film.png"] forState:UIControlStateNormal];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.film.pressed.png"] forState:UIControlStateHighlighted];
    [youtubeButton setFrame:(CGRect){ 173, self.toolbarView.frame.origin.y, 44, 44 }];
    [youtubeButton setShowsTouchWhenHighlighted:NO];
    [youtubeButton addTarget:self action:@selector(playTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:youtubeButton];

    self.shareEpisodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.download.png"] forState:UIControlStateNormal];
    [self.shareEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.download.pressed.png"] forState:UIControlStateHighlighted];
    [self.shareEpisodeButton setFrame:(CGRect){ 245, self.toolbarView.frame.origin.y, 44, 44 }];
    [self.shareEpisodeButton setShowsTouchWhenHighlighted:NO];
    [self.shareEpisodeButton addTarget:self action:@selector(displayShareSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareEpisodeButton];
    
    UISwipeGestureRecognizer *swipeBackGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBack)];
    [swipeBackGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeBackGesture];
    
    // setup section header
    self.sectionHeaderView = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionHeaderView"];
    [self.sectionHeaderView setBackgroundColor:[UIColor clearColor]];
    [self.sectionHeaderView setSelectionStyle:UITableViewCellSelectionStyleNone];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 2, 150, 20}];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextAlignment:UITextAlignmentLeft];
    [sectionLabel setTextColor:[UIColor lightGrayColor]];
    [sectionLabel setFont:[UIFont systemFontOfSize:12.0]];
    [sectionLabel setText:[NSString stringWithFormat:@"Episode #%@", self.movie.number]];
    [sectionLabel setShadowColor:[UIColor whiteColor]];
    [sectionLabel setShadowOffset:(CGSize){ 0, 1 }];
    [self.sectionHeaderView.contentView addSubview:sectionLabel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:self.movie.published];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    UILabel *publishedLabel = [[UILabel alloc] initWithFrame:(CGRect){ 160, 2, 150, 20 }];
    [publishedLabel setText:dateString];
    [publishedLabel setBackgroundColor:[UIColor clearColor]];
    [publishedLabel setFont:[UIFont systemFontOfSize:12.0]];
    [publishedLabel setTextColor:[UIColor lightGrayColor]];
    [publishedLabel setTextAlignment:UITextAlignmentRight];
    [publishedLabel setShadowColor:[UIColor whiteColor]];
    [publishedLabel setShadowOffset:(CGSize){ 0, 1 }];
    [self.sectionHeaderView.contentView addSubview:publishedLabel];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.shareEpisodeButton = nil;
    self.episodeButton = nil;
    self.downloadButton = nil;
    self.episodeImageView = nil;
    
    self.sectionHeaderView = nil;
    self.headerView = nil;
    self.tableView = nil;
	self.downloadingView = nil;
	self.progressView = nil;
    
    self.playerController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([[JJBadMovieDownloadManager sharedManager] downloadingActiveForMovie:self.movie]) {
		[self showDownloadView:NO];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[[JJBadMovieDownloadManager sharedManager] addDownloadObserver:self forMovie:self.movie];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[JJBadMovieDownloadManager sharedManager] removeDownloadObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == kJJBadMovieCellRowHeader) {
        cell = self.sectionHeaderView;
    } else if (indexPath.row == kJJBadMovieCellRowDescription) {
        cell = [self cellForDescriptionRow];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kJJBadMovieCellRowHeader) {
        return 22;
    } else if (indexPath.row == kJJBadMovieCellRowDescription) {
        CGSize descriptionConstraint = (CGSize){300, CGFLOAT_MAX};
        CGSize episodeDescriptionSize = [self.movie.descriptionText sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:descriptionConstraint lineBreakMode:UILineBreakModeWordWrap];
        return episodeDescriptionSize.height + 20;
    }
    return 44;
}

- (UITableViewCell *)cellForDescriptionRow {
    static NSString *jj_cellForDescription = @"com.jnjosh.descriptionCell";
    UITableViewCell *descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:jj_cellForDescription];
    if (! descriptionCell) {
        descriptionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jj_cellForDescription];
        [descriptionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [descriptionCell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [descriptionCell.textLabel setNumberOfLines:10];
        [descriptionCell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
        [descriptionCell.textLabel setTextColor:[UIColor darkGrayColor]];
        [descriptionCell.textLabel setShadowColor:[UIColor whiteColor]];
        [descriptionCell.textLabel setShadowOffset:(CGSize){0, 1}];
    }
    descriptionCell.textLabel.text = self.movie.descriptionText;
    return descriptionCell;
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([actionSheet tag] == kJJBadMovieShareSheet) {
		switch (buttonIndex) {
			case 0: [self tweetEpisode]; break;
			case 1: [self copyEpisodeURL]; break;
			case 2: [self openInSafari]; break;
		}
	} else {
		switch (buttonIndex) {
			case 0: [self removeDownloadedFile]; break;
		}
	}
}

#pragma mark - JJBadMovieAudioPlayerDelegate methods 

- (void)playerViewControllerDidBeginPlaying:(JJBadMoviePlayerViewController *)playerViewController {
	self.playerStarting = NO;
    [self configureForPlayState:JJBadMoviePlayerStatePlaying];
}

- (void)playerViewControllerDidPause:(JJBadMoviePlayerViewController *)playerViewController {
    [self configureForPlayState:JJBadMoviePlayerStatePaused];
}

- (void)playerViewControllerDidEndPlaying:(JJBadMoviePlayerViewController *)playerViewController {
    [self configureForPlayState:JJBadMoviePlayerStateEnded];
}

#pragma mark - share methods

- (void)tweetEpisode {
	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		TWTweetComposeViewController *twitterController = [[TWTweetComposeViewController alloc] init];
		[twitterController setInitialText:[NSString stringWithFormat:@"Listened to Episode #%@ - %@ on @BadMoviePodcast", self.movie.number, self.movie.name]];
		[twitterController addURL:[NSURL URLWithString:self.movie.location]];
		[self presentModalViewController:twitterController animated:YES];
	} failed:nil];
}

- (void)copyEpisodeURL {
    [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:self.movie.location]];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Link Copied";
	[hud hide:YES afterDelay:2.0];
}

- (void)openInSafari {
	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:self.movie.location]];
	} failed:nil];
}

- (void)setupOfflineButton
{
	if (! [self.movie hasDownloaded]) {
		[self.saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.offline.png"] forState:UIControlStateNormal];
		[self.saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.offline.pressed.png"] forState:UIControlStateHighlighted];
	} else {
		[self.saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.delete.png"] forState:UIControlStateNormal];
		[self.saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.delete.pressed.png"] forState:UIControlStateHighlighted];
	}
}

#pragma mark - episode methods

- (void)configureForPlayState:(JJBadMoviePlayerState)playerState {
    if (playerState == JJBadMoviePlayerStatePlaying) {
		[self.episodeButton setTitle:@"Listening..." forState:UIControlStateNormal];
		[self.episodeButton setTitle:@"Listening..." forState:UIControlStateHighlighted];
        [self setPlaying:YES];
    } else {
		[self.episodeButton setTitle:@"Listen" forState:UIControlStateNormal];
		[self.episodeButton setTitle:@"Listen" forState:UIControlStateHighlighted];
        [self setPlaying:NO];
    }
}

- (void)displayShareSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", @"Copy URL", @"View in Safari", nil];
	[actionSheet setTag:kJJBadMovieShareSheet];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.view];
}

- (void)displayDeleteSheet {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete the downloaded episode?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove file" otherButtonTitles:nil];
	[actionSheet setTag:kJJBadMovieDeleteSheet];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.view];
}

- (void)swipeBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)launchPlayerWithEpisode
{
	if (! [self isPlayerStarting]) {
		self.playerStarting = YES;
		[self setCurrentMovie:YES];
		[self.playerController setDelegate:self];
		[self.playerController setCurrentEpisode:self.movie];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:self.episodeImageView.frame], @"episodeImageFrame", self.episodeImageView.image, @"episodeImage", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationShowPlayerControl object:self userInfo:userInfo];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
			[self.playerController loadEpisodeWithCompletionHandler:^{
				[self.playerController play];
			}];
		});
	}
}

- (void)startPlayingEpisode {
	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		[self launchPlayerWithEpisode];
	} failed:^{
		if ([self.movie hasDownloaded]) {
			[self launchPlayerWithEpisode];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationGlobalNotification object:kJJBadMovieNetworkErrorMessage];
		}
	}];
}

- (void)togglePlayerState {
    if ([self isCurrentMovie]) {
        if (self.playerController.playerState == JJBadMoviePlayerStateNotStarted || self.playerController.playerState == JJBadMoviePlayerStateEnded) {
            [self startPlayingEpisode];
        } else if (self.playerController.playerState == JJBadMoviePlayerStatePaused) {
            [self.playerController play];
        } else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationShowPlayer object:nil];
		}
    } else {
        [self startPlayingEpisode];
    }
}

- (void)playTrailer {
	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		JJBadMovieWebViewController *trailerWebView = [[JJBadMovieWebViewController alloc] initWithURL:self.movie.video];
		[self.navigationController pushViewController:trailerWebView animated:YES];
	} failed:nil];
}

- (void)showMovieInfo {
	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithURL:self.movie.imdb];
		[self.navigationController pushViewController:movieInfoView animated:YES];
	} failed:nil];
}

- (void)downloadPodcast {
	if (! [self.movie hasDownloaded]) {
		[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
			[[JJBadMovieDownloadManager sharedManager] downloadEpisodeForMovie:self.movie];
		} failed:nil];
	} else {
		[self displayDeleteSheet];
	}
}

- (void)removeDownloadedFile {
	[[JJBadMovieDownloadManager sharedManager] removeEpisode:self.movie];
	[self setupOfflineButton];
}

#pragma mark - Download view

- (void)showDownloadView:(BOOL)animated
{
	[self.progressView setProgress:0];
	[self.saveButton setEnabled:NO];
	[self.view insertSubview:self.downloadingView belowSubview:self.toolbarView];
	CGFloat duration = animated ? 0.25 : 0;
	[UIView animateWithDuration:duration animations:^{
		[self.downloadingView setFrame:(CGRect) { self.downloadingView.frame.origin.x, self.downloadingView.frame.origin.y - self.downloadingView.frame.size.height, self.downloadingView.frame.size }];
	}];
}

- (void)hideDownloadView {
	[UIView animateWithDuration:0.25 animations:^{
		[self.downloadingView setFrame:(CGRect) { self.downloadingView.frame.origin.x, self.downloadingView.frame.origin.y + self.downloadingView.frame.size.height, self.downloadingView.frame.size }];
	} completion:^(BOOL finished) {
		[self setupOfflineButton];
		[self.saveButton setEnabled:YES];
	}];
}

- (void)cancelDownload {
	[[JJBadMovieDownloadManager sharedManager] cancelDownloadingEpisodeForMovie:self.movie];
}

#pragma mark - JJBadMovieDownloadObserver

- (void)movieDidBeginDownloading
{
	[self showDownloadView:YES];
}

- (void)movieDidFinishDownloading
{
	[self hideDownloadView];
}

- (void)movieDidFailDownloadingWithError:(NSError *)error
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Download Failed";
	[hud hide:YES afterDelay:2.0];
	[self hideDownloadView];
}

- (void)movieDidCancelDownloading
{
	[self hideDownloadView];
}

- (void)movieDownloadDidProgress:(NSNumber *)progress total:(NSNumber *)total
{
	if (! [self.downloadingView isDescendantOfView:self.view]) {
		[self showDownloadView:YES];
	}
	float progressPosition = ([progress floatValue] / [total floatValue]);
	[self.progressView setProgress:progressPosition];
	[self.downloadProgressLabel setText:[NSString stringWithFormat:@"%i%%", (int)floorl(progressPosition * 100.0f)]];
}

@end
