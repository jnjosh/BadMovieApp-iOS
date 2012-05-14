//
//  JJBadMovieWindowController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBadMoviePlayerViewController;

@interface JJBadMovieWindowController : NSObject <UINavigationControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) JJBadMoviePlayerViewController *playerController;

+ (void)configureAppearance;
+ (void)configureCache;
- (void)presentAudioPlayer;
- (void)hideAudioPlayer;

@end
