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
static UIColor *jj_detailTextColor = nil;
static UIFont *jj_titleFont = nil;
static UIFont *jj_detailFont = nil;

@implementation JJBadMovieEpisodeCell

#pragma mark - synth

@synthesize episode = _episode;

#pragma mark - class

+ (void)initialize {
    if (! jj_textColor && self == [JJBadMovieEpisodeCell class]) {
        jj_textColor = [UIColor darkGrayColor];
        jj_selectedTextColor = [UIColor whiteColor];
        jj_detailTextColor = [UIColor lightGrayColor];
        jj_titleFont = [UIFont boldSystemFontOfSize:17.0f];
        jj_detailFont = [UIFont systemFontOfSize:11.0f];
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
    
    [jj_selectedTextColor set];
    CGContextFillRect(context, (CGRect){10, 10, 65, 65});
    
    UIImage *image = [self.episode cachedImage];
    if (image) {
        [image drawInRect:(CGRect){15, 15, 55, 55}];
    }
    
    [jj_textColor set];
    if ([self isSelected] || [self isHighlighted]) {
        shadowColorRef = jj_textColor.CGColor;
        shadowSize = (CGSize){0, 0};
    } else {
        shadowColorRef = jj_selectedTextColor.CGColor;
        shadowSize = (CGSize){0, 1};
    }
    
    CGRect titleRect = rect;
    titleRect.origin.x += 85;
    titleRect.origin.y += 10;
    titleRect.size.width -= 115;
    titleRect.size.height = 20;
    CGContextSetShadowWithColor(context, shadowSize, 0.0, shadowColorRef);
    [[self.episode name] drawInRect:titleRect withFont:jj_titleFont lineBreakMode:UILineBreakModeTailTruncation];

    CGRect descRect = rect;
    descRect.origin.x += 85;
    descRect.origin.y += 32;
    descRect.size.width -= 115;
    descRect.size.height = 38;
    [jj_detailTextColor set];
    [[self.episode descriptionText] drawInRect:descRect withFont:jj_detailFont lineBreakMode:UILineBreakModeWordWrap];
    
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
