//
//  VenueTableView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueTableView.h"

@interface VenueTableView()
- (BOOL) hitTestForSubview:(UIView *)subview forPoint:(CGPoint)point withEvent:(UIEvent *)event;
@end

@implementation VenueTableView

@synthesize titleBarForHitTest, infoContainerForHitTest, eventsHeaderContainerForHitTest;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"VenueTableView hitTest:%@ withEvent:%@", NSStringFromCGPoint(point), event);
    UIView * result = nil;
    if ([self hitTestForSubview:self.titleBarForHitTest forPoint:point withEvent:event]) {
        result = self.titleBarForHitTest;
    } else if ([self hitTestForSubview:self.infoContainerForHitTest forPoint:point withEvent:event]) {
        result = self.infoContainerForHitTest;
    } else if ([self hitTestForSubview:self.eventsHeaderContainerForHitTest forPoint:point withEvent:event]) {
        result = self.eventsHeaderContainerForHitTest;
    }
    if (result == nil) {
        result = [super hitTest:point withEvent:event];
    }
    NSLog(@"result view is %@", result);
    return result;
}

- (BOOL) hitTestForSubview:(UIView *)subview forPoint:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL hit = NO;
    if (subview != nil) {
        CGPoint pointInSubview = [subview convertPoint:point fromView:self];
        hit = [subview pointInside:pointInSubview withEvent:event];        
    }
    return hit;
}

@end
