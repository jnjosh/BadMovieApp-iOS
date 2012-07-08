//
//  JJBadMovieViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJBadMovieBaseViewController.h"
#import "JJBadMovieAudioPlayerDelegate.h"
#import "JJBadMoviePlayerViewController.h"

@class JJBadMovie;

@interface JJBadMovieViewController : JJBadMovieBaseViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, JJBadMovieAudioPlayerDelegate>

@property (nonatomic, strong) JJBadMovie *movie;
@property (nonatomic, weak) JJBadMoviePlayerViewController *playerController;
@property (nonatomic, assign, getter = isCurrentMovie) BOOL currentMovie;

- (id)initWithBadMovie:(JJBadMovie *)badMovie;
- (void)configureForPlayState:(JJBadMoviePlayerState)playerState;

@end
