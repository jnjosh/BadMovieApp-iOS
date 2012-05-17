//
//  JJBadMovieEpisodeDataSource.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/16/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBadMovie;

typedef void(^JJBadMovieEpisodeCompletionBlock)(void);

@interface JJBadMovieEpisodeDataSource : NSObject

@property (nonatomic, strong) NSArray *episodes;

- (JJBadMovie *)episodeForIndexPath:(NSIndexPath *)indexPath;
- (void)downloadImageForIndexPath:(NSIndexPath *)indexPath completionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler;
- (void)loadEpisodesWithCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler;

@end
