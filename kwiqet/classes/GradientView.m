//
//  GradientView.m
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "GradientView.h"

@interface GradientView()
- (void) initWithFrameOrCoder;
@end

@implementation GradientView

@synthesize colorEnd;
@synthesize endX=endX_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
        self.colorEnd = self.backgroundColor;
		[self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.endX = self.frame.size.width;
}

- (void)dealloc
{
    [colorEnd release];
    [super dealloc];
}

- (void)setColorEnd:(UIColor *)theColor {
    if (colorEnd != theColor) {
//        NSLog(@"GradientView setColor:%@", theColor);
        [colorEnd release];
        colorEnd = [theColor retain];
        [self setNeedsDisplay];
    }
}

- (void)setEndX:(CGFloat)endX {
    endX_ = endX;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    NSLog(@"drawrect");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    CGColorRef startColor = [self.colorEnd colorWithAlphaComponent:0.0].CGColor;
    CGColorRef endColor = self.colorEnd.CGColor;
    
    NSArray * colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(self.endX, CGRectGetMidY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}

@end
