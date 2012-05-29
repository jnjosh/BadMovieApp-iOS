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
#import "JJBadMovie.h"
#import "JJBadMovieEnvironment.h"
#import "SDImageCache.h"
#import "MBProgressHUD.h"

const NSUInteger kJJBadMovieCellRowHeader = 0;
const NSUInteger kJJBadMovieCellRowDescription = 1;

const CGFloat kJJBadMovieToolbarItemVerticalOffset = 373;

@interface JJBadMovieViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign, getter = isPlaying) BOOL playing;

@property (nonatomic, strong) UIButton *episodeButton;
@property (nonatomic, strong) UIButton *shareEpisodeButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIImageView *episodeImageView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableViewCell *sectionHeaderView;

- (void)swipeBack;
- (void)playEpisode;
- (void)playTrailer;
- (void)showMovieInfo;
- (void)downloadPodcast;
- (void)displayShareSheet;

- (UITableViewCell *)cellForDescriptionRow;
- (void)copyEpisodeURL;
- (void)tweetEpisode;

@end

@implementation JJBadMovieViewController

#pragma mark - synth

@synthesize movie = _movie, currentMovie = _currentMovie;
@synthesize headerView = _headerView, tableView = _tableView, sectionHeaderView = _sectionHeaderView;
@synthesize episodeButton = _episodeButton, episodeImageView = _episodeImageView;
@synthesize shareEpisodeButton = _shareEpisodeButton, downloadButton = _downloadButton;
@synthesize playing = _playing;

#pragma mark - lifecycle

- (id)initWithBadMovie:(JJBadMovie *)badMovie {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.movie = badMovie;
    }
    return self;
}

#pragma mark - view

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.movie.name;

    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){ 0, 97, 320, 275 } style:UITableViewStylePlain];
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
    UIImage *episodeButtonListenImage = [UIImage imageNamed:@"ui.buttons.image.listen.png"];
    UIImage *episodeButtonListenImageHighlighted = [UIImage imageNamed:@"ui.buttons.image.listen.highlighted.png"];    
    self.episodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.episodeButton setFrame:(CGRect){ 173, 28, 137, 39 }];
    [self.episodeButton setShowsTouchWhenHighlighted:NO];
    [self.episodeButton setBackgroundImage:episodeButtonImage forState:UIControlStateNormal];
    [self.episodeButton setBackgroundImage:episodeButtonImageHighlighted forState:UIControlStateHighlighted];
    [self.episodeButton setImage:episodeButtonListenImage forState:UIControlStateNormal];
    [self.episodeButton setImage:episodeButtonListenImageHighlighted forState:UIControlStateHighlighted];
    [self.episodeButton addTarget:self action:@selector(playEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.episodeButton];

    UIImageView *fadeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.tableview.fade.png"]];
    [fadeView setFrame:(CGRect){{0, self.headerView.frame.size.height},fadeView.frame.size}];
    [self.view insertSubview:fadeView aboveSubview:self.tableView];
    
    UIImageView *toolbarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.toolbar.png"]];
    [toolbarView setFrame:(CGRect){{0, self.tableView.frame.origin.y + self.tableView.frame.size.height}, toolbarView.frame.size}];
    [self.view insertSubview:toolbarView aboveSubview:self.tableView];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.offline.png"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.offline.pressed.png"] forState:UIControlStateHighlighted];
    [saveButton setFrame:(CGRect){ 29, kJJBadMovieToolbarItemVerticalOffset, 44, 44 }];
    [saveButton addTarget:self action:@selector(downloadPodcast) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setShowsTouchWhenHighlighted:NO];
    [self.view addSubview:saveButton];

    UIButton *imdbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imdbButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.imdb.png"] forState:UIControlStateNormal];
    [imdbButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.imdb.pressed.png"] forState:UIControlStateHighlighted];
    [imdbButton setFrame:(CGRect){ 101, kJJBadMovieToolbarItemVerticalOffset, 44, 44 }];
    [imdbButton setShowsTouchWhenHighlighted:NO];
    [imdbButton addTarget:self action:@selector(showMovieInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imdbButton];

    UIButton *youtubeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.film.png"] forState:UIControlStateNormal];
    [youtubeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.film.pressed.png"] forState:UIControlStateHighlighted];
    [youtubeButton setFrame:(CGRect){ 173, kJJBadMovieToolbarItemVerticalOffset, 44, 44 }];
    [youtubeButton setShowsTouchWhenHighlighted:NO];
    [youtubeButton addTarget:self action:@selector(playTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:youtubeButton];

    self.shareEpisodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.download.png"] forState:UIControlStateNormal];
    [self.shareEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.toolbar.download.pressed.png"] forState:UIControlStateHighlighted];
    [self.shareEpisodeButton setFrame:(CGRect){ 245, kJJBadMovieToolbarItemVerticalOffset, 44, 44 }];
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
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self isCurrentMovie]) {
//        [self.episodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.pause.png"] forState:UIControlStateNormal];
    } else {
//        [self.episodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.play.png"] forState:UIControlStateNormal];
    }
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
    switch (buttonIndex) {
        case 0:
            [self tweetEpisode];
            break;
        case 1:
            [self copyEpisodeURL];
            break;
    }
}

#pragma mark - JJBadMovieAudioPlayerDelegate methods 

- (void)playerViewControllerDidBeginPlaying:(JJBadMoviePlayerViewController *)playerViewController {
    NSLog(@"Playing!");
}

- (void)playerViewControllerDidPause:(JJBadMoviePlayerViewController *)playerViewController {
    NSLog(@"Paused!");
}

- (void)playerViewControllerDidEndPlaying:(JJBadMoviePlayerViewController *)playerViewController {
    NSLog(@"Ended!");
}

#pragma mark - share methods

- (void)tweetEpisode {
    TWTweetComposeViewController *twitterController = [[TWTweetComposeViewController alloc] init];
    [twitterController setInitialText:[NSString stringWithFormat:@"Listened to Episode #%@ - %@ on @BadMoviePodcast", self.movie.number, self.movie.name]];
    [twitterController addURL:[NSURL URLWithString:@"http://badmoviepodcast.com"]];
    [self presentModalViewController:twitterController animated:YES];
}

- (void)copyEpisodeURL {
    [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:@"http://badmoviepodcast.com"]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Link Copied";

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

#pragma mark - episode methods

- (void)displayShareSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", @"Copy URL", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.view];
}

- (void)swipeBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playEpisode {
    if (! [self isPlaying]) {
//        [self.episodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.pause.png"] forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationBeginPlayingEpisode object:self.movie];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:self.episodeImageView.frame], @"episodeImageFrame", self.episodeImageView.image, @"episodeImage", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationShowPlayerControl object:self userInfo:userInfo];
    } else {
//        [self.episodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.play.png"] forState:UIControlStateNormal];

        [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationPausePlayingEpisode object:self.movie];
    }
    
    [self setPlaying:![self isPlaying]];
}

- (void)playTrailer {
    JJBadMovieWebViewController *trailerWebView = [[JJBadMovieWebViewController alloc] initWithURL:self.movie.video];
    [self.navigationController pushViewController:trailerWebView animated:YES];
}

- (void)showMovieInfo {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithURL:self.movie.imdb];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

- (void)downloadPodcast {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"Not Implemented Yet...";
    [hud hide:YES afterDelay:2.0];
}

@end
