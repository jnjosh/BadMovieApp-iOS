//
//  JJBadMovieDownloadManager.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJBadMovieDownloadObserver.h"

@class JJBadMovie;

@interface JJBadMovieDownloadManager : NSObject

+ (id)sharedManager;

// downloading
- (void)downloadEpisodeForMovie:(JJBadMovie *)badMovie;
- (void)cancelDownloadingEpisodeForMovie:(JJBadMovie *)badMovie;

// observers
- (void)addDownloadObserver:(id<JJBadMovieDownloadObserver>)observer forMovie:(JJBadMovie *)movie;
- (void)removeDownloadObserver:(id<JJBadMovieDownloadObserver>)observer;

@end
