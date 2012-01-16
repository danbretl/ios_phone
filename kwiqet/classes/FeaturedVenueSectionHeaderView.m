//
//  FeaturedVenueSectionHeaderView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedVenueSectionHeaderView.h"
#import "UIFont+Kwiqet.h"

@interface FeaturedVenueSectionHeaderView()
@property (retain, nonatomic) CALayer * highlightLayer;
- (void) updateHighlightLayer;
@end

@implementation FeaturedVenueSectionHeaderView

@synthesize button=button_;
@synthesize highlightColor=highlightColor_;
@synthesize highlightLayer=highlightLayer_;
@synthesize selectedHighlightIndex=selectedHighlightIndex_;
@synthesize venueNameString=venueNameString_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:140.0/255.0 alpha:1.0];
        
        // Button
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.button.backgroundColor = [UIColor clearColor];
        // Button image view
        UIImage * plateImage = [UIImage imageNamed:@"featured_venue_bar_plate.png"];
        if ([plateImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            plateImage = [plateImage resizableImageWithCapInsets:UIEdgeInsetsMake(plateImage.size.height, 40, plateImage.size.height, 40)];
        } else {
            plateImage = [plateImage stretchableImageWithLeftCapWidth:40 topCapHeight:plateImage.size.height];
        }
        [self.button setBackgroundImage:plateImage forState:UIControlStateNormal];
        [self.button setBackgroundImage:plateImage forState:UIControlStateHighlighted];
        // Button title label
        self.button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIColor * darkTextColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
        [self.button setTitleColor:darkTextColor forState:UIControlStateNormal];
        [self.button setTitleColor:darkTextColor forState:UIControlStateHighlighted];
        self.button.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:15];
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.button];
        self.venueNameString = @"Featured Venue";
        
        // Highlight layer
        self.highlightLayer = [CALayer layer];
        self.highlightLayer.frame = CGRectMake(0, 0, 9, frame.size.height);
        [self.layer insertSublayer:self.highlightLayer below:self.button.layer];

        self.highlightColor = [UIColor whiteColor];
        self.selectedHighlightIndex = 0;
        
//        CGRect shadowFrame = CGRectMake(0, frame.size.height / 2.0, frame.size.width, frame.size.height / 2.0);
//        CALayer * shadowLayer = [CALayer layer];
//        shadowLayer.frame = shadowFrame;
//        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
//        shadowLayer.shadowOffset = CGSizeMake(0, 0);
//        shadowLayer.shadowOpacity = 0.5;
//        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:shadowLayer.bounds].CGPath;
//        shadowLayer.shouldRasterize = YES;
//        [self.layer insertSublayer:shadowLayer below:self.button.layer];
//        CALayer * backgroundColorLayer = [CALayer layer];
//        backgroundColorLayer.frame = self.bounds;
//        backgroundColorLayer.backgroundColor = [UIColor colorWithWhite:140.0/255.0 alpha:1.0].CGColor;
//        [self.layer insertSublayer:backgroundColorLayer above:shadowLayer];
        
    }
    return self;
}

- (void)dealloc {
    [button_ release];
    [highlightColor_ release];
    [highlightLayer_ release];
    [venueNameString_ release];
    [super dealloc];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (highlightColor_ != highlightColor) {
        [highlightColor_ release];
        highlightColor_ = [highlightColor retain];
    }
    self.highlightLayer.backgroundColor = [self.highlightColor colorWithAlphaComponent:0.5].CGColor;
}

- (void) setSelectedHighlightIndex:(int)selectedHighlightIndex {
    selectedHighlightIndex_ = selectedHighlightIndex;
    [self updateHighlightLayer];
}

// Hardcoded disgustingness. No way around it really though.
- (void) updateHighlightLayer {
    CGFloat distanceFromRightEdge = 41;
    switch (self.selectedHighlightIndex) {
        case 0: distanceFromRightEdge = 41; break;
        case 1: distanceFromRightEdge = 30; break;
        case 2: distanceFromRightEdge = 20; break;
        default: break;
    }
    CGRect highlightLayerFrame = self.highlightLayer.frame;
    highlightLayerFrame.origin.x = self.frame.size.width - distanceFromRightEdge;
    self.highlightLayer.frame = highlightLayerFrame;
}

- (void)setVenueNameString:(NSString *)venueNameString {
    if (venueNameString_ != venueNameString) {
        [venueNameString_ release];
        venueNameString_ = [venueNameString retain];
    }
    [self.button setTitle:self.venueNameString forState:UIControlStateNormal];
    [self.button setTitle:self.venueNameString forState:UIControlStateHighlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
