//
//  NSManagedObjectModel+DataStack.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "NSManagedObjectModel+DataStack.h"

static NSManagedObjectModel *jj_current_managed_object_model = nil;
NSString * const kJJManagedObjectModelResource = @"BadMovieAppModel";

@implementation NSManagedObjectModel (DataStack)

+ (NSManagedObjectModel *)currentManagedObjectModel {
    if (jj_current_managed_object_model) return jj_current_managed_object_model;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kJJManagedObjectModelResource withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    jj_current_managed_object_model = model;
    
    return jj_current_managed_object_model;
}

@end