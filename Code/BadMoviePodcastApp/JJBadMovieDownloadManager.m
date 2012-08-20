//
//  JJBadMovieDownloadManager.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieDownloadManager.h"
#import "JJBadMovie.h"
#import "JJBadMovieDownloadOperation.h"

@interface JJBadMovieDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation JJBadMovieDownloadManager

+ (id)sharedManager
{
	static dispatch_once_t onceToken;
	static id shared_movieManager = nil;
	dispatch_once(&onceToken, ^{
		shared_movieManager = [[self alloc] init];
	});
	return shared_movieManager;
}

#pragma mark - Life cycle

- (id)init
{
	if (self = [super init]) {
		_observers = [NSMutableDictionary dictionary];
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:4];
	}
	return self;
}

#pragma mark - Downloading

- (void)downloadEpisodeForMovie:(JJBadMovie *)badMovie
{
	NSURL *episodeUrl = [NSURL URLWithString:[badMovie url]];
	if (episodeUrl) {
		NSURLRequest *request = [NSURLRequest requestWithURL:episodeUrl];

		JJBadMovieDownloadOperation *operation = [[JJBadMovieDownloadOperation alloc] initWithRequest:request];
		[operation setBadMovie:badMovie];
		
		// set progress handler
		[operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
			[observer movieDownloadDidProgress:@(totalBytesRead) total:@(totalBytesExpectedToRead)];
		}];
		
		// set completion handlers
		[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSData *downloadedData = (NSData *)responseObject;
			NSString *filePath = [badMovie localFilePath];
			[downloadedData writeToFile:filePath atomically:NO];
			
			id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
			[observer movieDidFinishDownloading];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
			[observer movieDidFailDownloadingWithError:error];
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		}];
		
		[self.operationQueue addOperation:operation];

		id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
		[observer movieDidBeginDownloading];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)cancelDownloadingEpisodeForMovie:(JJBadMovie *)badMovie
{
	for (JJBadMovieDownloadOperation *operation in [self.operationQueue operations]) {
		if ([[operation badMovie] isEqual:badMovie]) {
			[operation cancel];
			break;
		}
	}
	id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
	[observer movieDidCancelDownloading];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Observers

- (void)addDownloadObserver:(id<JJBadMovieDownloadObserver>)observer forMovie:(JJBadMovie *)movie
{
	[self.observers setObject:observer forKey:[[movie number] stringValue]];
}

- (void)removeDownloadObserver:(id<JJBadMovieDownloadObserver>)observer
{
	NSArray *keysForObject = [self.observers allKeysForObject:observer];
	[self.observers removeObjectsForKeys:keysForObject];
}

@end
