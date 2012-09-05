//
//  JJBadMovieDownloadObserver.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJBadMovie;

@protocol JJBadMovieDownloadObserver <NSObject>

@optional

- (void)movieDidBeginDownloading;

- (void)movieDidFinishDownloading;

- (void)movieDidFinishDownloadingEpisode:(JJBadMovie *)badmovie;

- (void)movieDidCancelDownloading;

- (void)movieDidFailDownloadingWithError:(NSError *)error;

- (void)movieDownloadDidProgress:(NSNumber *)progress total:(NSNumber *)total;

- (void)didCompleteDownloading;

- (void)didDeleteEpisode:(JJBadMovie *)episode;

@end
