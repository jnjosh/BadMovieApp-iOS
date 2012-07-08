//
//  JJBadMovieBaseViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 7/7/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface JJBadMovieBaseViewController : UIViewController

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

@end
