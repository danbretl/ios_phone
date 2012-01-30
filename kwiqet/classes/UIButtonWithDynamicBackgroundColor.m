//
//  UIButtonWithDynamicBackgroundColor.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButtonWithDynamicBackgroundColor.h"

@interface UIButtonWithDynamicBackgroundColor()
- (void) initWithFrameOrCoder;
@property (nonatomic, retain) CALayer * backgroundDynamic;
@end

@implementation UIButtonWithDynamicBackgroundColor

@synthesize backgroundDynamic=backgroundDynamic_;
@synthesize backgroundColorDefault=backgroundColorDefault_;
@synthesize backgroundColorHighlight=backgroundColorHighlight_;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    self.backgroundColor = [UIColor whiteColor];
    self.backgroundColorDefault = self.backgroundColor;
    self.backgroundColorHighlight = self.backgroundColor;
    self.backgroundDynamic = [CALayer layer];
    self.backgroundDynamic.backgroundColor = self.backgroundColorDefault.CGColor;
    self.backgroundDynamic.frame = self.bounds;
    self.backgroundDynamic.contentsGravity = kCAGravityResize;
    [self.layer insertSublayer:self.backgroundDynamic below:self.imageView.layer];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundDynamic.backgroundColor = self.backgroundColorHighlight.CGColor;
//        self.backgroundColor = self.backgroundColorHighlight;
    } else {
        self.backgroundDynamic.backgroundColor = self.backgroundColorDefault.CGColor;
//        self.backgroundColor = self.backgroundColorDefault;
    }
}

- (void)dealloc {
    [backgroundDynamic_ release];
    [backgroundColorDefault_ release];
    [backgroundColorHighlight_ release];
}

@end
