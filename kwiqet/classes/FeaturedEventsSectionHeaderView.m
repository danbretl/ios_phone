//
//  FeaturedEventsSectionHeaderView.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedEventsSectionHeaderView.h"
#import "UIFont+Kwiqet.h"
#import <QuartzCore/QuartzCore.h>

@interface FeaturedEventsSectionHeaderView()
//@property (nonatomic, retain) CALayer * shadowLayer;
//@property (nonatomic, retain) CALayer * backgroundLayer;
@end

@implementation FeaturedEventsSectionHeaderView

@synthesize titleLabel=titleLabel_;
//@synthesize shadowLayer=shadowLayer_, backgroundLayer=backgroundLayer_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"featured_events_section_bar.png"]];
        
        titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 2 * 10, frame.size.height)];
        self.titleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
        self.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.titleLabel];
        self.titleLabel.text = @"Featured Events";
        NSLog(@"self.titleLabel.frame = %@", NSStringFromCGRect(self.titleLabel.frame));
        
//        self.shadowLayer = [CALayer layer];
//        self.shadowLayer.frame = self.bounds;
////        self.shadowLayer.contentsGravity = kCAGravityTopLeft;
//        self.shadowLayer.shadowColor = [UIColor blackColor].CGColor;
//        self.shadowLayer.shadowOffset = CGSizeMake(0, 0);
//        self.shadowLayer.shadowOpacity = 0.5;
//        self.shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
//        self.shadowLayer.shouldRasterize = YES;
//        [self.layer insertSublayer:self.shadowLayer below:self.titleLabel.layer];
//        self.backgroundLayer = [CALayer layer];
//        self.backgroundLayer.frame = self.bounds;
////        self.backgroundLayer.frame = CGRectMake(0, 0, 320, 90);
////        self.shadowLayer.contentsGravity = kCAGravityTopLeft;
//        self.backgroundLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"featured_events_section_bar.png"]].CGColor;
//        self.backgroundLayer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
//        [self.layer insertSublayer:self.backgroundLayer above:self.shadowLayer];
        
    }
    return self;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
////    self.shadowLayer.frame = self.bounds;
////    self.backgroundLayer.frame = self.bounds;
//}

- (void)dealloc {
    [titleLabel_ release];
//    [shadowLayer_ release];
//    [backgroundLayer_ release];
    [super dealloc];
}

@end
