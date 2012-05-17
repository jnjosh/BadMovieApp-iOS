//
//  JJBadMovieViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieViewController.h"
#import "JJBadMovieWebViewController.h"
#import "JJBadMovie.h"
#import "JJBadMovieEnvironment.h"
#import "SDImageCache.h"

@interface JJBadMovieViewController ()

@property (nonatomic, strong) JJBadMovie *movie;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *episodeButton;
@property (nonatomic, strong) UIImageView *episodeImageView;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)playEpisode;
- (void)playTrailer;
- (void)showMovieInfo;

@end

@implementation JJBadMovieViewController

#pragma mark - synth

@synthesize movie = _movie;
@synthesize headerView = _headerView, scrollView = _scrollView;
@synthesize episodeButton = _episodeButton, episodeImageView = _episodeImageView;

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

    self.headerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {320, 148}}];
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.moviedetails.png"]]];
    [self.headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.headerView setAutoresizesSubviews:YES];
    
    self.episodeImageView = [[UIImageView alloc] initWithFrame:(CGRect){10, 10, 124, 124}];
    [self.episodeImageView setContentMode:UIViewContentModeScaleToFill];
    [self.episodeImageView setBackgroundColor:[UIColor whiteColor]];
    [self.episodeImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.episodeImageView.layer setBorderWidth:2.0];
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:self.movie.photo fromDisk:YES];
    [self.episodeImageView setImage:image];
    [self.headerView addSubview:self.episodeImageView];
    
    UILabel *episodeNumber = [[UILabel alloc] initWithFrame:CGRectZero];
    [episodeNumber setBackgroundColor:[UIColor clearColor]];
    [episodeNumber setTextColor:[UIColor blackColor]];
    [episodeNumber setShadowColor:[UIColor whiteColor]];
    [episodeNumber setShadowOffset:(CGSize){0,1}];
    [episodeNumber setFont:[UIFont boldSystemFontOfSize:16.0]];
    [episodeNumber setNumberOfLines:4];
    [episodeNumber setText:[NSString stringWithFormat:@"%@: %@", self.movie.number, self.movie.name]];
    [episodeNumber setTextAlignment:UITextAlignmentLeft];
    CGSize constraint = (CGSize){162, CGFLOAT_MAX};
    CGSize episodeTitleSize = [episodeNumber.text sizeWithFont:episodeNumber.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    [episodeNumber setFrame:(CGRect){ {142, 10}, episodeTitleSize }];
    [self.headerView addSubview:episodeNumber];
    
    self.episodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.episodeButton setFrame:(CGRect){ 142, 92, 160, 44}];
    [self.episodeButton setTitle:@"Play Episode" forState:UIControlStateNormal];
    [self.episodeButton addTarget:self action:@selector(playEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.episodeButton];

    [self.view addSubview:self.headerView];

    self.scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){ 0, self.headerView.frame.size.height, 320, 312}];
    [self.scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.scrollView setAutoresizingMask:self.view.autoresizingMask];
    
    ////

    UILabel *episodeDescription = [[UILabel alloc] initWithFrame:CGRectZero];
    [episodeDescription setBackgroundColor:[UIColor clearColor]];
    [episodeDescription setTextColor:[UIColor blackColor]];
    [episodeDescription setFont:[UIFont systemFontOfSize:14.0]];
    [episodeDescription setShadowColor:[UIColor whiteColor]];
    [episodeDescription setShadowOffset:(CGSize){0,1}];
    [episodeDescription setText:self.movie.descriptionText];
    [episodeDescription setNumberOfLines:5];
    CGSize descriptionConstraint = (CGSize){300, CGFLOAT_MAX};
    CGSize episodeDescriptionSize = [episodeDescription.text sizeWithFont:episodeDescription.font constrainedToSize:descriptionConstraint lineBreakMode:UILineBreakModeWordWrap];
    [episodeDescription setFrame:(CGRect){ {10, 10}, episodeDescriptionSize }];
    [self.scrollView addSubview:episodeDescription];

    UIButton *youtubeTrailer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [youtubeTrailer setFrame:(CGRect){ 10, episodeDescription.frame.origin.y + episodeDescription.frame.size.height + 10, 145, 44}];
    [youtubeTrailer setTitle:@"Watch Trailer" forState:UIControlStateNormal];
    [youtubeTrailer addTarget:self action:@selector(playTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:youtubeTrailer];

    UIButton *imdbPage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imdbPage setFrame:(CGRect){ youtubeTrailer.frame.size.width + 20, episodeDescription.frame.origin.y + episodeDescription.frame.size.height + 10, 145, 44}];
    [imdbPage setTitle:@"IMDb" forState:UIControlStateNormal];
    [imdbPage addTarget:self action:@selector(showMovieInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:imdbPage];
    
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.scrollView setContentSize:(CGSize){self.scrollView.frame.size.width, self.scrollView.frame.size.height * 1.01}];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.headerView = nil;
    self.episodeButton = nil;
    self.scrollView = nil;}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - episode methods

- (void)playEpisode {
    [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationBeginPlayingEpisode object:self.movie];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:self.episodeImageView.frame], @"episodeImageFrame", self.episodeImageView.image, @"episodeImage", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationShowPlayerControl object:self userInfo:userInfo];
}

- (void)playTrailer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.movie.video]];
}

- (void)showMovieInfo {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithIMDBUrl:self.movie.imdb];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

@end
