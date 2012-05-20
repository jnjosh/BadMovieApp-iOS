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
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.webview setAutoresizingMask:self.view.autoresizingMask];
    [self.webview setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
    [self.webview setDelegate:self];
    [self.view addSubview:self.webview];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.navigationItem setTitleView:self.activityIndicator];
    
    NSURLRequest *webURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]];
    [self.webview loadRequest:webURLRequest];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.activityIndicator = nil;
    self.webview = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - web view

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.navigationItem setTitleView:nil];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
