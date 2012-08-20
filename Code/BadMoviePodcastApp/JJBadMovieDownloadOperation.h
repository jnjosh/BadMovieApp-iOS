//
//  JJBadMovieDownloadOperation.h
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@class JJBadMovie;

@interface JJBadMovieDownloadOperation : AFHTTPRequestOperation

@property (nonatomic, strong) JJBadMovie *badMovie;

@end
