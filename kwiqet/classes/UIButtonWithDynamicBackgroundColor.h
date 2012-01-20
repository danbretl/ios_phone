//
//  UIButtonWithDynamicBackgroundColor.h
//  kwiqet
//
//  Created by Dan Bretl on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIButtonWithDynamicBackgroundColor : UIButton {
    CALayer * backgroundDynamic_;
    UIColor * backgroundColorDefault_;
    UIColor * backgroundColorHighlight_;
}

@property (nonatomic, retain) UIColor * backgroundColorDefault;
@property (nonatomic, retain) UIColor * backgroundColorHighlight;

@end
