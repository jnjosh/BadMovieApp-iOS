//
//  JJEpisode.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJEpisode.h"

@implementation JJEpisode

@dynamic name;
@dynamic number;
@dynamic descriptionText;
@dynamic imdbURL;
@dynamic photoURL;
@dynamic published;
@dynamic url;
@dynamic videoURL;
@dynamic directURL;

+ (NSDictionary *)objectMappingWithDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mappedValues = [NSMutableDictionary dictionary];
    [mappedValues setObject:[dictionary objectForKey:@"name"] forKey:@"name"];
    [mappedValues setObject:[dictionary objectForKey:@"description"] forKey:@"descriptionText"];
    [mappedValues setObject:[dictionary objectForKey:@"imdb"] forKey:@"imdbURL"];
    [mappedValues setObject:[dictionary objectForKey:@"number"] forKey:@"number"];
    [mappedValues setObject:[dictionary objectForKey:@"photo"] forKey:@"photoURL"];
    [mappedValues setObject:[dictionary objectForKey:@"published"] forKey:@"published"];
    [mappedValues setObject:[dictionary objectForKey:@"url"] forKey:@"url"];
    [mappedValues setObject:[dictionary objectForKey:@"video"] forKey:@"videoURL"];
    [mappedValues setObject:[dictionary objectForKey:@"location"] forKey:@"directURL"];
    return mappedValues;
}

@end
