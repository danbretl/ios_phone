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
- (void) initFromFrameOrCoder;
@end

@implementation SegmentedHighlighterView

@synthesize segmentHighlightAmounts;

- (void)dealloc {
    [segmentHighlightAmounts release];
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
    self.backgroundColor = [UIColor blackColor];
    self.segmentHighlightAmounts = [NSMutableArray array];
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
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, amount);
    CGContextFillRect(context, highlightFrame);
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
