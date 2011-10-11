//
//  MapViewController.h
//  Abextra
//
//  Created by Dan Bretl on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventLocationAnnotation.h"

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <MKMapViewDelegate/*,MKReverseGeocoderDelegate*/, CLLocationManagerDelegate> {
    
//    MKReverseGeocoder * reverseGeocoder;
//    MKPlacemark * placemark;
    
    IBOutlet UIView * navigationBarView;
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * googleMapButton;
    IBOutlet MKMapView * mapView;
    
    id<MapViewControllerDelegate> delegate;
    
    NSNumber * locationLatitude;
    NSNumber * locationLongitude;
    NSString * locationName;
    NSString * locationAddress;
    
    CLLocationManager * locationManager;
    
    // For memory efficiency:
    CLLocation * eventLocation;
    CLLocation * theUserLocation;
    CLLocation * middleLocation;
    BOOL zoomedMap;
    
}

@property (assign) id<MapViewControllerDelegate> delegate;
@property (retain) NSNumber * locationLatitude;
@property (retain) NSNumber * locationLongitude;
@property (retain) NSString * locationName;
@property (retain) NSString * locationAddress;

@property (retain) CLLocationManager * locationManager;

- (IBAction) backButtonPushed;
- (IBAction) googleMapButtonPushed;
- (void) zoomMapToFitEventCoordinate:(CLLocationCoordinate2D)eventCoordinate andUserLocation:(MKUserLocation *)userLocation;

@end

@protocol MapViewControllerDelegate <NSObject>

- (void) mapViewControllerDidPushBackButton:(MapViewController *)mapViewController;

@end