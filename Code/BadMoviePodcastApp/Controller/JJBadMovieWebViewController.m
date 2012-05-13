//
//  JJBadMovieWebViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/9/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieWebViewController.h"

@interface JJBadMovieWebViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, assign) BOOL isYoutube;
@property (nonatomic, copy) NSString *webURL;

@end

@implementation JJBadMovieWebViewController

#pragma mark - synth

@synthesize isYoutube = _isYoutube;
@synthesize webURL = _webURL;
@synthesize activityIndicator = _activityIndicator, webview = _webview;

#pragma mark - lifecycle

- (id)initWithYouTubeVideo:(NSString *)youtubeVideoString {
    if (self = [self initWithNibName:nil bundle:nil]) {
        _isYoutube = YES;
        self.webURL = youtubeVideoString;
    }
    return self;
}

- (id)initWithIMDBUrl:(NSString *)imdbUrl {
    if (self = [self initWithNibName:nil bundle:nil]) {
        _isYoutube = NO;
        self.webURL = imdbUrl;
    }
    return self;
}

#pragma mark - view

- (void)loadView 
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    [self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicator];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.webview setAutoresizingMask:self.view.autoresizingMask];
    [self.webview setDelegate:self];
    [self.view addSubview:self.webview];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.activityIndicator = nil;
    self.webview = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webview setHidden:YES];
    
    self.activityIndicator.center = self.view.center;
    [self.activityIndicator startAnimating];
    
    if (! [self isYoutube]) {
        NSURLRequest *imdbURL = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]];
        [self.webview loadRequest:imdbURL];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - web view

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.webview setHidden:NO];
    
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}


@end
