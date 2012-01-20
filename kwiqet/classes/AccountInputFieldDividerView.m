//
//  AccountInputFieldDividerView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountInputFieldDividerView.h"

@implementation AccountInputFieldDividerView

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat halfHeightFloored = floorf(rect.size.height / 2.0);
    CGFloat theRest = rect.size.height - halfHeightFloored;
    CGContextAddRect(context, CGRectMake(0, 0, rect.size.width, halfHeightFloored));
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:186.0/255.0 alpha:1.0].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    CGContextBeginPath(context);
    CGContextAddRect(context, CGRectMake(0, halfHeightFloored, rect.size.width, theRest));
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:252.0/255.0 alpha:1.0].CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

@end
