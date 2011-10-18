//
//  LocationView.h
//  kwiqet
//
//  Created by Dan Bretl on 10/18/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationView : UIView {
    
    MKMapView * mapView;
    UILabel * locationLabel;
    
}

@end
