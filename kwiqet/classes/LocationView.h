//
//  LocationView.h
//  kwiqet
//
//  Created by Dan Bretl on 10/18/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//
//  A LocationView will not display its locationLabel properly if it is square. Ideally, it is meant to be vertically oriented.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//extern NSString * const LOCATION_VIEW_SPAN_SMALL;

@interface LocationView : UIView {
    
    MKMapView * mapView;
    UILabel * locationLabel;
    
}

@property (retain) MKMapView * mapView;
@property (retain) UILabel * locationLabel;

- (void) setLocation:(CLLocation *)location withLocationString:(NSString *)locationString;

@end
