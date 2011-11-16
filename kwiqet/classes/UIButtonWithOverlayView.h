//
//  UIButtonWithOverlayView.h
//  kwiqet
//
//  Created by Dan Bretl on 8/3/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonWithOverlayView : UIView {
    
    NSString * buttonText_;
    UIImage  * buttonIconImage_;
    CGFloat cornerRadius_;
    
    UIButton * button_;
    UIImageView * overlay_;
    UIView * shadow_;

    BOOL isShadowVisibleWhenButtonNormal_;
    BOOL isShadowVisibleWhenButtonHighlighted_;
    
    BOOL isEnabled_;
    BOOL isButtonImageSpinning_;
    
}

@property (nonatomic, copy)   NSString * buttonText;
@property (nonatomic, retain) UIImage  * buttonIconImage;

@property (nonatomic, readonly) UIButton * button;
@property (nonatomic, readonly) UIImageView * overlay;
@property (nonatomic, readonly) UIView * shadow;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) BOOL isShadowVisibleWhenButtonNormal;
@property (nonatomic) BOOL isShadowVisibleWhenButtonHighlighted;

@property (nonatomic) BOOL enabled;

@property (readonly) BOOL isButtonImageSpinning;
- (void) startSpinningButtonImage;
- (void) stopSpinningButtonImage; // Animation is rough at the end. Fix this later.

@end
