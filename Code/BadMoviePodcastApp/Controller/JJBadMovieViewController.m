//
//  JJBadMovieViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "JJBadMovieViewController.h"
#import "JJBadMovieWebViewController.h"
#import "JJBadMovie.h"
#import "UIImageView+AFNetworking.h"

@interface JJBadMovieViewController ()

@property (nonatomic, strong) JJBadMovie *movie;

@property (nonatomic, strong) UIView *headerView;

- (void)playEpisode;
- (void)playTrailer;
- (void)showMovieInfo;

@end

@implementation JJBadMovieViewController

#pragma mark - synth

@synthesize movie = _movie;
@synthesize headerView = _headerView;

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
    self.title = [NSString stringWithFormat:@"Episode %i", [self.movie.number integerValue]];

    self.headerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {320, 148}}];
    [self.headerView setBackgroundColor:[UIColor grayColor]];
    [self.headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.headerView setAutoresizesSubviews:YES];
    
    UIImageView *episodeImageView = [[UIImageView alloc] initWithFrame:(CGRect){10, 10, 128, 128}];
    [episodeImageView setContentMode:UIViewContentModeScaleToFill];
    [episodeImageView setBackgroundColor:[UIColor whiteColor]];
    [episodeImageView setImageWithURL:[NSURL URLWithString:self.movie.photo]];
    [self.headerView addSubview:episodeImageView];
    
    UILabel *episodeNumber = [[UILabel alloc] initWithFrame:(CGRect){ 148, 10, 162, 128 }];
    [episodeNumber setBackgroundColor:[UIColor clearColor]];
    [episodeNumber setTextColor:[UIColor whiteColor]];
    [episodeNumber setNumberOfLines:4];
    [episodeNumber setText:[NSString stringWithFormat:@"%@", self.movie.name]];
    [self.headerView addSubview:episodeNumber];

    [self.view addSubview:self.headerView];

    UILabel *episodeDescription = [[UILabel alloc] initWithFrame:(CGRect){ 10, 148, 300, 128 }];
    [episodeDescription setTextColor:[UIColor blackColor]];
    [episodeDescription setNumberOfLines:5];
    [episodeDescription setText:self.movie.descriptionText];
    [self.view addSubview:episodeDescription];
    
    UIButton *episodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [episodeButton setFrame:(CGRect){ 10, episodeDescription.frame.origin.y + episodeDescription.frame.size.height + 10, 300, 44}];
    [episodeButton setTitle:@"Play Episode" forState:UIControlStateNormal];
    [episodeButton addTarget:self action:@selector(playEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:episodeButton];

    UIButton *youtubeTrailer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [youtubeTrailer setFrame:(CGRect){ 10, episodeButton.frame.origin.y + episodeButton.frame.size.height + 10, 145, 44}];
    [youtubeTrailer setTitle:@"Watch Trailer" forState:UIControlStateNormal];
    [youtubeTrailer addTarget:self action:@selector(playTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:youtubeTrailer];

    UIButton *imdbPage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imdbPage setFrame:(CGRect){ youtubeTrailer.frame.size.width + 20, episodeButton.frame.origin.y + episodeButton.frame.size.height + 10, 145, 44}];
    [imdbPage setTitle:@"IMDb" forState:UIControlStateNormal];
    [imdbPage addTarget:self action:@selector(showMovieInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imdbPage];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.headerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - episode methods

- (void)playEpisode {
    MPMoviePlayerViewController *episodePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.movie.url]];
    [episodePlayer.moviePlayer setAllowsAirPlay:YES];
    [episodePlayer.moviePlayer setShouldAutoplay:YES];
    [self.navigationController presentMoviePlayerViewControllerAnimated:episodePlayer];
}

- (void)playTrailer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.movie.video]];
}

- (void)showMovieInfo {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithIMDBUrl:self.movie.imdb];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

@end
