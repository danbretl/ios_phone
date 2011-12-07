//
//  ElasticUILabel.h
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"

extern CGFloat const ELASTICUILABEL_GRADIENT_VIEW_WIDTH;

@interface ElasticUILabel : UIView <UIScrollViewDelegate> {
    
    GradientView * gradientView;
    
    UIScrollView * scrollView;
    UILabel * label;
    
    NSString * text;
    UIColor * color;
    
    UIView * overlayView_;
    
    NSTimer * elasticDelayTimer_;
    
}

@property (nonatomic, copy) NSString * text;
@property (nonatomic, retain) UIColor * color;
@property (nonatomic, retain) UIView * overlayView;
//- (void) wiggleLabel;
//- (void) flashScrollBar;
- (void) scrollTextToOriginAnimated:(BOOL)animated;
- (void)invalidateTimerAndScrollTextToOriginAnimated:(BOOL)animated;

@end
