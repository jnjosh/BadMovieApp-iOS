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
@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, copy) NSString *webFile;

@end

@implementation JJBadMovieWebViewController

#pragma mark - synth

@synthesize webURL = _webURL, webFile = _webFile;
@synthesize activityIndicator = _activityIndicator, webview = _webview;

#pragma mark - lifecycle

- (id)initWithLocalHTML:(NSString *)localHTML {
    if (self = [self initWithNibName:nil bundle:nil]) {
        _webFile = [localHTML copy];
    }
    return self;
}

- (id)initWithURL:(NSString *)webURL {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.webURL = webURL;
    }
    return self;
}

#pragma mark - view

- (void)loadView 
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    [self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webview = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.webview setAutoresizingMask:self.view.autoresizingMask];
    [self.webview setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
    [self.webview setDelegate:self];
    [self.view addSubview:self.webview];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.navigationItem setTitleView:self.activityIndicator];
    
    if (self.webURL) {
        NSURLRequest *webURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]];
        [self.webview loadRequest:webURLRequest];
    } else if (self.webFile) {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:self.webFile ofType:@"html" inDirectory:nil];
        NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];   
        [self.webview loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.activityIndicator = nil;
    self.webview = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - web view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.webFile) {
        [[UIApplication sharedApplication] openURL:request.URL];   
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.navigationItem setTitleView:nil];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
