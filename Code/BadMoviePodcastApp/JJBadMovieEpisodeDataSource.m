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
#import "JJBadMovieNetwork.h"
#import "JJBadMovieDownloadManager.h"

NSString * const kJJBadMovieCachedEpisodes = @"com.jnjosh.badmovie.cachedEpisodes";

@interface JJBadMovieEpisodeDataSource ()

@property (nonatomic, strong) NSString *cachedPath;

- (void)updateEpisodesFromJSON:(id)json withCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completion;

@end

@implementation JJBadMovieEpisodeDataSource

@synthesize episodes = _episodes;

#pragma mark - Properties

- (NSString *)cachedPath
{
	if (! _cachedPath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		_cachedPath = [basePath stringByAppendingPathComponent:kJJBadMovieCachedEpisodes];
	}
	return _cachedPath;
}

#pragma mark - Methods

- (JJBadMovie *)episodeForIndexPath:(NSIndexPath *)indexPath {
    JJBadMovie *movie = nil;
    if ([self.episodes count] >= indexPath.row) {
        movie = [self.episodes objectAtIndex:indexPath.row];
    }
    return movie;
}

- (NSIndexPath *)indexPathForEpisode:(JJBadMovie *)episode
{
	NSIndexPath *indexPath = nil;
	for (NSInteger i = 0; i < [self.episodes count]; i++) {
		JJBadMovie *movie = [self.episodes objectAtIndex:i];
		if ([movie isEqual:episode]) {
			indexPath = [NSIndexPath indexPathForRow:i inSection:0];
			break;
		}
	}
	return indexPath;
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

- (void)loadEpisodesWithCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completionHandler {
	
	// load any cached objects
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachedPath]]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSArray *cachedEpisodes = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachedPath]];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.episodes = cachedEpisodes;
				if (completionHandler) {
					completionHandler();
				}
			});
		});
	}

	[[JJBadMovieNetwork sharedNetwork] executeNetworkActivity:^{
		NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
		NSURLRequest *urlRequest = [NSURLRequest requestWithURL:episodeURL];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
		JJBadMovieEpisodeCompletionBlock completionCopy = [completionHandler copy];
		AFJSONRequestOperation *jsonRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			[self updateEpisodesFromJSON:JSON withCompletionHandler:completionCopy];

			if ([[JJBadMovieDownloadManager sharedManager] completedDownloadRequests]) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			}
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			if ([[JJBadMovieDownloadManager sharedManager] completedDownloadRequests]) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			}
		}];
		[jsonRequest start];
	} failed:^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kJJBadMovieNotificationGlobalNotification object:kJJBadMovieNetworkErrorMessage];
	}];
}

- (void)updateEpisodesFromJSON:(id)json withCompletionHandler:(JJBadMovieEpisodeCompletionBlock)completion
{
	NSMutableArray *episodeList = [NSMutableArray array];
	for (id episode in json) {
		JJBadMovie *badMovie = [JJBadMovie instanceFromDictionary:episode];
		if (badMovie) {
			[episodeList addObject:badMovie];
		}
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[NSKeyedArchiver archiveRootObject:episodeList toFile:[self cachedPath]];
	});

	self.episodes = episodeList;
	if (completion) {
		completion();
	}
}

@end
