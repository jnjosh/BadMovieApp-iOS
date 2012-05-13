//
//  JJBadMovieSettingsViewController.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/12/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieSettingsViewController.h"

@interface JJBadMovieSettingsViewController ()

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSArray *settings;

- (void)closeSettings;

@end

@implementation JJBadMovieSettingsViewController

@synthesize footerView = _footerView;
@synthesize settings = _settings;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        _settings = [NSArray arrayWithObjects:@"Push Notifications", @"Follow @BadMoviePodcast", @"About Bad Movie Podcast App", nil];
    }
    return self;
}

- (void)closeSettings {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ui.tableview.background.png"]]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeSettings)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    self.footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
    [self.footerView setAutoresizesSubviews:YES];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:self.footerView.bounds];
    [footerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [footerLabel setNumberOfLines:2];
    [footerLabel setText:@"Bad Movie Podcast App 1.0 (100)\nDesigned and Developed by Josh Johnson"];
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [footerLabel setTextColor:[UIColor grayColor]];
    [footerLabel setShadowColor:[UIColor whiteColor]];
    [footerLabel setShadowOffset:(CGSize){0,1}];
    [footerLabel setTextAlignment:UITextAlignmentCenter];
    [footerLabel setBackgroundColor:[UIColor clearColor]];
    [self.footerView addSubview:footerLabel];
    
    [self.tableView setTableFooterView:self.footerView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.footerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    cell.textLabel.text = [self.settings objectAtIndex:indexPath.section];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
