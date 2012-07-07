//
//  JJBadMovieDownloadRequest.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 6/25/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBadMovie;

typedef void(^JJBadMovieDownloadRequestCompletion)(NSData *data, NSError *error);

@interface JJBadMovieDownloadRequest : NSObject

@property (nonatomic, assign) id progressHud;

- (void)downloadEpisode:(JJBadMovie *)episode withCompletionHandler:(JJBadMovieDownloadRequestCompletion)completion;

@end
