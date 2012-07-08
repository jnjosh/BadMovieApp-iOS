//
//  NSPersistentStoreCoordinator+DataStack.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "NSPersistentStoreCoordinator+DataStack.h"
#import "NSManagedObjectModel+DataStack.h"
#import "JJBadMovieWebStore.h"
#import "JJBadMovieEnvironment.h"

static NSPersistentStoreCoordinator *jj_current_persistent_store_coordinator = nil;

@implementation NSPersistentStoreCoordinator (DataStack)

+ (NSPersistentStoreCoordinator *)currentPersistentStoreCoordinator
{
    if (jj_current_persistent_store_coordinator) return jj_current_persistent_store_coordinator;
    
    // Get model
    NSManagedObjectModel *mom = [NSManagedObjectModel currentManagedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    // get remote store URL
//    NSURL *storeURL = [NSURL URLWithString:kJJBadMovieAPIURLRoot];

    NSString *storeType = [JJBadMovieWebStore storeType];
    
    // build coordinator
    [NSPersistentStoreCoordinator registerStoreClass:[JJBadMovieWebStore class] forStoreType:storeType];
    
    NSError *error = nil;
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    [coordinator addPersistentStoreWithType:storeType configuration:nil URL:nil options:nil error:&error];
    
    NSLog(@"Error: %@", error);
    
    jj_current_persistent_store_coordinator = coordinator;
    return jj_current_persistent_store_coordinator;
}

@end