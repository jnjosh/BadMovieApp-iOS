//
//  JJBadMovie.m
//  
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovie.h"
#import "SDImageCache.h"

NSString * const kJJBadMovieEpisodeKeyDescription = @"com.jnjosh.episode.description";
NSString * const kJJBadMovieEpisodeKeyImdb = @"com.jnjosh.episode.imdb";
NSString * const kJJBadMovieEpisodeKeyName = @"com.jnjosh.episode.name";
NSString * const kJJBadMovieEpisodeKeyNumber = @"com.jnjosh.episode.number";
NSString * const kJJBadMovieEpisodeKeyPhoto = @"com.jnjosh.episode.photo";
NSString * const kJJBadMovieEpisodeKeyPublished = @"com.jnjosh.episode.published";
NSString * const kJJBadMovieEpisodeKeyURL = @"com.jnjosh.episode.url";
NSString * const kJJBadMovieEpisodeKeyVideo = @"com.jnjosh.episode.video";
NSString * const kJJBadMovieEpisodeKeyLocation = @"com.jnjosh.episode.location";

@implementation JJBadMovie {
	NSString *_localFilePath;
}

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        self.descriptionText = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyDescription];
        self.imdb = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyImdb];
        self.name = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyName];
        self.number = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyNumber];
        self.photo = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyPhoto];
        self.published = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyPublished];
        self.url = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyURL];
        self.video = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyVideo];
        self.location = [aDecoder decodeObjectForKey:kJJBadMovieEpisodeKeyLocation];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.descriptionText forKey:kJJBadMovieEpisodeKeyDescription];
    [aCoder encodeObject:self.imdb forKey:kJJBadMovieEpisodeKeyImdb];
    [aCoder encodeObject:self.name forKey:kJJBadMovieEpisodeKeyName];
    [aCoder encodeObject:self.number forKey:kJJBadMovieEpisodeKeyNumber];
    [aCoder encodeObject:self.photo forKey:kJJBadMovieEpisodeKeyPhoto];
    [aCoder encodeObject:self.published forKey:kJJBadMovieEpisodeKeyPublished];
    [aCoder encodeObject:self.url forKey:kJJBadMovieEpisodeKeyURL];
    [aCoder encodeObject:self.video forKey:kJJBadMovieEpisodeKeyVideo];
    [aCoder encodeObject:self.location forKey:kJJBadMovieEpisodeKeyLocation];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        JJBadMovie *otherClass = object;
        return [[self number] compare:[otherClass number]] == NSOrderedSame;
    }
    return NO;
}

#pragma mark - class methods

+ (JJBadMovie *)instanceFromDictionary:(NSDictionary *)aDictionary {
    JJBadMovie *instance = [[JJBadMovie alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;
}

#pragma mark - methods

- (NSString *)localFilePath {
	if (! _localFilePath) {
		NSString *filePrefix = [self.name lowercaseString];
		filePrefix = [[filePrefix stringByReplacingOccurrencesOfString:@" " withString:@""] stringByAppendingString:[self.number stringValue]];
		NSString *fileName = [filePrefix stringByAppendingPathExtension:@"mp3"];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
		_localFilePath = [basePath stringByAppendingPathComponent:fileName];
	}
	return _localFilePath;

}

- (BOOL)hasDownloaded
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self localFilePath]];
}

- (UIImage *)cachedImage {
    UIImage *imageFromCache = [[SDImageCache sharedImageCache] imageFromKey:self.photo fromDisk:YES];
    return imageFromCache ? : nil;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    if (! [aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    self.descriptionText = [aDictionary objectForKey:@"description"];
    self.imdb = [aDictionary objectForKey:@"imdb"];
    self.name = [aDictionary objectForKey:@"name"];
    self.number = [aDictionary objectForKey:@"number"];
    self.photo = [aDictionary objectForKey:@"photo"];
    self.published = [aDictionary objectForKey:@"published"];
    self.url = [aDictionary objectForKey:@"url"];
    self.video = [aDictionary objectForKey:@"video"];
    self.location = [aDictionary objectForKey:@"location"];
}

@end
