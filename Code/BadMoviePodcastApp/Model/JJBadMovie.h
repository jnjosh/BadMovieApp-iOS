//
//  JJBadMovie.h
//  
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJBadMovie : NSObject <NSCoding>

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSString *imdb;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *published;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, assign) CGFloat latestDownloadProgress;
@property (nonatomic, assign) BOOL hasDownloaded;
@property (nonatomic, strong, readonly) UIImage *cachedImage;

+ (JJBadMovie *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSString *)localFilePath;

@end
