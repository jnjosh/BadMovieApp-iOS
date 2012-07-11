//
//  NSManagedObjectContext+DataStack.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "NSManagedObjectContext+DataStack.h"
#import "NSPersistentStoreCoordinator+DataStack.h"

static NSManagedObjectContext *jj_parent_managed_object_context = nil;

@implementation NSManagedObjectContext (DataStack)

+ (void)setupDataStack {
    [self parentManagedObjectContext];
}

+ (NSManagedObjectContext *)parentManagedObjectContext {
    if (jj_parent_managed_object_context) return jj_parent_managed_object_context;
    
    NSPersistentStoreCoordinator *coordinator = [NSPersistentStoreCoordinator currentPersistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    jj_parent_managed_object_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [jj_parent_managed_object_context setPersistentStoreCoordinator:coordinator];
    
    return jj_parent_managed_object_context;
}

+ (NSManagedObjectContext *)childManagedObjectContext {
    if (! jj_parent_managed_object_context) [self parentManagedObjectContext];
    
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:jj_parent_managed_object_context];
    return childContext;
}

@end
