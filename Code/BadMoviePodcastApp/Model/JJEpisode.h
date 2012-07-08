//
//  JJEpisode.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface JJEpisode : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *number;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSString *imdbURL;
@property (nonatomic, retain) NSString *photoURL;
@property (nonatomic, retain) NSString *published;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) NSString *directURL;

@end
