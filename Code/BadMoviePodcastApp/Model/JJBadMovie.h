//
//  JJBadMovie.h
//  
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJBadMovie : NSObject

@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSString *imdb;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *published;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *video;

+ (JJBadMovie *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
