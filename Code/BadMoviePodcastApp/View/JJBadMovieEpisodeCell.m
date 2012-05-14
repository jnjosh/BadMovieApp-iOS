//
//  JJBadMovieEpisodeCell.m
//  BadMoviePodcastApp
//
//  Created by Joshua Johnson on 5/13/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJBadMovieEpisodeCell.h"
#import "JJBadMovie.h"

static UIColor *jj_textColor = nil;
static UIColor *jj_selectedTextColor = nil;

@implementation JJBadMovieEpisodeCell

#pragma mark - synth

@synthesize episode = _episode;

#pragma mark - class

+ (void)initialize {
    if (! jj_textColor && self == [JJBadMovieEpisodeCell class]) {
        jj_textColor = [UIColor darkGrayColor];
        jj_selectedTextColor = [UIColor whiteColor];
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

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef shadowColorRef;
    CGSize shadowSize;
    
    [jj_textColor set];
    if ([self isSelected] || [self isHighlighted]) {
        shadowColorRef = jj_textColor.CGColor;
        shadowSize = (CGSize){0, 0};
    } else {
        shadowColorRef = jj_selectedTextColor.CGColor;
        shadowSize = (CGSize){0, 1};
    }
    
    CGContextSetShadowWithColor(context, shadowSize, 0.0, shadowColorRef);
    [[self.episode name] drawInRect:rect withFont:[UIFont boldSystemFontOfSize:16]];
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setNeedsDisplay];
}

@end
