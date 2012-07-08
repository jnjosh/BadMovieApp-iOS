//
//  NSManagedObjectContext+DataStack.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (DataStack)

+ (void)setupDataStack;
+ (NSManagedObjectContext *)parentManagedObjectContext;
+ (NSManagedObjectContext *)childManagedObjectContext;

@end
