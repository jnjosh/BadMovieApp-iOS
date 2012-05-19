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

@implementation JJBadMovie

@synthesize descriptionText = _descriptionText;
@synthesize imdb = _imdb;
@synthesize name = _name;
@synthesize number = _number;
@synthesize photo = _photo;
@synthesize published = _published;
@synthesize url = _url;
@synthesize video = _video;

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
}

#pragma mark - class methods

+ (JJBadMovie *)instanceFromDictionary:(NSDictionary *)aDictionary {
    JJBadMovie *instance = [[JJBadMovie alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;
}

#pragma mark - methods

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
}

@end
