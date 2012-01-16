//
//  FeaturedVenueSectionHeaderView.h
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FeaturedVenueSectionHeaderView : UIView {
    
    UIButton * button_;
    UIColor * highlightColor_;
    CALayer * highlightLayer_;
    
    NSString * venueNameString_;
    int selectedHighlightIndex_;
    
}

@property (retain, nonatomic) UIButton * button;
@property (retain, nonatomic) NSString * venueNameString;
@property (retain, nonatomic) UIColor * highlightColor;
@property (nonatomic) int selectedHighlightIndex;

@end