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

@property (nonatomic, strong) UIView *nowPlayingView;

@property (nonatomic, strong) UIImageView *currentEpisodeImage;

@property (nonatomic, strong) UIButton *playPauseEpisodeButton;
@property (nonatomic, strong) UIButton *skipForwardButton;
@property (nonatomic, strong) UIButton *skipBackButton;
@property (nonatomic, strong) UILabel *currentlyPlaying;

@property (nonatomic, strong) UILabel *playClock;
@property (nonatomic, strong) UILabel *playRemainingClock;

@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, copy) JJBadMovieLoaderCompletionHandler loaderComplete;

@property (nonatomic, strong) AVPlayer *streamingAudioPlayer;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (void)togglePlayState;
- (void)skipForward;
- (void)skipBackward;
- (void)updatePlayerTrackInformation:(CMTime)currentTime;

- (void)progressSliderTouchBegan:(id)sender;
- (void)progressSliderDidChange:(id)sender;
- (void)episodeDidFinishPlaying:(NSNotification *)note;
- (NSDictionary *)nowPlayingDictionaryForDuration:(CGFloat)duration;

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

@synthesize nowPlayingView = _nowPlayingView;
@synthesize currentEpisodeImage = _currentEpisodeImage;

@synthesize streamingAudioPlayer = _streamingAudioPlayer, playerItem = _playerItem, loaderComplete = _loaderComplete;
@synthesize delegate = _delegate, playerState = _playerState;

#pragma mark - lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _playerState = JJBadMoviePlayerStateNotStarted;
    }
    return self;
}

#pragma mark - view

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.window.png"]]]; 
    self.view.layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -150.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nowPlayingView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, 320, 20}];
    [self.nowPlayingView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.player.nowplayingtrack.png"]]];
    [self.view addSubview:self.nowPlayingView];
    
    self.currentlyPlaying = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 320, 20}];
    [self.currentlyPlaying setBackgroundColor:[UIColor clearColor]];
    [self.currentlyPlaying setFont:[UIFont boldSystemFontOfSize:10.0f]];
    [self.currentlyPlaying setTextAlignment:UITextAlignmentCenter];
    [self.currentlyPlaying setTextColor:[UIColor grayColor]];
    [self.currentlyPlaying setShadowColor:[UIColor blackColor]];
    [self.currentlyPlaying setShadowOffset:(CGSize){0, -1}];
    [self.view addSubview:self.currentlyPlaying];
    
    self.currentEpisodeImage = [[UIImageView alloc] initWithFrame:(CGRect) { 0, 20, 320, 320 }];
    [self.currentEpisodeImage setAlpha:0.1];
    [self.view addSubview:self.currentEpisodeImage];

    UIImageView *gradientView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.player.background.gradient.png"]];
    [self.view addSubview:gradientView];
    
    self.playPauseEpisodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playPauseEpisodeButton setShowsTouchWhenHighlighted:YES];
    [self.playPauseEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.player.buttons.play.png"] forState:UIControlStateNormal];
    [self.playPauseEpisodeButton addTarget:self action:@selector(togglePlayState) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseEpisodeButton setFrame:(CGRect){138, 60, 44, 44}];
    [self.view addSubview:self.playPauseEpisodeButton];
    
    self.skipBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipBackButton setShowsTouchWhenHighlighted:YES];
    [self.skipBackButton setBackgroundImage:[UIImage imageNamed:@"ui.player.buttons.rewind.png"] forState:UIControlStateNormal];
    [self.skipBackButton addTarget:self action:@selector(skipBackward) forControlEvents:UIControlEventTouchUpInside];
    [self.skipBackButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x - 66, 60, 44, 44}];
    [self.view addSubview:self.skipBackButton];

    self.skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.skipForwardButton setShowsTouchWhenHighlighted:YES];
    [self.skipForwardButton setBackgroundImage:[UIImage imageNamed:@"ui.player.buttons.forward.png"] forState:UIControlStateNormal];
    [self.skipForwardButton addTarget:self action:@selector(skipForward) forControlEvents:UIControlEventTouchUpInside];
    [self.skipForwardButton setFrame:(CGRect){self.playPauseEpisodeButton.frame.origin.x + 66, 60, 44, 44}];
    [self.view addSubview:self.skipForwardButton];
    
    self.playClock = [[UILabel alloc] initWithFrame:(CGRect){25, 122, 43, 24}];
    [self.playClock setBackgroundColor:[UIColor clearColor]];
    [self.playClock setFont:[UIFont boldSystemFontOfSize:9.0f]];
    [self.playClock setTextAlignment:UITextAlignmentLeft];
    [self.playClock setTextColor:[UIColor whiteColor]];
    [self.playClock setShadowColor:[UIColor blackColor]];
    [self.playClock setShadowOffset:(CGSize){0, -1}];
    [self.playClock setText:@"0:00:00"];
    [self.view addSubview:self.playClock];

    self.playRemainingClock = [[UILabel alloc] initWithFrame:(CGRect){252, 122, 43, 24}];
    [self.playRemainingClock setBackgroundColor:[UIColor clearColor]];
    [self.playRemainingClock setFont:[UIFont boldSystemFontOfSize:9.0f]];
    [self.playRemainingClock setTextAlignment:UITextAlignmentRight];
    [self.playRemainingClock setTextColor:[UIColor whiteColor]];
    [self.playRemainingClock setShadowColor:[UIColor blackColor]];
    [self.playRemainingClock setShadowOffset:(CGSize){0, -1}];
    [self.playRemainingClock setText:@"-0:00:00"];
    [self.view addSubview:self.playRemainingClock];

    self.progressSlider = [[UISlider alloc] initWithFrame:(CGRect){70, 122, 180, 20}];
    [self.progressSlider setMinimumTrackTintColor:[UIColor darkGrayColor]];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"ui.player.track.knob.png"] forState:UIControlStateNormal];
    [self.progressSlider addTarget:self action:@selector(progressSliderDidChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(progressSliderDidChange:) forControlEvents:UIControlEventTouchUpOutside];
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.progressSlider];

    self.volumeView = [[MPVolumeView alloc] initWithFrame:(CGRect){self.skipForwardButton.frame.origin.x + 64, 70, 30, 30}];
#if TARGET_IPHONE_SIMULATOR
    [self.volumeView setBackgroundColor:[UIColor lightGrayColor]];
#endif
    [self.volumeView setShowsVolumeSlider:NO];
    [self.volumeView setShowsRouteButton:YES];
    [self.volumeView sizeThatFits:self.volumeView.frame.size];
    [self.view addSubview:self.volumeView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(episodeDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.playPauseEpisodeButton = nil;
    self.skipBackButton = nil;
    self.skipForwardButton = nil;
    self.currentlyPlaying = nil;
    
    self.nowPlayingView = nil;
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
    self.playerState = JJBadMoviePlayerStatePlaying;
    [self setPlaying:YES];
    [self.playPauseEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.player.buttons.pause.png"] forState:UIControlStateNormal];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(playerViewControllerDidBeginPlaying:)]) {
            [self.delegate playerViewControllerDidBeginPlaying:self];
        }
    }
}

- (void)pause {
    [self.streamingAudioPlayer pause];
    [self setPlaying:NO];
    self.playerState = JJBadMoviePlayerStatePaused;
    [self.playPauseEpisodeButton setBackgroundImage:[UIImage imageNamed:@"ui.player.buttons.play.png"] forState:UIControlStateNormal];
    
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

- (void)progressSliderTouchBegan:(id)sender {
    [self.progressSlider setEnabled:NO];
}

- (void)progressSliderDidChange:(id)sender {
    [self.progressSlider setEnabled:YES];
    CMTime currentTime = [self.streamingAudioPlayer currentTime];
    currentTime.value = self.progressSlider.value * currentTime.timescale;
    [self.streamingAudioPlayer seekToTime:currentTime];
}

- (void)episodeDidFinishPlaying:(NSNotification *)note {
    self.playerState = JJBadMoviePlayerStateEnded;
    [self.streamingAudioPlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(playerViewControllerDidEndPlaying:)]) {
            [self.delegate playerViewControllerDidEndPlaying:self];
        }
    }
}

- (void)updatePlayerTrackInformation:(CMTime)currentTime {
    CGFloat duration = self.streamingAudioPlayer.currentItem.duration.value / self.streamingAudioPlayer.currentItem.duration.timescale;
    
    // calculate progress
    CGFloat currentSeconds = currentTime.value / currentTime.timescale;
    
    CGFloat progressHours = MAX(0.0, floorf(currentSeconds / (60 * 60)));
    CGFloat minutesDivisor = fmodf(currentSeconds, (60 * 60));
    CGFloat progressMinutes = MAX(0.0, floorf(minutesDivisor / 60));
    
    CGFloat secondsDivisor = fmodf(minutesDivisor, 60);
    CGFloat progressSeconds = MAX(0.0, ceilf(secondsDivisor));
    
    // calculate remaining
    CGFloat remainingSeconds = duration - currentSeconds;
    CGFloat remainHours = MAX(floorf(remainingSeconds / (60 * 60)), 0.0);
    CGFloat minutesRemainDivisor = fmodf(remainingSeconds, (60 * 60));
    CGFloat remainMinutes = MAX(floorf(minutesRemainDivisor / 60), 0.0);
    
    CGFloat secondsRemainDivisor = fmodf(minutesRemainDivisor, 60);
    CGFloat remainSeconds = MAX(ceilf(secondsRemainDivisor), 0.0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.progressSlider isEnabled]) {
            [self.progressSlider setValue:currentSeconds];
        }
        [self.playClock setText:[NSString stringWithFormat:@"%01d:%02d:%02d", (int)progressHours, (int)progressMinutes, (int)progressSeconds]];
        [self.playRemainingClock setText:[NSString stringWithFormat:@"-%01d:%02d:%02d", (int)remainHours, (int)remainMinutes, (int)remainSeconds]];
    });    
}

- (void)loadEpisodeWithCompletionHandler:(JJBadMovieLoaderCompletionHandler)loaderComplete {
    if (! self.currentEpisode || ! [self.currentEpisode isKindOfClass:[JJBadMovie class]]) return;

    self.loaderComplete = loaderComplete;
    self.playerState = JJBadMoviePlayerStateNotStarted;
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.currentEpisode.url]];

    if (_timeObserver) {
        [self.streamingAudioPlayer removeTimeObserver:_timeObserver];
    }
    
    self.streamingAudioPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    [self.streamingAudioPlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    [self.streamingAudioPlayer setAllowsAirPlayVideo:NO];

    __block typeof(self) blockSelf = self;
    _timeObserver = [self.streamingAudioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:jj_player_queue usingBlock:^(CMTime time) {
        [blockSelf updatePlayerTrackInformation:time];
    }];
    
    CGFloat duration = self.streamingAudioPlayer.currentItem.duration.value / self.streamingAudioPlayer.currentItem.duration.timescale;
    [self.progressSlider setMinimumValue:0];
    [self.progressSlider setMaximumValue:duration];
    
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
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[self nowPlayingDictionaryForDuration:duration]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentlyPlaying setText:[NSString stringWithFormat:@"NOW PLAYING: Episode #%@ - %@", [[self currentEpisode] number], [[self currentEpisode] name]]];
        [self.currentEpisodeImage setImage:[[self currentEpisode] cachedImage]];
        
        if (self.loaderComplete) {
            self.loaderComplete();
        }
        self.loaderComplete = nil;
    });
    
}

- (NSDictionary *)nowPlayingDictionaryForDuration:(CGFloat)duration {
    NSMutableDictionary *mediaDictionary = [NSMutableDictionary dictionary];
    [mediaDictionary setObject:kJJBadMovieAlbumTitle forKey:MPMediaItemPropertyAlbumTitle];
    [mediaDictionary setObject:self.currentEpisode.number forKey:MPMediaItemPropertyAlbumTrackNumber];
    [mediaDictionary setObject:kJJBadMovieArtistName forKey:MPMediaItemPropertyArtist];
    [mediaDictionary setObject:kJJBadMovieGenre forKey:MPMediaItemPropertyGenre];
    [mediaDictionary setObject:self.currentEpisode.name forKey:MPMediaItemPropertyTitle];
    [mediaDictionary setObject:self.currentEpisode.name forKey:MPMediaItemPropertyPodcastTitle];
    [mediaDictionary setObject:self.currentEpisode.url forKey:MPMediaItemPropertyAssetURL];
    [mediaDictionary setObject:[NSNumber numberWithDouble:duration] forKey:MPMediaItemPropertyPlaybackDuration];

    UIImage *episodeImage = [self.currentEpisode cachedImage];
    if (episodeImage) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:episodeImage];
        [mediaDictionary setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }
    
    return mediaDictionary;
}

@end
