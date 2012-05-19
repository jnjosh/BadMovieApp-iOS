//
//  JJBadMovie.m
//  
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovie.h"
#import "SDImageCache.h"

@implementation JJBadMovie

@synthesize descriptionText = _descriptionText;
@synthesize imdb = _imdb;
@synthesize name = _name;
@synthesize number = _number;
@synthesize photo = _photo;
@synthesize published = _published;
@synthesize url = _url;
@synthesize video = _video;

+ (JJBadMovie *)instanceFromDictionary:(NSDictionary *)aDictionary {
    JJBadMovie *instance = [[JJBadMovie alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;
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
}

@end
