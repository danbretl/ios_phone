//
//  SegmentedHighlighterView.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SegmentedHighlighterView.h"

@interface SegmentedHighlighterView()
- (void) drawHighlightAmount:(float)amount atIndex:(int)index inContext:(CGContextRef)context;
- (void) drawHighlightAmount:(float)amount inFrame:(CGRect)frame inContext:(CGContextRef)context;
- (void) initFromFrameOrCoder;
- (CGRect) frameForSegmentIndex:(int)index;
@end

@implementation SegmentedHighlighterView

@synthesize numberOfSegments=numberOfSegments_, highlightColor;

- (void)dealloc {
    [highlightColor release];
    free(highlightAmounts);
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
    self.highlightColor = [UIColor redColor];
    self.numberOfSegments = 2;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    for (int i=0; i<self.numberOfSegments; i++) {
        float highlightAmount = highlightAmounts[i];
        [self drawHighlightAmount:highlightAmount atIndex:i inContext:graphicsContext];
    }
    
}

- (void) drawHighlightAmount:(float)amount atIndex:(int)index inContext:(CGContextRef)context {
    [self drawHighlightAmount:amount inFrame:[self frameForSegmentIndex:index] inContext:context];
}

- (void) drawHighlightAmount:(float)amount inFrame:(CGRect)frame inContext:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, [[self.highlightColor colorWithAlphaComponent:amount] CGColor]);
    CGContextFillRect(context, frame);
}

- (void)setNumberOfSegments:(int)numberOfSegments {
    if (numberOfSegments_ != numberOfSegments) {
        numberOfSegments_ = numberOfSegments;
        free(highlightAmounts);
        highlightAmounts = malloc(sizeof(float)*self.numberOfSegments);
    }
}

- (void)setHighlightAmount:(float)highlightAmount forSegmentAtIndex:(int)index {
    if (highlightAmounts[index] != highlightAmount) {
        highlightAmounts[index] = highlightAmount;
        [self setNeedsDisplayInRect:[self frameForSegmentIndex:index]];
    }
}

- (CGRect) frameForSegmentIndex:(int)index {
    CGFloat segmentWidth = self.bounds.size.width / (float)self.numberOfSegments;
    CGRect segmentFrame = CGRectMake(index * segmentWidth, 
                                     0, 
                                     segmentWidth, 
                                     self.bounds.size.height);
    return segmentFrame;
}

@end
