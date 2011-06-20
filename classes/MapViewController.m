//
//  MapViewController.m
//  Abextra
//
//  Created by Dan Bretl on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
//#import "MyLocation.h"

@interface MapViewController()
//@property (retain) MKReverseGeocoder * reverseGeocoder;
//@property (retain) MKPlacemark * placemark;
@property (retain) UIView * navigationBarView;
@property (retain) UIButton * backButton;
@property (retain) UIButton * googleMapButton;
@property (retain) MKMapView * mapView;
@property (retain) CLLocation * eventLocation;
@property (retain) CLLocation * theUserLocation;
@property (retain) CLLocation * middleLocation;
@property BOOL zoomedMap;
@end

@implementation MapViewController

@synthesize delegate;
//@synthesize reverseGeocoder, placemark;
@synthesize locationManager;
@synthesize navigationBarView, backButton, googleMapButton;
@synthesize mapView;
@synthesize locationLatitude, locationLongitude, locationName, locationAddress;
@synthesize eventLocation, theUserLocation, middleLocation, zoomedMap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

- (void)dealloc
{
//    [reverseGeocoder release];
    [locationManager release];
//    [placemark release];
    [locationLatitude release];
    [locationLongitude release];
    [locationName release];
    [locationAddress release];
    [navigationBarView release];
    [backButton release];
    [googleMapButton release];
    [mapView release];
    [eventLocation release];
    [theUserLocation release];
    [middleLocation release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation bar
    self.navigationBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
    // Back button
    [self.backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    self.backButton.backgroundColor = [UIColor clearColor];

    // Google Map button
    [self.googleMapButton setImage:[UIImage imageNamed:@"btn_google.png"] forState:UIControlStateNormal];
    self.googleMapButton.backgroundColor = [UIColor clearColor];
    
    // Set up Map View
    self.mapView.showsUserLocation = YES;
    self.mapView.scrollEnabled = YES;
	self.mapView.zoomEnabled = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    // Orient Map View
    // Set the region and zoom level
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	CLLocationCoordinate2D location;
    location.latitude  = [self.locationLatitude  floatValue];
    location.longitude = [self.locationLongitude floatValue];
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	region.span = span;
	region.center = location;
	// Set to that region with an animated effect
	[self.mapView setRegion:region animated:TRUE];
    
    EventLocationAnnotation * eventLocationAnnotation = [[EventLocationAnnotation alloc] initWithName:self.locationName address:self.locationAddress coordinate:CLLocationCoordinate2DMake([self.locationLatitude floatValue], [self.locationLongitude floatValue])];
    [self.mapView addAnnotation:eventLocationAnnotation];
    [eventLocationAnnotation release];
    
    /*
    // Reverse Geocoder
    self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:location] autorelease];
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
     */
    
    // Location Manager
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [self zoomMapToFitEventCoordinate:CLLocationCoordinate2DMake([self.locationLatitude floatValue], [self.locationLongitude floatValue]) andUserLocation:self.mapView.userLocation];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)backButtonPushed {
    [self.delegate mapViewControllerDidPushBackButton:self];
}

- (void)googleMapButtonPushed {
    NSString * searchQuery = [[[self.locationName stringByAppendingFormat:@" %@", self.locationAddress] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSString * locationNameFormatted = [self.locationName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%f,%f", searchQuery, [self.locationLatitude floatValue], [self.locationLongitude floatValue]];
    NSLog(@"%@", urlString);
    UIApplication * app = [UIApplication sharedApplication];  
    [app openURL:[NSURL URLWithString:urlString]];
}

/*
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)thePlacemark {
	NSLog(@"Reverse Geocoder completed");
    self.placemark = thePlacemark;
	[mapView addAnnotation:self.placemark];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    NSLog(@"Reverse Geocoder Errored");
}
*/
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView * annotationView = nil;
    if (annotation != theMapView.userLocation) {
        annotationView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"ReusableAnnotationView"];
        if (annotationView == nil) {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ReusableAnnotationView"] autorelease];
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
    }
	return annotationView;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {    
    NSLog(@"updating location");
    if (!self.zoomedMap) {
        [self zoomMapToFitEventCoordinate:CLLocationCoordinate2DMake([self.locationLatitude floatValue], [self.locationLongitude floatValue]) andUserLocation:self.mapView.userLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"CCLocation error");
}

- (void) zoomMapToFitEventCoordinate:(CLLocationCoordinate2D)eventCoordinate andUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        self.eventLocation = [[[CLLocation alloc] initWithLatitude:eventCoordinate.latitude longitude:eventCoordinate.longitude] autorelease];
        self.theUserLocation = [[[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude] autorelease];
        self.middleLocation = [[[CLLocation alloc] initWithLatitude:((eventLocation.coordinate.latitude + theUserLocation.coordinate.latitude) / 2.0) longitude:((eventLocation.coordinate.longitude + theUserLocation.coordinate.longitude) / 2.0)] autorelease];
        CLLocation * eventLatUserLong = [[CLLocation alloc] initWithLatitude:self.eventLocation.coordinate.latitude longitude:self.theUserLocation.coordinate.longitude];
        CLLocation * userLatEventLong = [[CLLocation alloc] initWithLatitude:self.theUserLocation.coordinate.latitude longitude:self.eventLocation.coordinate.longitude];
        CLLocationDistance distance = [eventLocation distanceFromLocation:theUserLocation];
        CLLocationDistance longitudinalDistance = [self.eventLocation distanceFromLocation:eventLatUserLong];
        CLLocationDistance latitudinalDistance = [self.eventLocation distanceFromLocation:userLatEventLong];
        [eventLatUserLong release];
        [userLatEventLong release];
        if (distance < 100000) {
            self.zoomedMap = YES;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(middleLocation.coordinate, latitudinalDistance * 1.1, longitudinalDistance * 1.1);
            NSLog(@"%f %f %f %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
            [self.mapView setRegion:region animated:YES];
        }
    }
}

@end
