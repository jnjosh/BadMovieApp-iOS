//
//  JJBadMoviePlayerViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJBadMovieAudioPlayerDelegate.h"

typedef enum {
    JJBadMoviePlayerStateNotStarted,
    JJBadMoviePlayerStatePlaying,
    JJBadMoviePlayerStatePaused,
    JJBadMoviePlayerStateEnded,
    JJBadMoviePlayerStateUnknown
} JJBadMoviePlayerState;

typedef void(^JJBadMovieLoaderCompletionHandler)(void);

@class JJBadMovie;

@interface JJBadMoviePlayerViewController : UIViewController

@property (nonatomic, strong) JJBadMovie *currentEpisode;
@property (nonatomic, assign) NSObject<JJBadMovieAudioPlayerDelegate> *delegate;
@property (nonatomic, assign) JJBadMoviePlayerState playerState;

- (void)loadEpisodeWithCompletionHandler:(JJBadMovieLoaderCompletionHandler)loaderComplete;

- (void)play;
- (void)pause;

@end
