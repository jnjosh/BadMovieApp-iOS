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
static CGColorRef jj_shadowColorRef;

const CGSize jj_shadowOffsetSize = (CGSize){0, 1};
const CGRect jj_imageRect = (CGRect){15,15,55,55};
const CGRect jj_imageBorderRect = (CGRect){10,10,65,65};
const CGRect jj_titleTextRect = (CGRect){85,10,205,20};
const CGRect jj_detailTextRect = (CGRect){85,32,205,50};

@interface JJBadMovieEpisodeCell ()

- (void)cleanImageLayer;

@end


@implementation JJBadMovieEpisodeCell

#pragma mark - synth

@synthesize episode = _episode, imageLayer = _imageLayer;

#pragma mark - class

+ (void)initialize {
    if (self == [JJBadMovieEpisodeCell class]) {
        jj_textColor = [UIColor darkGrayColor];
        jj_selectedTextColor = [UIColor whiteColor];
        jj_detailTextColor = [UIColor grayColor];
        jj_titleFont = [UIFont boldSystemFontOfSize:17.0f];
        jj_detailFont = [UIFont systemFontOfSize:11.0f];
        jj_moviePlaceholderImage = [UIImage imageNamed:@"ui.placeholder.png"];
        jj_shadowColorRef = [jj_selectedTextColor CGColor];
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
    
    self.imageLayer = [CALayer layer];
    self.imageLayer.contents = (__bridge id)[[self.episode cachedImage] CGImage];
    self.imageLayer.frame = jj_imageRect;
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
    [jj_moviePlaceholderImage drawInRect:jj_imageBorderRect];
    
    if (! [self isSelected] && ! [self isHighlighted]) {
        CGContextSetShadowWithColor(context, jj_shadowOffsetSize, 0.0, jj_shadowColorRef);
    }

	[jj_textColor set];
    [[self.episode name] drawInRect:jj_titleTextRect withFont:jj_titleFont lineBreakMode:UILineBreakModeTailTruncation];

    [jj_detailTextColor set];
    [[self.episode descriptionText] drawInRect:jj_detailTextRect withFont:jj_detailFont lineBreakMode:UILineBreakModeWordWrap];
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
