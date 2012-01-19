//
//  FeaturedEventBubbleView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedEventBubbleView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Kwiqet.h"

const CGFloat FEBV_INFO_CONTAINER_HEIGHT = 68.0;

@implementation FeaturedEventBubbleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.infoContainerHeight = FEBV_INFO_CONTAINER_HEIGHT;
        
        self.dateTimeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.venueLabel.hidden = NO;
        self.priceLabel.hidden = NO;
        self.colorBarLayer.hidden = NO;
        
        self.dateTimeLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:12];
        self.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:13];
        self.venueLabel.font = [UIFont kwiqetFontOfType:LightCondensed size:12];
        self.priceLabel.font = [UIFont kwiqetFontOfType:LightCondensed size:12];
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateTimeLabel.frame = CGRectMake(0, 0, self.infoContainer.frame.size.width, 15);
    self.colorBarLayer.frame = CGRectMake(0, CGRectGetMaxY(self.dateTimeLabel.frame) + 1, self.infoContainer.frame.size.width, 4);
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.colorBarLayer.frame) + 1, self.infoContainer.frame.size.width, 17);
    self.venueLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.infoContainer.frame.size.width, 15);
    self.priceLabel.frame = CGRectMake(0, CGRectGetMaxY(self.venueLabel.frame), self.infoContainer.frame.size.width, 15);
    
    if (debugging) {
        [self.dateTimeLabel sizeToFit];
        NSLog(@"self.dateTimeLabel.frame %@", NSStringFromCGRect(self.dateTimeLabel.frame));
        [self.titleLabel sizeToFit];
        NSLog(@"self.titleLabel.frame %@", NSStringFromCGRect(self.titleLabel.frame));
        [self.venueLabel sizeToFit];
        NSLog(@"self.venueLabel.frame %@", NSStringFromCGRect(self.venueLabel.frame));
        [self.priceLabel sizeToFit];
        NSLog(@"self.priceLabel.frame %@", NSStringFromCGRect(self.priceLabel.frame));
    }
    
}

@end
