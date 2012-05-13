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
    if (! jj_textColor) {
        jj_textColor = [UIColor darkGrayColor];
        jj_selectedTextColor = [UIColor whiteColor];
    }
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    if ([self isSelected] || [self isHighlighted]) {
        [jj_selectedTextColor set];
    } else {
        [jj_textColor set];
    }
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
