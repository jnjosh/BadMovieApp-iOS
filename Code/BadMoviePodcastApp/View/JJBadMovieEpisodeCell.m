//
//  JJBadMovieEpisodeCell.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/13/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JJBadMovieEpisodeCell.h"
#import "JJBadMovie.h"

static UIColor *jj_textColor = nil;
static UIColor *jj_selectedTextColor = nil;
static UIColor *jj_detailTextColor = nil;
static UIFont *jj_titleFont = nil;
static UIFont *jj_detailFont = nil;
static UIImage *jj_moviePlaceholderImage = nil;
static UIImage *jj_movieDownloadedImage = nil;
static CGColorRef jj_shadowColorRef;
static UIColor * jj_downloadedColor;

static const CGSize jj_shadowOffsetSize = (CGSize){0, 1};
static const CGRect jj_imageRect = (CGRect){15,15,55,55};
static const CGRect jj_imageBorderRect = (CGRect){10,10,65,65};
static const CGRect jj_titleTextRect = (CGRect){85,10,205,20};
static const CGRect jj_detailTextRect = (CGRect){85,32,205,50};

static const CGRect jj_downloadedRect = (CGRect){12,34,20,20};
static const CGRect jj_downloaded_imageRect = (CGRect){45,15,55,55};
static const CGRect jj_downloaded_imageBorderRect = (CGRect){40,10,65,65};
static const CGRect jj_downloaded_titleTextRect = (CGRect){115,10,180,20};
static const CGRect jj_downloaded_detailTextRect = (CGRect){115,32,180,50};

@interface JJBadMovieEpisodeCell ()

@property (nonatomic, strong) CALayer *downloadedLayer;

- (void)cleanImageLayer;

@end

@implementation JJBadMovieEpisodeCell

#pragma mark - class

+ (void)initialize {
    if (self == [JJBadMovieEpisodeCell class]) {
        jj_textColor = [UIColor darkGrayColor];
        jj_selectedTextColor = [UIColor whiteColor];
        jj_detailTextColor = [UIColor grayColor];
        jj_titleFont = [UIFont boldSystemFontOfSize:17.0f];
        jj_detailFont = [UIFont systemFontOfSize:11.0f];
        jj_moviePlaceholderImage = [UIImage imageNamed:@"ui.placeholder.png"];
		jj_movieDownloadedImage = [UIImage imageNamed:@"ui-downloaded.png"];
        jj_shadowColorRef = [jj_selectedTextColor CGColor];
		jj_downloadedColor = [UIColor colorWithRed:133/255.0f green:0 blue:0 alpha:1.0];
    }
}

#pragma mark - lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

#pragma mark - draw

- (void)cleanImageLayer {
    if (self.imageLayer) {
        [self.imageLayer removeFromSuperlayer];
        self.imageLayer = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (! [self.episode cachedImage]) {
        [self cleanImageLayer];
        return;
    }
    
    BOOL animateImage = YES;
    if (self.imageLayer) {
        animateImage = NO;
        [self cleanImageLayer];
    }
	
	CGRect imageRect = jj_downloaded_imageRect;
    self.imageLayer = [CALayer layer];
    self.imageLayer.contents = (__bridge id)[[self.episode cachedImage] CGImage];
    self.imageLayer.frame = imageRect;
    self.imageLayer.opaque = NO;
    self.imageLayer.opacity = animateImage ? 0.0 : 1.0;
    
    if (animateImage) {
        CABasicAnimation *layerShow = [CABasicAnimation animation];
        [layerShow setKeyPath:@"opacity"];
        [layerShow setFromValue:[NSNumber numberWithFloat:0.0]];
        [layerShow setToValue:[NSNumber numberWithFloat:1.0]];
        [layerShow setDuration:0.33];
        [layerShow setRemovedOnCompletion:NO];
        [layerShow setAutoreverses:NO];
        [layerShow setFillMode:kCAFillModeForwards];
        [self.imageLayer addAnimation:layerShow forKey:@"showLayer"];
    }
    
    [self.layer addSublayer:self.imageLayer];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

	BOOL hasDownloaded = [self.episode hasDownloaded];
	CGRect imageBorderRect = jj_downloaded_imageBorderRect;
	CGRect titleTextRect = jj_downloaded_titleTextRect;
	CGRect detailTextRect = jj_downloaded_detailTextRect;
	
	if (hasDownloaded) {
		[jj_movieDownloadedImage drawInRect:jj_downloadedRect];
	} else {
		[jj_movieDownloadedImage drawInRect:jj_downloadedRect blendMode:kCGBlendModeNormal alpha:0.1];
	}
	
    [jj_moviePlaceholderImage drawInRect:imageBorderRect];
    
    if (! [self isSelected] && ! [self isHighlighted]) {
        CGContextSetShadowWithColor(context, jj_shadowOffsetSize, 0.0, jj_shadowColorRef);
    }

	if (hasDownloaded) {
		[jj_downloadedColor set];
	} else {
		[jj_textColor set];
	}
	[[self.episode name] drawInRect:titleTextRect withFont:jj_titleFont lineBreakMode:UILineBreakModeTailTruncation];
    
	[jj_detailTextColor set];
    [[self.episode descriptionText] drawInRect:detailTextRect withFont:jj_detailFont lineBreakMode:UILineBreakModeWordWrap];
}

#pragma mark - properties

- (void)setEpisode:(JJBadMovie *)episode {
    if (! [_episode isEqual:episode]) {
        _episode = episode;
        [self setNeedsDisplay];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated 
{
    [super setHighlighted:highlighted animated:animated];
    [self setNeedsDisplay];
}

@end
