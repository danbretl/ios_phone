//
//  FeaturedBubbleView.h
//  Kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat FBV_PADDING = 5.0;
static const CGFloat FBV_IMAGE_PADDING_BOTTOM = 5.0;

@interface FeaturedBubbleView : UIView {
    
    BOOL debugging;
    
    UIImageView * imageView_;
    UIView * infoContainer_;
    CGFloat infoContainerHeight_;
    UILabel * dateTimeLabel_;
    UIColor * colorBarColor_;
    CALayer * colorBarLayer_;
    UILabel * titleLabel_;
    UILabel * venueLabel_;
    UILabel * priceLabel_;
    
}

@property (nonatomic, retain) UIImageView * imageView;
@property (nonatomic, retain) UIView * infoContainer; // The content (and setting) of this container is up to the subclasses, but the positioning of the container is handled by this parent class.
@property (nonatomic) CGFloat infoContainerHeight;
@property (nonatomic, retain) UILabel * dateTimeLabel;
@property (nonatomic, retain) UIColor * colorBarColor;
@property (nonatomic, retain) CALayer * colorBarLayer;
@property (nonatomic, retain) UILabel * titleLabel;
@property (nonatomic, retain) UILabel * venueLabel;
@property (nonatomic, retain) UILabel * priceLabel;

@end
