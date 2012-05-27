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
#import <CoreMedia/CoreMedia.h>
#import <tgmath.h>
#import "JJBadMovieEnvironment.h"
#import "JJBadMoviePlayerViewController.h"
#import "JJBadMovie.h"

static dispatch_queue_t jj_player_queue = nil;

@interface JJBadMoviePlayerViewController () {
    id _timeObserver;
}

@property (nonatomic, assign, getter = isPlaying) BOOL playing;

@property (nonatomic, strong) UIButton *playPauseEpisodeButton;
@property (nonatomic, strong) UIButton *skipForwardButton;
@property (nonatomic, strong) UIButton *skipBackButton;
@property (nonatomic, strong) UILabel *currentlyPlaying;

@property (nonatomic, strong) UILabel *playClock;
@property (nonatomic, strong) UILabel *playRemainingClock;

@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) AVPlayer *streamingAudioPlayer;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (void)play;
- (void)pause;
- (void)togglePlayState;
- (void)skipForward;
- (void)skipBackward;

- (void)episodeDidFinishPlaying:(NSNotification *)note;

- (void)loadEpisode:(NSNotification *)note;
- (void)unloadCurrentEpisode:(BOOL)fullUnload;

@end

@implementation JJBadMoviePlayerViewController

#pragma mark - class

+ (void)initialize {
    if (self == [JJBadMoviePlayerViewController class]) {
        jj_player_queue = dispatch_queue_create("com.jnjosh.player_queue", NULL);
    }
}


#pragma mark - synth

@synthesize currentEpisode = _currentEpisode, playing = _playing;
@synthesize currentlyPlaying = _currentlyPlaying;
@synthesize playPauseEpisodeButton = _playPauseEpisodeButton, volumeView = _volumeView;
@synthesize skipBackButton = _skipBackButton, skipForwardButton = _skipForwardButton;

@synthesize playClock = _playClock, playRemainingClock = _playRemainingClock;
@synthesize progressSlider = _progressSlider;

@synthesize streamingAudioPlayer = _streamingAudioPlayer;
@synthesize delegate = _delegate;

#pragma mark - lifecycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.window.png"]]]; 
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
    [self.playPauseEpisodeButton setFrame:(CGRect){138, 20, 44, 44}];
    [self.view addSubview:self.playPauseEpisodeButton];
    
    self.skipBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipBackButton setShowsTouchWhenHighlighted:YES];
    [self.skipBackButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.skip.back.png"] forState:UIControlStateNormal];
    [self.skipBackButton addTarget:self action:@selector(skipBackward) forControlEvents:UIControlEventTouchUpInside];
    [self.skipBackButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x - 66, 20, 44, 44}];
    [self.view addSubview:self.skipBackButton];

    self.skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipForwardButton setShowsTouchWhenHighlighted:YES];
    [self.skipForwardButton setBackgroundImage:[UIImage imageNamed:@"ui.buttons.skip.forward.png"] forState:UIControlStateNormal];
    [self.skipForwardButton addTarget:self action:@selector(skipForward) forControlEvents:UIControlEventTouchUpInside];
    [self.skipForwardButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x + 66, 20, 44, 44}];
    [self.view addSubview:self.skipForwardButton];
    
    self.currentlyPlaying = [[UILabel alloc] initWithFrame:(CGRect){0, 74, 300, 24}];
    [self.currentlyPlaying setBackgroundColor:[UIColor clearColor]];
    [self.currentlyPlaying setFont:[UIFont systemFontOfSize:12.0f]];
    [self.currentlyPlaying setTextAlignment:UITextAlignmentCenter];
    [self.currentlyPlaying setTextColor:[UIColor whiteColor]];
    [self.currentlyPlaying setShadowColor:[UIColor blackColor]];
    [self.currentlyPlaying setShadowOffset:(CGSize){0, -1}];
    [self.view addSubview:self.currentlyPlaying];
    
    self.playClock = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 300, 24}];
    [self.playClock setBackgroundColor:[UIColor clearColor]];
    [self.playClock setFont:[UIFont systemFontOfSize:12.0f]];
    [self.playClock setTextAlignment:UITextAlignmentLeft];
    [self.playClock setTextColor:[UIColor whiteColor]];
    [self.playClock setShadowColor:[UIColor blackColor]];
    [self.playClock setShadowOffset:(CGSize){0, -1}];
    [self.view addSubview:self.playClock];

    self.playRemainingClock = [[UILabel alloc] initWithFrame:(CGRect){0, 26, 300, 24}];
    [self.playRemainingClock setBackgroundColor:[UIColor clearColor]];
    [self.playRemainingClock setFont:[UIFont systemFontOfSize:12.0f]];
    [self.playRemainingClock setTextAlignment:UITextAlignmentLeft];
    [self.playRemainingClock setTextColor:[UIColor whiteColor]];
    [self.playRemainingClock setShadowColor:[UIColor blackColor]];
    [self.playRemainingClock setShadowOffset:(CGSize){0, -1}];
    [self.view addSubview:self.playRemainingClock];

//    self.progressSlider = [[UISlider alloc] initWithFrame:(CGRect){10, 100, 280, 20}];
//    [self.view addSubview:self.progressSlider];
//    (CGRect){self.skipForwardButton.frame.origin.x + 66, 20, 44, 44}
    
    self.volumeView = [[MPVolumeView alloc] initWithFrame:(CGRect){self.skipForwardButton.frame.origin.x + 66, 20, 44, 44}];
#if TARGET_IPHONE_SIMULATOR
    [self.volumeView setBackgroundColor:[UIColor redColor]];
#endif
    [self.volumeView setShowsVolumeSlider:NO];
    [self.volumeView setShowsRouteButton:YES];
    [self.volumeView sizeThatFits:self.volumeView.frame.size];
    [self.view addSubview:self.volumeView];
    
//    UIView *testView = [[UIView alloc] initWithFrame:(CGRect){20, 20, 150, 150}];
//    [testView setBackgroundColor:[UIColor yellowColor]];
//    [self.view addSubview:testView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadEpisode:) name:kJJBadMovieNotificationBeginPlayingEpisode object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:kJJBadMovieNotificationPausePlayingEpisode object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.playPauseEpisodeButton = nil;
    self.skipBackButton = nil;
    self.skipForwardButton = nil;
    self.currentlyPlaying = nil;
    
    self.progressSlider = nil;
    self.playRemainingClock = nil;
    self.playClock = nil;
    
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

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(playerViewControllerDidBeginPlaying:)]) {
            [self.delegate playerViewControllerDidBeginPlaying:self];
        }
    }
}

- (void)pause {
    [self.streamingAudioPlayer pause];
    [self setPlaying:NO];
    [self.playPauseEpisodeButton setSelected:NO];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(playerViewControllerDidPause:)]) {
            [self.delegate playerViewControllerDidPause:self];
        }
    }
}

- (void)togglePlayState {
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)skipForward {
    CMTime currentTime = [self.streamingAudioPlayer currentTime];

    CGFloat seconds = currentTime.value / currentTime.timescale;
    seconds += 30;
    currentTime.value = seconds * currentTime.timescale;

    [self.streamingAudioPlayer seekToTime:currentTime];
}

- (void)skipBackward {
    CMTime currentTime = [self.streamingAudioPlayer currentTime];
    
    CGFloat seconds = currentTime.value / currentTime.timescale;
    seconds -= 30;
    currentTime.value = seconds * currentTime.timescale;
    
    [self.streamingAudioPlayer seekToTime:currentTime];
}

#pragma mark - Episode Player

- (void)episodeDidFinishPlaying:(NSNotification *)note {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(playerViewControllerDidEndPlaying:)]) {
            [self.delegate playerViewControllerDidEndPlaying:self];
        }
    }
}

- (void)unloadCurrentEpisode:(BOOL)fullUnload {
    if (fullUnload) {
        [self.streamingAudioPlayer pause];
        [self.streamingAudioPlayer removeTimeObserver:_timeObserver];
        self.streamingAudioPlayer = nil;
    }
}

- (void)loadEpisode:(NSNotification *)note {
    JJBadMovie *episode = [note object];
    if (! episode || ! [episode isKindOfClass:[JJBadMovie class]]) return;
    
    if (self.currentEpisode) {
        [self unloadCurrentEpisode:YES];
    }

    [self setCurrentEpisode:episode];
    [self.currentlyPlaying setText:[NSString stringWithFormat:@"Now Playing: %@", episode.name]];
    
    // load player
    self.streamingAudioPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:self.currentEpisode.url]];
    [self.streamingAudioPlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    _timeObserver = [self.streamingAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:jj_player_queue usingBlock:^(CMTime time) {
        CGFloat duration = self.streamingAudioPlayer.currentItem.duration.value / self.streamingAudioPlayer.currentItem.duration.timescale;

        // calculate progress
        CGFloat currentSeconds = time.value / time.timescale;

        CGFloat progressHours = floorf(currentSeconds / (60 * 60));
        CGFloat minutesDivisor = fmodf(currentSeconds, (60 * 60));
        CGFloat progressMinutes = floorf(minutesDivisor / 60);
        
        CGFloat secondsDivisor = fmodf(minutesDivisor, 60);
        CGFloat progressSeconds = ceilf(secondsDivisor);
        
        // calculate remaining
        CGFloat remainingSeconds = duration - currentSeconds;
        CGFloat remainHours = floorf(remainingSeconds / (60 * 60));
        CGFloat minutesRemainDivisor = fmodf(remainingSeconds, (60 * 60));
        CGFloat remainMinutes = floorf(minutesRemainDivisor / 60);
        
        CGFloat secondsRemainDivisor = fmodf(minutesRemainDivisor, 60);
        CGFloat remainSeconds = ceilf(secondsRemainDivisor);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playClock setText:[NSString stringWithFormat:@"%02d:%02d:%02d", (int)progressHours, (int)progressMinutes, (int)progressSeconds]];
            [self.playRemainingClock setText:[NSString stringWithFormat:@"%02d:%02d:%02d", (int)remainHours, (int)remainMinutes, (int)remainSeconds]];
        });
    }];
    
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
    
    UIImage *episodeImage = [episode cachedImage];
    NSDictionary *mediaDictionary = nil;
    if (episodeImage) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:episodeImage];
        mediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                           kJJBadMovieAlbumTitle, MPMediaItemPropertyAlbumTitle,
                           self.currentEpisode.number, MPMediaItemPropertyAlbumTrackNumber,
                           kJJBadMovieArtistName, MPMediaItemPropertyArtist,
                           artwork, MPMediaItemPropertyArtwork,
                           kJJBadMovieGenre, MPMediaItemPropertyGenre,
                           self.currentEpisode.name, MPMediaItemPropertyTitle,
                           self.currentEpisode.name, MPMediaItemPropertyPodcastTitle,
                           nil];
    } else {
        mediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kJJBadMovieAlbumTitle, MPMediaItemPropertyAlbumTitle,
                                    self.currentEpisode.number, MPMediaItemPropertyAlbumTrackNumber,
                                    kJJBadMovieArtistName, MPMediaItemPropertyArtist,
                                    kJJBadMovieGenre, MPMediaItemPropertyGenre,
                                    self.currentEpisode.name, MPMediaItemPropertyTitle,
                                    self.currentEpisode.name, MPMediaItemPropertyPodcastTitle,
                                    nil];
        
    }
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaDictionary];
    
    [self play];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(episodeDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end
