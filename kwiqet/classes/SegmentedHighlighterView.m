//
//  SegmentedHighlighterView.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SegmentedHighlighterView.h"

@interface SegmentedHighlighterView()
@property (retain) NSMutableArray * segmentHighlightAmounts;
- (void) drawHighlightAmount:(float)amount atIndex:(int)index inContext:(CGContextRef)context;
- (void) drawHighlightAmount:(float)amount inFrame:(CGRect)frame inContext:(CGContextRef)context;
- (void) initFromFrameOrCoder;
@end

@implementation SegmentedHighlighterView

@synthesize segmentHighlightAmounts;
@synthesize highlightColor;

- (void)dealloc {
    [segmentHighlightAmounts release];
    [highlightColor release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self initFromFrameOrCoder];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self initFromFrameOrCoder];
    }
    return self;
}

- (void) initFromFrameOrCoder {
    self.backgroundColor = [UIColor clearColor];
    self.segmentHighlightAmounts = [NSMutableArray array];
    self.highlightColor = [UIColor redColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    for (int i=0; i<self.numberOfSegments; i++) {
        NSNumber * highlightAmount = (NSNumber *)[self.segmentHighlightAmounts objectAtIndex:i];
        [self drawHighlightAmount:highlightAmount.floatValue atIndex:i inContext:graphicsContext];
    }
    
}

- (void) drawHighlightAmount:(float)amount atIndex:(int)index inContext:(CGContextRef)context {
    CGFloat highlightWidth = self.bounds.size.width / (float)self.numberOfSegments;
    CGRect highlightFrame = CGRectMake(index * highlightWidth, 0, highlightWidth, self.bounds.size.height);
    [self drawHighlightAmount:amount inFrame:highlightFrame inContext:context];
}

- (void) drawHighlightAmount:(float)amount inFrame:(CGRect)frame inContext:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, [[self.highlightColor colorWithAlphaComponent:amount] CGColor]);
    CGContextFillRect(context, frame);
}

- (void) setNumberOfSegments:(int)count {
    [self.segmentHighlightAmounts removeAllObjects];
    for (int i=0; i<count; i++) {
        NSNumber * highlightAmount = [NSNumber numberWithFloat:0.0];
        [self.segmentHighlightAmounts addObject:highlightAmount];
    }
}

- (int) numberOfSegments {
    return [self.segmentHighlightAmounts count];
}

- (void)setHighlightAmount:(float)highlightAmount forSegmentAtIndex:(int)index {
    [self.segmentHighlightAmounts replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:highlightAmount]];
    [self setNeedsDisplay];
}

@end
