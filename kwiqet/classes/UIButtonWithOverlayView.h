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

    BOOL isShadowVisibleWhenButtonNormal;
    BOOL isShadowVisibleWhenButtonHighlighted;
    
    BOOL isEnabled_;
    
}

@property (nonatomic, copy)   NSString * buttonText;
@property (nonatomic, retain) UIImage  * buttonIconImage;

@property (nonatomic, readonly) UIButton * button;
@property (nonatomic, readonly) UIImageView * overlay;
@property (nonatomic, readonly) UIView * shadow;

@property (nonatomic) CGFloat cornerRadius;
@property BOOL isShadowVisibleWhenButtonNormal;
@property BOOL isShadowVisibleWhenButtonHighlighted;

@property (nonatomic) BOOL enabled;

@end
