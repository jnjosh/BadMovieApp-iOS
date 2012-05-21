//
//  JJBadMovieEpisodesViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJBadMovieEpisodeDataSource;

@interface JJBadMovieEpisodesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithEpisodeDataSource:(JJBadMovieEpisodeDataSource *)dataSource;

@end
