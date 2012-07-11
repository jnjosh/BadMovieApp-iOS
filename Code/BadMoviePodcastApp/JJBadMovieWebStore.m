//
//  JJBadMovieWebStore.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieWebStore.h"
#import "JJBadMovieEpisodeDataSource.h"

@interface JJBadMovieWebStore ()

@property (nonatomic, strong) NSMutableDictionary *storeCache;
@property (nonatomic, strong) NSArray *episodes;
@property (nonatomic, strong) JJBadMovieEpisodeDataSource *dataSource;

- (id)fetchObjects:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context;
- (id)fetchObjectIDs:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context;
- (NSManagedObjectID *)objectIdForNewObjectOfEntity:(NSEntityDescription*)entityDescription cacheValues:(NSDictionary*)values;

@end


@implementation JJBadMovieWebStore

#pragma mark - synth

@synthesize storeCache = _storeCache;
@synthesize episodes = _episodes;
@synthesize dataSource = _dataSource;

#pragma mark - lifecycle

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options
{
    if (self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options]) {
        _storeCache = [NSMutableDictionary dictionary];
        _dataSource = [[JJBadMovieEpisodeDataSource alloc] init];
    }
    return self;
}

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error
{
    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    [self setMetadata:[NSDictionary dictionaryWithObjectsAndKeys:[[self class] storeType], NSStoreTypeKey, uuid, NSStoreUUIDKey, nil]];
    return YES;
}

#pragma mark - properties

+ (NSString *)storeType
{
    return NSStringFromClass([self class]);
}

#pragma mark - core data calls to web calls

- (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error
{
    if (request.requestType == NSFetchRequestType) {
        NSFetchRequest *fetchRequest = (NSFetchRequest*)request;
        if (fetchRequest.resultType == NSManagedObjectResultType) {
            return [self fetchObjects:fetchRequest withContext:context];
        } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
            return [self fetchObjectIDs:fetchRequest withContext:context];
        }
    }
    
    NSLog(@"Unimplemented Request: %@", request);
    return nil;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID 
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError **)error {

    NSDictionary *values = [self.storeCache objectForKey:objectID];
    
    NSDictionary *mappedValues = nil;
    Class objectClass = NSClassFromString([[objectID entity] managedObjectClassName]);
    if ([objectClass respondsToSelector:@selector(objectMappingWithDictionary:)]) {
        mappedValues = [objectClass performSelector:@selector(objectMappingWithDictionary:) withObject:values];
    }

    NSIncrementalStoreNode *node =  [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                                          withValues:mappedValues 
                                                                             version:1];
    return node;
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError **)error {
    return nil;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError **)error {
    NSLog(@"unknown relatioship: %@", relationship);
    return nil;
}

#pragma mark - fetching objects from web

- (id)fetchObjects:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context {
    
    if (! self.episodes) {
        [self.dataSource asyncLoadEpisodesCompletion:^(id objects) {
            self.episodes = objects; 
        }];
    }
    
    NSArray *filteredArray = self.episodes;
    if (request.predicate) {
       filteredArray = [self.episodes filteredArrayUsingPredicate:request.predicate];
    }
    
    NSMutableArray *episodeObjectIDs = [NSMutableArray array];
    for (id object in filteredArray) {
        NSManagedObjectID *oid = [self objectIdForNewObjectOfEntity:request.entity cacheValues:object];
        [episodeObjectIDs addObject:[context objectWithID:oid]];
    }
    
    return episodeObjectIDs;
}

- (id)fetchObjectIDs:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context {
    
    if (! self.episodes) {
        JJBadMovieEpisodeDataSource *dataSource = [[JJBadMovieEpisodeDataSource alloc] init];
        self.episodes = [dataSource syncLoadEpisodes];
    }
    
    NSArray *filteredArray = self.episodes;
    if (request.predicate) {
        filteredArray = [self.episodes filteredArrayUsingPredicate:request.predicate];
    }
    
    NSMutableArray *episodeObjectIDs = [NSMutableArray array];
    for (id object in filteredArray) {
        NSManagedObjectID *oid = [self objectIdForNewObjectOfEntity:request.entity cacheValues:object];
        [episodeObjectIDs addObject:oid];
    }
    
    return episodeObjectIDs;
}


- (NSManagedObjectID *)objectIdForNewObjectOfEntity:(NSEntityDescription *)entityDescription cacheValues:(NSDictionary *)values {
    NSString *nativeKey = @"number";
    id referenceId = [values objectForKey:nativeKey];
    NSManagedObjectID *objectId = [self newObjectIDForEntity:entityDescription 
                                             referenceObject:referenceId];
    [self.storeCache setObject:values forKey:objectId];
    return objectId;
}

@end
