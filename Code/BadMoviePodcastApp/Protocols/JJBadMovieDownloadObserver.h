//
//  JJBadMovieDownloadObserver.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JJBadMovieDownloadObserver <NSObject>

- (void)movieDidBeginDownloading;

- (void)movieDidFinishDownloading;

- (void)movieDidCancelDownloading;

- (void)movieDidFailDownloadingWithError:(NSError *)error;

- (void)movieDownloadDidProgress:(NSNumber *)progress total:(NSNumber *)total;

@end
