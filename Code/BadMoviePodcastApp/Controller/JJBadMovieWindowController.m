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
#import "JJBadMovieViewController.h"
#import "JJBadMovieEpisodesViewController.h"
#import "JJBadMovieEpisodeDataSource.h"
#import "JJBadMovieRootViewController.h"
#import "JJBadMovie.h"
#import "SDURLCache.h"
#import "MBProgressHUD.h"

static inline CGFloat degreesToRadian(CGFloat degree)
{
    return degree * M_PI / 180.0f;
}

@interface JJBadMovieWindowController ()

@property (nonatomic, strong) JJBadMovieRootViewController *rootViewController;
@property (nonatomic, strong) UIBarButtonItem *nowPlayingButton;
@property (nonatomic, strong) UIView *downView;
@property (nonatomic, strong) UIImageView *vignetteView;

- (CGImageRef)imageFromLayer:(CALayer *)layer size:(CGSize)size;

- (void)showPlayerControl:(NSNotification *)note;
- (void)presentNowPlayingEpisodeView:(UIImageView *)episodeView forViewController:(UIViewController *)viewController;
- (void)displayNotification:(NSNotification *)notification;

@end

@implementation JJBadMovieWindowController

#pragma mark - lifecycle

- (id)init {
    if (self = [super init]) {
        [[self class] configureAppearance];
        [[self class] configureCache];
        
        JJBadMovieEpisodeDataSource *dataSource = [[JJBadMovieEpisodeDataSource alloc] init];
        JJBadMovieEpisodesViewController *episodeViewController = [[JJBadMovieEpisodesViewController alloc] initWithEpisodeDataSource:dataSource];
        _playerController = [[JJBadMoviePlayerViewController alloc] initWithNibName:nil bundle:nil];
        
        _navigationController = [[UINavigationController alloc] initWithRootViewController:episodeViewController];
        [_navigationController setDelegate:self];
        [_navigationController.view setBackgroundColor:[UIColor clearColor]];
        
        _rootViewController = [[JJBadMovieRootViewController alloc] initWithNibName:nil bundle:nil];
        [_rootViewController addChildViewController:_playerController];
        [_rootViewController addChildViewController:_navigationController];
        
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.rootViewController = _rootViewController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPlayerControl:) name:kJJBadMovieNotificationShowPlayerControl object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAudioPlayer) name:kJJBadMovieNotificationShowPlayer object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNotification:) name:kJJBadMovieNotificationGlobalNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification

- (void)displayNotification:(NSNotification *)notification
{
	NSString *message = [notification object];
	if (message) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
		[hud setMode:MBProgressHUDModeText];
		[hud setLabelText:message];
		[hud hide:YES afterDelay:2.0];
	}
}

#pragma mark - navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self presentNowPlayingEpisodeView:nil forViewController:viewController];
    [self.playerController setDelegate:nil];
    
    if ([viewController isKindOfClass:[JJBadMovieViewController class]]) {
        JJBadMovieViewController *badMovieViewController = (JJBadMovieViewController *)viewController;
        [badMovieViewController setCurrentMovie:NO];
        
        if ([[badMovieViewController movie] isEqual:self.playerController.currentEpisode]) {
            [badMovieViewController setCurrentMovie:YES];
            [badMovieViewController configureForPlayState:self.playerController.playerState];
            [self.playerController setDelegate:badMovieViewController];
        }
        
        [badMovieViewController setPlayerController:self.playerController];
    }
}

#pragma mark - player control

- (void)showPlayerControl:(NSNotification *)note {
    UIViewController *viewController = [note object];
    if (viewController) {
        UIImageView *imageViewForAnimation = [[UIImageView alloc] initWithImage:[[note userInfo] objectForKey:@"episodeImage"]];
        [imageViewForAnimation setContentMode:UIViewContentModeScaleAspectFit];
        CGRect originRect = [[[note userInfo] objectForKey:@"episodeImageFrame"] CGRectValue];
        CGPoint imagePoint = originRect.origin;
        
        CGPoint viewPoint = [self.navigationController.view convertPoint:imagePoint fromView:viewController.view];
        [imageViewForAnimation setFrame:(CGRect){viewPoint, originRect.size}];
        CGRect targetRect = (CGRect){ 300, 44, 30, 30 };

        CGRect imageFrame = imageViewForAnimation.frame;
        CGPoint viewOrigin = imageFrame.origin;
        viewOrigin.y = viewOrigin.y + imageFrame.size.height / 2.0f;
        viewOrigin.x = viewOrigin.x + imageFrame.size.width / 2.0f;
        
        imageViewForAnimation.frame = imageFrame;
        imageViewForAnimation.layer.position = viewOrigin;
        [self.navigationController.view addSubview:imageViewForAnimation];

        // Set up fade out effect
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fadeOutAnimation setToValue:[NSNumber numberWithFloat:0.3]];
        fadeOutAnimation.fillMode = kCAFillModeForwards;
        fadeOutAnimation.removedOnCompletion = NO;
        
        // Set up scaling
        CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
        [resizeAnimation setToValue:[NSValue valueWithCGSize:targetRect.size]];
        resizeAnimation.fillMode = kCAFillModeForwards;
        resizeAnimation.removedOnCompletion = NO;
        
        // Set up path movement
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        pathAnimation.calculationMode = kCAAnimationPaced;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        
        CGPoint endPoint = targetRect.origin;
        CGMutablePathRef curvedPath = CGPathCreateMutable();
        CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
        CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, viewOrigin.y + 200, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
        pathAnimation.path = curvedPath;
        CGPathRelease(curvedPath);
        
        CAAnimationGroup *group = [CAAnimationGroup animation]; 
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, resizeAnimation, nil]];
        [group setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        group.duration = 0.33f;
        group.delegate = self;
        [group setValue:imageViewForAnimation forKey:@"imageViewBeingAnimated"];
        [group setValue:viewController forKey:@"imageViewWillReplaceViewController"];
        
        [imageViewForAnimation.layer addAnimation:group forKey:@"savingAnimation"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        UIImageView *imageView = [anim valueForKey:@"imageViewBeingAnimated"];
        UIViewController *viewController = [anim valueForKey:@"imageViewWillReplaceViewController"];
        [self presentNowPlayingEpisodeView:imageView forViewController:viewController];
        [self.playerController setDelegate:(JJBadMovieViewController *)viewController];
    }
}

- (void)presentNowPlayingEpisodeView:(UIImageView *)episodeView forViewController:(UIViewController *)viewController {
    if (self.playerController.currentEpisode) {
        if (episodeView) {
            UIImage *episodeImage = [episodeView image];
            [episodeView removeFromSuperview];
            UIImage *playOverlay = [UIImage imageNamed:@"ui.nowplaying.png"];
            UIImage *playOverlayHighlighted = [UIImage imageNamed:@"ui.nowplaying.highlighted.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:playOverlay forState:UIControlStateNormal];
            [button setImage:playOverlayHighlighted forState:UIControlStateHighlighted];
            [button setBackgroundImage:episodeImage forState:UIControlStateNormal];
            [button setBackgroundImage:episodeImage forState:UIControlStateHighlighted];
            [button setFrame:(CGRect){CGPointZero, {30, 30}}];
            [button addTarget:self action:@selector(presentAudioPlayer) forControlEvents:UIControlEventTouchUpInside];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderColor:[UIColor blackColor].CGColor];
            [button.layer setBorderWidth:0.5];
            [button.layer setCornerRadius:4.0];
            self.nowPlayingButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
        [viewController.navigationItem setRightBarButtonItem:self.nowPlayingButton animated:NO];
    } else {
        [episodeView removeFromSuperview];
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
    [self.vignetteView setFrame:(CGRect){{0, 10},imageView.frame.size}];
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
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.25 animations:^{
            self.downView.layer.transform = imageMatrix;
            [self.vignetteView setAlpha:0.8];
        }];
    }];   
}

- (void)hideAudioPlayer {
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
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
    static dispatch_once_t appearanceOnceToken;
    dispatch_once(&appearanceOnceToken, ^{
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ui.navigationbar.background.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ui.navigationbar.landscape.background.png"] forBarMetrics:UIBarMetricsLandscapePhone];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:89/255.0 green:0.0 blue:0.0 alpha:1.0]];
    });
}

+ (void)configureCache {
    static dispatch_once_t cacheOnceToken;
    dispatch_once(&cacheOnceToken, ^{
        SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:[SDURLCache defaultCachePath]];
        [urlCache setMinCacheInterval:0];
        [NSURLCache setSharedURLCache:urlCache];
    });
}

@end
