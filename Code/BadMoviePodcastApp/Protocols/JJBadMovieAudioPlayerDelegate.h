//
//  JJBadMovieAudioPlayerDelegate.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/26/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBadMoviePlayerViewController;

@protocol JJBadMovieAudioPlayerDelegate <NSObject>

@optional

- (void)playerViewControllerDidBeginPlaying:(JJBadMoviePlayerViewController *)playerViewController;
- (void)playerViewControllerDidPause:(JJBadMoviePlayerViewController *)playerViewController;
- (void)playerViewControllerDidEndPlaying:(JJBadMoviePlayerViewController *)playerViewController;

@end
