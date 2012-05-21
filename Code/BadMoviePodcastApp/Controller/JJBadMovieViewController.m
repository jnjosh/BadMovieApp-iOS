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
const NSUInteger kJJBadMovieCellRowImdb = 2;
const NSUInteger kJJBadMovieCellRowYouTube = 3;

@interface JJBadMovieViewController ()

@property (nonatomic, strong) JJBadMovie *movie;
@property (nonatomic, strong) UIView *headerView;

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
- (void)displayShareSheet;

- (UITableViewCell *)cellForDescriptionRow;
- (UITableViewCell *)cellForLinkRow:(NSIndexPath *)indexPath;
- (void)copyEpisodeURL;
- (void)tweetEpisode;

@end

@implementation JJBadMovieViewController

#pragma mark - synth

@synthesize movie = _movie;
@synthesize headerView = _headerView, tableView = _tableView, sectionHeaderView = _sectionHeaderView;
@synthesize episodeButton = _episodeButton, episodeImageView = _episodeImageView;
@synthesize shareEpisodeButton = _shareEpisodeButton, downloadButton = _downloadButton;

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
    
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){ 0, 122, 320, 294 } style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.view addSubview:self.tableView];

    self.headerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {320, 122}}];
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.moviedetails.png"]]];
    [self.headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.headerView setAutoresizesSubviews:YES];
    [self.view addSubview:self.headerView];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:self.movie.photo fromDisk:YES];
    self.episodeImageView = [[UIImageView alloc] initWithFrame:(CGRect){12, self.headerView.center.y - 51, 102, 102}];
    [self.episodeImageView setContentMode:UIViewContentModeScaleToFill];
    [self.episodeImageView setBackgroundColor:[UIColor whiteColor]];
    [self.episodeImageView setImage:image];
    [self.episodeImageView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.episodeImageView.layer setShadowOffset:(CGSize){0, 1}];
    [self.episodeImageView.layer setShadowRadius:2.0];
    [self.episodeImageView.layer setShadowOpacity:1.0];
    [self.headerView addSubview:self.episodeImageView];
    
    self.episodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.episodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.play.png"] forState:UIControlStateNormal];
    [self.episodeButton setFrame:(CGRect){ 162, 48, 26, 26 }];
    [self.episodeButton setShowsTouchWhenHighlighted:YES];
    [self.episodeButton addTarget:self action:@selector(playEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.episodeButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.episodeButton.layer setShadowOffset:(CGSize){0, 1}];
    [self.episodeButton.layer setShadowRadius:2.0];
    [self.episodeButton.layer setShadowOpacity:1.0];
    [self.headerView addSubview:self.episodeButton];

//    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.download.png"] forState:UIControlStateNormal];
//    [self.downloadButton setFrame:(CGRect){ 208, 48, 26, 26 }];
//    [self.downloadButton setShowsTouchWhenHighlighted:YES];
//    [self.downloadButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
//    [self.downloadButton.layer setShadowOffset:(CGSize){0, 1}];
//    [self.downloadButton.layer setShadowRadius:2.0];
//    [self.downloadButton.layer setShadowOpacity:1.0];
//    [self.headerView addSubview:self.downloadButton];
    
    self.shareEpisodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.share.png"] forState:UIControlStateNormal];
    [self.shareEpisodeButton setFrame:(CGRect){ 240, 48, 26, 26 }];
    [self.shareEpisodeButton setShowsTouchWhenHighlighted:YES];
    [self.shareEpisodeButton addTarget:self action:@selector(displayShareSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.shareEpisodeButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.shareEpisodeButton.layer setShadowOffset:(CGSize){0, 1}];
    [self.shareEpisodeButton.layer setShadowRadius:2.0];
    [self.shareEpisodeButton.layer setShadowOpacity:1.0];
    [self.headerView addSubview:self.shareEpisodeButton];
    
    UIImageView *fadeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.tableview.fade.png"]];
    [fadeView setFrame:(CGRect){{0, self.headerView.frame.size.height},fadeView.frame.size}];
    [self.view insertSubview:fadeView aboveSubview:self.tableView];
    
    UISwipeGestureRecognizer *swipeBackGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBack)];
    [swipeBackGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeBackGesture];
    
    // setup section header
    
    self.sectionHeaderView = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionHeaderView"];
    [self.sectionHeaderView setBackgroundColor:[UIColor clearColor]];
    [self.sectionHeaderView setSelectionStyle:UITableViewCellSelectionStyleNone];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0, 150, 20}];
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
    
    UILabel *publishedLabel = [[UILabel alloc] initWithFrame:(CGRect){ 160, 0, 150, 20 }];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == kJJBadMovieCellRowHeader) {
        cell = self.sectionHeaderView;
    } else if (indexPath.row == kJJBadMovieCellRowDescription) {
        cell = [self cellForDescriptionRow];
    } else { 
        cell = [self cellForLinkRow:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == kJJBadMovieCellRowImdb) {
        [self showMovieInfo];
    } else if (indexPath.row == kJJBadMovieCellRowYouTube) {
        [self playTrailer];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kJJBadMovieCellRowHeader) {
        return 22;
    } else if (indexPath.row == kJJBadMovieCellRowDescription) {
        CGSize descriptionConstraint = (CGSize){300, CGFLOAT_MAX};
        CGSize episodeDescriptionSize = [self.movie.descriptionText sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:descriptionConstraint lineBreakMode:UILineBreakModeWordWrap];
        return episodeDescriptionSize.height + 20;
    } else if (indexPath.row == kJJBadMovieCellRowYouTube || indexPath.row == kJJBadMovieCellRowImdb) {
        return 54;
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

- (UITableViewCell *)cellForLinkRow:(NSIndexPath *)indexPath {
    static NSString *jj_cellForDescription = @"com.jnjosh.linkCell";
    UITableViewCell *linkCell = [self.tableView dequeueReusableCellWithIdentifier:jj_cellForDescription];
    if (! linkCell) {
        linkCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:jj_cellForDescription];
        UIView *backgroundSelectView = [[UIView alloc] initWithFrame:linkCell.bounds];
        [backgroundSelectView setBackgroundColor:[UIColor clearColor]];
        [linkCell setSelectedBackgroundView:backgroundSelectView];
        [linkCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [linkCell.textLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [linkCell.textLabel setTextColor:[UIColor darkGrayColor]];
        [linkCell.textLabel setShadowColor:[UIColor whiteColor]];
        [linkCell.textLabel setHighlightedTextColor:[UIColor whiteColor]];
        [linkCell.textLabel setShadowOffset:(CGSize){0, 1}];
    }
    
    if (indexPath.row == kJJBadMovieCellRowImdb) {
        linkCell.textLabel.text = @"View on IMDb.com";
    } else if (indexPath.row == kJJBadMovieCellRowYouTube) {
        linkCell.textLabel.text = @"Watch a video on YouTube";
    }
    return linkCell;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationBeginPlayingEpisode object:self.movie];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:self.episodeImageView.frame], @"episodeImageFrame", self.episodeImageView.image, @"episodeImage", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationShowPlayerControl object:self userInfo:userInfo];
}

- (void)playTrailer {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithIMDBUrl:self.movie.video];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

- (void)showMovieInfo {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithIMDBUrl:self.movie.imdb];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

@end
