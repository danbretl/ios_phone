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
@property (retain) UIButton * buttonPrivate;
@property (retain) UIImageView * overlayPrivate;
@property (retain) UIView * shadowPrivate;
@end

@implementation UIButtonWithOverlayView

@synthesize buttonText=buttonText_, buttonIconImage=buttonIconImage_;
@synthesize buttonPrivate=button_, overlayPrivate=overlay_, shadowPrivate=shadow_;
@synthesize cornerRadius=cornerRadius_;
@synthesize isShadowVisibleWhenButtonNormal, isShadowVisibleWhenButtonHighlighted;

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
    
    self.isShadowVisibleWhenButtonNormal = YES;
    self.isShadowVisibleWhenButtonHighlighted = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.buttonPrivate = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    self.buttonPrivate.frame = self.bounds;
    self.buttonPrivate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.buttonPrivate addTarget:self action:@selector(buttonTouchEvent) forControlEvents:UIControlEventAllTouchEvents];
    [self.buttonPrivate addTarget:self action:@selector(buttonTouchEnded) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    UIColor * darkTextColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
    UIColor * lightTextColor = [UIColor colorWithWhite:251.0/255.0 alpha:1.0];
    [self.buttonPrivate setTitleColor:darkTextColor forState:UIControlStateNormal];
    [self.buttonPrivate setTitleColor:darkTextColor forState:UIControlStateHighlighted];
    [self.buttonPrivate setTitleColor:lightTextColor forState:UIControlStateSelected];
    self.buttonPrivate.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:18.0];
    self.buttonPrivate.titleEdgeInsets = UIEdgeInsetsMake(10.0, 0, 0, 0);
    [self addSubview:self.buttonPrivate];
    
    overlay_ = [[UIImageView alloc] initWithFrame:self.bounds];
    self.overlayPrivate.userInteractionEnabled = NO;
    [self insertSubview:self.overlayPrivate aboveSubview:self.buttonPrivate];
    
    shadow_ = [[UIView alloc] initWithFrame:self.bounds];
    self.shadowPrivate.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowPrivate.layer.shadowOffset = CGSizeMake(0, 1.0);
    self.shadowPrivate.layer.shadowOpacity = 0.5;
    self.shadowPrivate.layer.shadowRadius = 1.0;
    self.shadowPrivate.layer.shouldRasterize = YES;
    [self insertSubview:self.shadowPrivate belowSubview:self.buttonPrivate];
    
    self.cornerRadius = 0.0;
    
}

- (UIButton *) button  { return self.buttonPrivate;  }
- (UIView *)   overlay { return self.overlayPrivate; }
- (UIView *)   shadow  { return self.shadowPrivate;  }

- (void) setButtonText:(NSString *)buttonText {
    if (buttonText_ != buttonText) {
        [buttonText_ release];
        buttonText_ = [buttonText copy];
        [self.buttonPrivate setTitle:self.buttonText forState:UIControlStateNormal];
        [self.buttonPrivate setTitle:self.buttonText forState:UIControlStateHighlighted];
        [self.buttonPrivate setTitle:self.buttonText forState:UIControlStateSelected];
    }
}

- (void) setButtonIconImage:(UIImage *)buttonIconImage {
    if (buttonIconImage_ != buttonIconImage) {
        [buttonIconImage_ release];
        buttonIconImage_ = [buttonIconImage retain];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateNormal];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateHighlighted];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateSelected];
        UIControlContentHorizontalAlignment buttonHorizontalAlignment;
        UIEdgeInsets titleInsets = self.buttonPrivate.titleEdgeInsets;
        if (buttonIconImage != nil) {
            buttonHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            CGFloat imageLeftInset = 10 + (30.0 - buttonIconImage.size.width) / 2.0;
            self.buttonPrivate.imageEdgeInsets = UIEdgeInsetsMake(0, imageLeftInset, 0, 0);
            titleInsets.left = 80.0 - (imageLeftInset + buttonIconImage.size.width + buttonIconImage.size.width / 2.0);
        } else {
            buttonHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            titleInsets.left = 0;
        }
        self.buttonPrivate.contentHorizontalAlignment = buttonHorizontalAlignment;
        self.buttonPrivate.titleEdgeInsets = titleInsets;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    cornerRadius_ = cornerRadius;
    self.shadowPrivate.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius].CGPath;
}

- (void)buttonTouchEvent {
    if (self.button.highlighted) {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonHighlighted ? 0.5 : 0.0;
    } else {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 0.5 : 0.0;
    }
}

- (void) buttonTouchEnded {
    self.shadowPrivate.layer.shadowOpacity = 0.5;
}

- (void)dealloc {
    [buttonText_ release];
    [buttonIconImage_ release];
    [button_ release];
    [overlay_ release];
    [shadow_ release];
    [super dealloc];
}

@end
