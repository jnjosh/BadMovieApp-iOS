//
//  JJBadMovieViewController.h
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJBadMovie;

@interface JJBadMovieViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, assign) JJBadMovie *currentMovie;

- (id)initWithBadMovie:(JJBadMovie *)badMovie;

@end
