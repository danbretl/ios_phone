//
//  LocationView.m
//  kwiqet
//
//  Created by Dan Bretl on 10/18/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "LocationView.h"
#import "UIFont+Kwiqet.h"

//NSString * const LOCATION_VIEW_SPAN_SMALL = @"LOCATION_VIEW_SPAN_SMALL";

float const LOCATION_VIEW_INNER_PADDING = 5.0;
float const LOCATION_VIEW_MAP_LABEL_SPACING = 5.0;

@interface LocationView(Private)
// ...
@end

@implementation LocationView

@synthesize mapView, locationLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Allocating & initializing
        // Map view
        mapView = [[MKMapView alloc] init];
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        [self addSubview:self.mapView];
        // Location label
        locationLabel = [[UILabel alloc] init];
        self.locationLabel.numberOfLines = 0;
        [self addSubview:self.locationLabel];
        
        // Positioning & autoresizing
        CGFloat mapViewSideLength = MIN(frame.size.width, frame.size.height) - 2 * LOCATION_VIEW_INNER_PADDING;
        self.mapView.frame = CGRectMake(LOCATION_VIEW_INNER_PADDING, LOCATION_VIEW_INNER_PADDING, mapViewSideLength, mapViewSideLength);
        if (frame.size.width < frame.size.height) {
            CGFloat locationLabelOriginY = CGRectGetMaxY(self.mapView.frame) + LOCATION_VIEW_MAP_LABEL_SPACING;
            self.locationLabel.frame = CGRectMake(LOCATION_VIEW_INNER_PADDING, locationLabelOriginY, self.mapView.frame.size.width, frame.size.height - LOCATION_VIEW_INNER_PADDING - locationLabelOriginY);
            self.mapView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            self.locationLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else {
            CGFloat locationLabelOriginX = CGRectGetMaxX(self.mapView.frame) + LOCATION_VIEW_MAP_LABEL_SPACING;
            self.locationLabel.frame = CGRectMake(locationLabelOriginX, LOCATION_VIEW_INNER_PADDING, frame.size.width - LOCATION_VIEW_INNER_PADDING - locationLabelOriginX, self.mapView.frame.size.height);
            self.mapView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            self.locationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
    }
    return self;
}

- (void)setLocation:(CLLocation *)location withLocationString:(NSString *)locationString {
    // ...
    // ...
    // ...
}


- (void)dealloc {
    [super dealloc];
    [mapView release];
    [locationLabel release];
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
