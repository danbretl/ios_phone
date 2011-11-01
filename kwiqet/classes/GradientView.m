//
//  GradientView.m
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

@synthesize colorEnd;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
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
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}

@end
