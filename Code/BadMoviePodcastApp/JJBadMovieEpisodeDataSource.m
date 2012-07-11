//
//  JJBadMovieEpisodeDataSource.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/16/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieEpisodeDataSource.h"
#import "JJBadMovieEnvironment.h"
#import "AFJSONRequestOperation.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "JJBadMovie.h"

@implementation JJBadMovieEpisodeDataSource {
    NSOperationQueue *_queue;
}

@synthesize episodes = _episodes;

- (JJBadMovie *)episodeForIndexPath:(NSIndexPath *)indexPath {
    JJBadMovie *movie = nil;
    if ([self.episodes count] >= indexPath.row) {
        movie = [self.episodes objectAtIndex:indexPath.row];
    }
    return movie;
}

- (void)downloadImageForIndexPath:(NSIndexPath *)indexPath completionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler {
    JJBadMovie *movie = [self episodeForIndexPath:indexPath];
    if (! movie.cachedImage) {
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:movie.photo] delegate:self options:SDWebImageProgressiveDownload success:^(UIImage *image) {
            if (image && completionHandler) {
                completionHandler();
            }
        } failure:nil];
    }
}

- (void)checkServerForUpdatesWithCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler {
    // todo
}

- (void)loadEpisodesWithCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler {
    NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:episodeURL];
    AFJSONRequestOperation *jsonRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *episodeList = [NSMutableArray array];
        for (id episode in JSON) {
            JJBadMovie *badMovie = [JJBadMovie instanceFromDictionary:episode];
            if (badMovie) {
                [episodeList addObject:badMovie];
            }
        }
        self.episodes = [NSArray arrayWithArray:episodeList];
        
        if (completionHandler) {
            completionHandler();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: %@", error);
    }];
    [jsonRequest start];
}

- (void)asyncLoadEpisodesCompletion:(void (^)(id objects))handler {
    if (! _queue) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
    }
    
    NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:episodeURL];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (handler) {
            handler(jsonResponse);
        }
    }];
}

- (NSArray *)syncLoadEpisodes {
    NSLog(@"syncload episodes");
    NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
    NSData *episodeResponse = [NSData dataWithContentsOfURL:episodeURL];    
    id jsonResponse = [NSJSONSerialization JSONObjectWithData:episodeResponse options:0 error:nil];
    return jsonResponse;
}

@end
