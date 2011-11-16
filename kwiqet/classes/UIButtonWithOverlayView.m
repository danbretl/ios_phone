//
//  UIButtonWithOverlayView.m
//  kwiqet
//
//  Created by Dan Bretl on 8/3/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "UIButtonWithOverlayView.h"
#import <QuartzCore/QuartzCore.h>

#define CLOCK_WISE 1
#define COUNTERCLOCK_WISE -1

float const UIBUTTON_WITH_OVERLAY_VIEW_DISABLED_ALPHA = 0.25;

@interface UIButtonWithOverlayView()
- (void) initWithFrameOrCoder;
- (void) buttonTouchEvent;
- (void) buttonTouchEnded;
- (void) guessAndSetAppropriateTitleAndImageInsetsAndAlignment;
@property (retain) UIButton * buttonPrivate;
@property (retain) UIImageView * overlayPrivate;
@property (retain) UIView * shadowPrivate;
//- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction;
@end

@implementation UIButtonWithOverlayView

@synthesize buttonText=buttonText_, buttonIconImage=buttonIconImage_;
@synthesize buttonPrivate=button_, overlayPrivate=overlay_, shadowPrivate=shadow_;
@synthesize cornerRadius=cornerRadius_;
@synthesize isShadowVisibleWhenButtonNormal=isShadowVisibleWhenButtonNormal_, isShadowVisibleWhenButtonHighlighted=isShadowVisibleWhenButtonHighlighted_;
@synthesize enabled=isEnabled_;
@synthesize isButtonImageSpinning=isButtonImageSpinning_;

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
    self.isShadowVisibleWhenButtonHighlighted = YES;
    self.enabled = YES;
    isButtonImageSpinning_ = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.buttonPrivate = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonPrivate.frame = self.bounds;
    self.buttonPrivate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.buttonPrivate addTarget:self action:@selector(buttonTouchEvent) forControlEvents:UIControlEventAllTouchEvents];
    [self.buttonPrivate addTarget:self action:@selector(buttonTouchEnded) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
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

- (void)dealloc {
    [buttonText_ release];
    [buttonIconImage_ release];
    [button_ release];
    [overlay_ release];
    [shadow_ release];
    [super dealloc];
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
        [self guessAndSetAppropriateTitleAndImageInsetsAndAlignment];
    }
}

- (void) setButtonIconImage:(UIImage *)buttonIconImage {
    if (buttonIconImage_ != buttonIconImage) {
        [buttonIconImage_ release];
        buttonIconImage_ = [buttonIconImage retain];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateNormal];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateHighlighted];
        [self.buttonPrivate setImage:self.buttonIconImage forState:UIControlStateSelected];
        [self guessAndSetAppropriateTitleAndImageInsetsAndAlignment];
    }
}

- (void) guessAndSetAppropriateTitleAndImageInsetsAndAlignment {
    
    UIControlContentHorizontalAlignment buttonHorizontalAlignment;
    UIEdgeInsets titleInsets = self.buttonPrivate.titleEdgeInsets;
    UIEdgeInsets imageInsets = self.buttonPrivate.imageEdgeInsets;
    
    BOOL haveText = self.buttonText && self.buttonText.length > 0;
    BOOL haveImage = self.buttonIconImage != nil;
    
    if (haveText && haveImage) {
        buttonHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        imageInsets.left = 10 + (30.0 - self.buttonIconImage.size.width) / 2.0;
        titleInsets.left = 80.0 - (imageInsets.left + self.buttonIconImage.size.width + self.buttonIconImage.size.width / 2.0);
    } else {
        buttonHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;        
        imageInsets.left = 0;
        titleInsets.left = 0;
    }
    
    self.buttonPrivate.contentHorizontalAlignment = buttonHorizontalAlignment;
    self.buttonPrivate.titleEdgeInsets = titleInsets;
    self.buttonPrivate.imageEdgeInsets = imageInsets;
    
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    cornerRadius_ = cornerRadius;
    self.shadowPrivate.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius].CGPath;
}

- (void)buttonTouchEvent {
//    NSLog(@"UIButtonWithOverlayView buttonTouchEvent");
    if (self.button.highlighted) {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonHighlighted ? 0.5 : 0.0;
    } else {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 0.5 : 0.0;
    }
}

- (void) buttonTouchEnded {
    self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 0.5 : 0.0;
}

- (void)setEnabled:(BOOL)enabled {
    isEnabled_ = enabled;
    self.userInteractionEnabled = self.enabled;
    if (self.enabled) {
        self.button.titleLabel.alpha = 1.0;
        self.button.imageView.alpha = 1.0;
    } else {
        self.button.titleLabel.alpha = UIBUTTON_WITH_OVERLAY_VIEW_DISABLED_ALPHA;
        self.button.imageView.alpha = UIBUTTON_WITH_OVERLAY_VIEW_DISABLED_ALPHA;
    }
}

- (void)setIsShadowVisibleWhenButtonNormal:(BOOL)isShadowVisibleWhenButtonNormal {
    isShadowVisibleWhenButtonNormal_ = isShadowVisibleWhenButtonNormal;
    if (!self.button.highlighted) {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonNormal ? 0.5 : 0.0;
    }
}

- (void)setIsShadowVisibleWhenButtonHighlighted:(BOOL)isShadowVisibleWhenButtonHighlighted {
    isShadowVisibleWhenButtonHighlighted_ = isShadowVisibleWhenButtonHighlighted;
    if (self.button.highlighted) {
        self.shadowPrivate.layer.shadowOpacity = self.isShadowVisibleWhenButtonHighlighted ? 0.5 : 0.0;
    }
}

- (void)startSpinningButtonImage {
    NSLog(@"spinButtonImage");
    
    if (!isButtonImageSpinning_) {
        
        isButtonImageSpinning_ = YES;
        
        //    [UIView beginAnimations:nil context:nil];
        //    [UIView setAnimationDuration:10.0];
        //    
        //    // (180 * M_PI) / 180 == M_PI, so just use M_PI
        //    self.button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        //    
        //    [UIView commitAnimations];
        
        //    [self spinLayer:self.overlay.layer duration:1.0 direction:CLOCK_WISE];
        
//        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//                             self.button.imageView.transform = CGAffineTransformRotate(self.button.imageView.transform, M_PI/2.0);
//                         }
//                         completion:^(BOOL finished){
//                             [UIView animateWithDuration:0.5 delay:0.0 options:/*UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowAnimatedContent|*/UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat
//                                              animations:^{
//                                                  self.button.imageView.transform = CGAffineTransformRotate(self.button.imageView.transform, M_PI/2.0);//CGAffineTransformMakeRotation(M_PI);
//                                              }
//                                              completion:NULL];
//                         }];
        
//        CABasicAnimation * startRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        startRotationAnimation.byValue = [NSNumber numberWithFloat: /*1.5 * */M_PI / 2.0];
//        startRotationAnimation.duration = 0.25;
//        startRotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//        [self.button.imageView.layer addAnimation:startRotationAnimation forKey:@"startRotationAnimation"];
        
        CABasicAnimation * repeatingRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        repeatingRotationAnimation.byValue = [NSNumber numberWithFloat: M_PI / 2.0];
        repeatingRotationAnimation.duration = 0.25;
        repeatingRotationAnimation.repeatCount = HUGE_VALF;
        repeatingRotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        repeatingRotationAnimation.beginTime = CACurrentMediaTime()+2.0;
//        repeatingRotationAnimation.delegate = self;
//        repeatingRotationAnimation.fillMode = kCAFillModeBackwards;
        NSLog(@"repeatingRotationAnimation rate = %f", [repeatingRotationAnimation.byValue floatValue]/repeatingRotationAnimation.duration);
        [self.button.imageView.layer addAnimation:repeatingRotationAnimation forKey:@"repeatingRotationAnimation"];
        
//        CABasicAnimation * stopRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        CALayer * presentationLayer = [self.button.imageView.layer presentationLayer];
//        float rotationAmount = atan2(presentationLayer.transform.m12, presentationLayer.transform.m11);
//        NSLog(@"rotationAmount = %f (%f degrees)", rotationAmount, rotationAmount * 180 / M_PI);
//        stopRotationAnimation.fromValue = [NSNumber numberWithFloat:rotationAmount];
//        float quarterTurn = M_PI / 2.0;
//        float rotationAmountLeftToGo = /*quarterTurn - */rotationAmount;
//        stopRotationAnimation.byValue = [NSNumber numberWithFloat: /*1.5 * *//*quarterTurn + */rotationAmountLeftToGo];
//        stopRotationAnimation.duration = /*(rotationAmountLeftToGo / quarterTurn) * 0.25 + */0.25;
//        stopRotationAnimation.beginTime = CACurrentMediaTime()+2.5;
//        stopRotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        NSLog(@"stopRotationAnimation rate = %f", [stopRotationAnimation.byValue floatValue]/stopRotationAnimation.duration);
//        [self.button.imageView.layer addAnimation:stopRotationAnimation forKey:@"stopRotationAnimation"];
        
    }
    
}

- (void)stopSpinningButtonImage {
    
    if (isButtonImageSpinning_) {
        
        isButtonImageSpinning_ = NO;
        
        CABasicAnimation * stopRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        CALayer * presentationLayer = [self.button.imageView.layer presentationLayer];
        float rotationAmount = atan2(presentationLayer.transform.m12, presentationLayer.transform.m11);
        NSLog(@"rotationAmount = %f (%f degrees)", rotationAmount, rotationAmount * 180 / M_PI);
        stopRotationAnimation.fromValue = [NSNumber numberWithFloat:rotationAmount];
        float quarterTurn = M_PI / 2.0;
        float rotationAmountLeftToGo = quarterTurn - rotationAmount;
        stopRotationAnimation.byValue = [NSNumber numberWithFloat: /*1.5 * *//*quarterTurn + */rotationAmountLeftToGo];
        stopRotationAnimation.duration = 0.25;
//        stopRotationAnimation.beginTime = CACurrentMediaTime()+2.5;
        stopRotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        NSLog(@"stopRotationAnimation rate = %f", [stopRotationAnimation.byValue floatValue]/stopRotationAnimation.duration);
        [self.button.imageView.layer removeAllAnimations];
        [self.button.imageView.layer addAnimation:stopRotationAnimation forKey:@"stopRotationAnimation"];
        
//        CGAffineTransform transform = self.button.imageView.transform;
//        float angle = atan2(transform.b, transform.a);
//        NSLog(@"the found angle is %f", angle);
        
//        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             self.button.imageView.transform = self.button.imageView.transform;
//                             self.button.imageView.transform = CGAffineTransformRotate(self.button.imageView.transform, M_PI/2.0);
//                             CGAffineTransform transform = self.button.imageView.transform;
//                             float angle = atan2(transform.b, transform.a);
//                             NSLog(@"the found angle is %f", angle);
//                             self.button.imageView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
//                         } completion:NULL];
        
    }
    
}



//- (void) spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration
//        direction:(int)direction {
//    
//    NSLog(@"spinLayer");
//    
//    CABasicAnimation * rotationAnimation;
//    
//    // Rotate about the z axis
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    
//    // Rotate 360 degress, in direction specified
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * direction];
//    
//    // Perform the rotation over this many seconds
//    rotationAnimation.duration = inDuration;
//    
//    // Set the pacing of the animation
//    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    
//    // Add animation to the layer and make it so
//    [inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//    
//}

@end
