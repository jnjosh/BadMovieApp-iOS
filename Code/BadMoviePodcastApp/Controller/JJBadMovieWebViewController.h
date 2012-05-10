//
//  JJBadMovieWebViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJBadMovieWebViewController : UIViewController <UIWebViewDelegate>

- (id)initWithYouTubeVideo:(NSString *)youtubeVideoString;
- (id)initWithIMDBUrl:(NSString *)imdbUrl;

@end
