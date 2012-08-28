//
//  JJBadMovieDownloadManager.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/19/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieDownloadManager.h"
#import "JJBadMovie.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadMovieDownloadOperation.h"

NSString * const kJJBadMovieStandaloneObserver = @"com.jnjosh.observers.standalone";

@interface JJBadMovieDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (NSArray *)currentObserversWithKey:(NSString *)key;

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

- (NSArray *)episodesDownloading
{
	return [[self operationQueue] operations];
}

- (NSUInteger)episodesCurrentlyDownloading
{
	return [[self operationQueue] operationCount];
}

- (void)downloadEpisodeForMovie:(JJBadMovie *)badMovie
{
	NSURL *episodeUrl = [NSURL URLWithString:[badMovie url]];
	if (episodeUrl) {
		NSURLRequest *request = [NSURLRequest requestWithURL:episodeUrl];

		JJBadMovieDownloadOperation *operation = [[JJBadMovieDownloadOperation alloc] initWithRequest:request];
		[operation setBadMovie:badMovie];
		[operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
			[self cancelAllDownloadOperations];
		}];
		
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
			if ([observer respondsToSelector:@selector(movieDidFinishDownloading)]) {
				[observer movieDidFinishDownloading];
			}

			id<JJBadMovieDownloadObserver> episodeObserver = [self.observers objectForKey:kJJBadMovieStandaloneObserver];
			if ([episodeObserver respondsToSelector:@selector(movieDidFinishDownloading)]) {
				[episodeObserver movieDidFinishDownloading];
			}
			
			if ([self.operationQueue operationCount] == 0) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				if ([episodeObserver respondsToSelector:@selector(didCompleteDownloading)]) {
					[episodeObserver didCompleteDownloading];
				}
			}
			
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			[notification setAlertBody:[NSString stringWithFormat:@"Finished downloading episode %@ - %@", badMovie.number, badMovie.name]];
			[notification setAlertAction:@"Listen Now!"];
			[notification setSoundName:UILocalNotificationDefaultSoundName];
			[notification setFireDate:[NSDate date]];
			[notification setUserInfo:@{ kJJBadMovieNotificationKey : badMovie.number }];
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
			[observer movieDidFailDownloadingWithError:error];

			id<JJBadMovieDownloadObserver> episodeObserver = [self.observers objectForKey:kJJBadMovieStandaloneObserver];
			if ([episodeObserver respondsToSelector:@selector(movieDidFinishDownloading)]) {
				[episodeObserver movieDidFinishDownloading];
			}
			
			if ([self.operationQueue operationCount] == 0) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				if ([episodeObserver respondsToSelector:@selector(didCompleteDownloading)]) {
					[episodeObserver didCompleteDownloading];
				}
			}
		}];
		
		[self.operationQueue addOperation:operation];

		id<JJBadMovieDownloadObserver> observer = [self.observers objectForKey:[[badMovie number] stringValue]];
		if ([observer respondsToSelector:@selector(movieDidBeginDownloading)]) {
			[observer movieDidBeginDownloading];
		}
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (BOOL)completedDownloadRequests
{
	return [self.operationQueue operationCount] == 0;
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
	if ([observer respondsToSelector:@selector(movieDidCancelDownloading)]) {
		[observer movieDidCancelDownloading];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		id<JJBadMovieDownloadObserver> episodeObserver = [self.observers objectForKey:kJJBadMovieStandaloneObserver];

		if ([self.operationQueue operationCount] == 0) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
			if ([episodeObserver respondsToSelector:@selector(didCompleteDownloading)]) {
				[episodeObserver didCompleteDownloading];
			}
		}

		if ([episodeObserver respondsToSelector:@selector(movieDidCancelDownloading)]) {
			[episodeObserver movieDidCancelDownloading];
		}
	
	});
}

- (BOOL)downloadingActiveForMovie:(JJBadMovie *)badmovie
{
	for (JJBadMovieDownloadOperation *operation in [self.operationQueue operations]) {
		if ([[operation badMovie] isEqual:badmovie]) {
			return YES;
		}
	}
	return NO;
}

- (void)cancelAllDownloadOperations
{
	[self.operationQueue cancelAllOperations];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	id<JJBadMovieDownloadObserver> episodeObserver = [self.observers objectForKey:kJJBadMovieStandaloneObserver];
	if ([episodeObserver respondsToSelector:@selector(didCompleteDownloading)]) {
		[episodeObserver didCompleteDownloading];
	}
}

#pragma mark - Observers

- (NSArray *)currentObserversWithKey:(NSString *)key
{
	NSMutableArray *observers = [NSMutableArray array];

	id standaloneObserver = [self.observers objectForKey:kJJBadMovieStandaloneObserver];
	if (standaloneObserver) {
		[observers addObject:standaloneObserver];
	}

	if (key) {
		id movieObserver = [self.observers objectForKey:key];
		if (movieObserver) {
			[observers addObject:movieObserver];
		}
	}
	
	return observers;
}

- (void)addDownloadObserver:(id<JJBadMovieDownloadObserver>)observer
{
	[self.observers setObject:observer forKey:kJJBadMovieStandaloneObserver];
}

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
