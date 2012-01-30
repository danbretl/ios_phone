//
//  FeaturedVenueEventBubbleView.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedVenueEventBubbleView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Kwiqet.h"

const CGFloat FVEBV_INFO_CONTAINER_HEIGHT = 34.0;

@implementation FeaturedVenueEventBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.infoContainerHeight = FVEBV_INFO_CONTAINER_HEIGHT;
        
        self.dateTimeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.colorBarLayer.hidden = NO;
        
        self.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
        self.dateTimeLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:12];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat extraHorizontalPadding = 0;
    CGFloat availableWidth = self.infoContainer.frame.size.width - 2 * extraHorizontalPadding;
    self.titleLabel.frame = CGRectMake(extraHorizontalPadding, 0, availableWidth, 15);
    self.colorBarLayer.frame = CGRectMake(extraHorizontalPadding, CGRectGetMaxY(self.titleLabel.frame) + 1, availableWidth, 2);
    self.dateTimeLabel.frame = CGRectMake(extraHorizontalPadding, CGRectGetMaxY(self.colorBarLayer.frame) + 1, availableWidth, 15);
}

@end
