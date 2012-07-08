//
//  JJBadMovieEpisodesViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJBadMovieBaseViewController.h"
#import "SSPullToRefresh.h"

@class JJBadMovieEpisodeDataSource;

@interface JJBadMovieEpisodesViewController : JJBadMovieBaseViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

- (id)initWithEpisodeDataSource:(JJBadMovieEpisodeDataSource *)dataSource;

@end
