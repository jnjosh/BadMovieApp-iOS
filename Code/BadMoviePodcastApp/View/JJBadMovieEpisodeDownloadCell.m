//
//  JJBadMovieEpisodeDownloadCell.m
//  BadMoviePodcastApp
//
//  Created by Josh Johnson on 8/26/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieEpisodeDownloadCell.h"
#import "JJBadMovie.h"
#import "JJBadMovieDownloadObserver.h"
#import "JJBAdMovieDownloadManager.h"

@interface JJBadMovieEpisodeDownloadCell () <JJBadMovieDownloadObserver>

@property (nonatomic, strong) UILabel *downloadingLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *downloadProgressLabel;

- (void)cancelDownload;

@end

@implementation JJBadMovieEpisodeDownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[_progressView setFrame:(CGRect){10.0f, 36.0f, 220.0f, self.progressView.frame.size.height }];
		[_progressView setTrackTintColor:[UIColor darkGrayColor]];
		[self.contentView addSubview:_progressView];

		_downloadingLabel = [[UILabel alloc] initWithFrame:(CGRect) { 10.0f, 8.0f, 220.0f, 32.0f }];
		[_downloadingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
		[_downloadingLabel setTextColor:[UIColor grayColor]];
		[_downloadingLabel setShadowColor:[UIColor whiteColor]];
		[_downloadingLabel setShadowOffset:(CGSize){ 0, 1 }];
		[_downloadingLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:_downloadingLabel];
		
		_downloadProgressLabel = [[UILabel alloc] initWithFrame:(CGRect) { 240.0f, 31.0f, 40.0f, 20.0f }];
		[_downloadProgressLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
		[_downloadProgressLabel setTextColor:[UIColor grayColor]];
		[_downloadProgressLabel setShadowColor:[UIColor whiteColor]];
		[_downloadProgressLabel setShadowOffset:(CGSize){ 0, 1 }];
		[_downloadProgressLabel setBackgroundColor:[UIColor clearColor]];
		[_downloadProgressLabel setText:@"0%"];
		[self.contentView addSubview:_downloadProgressLabel];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[cancelButton setTitle:@"X" forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
		[cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[[cancelButton titleLabel] setShadowOffset:(CGSize){ 0, 1 }];
		[[cancelButton titleLabel] setFont:[UIFont fontWithName:@"GillSans-Bold" size:16.0f]];
		[[cancelButton titleLabel] setTextAlignment:UITextAlignmentCenter];
		[cancelButton setFrame:(CGRect){ 275.0f, 13.0f, 44.0f, 44.0f }];
		[self.contentView addSubview:cancelButton];
		
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

#pragma mark - properties

- (void)setEpisode:(JJBadMovie *)episode
{
	if (_episode) {
		[[JJBadMovieDownloadManager sharedManager] removeDownloadObserver:self];
		_episode = nil;
	}
	
	_episode = episode;
	if ([_episode latestDownloadProgress] > 0) {
		[self.progressView setProgress:[_episode latestDownloadProgress]];
		[self.downloadProgressLabel setText:[NSString stringWithFormat:@"%i%%", (int)floorl([_episode latestDownloadProgress] * 100.0f)]];
	} else {
		[self.progressView setProgress:0];
		[self.downloadProgressLabel setText:@"0%"];
	}
	[self.downloadingLabel setText:[NSString stringWithFormat:@"#%@ - %@", [_episode.number stringValue], _episode.name]];
	[[JJBadMovieDownloadManager sharedManager] addDownloadObserver:self forMovie:_episode];
}

#pragma mark - Actions

- (void)cancelDownload
{
	[[JJBadMovieDownloadManager sharedManager] cancelDownloadingEpisodeForMovie:self.episode];
	[self.episode setLatestDownloadProgress:0];
}

#pragma mark - Observer

- (void)movieDownloadDidProgress:(NSNumber *)progress total:(NSNumber *)total
{
	float progressPosition = ([progress floatValue] / [total floatValue]);
	[self.episode setLatestDownloadProgress:progressPosition];
	[self.progressView setProgress:progressPosition];
	[self.downloadProgressLabel setText:[NSString stringWithFormat:@"%i%%", (int)floorl(progressPosition * 100.0f)]];
}

- (void)movieDidFinishDownloadingEpisode:(JJBadMovie *)badmovie
{
	[badmovie setLatestDownloadProgress:0];
}

@end
