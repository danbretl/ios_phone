//
//  FeaturedBubbleView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedBubbleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeaturedBubbleView

@synthesize imageView=imageView_;
@synthesize infoContainer=infoContainer_, infoContainerHeight=infoContainerHeight_;
@synthesize dateTimeLabel=dateTimeLabel_, colorBarColor=colorBarColor_, colorBarLayer=colorBarLayer_, titleLabel=titleLabel_, venueLabel=venueLabel_, priceLabel=priceLabel_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // BACKGROUND & SHADOW
        self.layer.cornerRadius = 5.0;
        CALayer * shadowLayer = [CALayer layer];
        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
        shadowLayer.shadowOffset = CGSizeMake(0, 0);
        shadowLayer.shadowOpacity = 0.75;
        shadowLayer.shadowRadius = 2.0;
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        shadowLayer.shouldRasterize = YES;
        shadowLayer.cornerRadius = self.layer.cornerRadius;
        [self.layer addSublayer:shadowLayer];
        CALayer * backgroundColorLayer = [CALayer layer];
        backgroundColorLayer.frame = self.bounds;
        backgroundColorLayer.backgroundColor = [UIColor colorWithWhite:247.0/255.0 alpha:1.0].CGColor;
        backgroundColorLayer.cornerRadius = self.layer.cornerRadius;
        [self.layer insertSublayer:backgroundColorLayer above:shadowLayer];
        
        // SUBVIEWS
        // Image view
        imageView_ = [[UIImageView alloc] init];
//        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // Unnecessary
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        self.imageView.layer.borderColor = [UIColor colorWithWhite:134.0/255.0 alpha:1.0].CGColor;
        self.imageView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        // Info container
        self.infoContainer = [[[UIView alloc] init] autorelease];
        [self addSubview:self.infoContainer];
        self.infoContainerHeight = 0;        
        // Info container subviews (controlled largely by subclasses)
        UIColor * darkTextColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
        titleLabel_ = [[UILabel alloc] init];
        self.titleLabel.textColor = darkTextColor;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.infoContainer addSubview:self.titleLabel];
        dateTimeLabel_ = [[UILabel alloc] init];
        self.dateTimeLabel.textColor = darkTextColor;
        self.dateTimeLabel.backgroundColor = [UIColor clearColor];
        [self.infoContainer addSubview:self.dateTimeLabel];
        venueLabel_ = [[UILabel alloc] init];
        self.venueLabel.textColor = darkTextColor;
        self.venueLabel.backgroundColor = [UIColor clearColor];
        [self.infoContainer addSubview:self.venueLabel];
        priceLabel_ = [[UILabel alloc] init];
        self.priceLabel.textColor = darkTextColor;
        self.priceLabel.backgroundColor = [UIColor clearColor];
        [self.infoContainer addSubview:self.priceLabel];
        // Color bar
        colorBarLayer_ = [CALayer layer];
        [self.infoContainer.layer addSublayer:self.colorBarLayer];
        
        self.dateTimeLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.venueLabel.hidden = YES;
        self.priceLabel.hidden = YES;
        self.colorBarLayer.hidden = YES;
        
        // DEBUGGING
        debugging = NO;
        if (debugging) {
            self.imageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
            self.titleLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
            self.dateTimeLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.25];
            self.venueLabel.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.25];
            self.priceLabel.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.25];
        }
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat availableWidth = self.frame.size.width - 2 * FBV_PADDING;
    self.infoContainer.frame = CGRectMake(FBV_PADDING, self.frame.size.height - FBV_PADDING - self.infoContainer.frame.size.height, availableWidth, self.infoContainerHeight);
    self.imageView.frame = CGRectMake(FBV_PADDING, FBV_PADDING, availableWidth, CGRectGetMinY(self.infoContainer.frame) - FBV_IMAGE_PADDING_BOTTOM - FBV_PADDING);
    NSLog(@"self.imageView.frame = %@", NSStringFromCGRect(self.imageView.frame));
    NSLog(@"self.infoContainer.frame = %@", NSStringFromCGRect(self.infoContainer.frame));
}

- (void)dealloc {
    [imageView_ release];
    [infoContainer_ release];
    [titleLabel_ release];
    [dateTimeLabel_ release];
    [colorBarLayer_ release];
    [colorBarColor_ release];
    [venueLabel_ release];
    [priceLabel_ release];
    [super dealloc];
}

- (void)setInfoContainerHeight:(CGFloat)infoContainerHeight {
    infoContainerHeight_ = infoContainerHeight;
    [self layoutSubviews];
}

- (void)setColorBarColor:(UIColor *)colorBarColor {
    if (colorBarColor_ != colorBarColor) {
        [colorBarColor_ release];
        colorBarColor_ = [colorBarColor retain];
    }
    self.colorBarLayer.backgroundColor = self.colorBarColor.CGColor;
}

@end
