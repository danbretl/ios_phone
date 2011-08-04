//
//  UIButtonWithOverlayView.h
//  kwiqet
//
//  Created by Dan Bretl on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonWithOverlayView : UIView {
    UIButton * button;
    UIView * overlay;
    CGFloat cornerRadius_;
    BOOL isShadowVisibleWhenButtonNormal;
    BOOL isShadowVisibleWhenButtonHighlighted;
//    CGSize touchDownPositionOffset_;
//    CGRect frameOriginal;
//    CGRect frameOffset;
}

@property (retain) UIButton * button;
@property (retain) UIView * overlay;
@property (nonatomic) CGFloat cornerRadius;
@property BOOL isShadowVisibleWhenButtonNormal;
@property BOOL isShadowVisibleWhenButtonHighlighted;

//@property (nonatomic) CGSize touchDownPositionOffset;

@end
