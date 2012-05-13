//
//  JJBadMovieEpisodesViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "JJBadMovieEpisodesViewController.h"
#import "JJBadMovieEnvironment.h"
#import "JJBadMovie.h"
#import "JJBadMovieViewController.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"

static inline CGFloat degreesToRadian(CGFloat degree)
{
    return degree * M_PI / 180.0f;
}

@interface JJBadMovieEpisodesViewController ()

@property (nonatomic, strong) NSArray *episodes;
@property (nonatomic, strong) UIView *downView;
@property (nonatomic, strong) UIImageView *vignetteView;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (CGImageRef)imageFromLayer:(CALayer *)layer size:(CGSize)size;
- (void)closePlayer:(UIGestureRecognizer *)gesture;

@end

@implementation JJBadMovieEpisodesViewController

#pragma mark - synth

@synthesize episodes = _episodes, downView = _downView, vignetteView = _vignetteView;
@synthesize volumeView = _volumeView;

#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.navigationbar.title.png"]];
    [self.navigationItem setTitleView:titleImage];
    
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settings)];
    [self.navigationItem setRightBarButtonItem:settingsItem];
    
    NSURL *episodeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/episodes", kJJBadMovieAPIURLRoot]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:episodeURL];
    AFJSONRequestOperation *jsonRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *episodeList = [NSMutableArray array];
        for (id episode in JSON) {
            JJBadMovie *badMovie = [JJBadMovie instanceFromDictionary:episode];
            if (badMovie) {
                [episodeList addObject:badMovie];
            }
        }
        self.episodes = [NSArray arrayWithArray:episodeList];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: %@", error);
    }];
    [jsonRequest start];
    
    self.volumeView = [[MPVolumeView alloc] initWithFrame:(CGRect){10, 40, 300, 80.0f}];
    [self.volumeView setAlpha:0.0];
    [self.volumeView sizeThatFits:(CGSize){ 300, 80 }];
    [self.navigationController.view.superview addSubview:self.volumeView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - methods

- (void)settings {
    CGImageRef image = [self imageFromLayer:self.navigationController.view.layer size:self.navigationController.view.frame.size];
    UIImage *viewImage = [[UIImage alloc] initWithCGImage:image];
    
    [self.navigationController.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    self.downView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    [imageView setFrame:self.navigationController.view.frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.downView addSubview:imageView];
    
    self.vignetteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.vignette.png"]];
    [self.vignetteView setContentMode:UIViewContentModeScaleAspectFill];
    [self.vignetteView setFrame:(CGRect){{0, 19},imageView.frame.size}];
    [self.vignetteView setAlpha:0.0];
    [self.downView addSubview:self.vignetteView];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closePlayer:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.downView addGestureRecognizer:swipeGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePlayer:)];
    [self.downView addGestureRecognizer:tapGesture];
    
    [UIView transitionFromView:self.navigationController.view toView:self.downView duration:0.0 options:UIViewAnimationOptionTransitionNone completion:^(BOOL finished) {

        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -600.0;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degreesToRadian(40.0), 1.0f, 0.0f, 0.0f);

        CATransform3D moveTranslation = CATransform3DMakeTranslation(0, 120.0f, 0);
        CATransform3D imageMatrix = CATransform3DConcat(moveTranslation, rotationAndPerspectiveTransform);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.downView.layer.transform = imageMatrix;
            [self.vignetteView setAlpha:0.7];
            [self.volumeView setAlpha:1.0];
        }];
    }];
}

- (CGImageRef)imageFromLayer:(CALayer *)layer size:(CGSize)size; {
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image.CGImage;
}

- (void)closePlayer:(UIGestureRecognizer *)gesture {
    [UIView animateWithDuration:0.25 animations:^{
        [self.volumeView setAlpha:0.0];
        self.downView.layer.transform = CATransform3DIdentity;
        [self.vignetteView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [UIView transitionFromView:self.downView toView:self.navigationController.view duration:0.0 options:UIViewAnimationOptionTransitionNone completion:nil];     
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BadMovieCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    JJBadMovie *movie = [self.episodes objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"#%i - %@", [movie.number integerValue], movie.name]];
    [cell.imageView setImageWithURL:[NSURL URLWithString:movie.photo] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJBadMovie *movie = [self.episodes objectAtIndex:indexPath.row];
    JJBadMovieViewController *detailViewController = [[JJBadMovieViewController alloc] initWithBadMovie:movie];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
