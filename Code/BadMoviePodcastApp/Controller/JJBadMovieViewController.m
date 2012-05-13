//
//  JJBadMovieViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "JJBadMovieViewController.h"
#import "JJBadMovieWebViewController.h"
#import "JJBadMovie.h"
#import "JJBadMovieEnvironment.h"
#import "UIImageView+AFNetworking.h"

@interface JJBadMovieViewController ()

@property (nonatomic, strong) JJBadMovie *movie;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *episodeButton;

@property (nonatomic, strong) AVPlayer *streamingAudioPlayer;
@property (nonatomic, assign, getter = isPlaying) BOOL playing;

- (void)play;
- (void)pause;
- (void)toggle;

- (void)playEpisode;
- (void)playTrailer;
- (void)showMovieInfo;

@end

@implementation JJBadMovieViewController

#pragma mark - synth

@synthesize movie = _movie, streamingAudioPlayer = _streamingAudioPlayer;
@synthesize headerView = _headerView;
@synthesize playing = _playing;
@synthesize episodeButton = _episodeButton;

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
    
    self.episodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.episodeButton setFrame:(CGRect){ 10, episodeDescription.frame.origin.y + episodeDescription.frame.size.height + 10, 300, 44}];
    [self.episodeButton setTitle:@"Play Episode" forState:UIControlStateNormal];
    [self.episodeButton addTarget:self action:@selector(playEpisode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.episodeButton];

    UIButton *youtubeTrailer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [youtubeTrailer setFrame:(CGRect){ 10, self.episodeButton.frame.origin.y + self.episodeButton.frame.size.height + 10, 145, 44}];
    [youtubeTrailer setTitle:@"Watch Trailer" forState:UIControlStateNormal];
    [youtubeTrailer addTarget:self action:@selector(playTrailer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:youtubeTrailer];

    UIButton *imdbPage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imdbPage setFrame:(CGRect){ youtubeTrailer.frame.size.width + 20, self.episodeButton.frame.origin.y + self.episodeButton.frame.size.height + 10, 145, 44}];
    [imdbPage setTitle:@"IMDb" forState:UIControlStateNormal];
    [imdbPage addTarget:self action:@selector(showMovieInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imdbPage];
    
    self.streamingAudioPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:self.movie.url]];
    
    NSError *playbackError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&playbackError];
    if (playbackError) {
        NSLog(@"%@", [playbackError localizedDescription]);
    }
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    if (activationError) {
        NSLog(@"%@", [activationError localizedDescription]);
    }
    
//    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:episodeImageView.image];
    NSDictionary *mediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     kJJBadMovieAlbumTitle, MPMediaItemPropertyAlbumTitle,
                                     self.movie.number, MPMediaItemPropertyAlbumTrackNumber,
                                     kJJBadMovieArtistName, MPMediaItemPropertyArtist,
//                                     artwork, MPMediaItemPropertyArtwork,
                                     kJJBadMovieGenre, MPMediaItemPropertyGenre,
                                     self.movie.name, MPMediaItemPropertyTitle,
                                     self.movie.name, MPMediaItemPropertyPodcastTitle,
                                     nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.streamingAudioPlayer = nil;
    self.headerView = nil;
    self.episodeButton = nil;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self play];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pause];
        } 
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self toggle];
        }
    }  
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - episode methods

- (void)play {
    [self.streamingAudioPlayer play];
    [self.episodeButton setTitle:@"Pause Episode" forState:UIControlStateNormal];
    [self setPlaying:YES];
}

- (void)pause {
    [self.streamingAudioPlayer pause];
    [self.episodeButton setTitle:@"Play Episode" forState:UIControlStateNormal];
    [self setPlaying:NO];
}

- (void)toggle {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)playEpisode {
    [self toggle];
}

- (void)playTrailer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.movie.video]];
}

- (void)showMovieInfo {
    JJBadMovieWebViewController *movieInfoView = [[JJBadMovieWebViewController alloc] initWithIMDBUrl:self.movie.imdb];
    [self.navigationController pushViewController:movieInfoView animated:YES];
}

@end
