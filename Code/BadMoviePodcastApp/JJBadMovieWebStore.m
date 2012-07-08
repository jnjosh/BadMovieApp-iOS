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

- (id)fetchObjects:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context;
- (NSManagedObjectID *)objectIdForNewObjectOfEntity:(NSEntityDescription*)entityDescription cacheValues:(NSDictionary*)values;

@end


@implementation JJBadMovieWebStore

#pragma mark - synth

@synthesize storeCache = _storeCache;

#pragma mark - lifecycle

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options
{
    if (self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options]) {
        _storeCache = [NSMutableDictionary dictionary];
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
        }
    }
    
    NSLog(@"Unimplemented Request: %@", request);
    return nil;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID 
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError **)error {

    NSDictionary *values = [self.storeCache objectForKey:objectID];
    
    // map objects to array
    NSMutableDictionary *mappedValues = [NSMutableDictionary dictionary];
    [mappedValues setObject:[values objectForKey:@"name"] forKey:@"name"];
    [mappedValues setObject:[values objectForKey:@"description"] forKey:@"descriptionText"];
    [mappedValues setObject:[values objectForKey:@"imdb"] forKey:@"imdbURL"];
    [mappedValues setObject:[values objectForKey:@"number"] forKey:@"number"];
    [mappedValues setObject:[values objectForKey:@"photo"] forKey:@"photoURL"];
    [mappedValues setObject:[values objectForKey:@"published"] forKey:@"published"];
    [mappedValues setObject:[values objectForKey:@"url"] forKey:@"url"];
    [mappedValues setObject:[values objectForKey:@"video"] forKey:@"videoURL"];
    [mappedValues setObject:[values objectForKey:@"location"] forKey:@"directURL"];

    NSIncrementalStoreNode *node =  [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                                          withValues:mappedValues 
                                                                             version:1];
    return node;
}

- (NSArray*)obtainPermanentIDsForObjects:(NSArray*)array error:(NSError**)error {
    return nil;
}

- (id)newValueForRelationship:(NSRelationshipDescription*)relationship forObjectWithID:(NSManagedObjectID*)objectID withContext:(NSManagedObjectContext*)context error:(NSError**)error {
    NSLog(@"unknown relatioship: %@", relationship);
    return nil;
}

#pragma mark - fetching objects from web

- (id)fetchObjects:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context {
    
    JJBadMovieEpisodeDataSource *dataSource = [[JJBadMovieEpisodeDataSource alloc] init];
    NSArray *episodeObjects = [dataSource syncLoadEpisodes];
    
    NSArray *filteredArray = episodeObjects;
    if (request.predicate) {
       filteredArray = [episodeObjects filteredArrayUsingPredicate:request.predicate];
    }
    
    NSMutableArray *episodeObjectIDs = [NSMutableArray array];
    for (id object in filteredArray) {
        NSManagedObjectID *oid = [self objectIdForNewObjectOfEntity:request.entity cacheValues:object];
        [episodeObjectIDs addObject:[context objectWithID:oid]];
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
