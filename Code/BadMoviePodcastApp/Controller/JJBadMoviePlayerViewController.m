//
//  JJBadMoviePlayerViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieEnvironment.h"
#import "JJBadMoviePlayerViewController.h"
#import "JJBadMovie.h"

@interface JJBadMoviePlayerViewController ()

@property (nonatomic, assign, getter = isPlaying) BOOL playing;

@property (nonatomic, strong) UIButton *playPauseEpisodeButton;
@property (nonatomic, strong) UIButton *skipForwardButton;
@property (nonatomic, strong) UIButton *skipBackButton;

@property (nonatomic, strong) AVPlayer *streamingAudioPlayer;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (void)play;
- (void)pause;
- (void)togglePlayState;
- (void)loadEpisode:(NSNotification *)note;

@end

@implementation JJBadMoviePlayerViewController

#pragma mark - synth

@synthesize currentEpisode = _currentEpisode, playing = _playing;
@synthesize playPauseEpisodeButton = _playPauseEpisodeButton, volumeView = _volumeView;
@synthesize skipBackButton = _skipBackButton, skipForwardButton = _skipForwardButton;
@synthesize streamingAudioPlayer = _streamingAudioPlayer;

#pragma mark - lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:(CGRect){ 10, 20, 300, 140 }];
    self.view.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -150.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playPauseEpisodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playPauseEpisodeButton setShowsTouchWhenHighlighted:YES];
    [self.playPauseEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.play.png"] forState:UIControlStateNormal];
    [self.playPauseEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.pause.png"] forState:UIControlStateSelected];
    [self.playPauseEpisodeButton addTarget:self action:@selector(togglePlayState) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseEpisodeButton setFrame:(CGRect){128, 20, 44, 44}];
    [self.view addSubview:self.playPauseEpisodeButton];
    
    self.skipBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipBackButton setShowsTouchWhenHighlighted:YES];
    [self.skipBackButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.skip.back.png"] forState:UIControlStateNormal];
    [self.skipBackButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x - 66, 20, 44, 44}];
    [self.view addSubview:self.skipBackButton];

    self.skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipForwardButton setShowsTouchWhenHighlighted:YES];
    [self.skipForwardButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.skip.forward.png"] forState:UIControlStateNormal];
    [self.skipForwardButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x + 66, 20, 44, 44}];
    [self.view addSubview:self.skipForwardButton];

    self.volumeView = [[MPVolumeView alloc] initWithFrame:(CGRect){10, 120, 280, 20}];
    [self.volumeView sizeThatFits:self.volumeView.frame.size];
    [self.view addSubview:self.volumeView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEpisode:) name:kJJBadMovieNotificationBeginPlayingEpisode object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.playPauseEpisodeButton = nil;
    self.skipBackButton = nil;
    self.skipForwardButton = nil;
    self.volumeView = nil;
    self.streamingAudioPlayer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - player control

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self play];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pause];
        } 
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayState];
        }
    }  
}

- (void)play {
    [self.streamingAudioPlayer play];
    [self setPlaying:YES];
    [self.playPauseEpisodeButton setSelected:YES];
}

- (void)pause {
    [self.streamingAudioPlayer pause];
    [self setPlaying:NO];
    [self.playPauseEpisodeButton setSelected:NO];
}

- (void)togglePlayState {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

#pragma mark - Episode Player

- (void)loadEpisode:(NSNotification *)note {
    JJBadMovie *episode = [note object];
    if (! episode || ! [episode isKindOfClass:[JJBadMovie class]]) return;
    [self setCurrentEpisode:episode];

    // load player
    self.streamingAudioPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:self.currentEpisode.url]];
    
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
                                     self.currentEpisode.number, MPMediaItemPropertyAlbumTrackNumber,
                                     kJJBadMovieArtistName, MPMediaItemPropertyArtist,
                                     //                                     artwork, MPMediaItemPropertyArtwork,
                                     kJJBadMovieGenre, MPMediaItemPropertyGenre,
                                     self.currentEpisode.name, MPMediaItemPropertyTitle,
                                     self.currentEpisode.name, MPMediaItemPropertyPodcastTitle,
                                     nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaDictionary];
    
    [self play];
}

@end
