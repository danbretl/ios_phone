//
//  UIButtonWithOverlayView.m
//  kwiqet
//
//  Created by Dan Bretl on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIButtonWithOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@interface UIButtonWithOverlayView()
- (void) initWithFrameOrCoder;
- (void) buttonTouchEvent;
- (void) buttonTouchEnded;
//@property CGRect frameOriginal;
//@property CGRect frameOffset;
@end

@implementation UIButtonWithOverlayView

@synthesize button, overlay;
@synthesize cornerRadius=cornerRadius_;
@synthesize isShadowVisibleWhenButtonNormal, isShadowVisibleWhenButtonHighlighted;
//@synthesize touchDownPositionOffset=touchDownPositionOffset_;
//@synthesize frameOriginal, frameOffset;

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
		[self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.button addTarget:self action:@selector(buttonTouchEvent) forControlEvents:UIControlEventAllTouchEvents];
    [self.button addTarget:self action:@selector(buttonTouchEnded) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addSubview:self.button];
    overlay = [[UIView alloc] initWithFrame:self.bounds];
    self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlay.userInteractionEnabled = NO;
    [self insertSubview:self.overlay aboveSubview:self.button];
    
//    touchDownPositionOffset_ = CGSizeMake(0, 0);
//    self.frameOriginal = self.frame;
//    self.frameOffset = self.frame;
    
    self.button.layer.masksToBounds = YES;
    
    self.isShadowVisibleWhenButtonNormal = YES;
    self.isShadowVisibleWhenButtonHighlighted = NO;
    self.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 1.0 : 0.0;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowRadius = 1.0;
    self.cornerRadius = 0.0;
    
    self.backgroundColor = [UIColor clearColor];
    self.button.backgroundColor = [UIColor clearColor];
    self.overlay.backgroundColor = [UIColor clearColor];
    
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
        
    cornerRadius_ = cornerRadius;
    self.button.layer.cornerRadius = self.cornerRadius;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius] CGPath];
    
}

//- (void)setTouchDownPositionOffset:(CGSize)touchDownPositionOffset {
//    if (!CGSizeEqualToSize(self.touchDownPositionOffset, touchDownPositionOffset)) {
//        touchDownPositionOffset_ = touchDownPositionOffset;
//        self.frameOffset = CGRectMake(self.frameOriginal.origin.x + self.touchDownPositionOffset.width, self.frameOriginal.origin.y + self.touchDownPositionOffset.height, self.frameOriginal.size.width, self.frameOriginal.size.height);
//    }
//}

- (void)buttonTouchEvent {
    if (self.button.highlighted) {
        self.layer.shadowOpacity = self.isShadowVisibleWhenButtonHighlighted ? 1.0 : 0.0;
    } else {
        self.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 1.0 : 0.0;
    }
}

- (void) buttonTouchEnded {
    self.layer.shadowOpacity = 1.0;
}

- (void)dealloc {
    [button release];
    [overlay release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
