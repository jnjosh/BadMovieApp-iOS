//
//  JJBadMovieWindowController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieEnvironment.h"
#import "JJBadMovieWindowController.h"
#import "JJBadMoviePlayerViewController.h"
#import "JJBadMovieEpisodesViewController.h"

static inline CGFloat degreesToRadian(CGFloat degree)
{
    return degree * M_PI / 180.0f;
}

@interface JJBadMovieWindowController ()

@property (nonatomic, strong) UIView *downView;
@property (nonatomic, strong) UIImageView *vignetteView;

- (CGImageRef)imageFromLayer:(CALayer *)layer size:(CGSize)size;

- (void)showPlayerControl:(NSNotification *)note;
- (void)presentPlayerControlBarButtonItemForViewController:(UIViewController *)viewController;

@end


@implementation JJBadMovieWindowController

#pragma mark - synth

@synthesize downView = _downView, vignetteView = _vignetteView;
@synthesize navigationController = _navigationController, playerController = _playerController, window = _window;

#pragma mark - lifecycle

- (id)init {
    if (self = [super init]) {
        [[self class] configureAppearance];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[[JJBadMovieEpisodesViewController alloc] initWithStyle:UITableViewStylePlain]];
        [_navigationController setDelegate:self];
        [_navigationController.view setBackgroundColor:[UIColor clearColor]];

        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.window.png"]];
        _window.rootViewController = _navigationController;
        
        _playerController = [[JJBadMoviePlayerViewController alloc] initWithNibName:nil bundle:nil];
        [_playerController.view setBackgroundColor:[UIColor clearColor]];
        [_window addSubview:_playerController.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayerControl:) name:kJJBadMovieNotificationShowPlayerControl object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self presentPlayerControlBarButtonItemForViewController:viewController];
}

#pragma mark - player control

- (void)showPlayerControl:(NSNotification *)note {
    if ([note object]) {
        [self presentPlayerControlBarButtonItemForViewController:[note object]];
    }
}

- (void)presentPlayerControlBarButtonItemForViewController:(UIViewController *)viewController {
    if (self.playerController.currentEpisode) {
        UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(presentAudioPlayer)];
        [viewController.navigationItem setRightBarButtonItem:settingsItem animated:NO];
    }
}

#pragma mark - presentation methods

- (void)presentAudioPlayer {
    CGImageRef image = [self imageFromLayer:self.navigationController.view.layer size:self.navigationController.view.frame.size];
    UIImage *viewImage = [[UIImage alloc] initWithCGImage:image];
    self.downView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
    [imageView setFrame:self.navigationController.view.frame];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.downView addSubview:imageView];
    
    self.vignetteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui.vignette.png"]];
    [self.vignetteView setContentMode:UIViewContentModeScaleAspectFill];
    [self.vignetteView setFrame:(CGRect){{0, 20},imageView.frame.size}];
    [self.vignetteView setAlpha:0.0];
    [self.downView addSubview:self.vignetteView];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideAudioPlayer)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.downView addGestureRecognizer:swipeGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAudioPlayer)];
    [self.downView addGestureRecognizer:tapGesture];
    
    [UIView transitionFromView:self.navigationController.view toView:self.downView duration:0.0 options:UIViewAnimationOptionTransitionNone completion:^(BOOL finished) {
        
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -600.0;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degreesToRadian(40.0), 1.0f, 0.0f, 0.0f);
        
        CATransform3D moveTranslation = CATransform3DMakeTranslation(0, 120.0f, -40.0f);
        CATransform3D imageMatrix = CATransform3DConcat(moveTranslation, rotationAndPerspectiveTransform);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.downView.layer.transform = imageMatrix;
            [self.vignetteView setAlpha:0.8];
        }];
    }];   
}

- (void)hideAudioPlayer {
    [UIView animateWithDuration:0.25 animations:^{
        self.downView.layer.transform = CATransform3DIdentity;
        [self.vignetteView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [UIView transitionFromView:self.downView toView:self.navigationController.view duration:0.0 options:UIViewAnimationOptionTransitionNone completion:nil];     
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

#pragma mark - class methods

+ (void)configureAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ui.navigationbar.background.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:89/255.0 green:0.0 blue:0.0 alpha:1.0]];
}

@end
