//
//  KwiqetLocationManager.m
//  kwiqet
//
//  Created by Dan Bretl on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KwiqetLocationManager.h"

@interface KwiqetLocationManager()
@property (retain) NSTimer * locationManagerTimer;
- (void) locationManagerTimerDidFire:(NSTimer *)theTimer;
@property (nonatomic, readonly) NSTimer * freshScheduledLocationManagerTimer;
@property (retain) CLLocation * foundLocation;
@property (retain) MKReverseGeocoder * reverseGeocoder;
- (void) didFindCurrentLocation:(CLLocation *)location withReverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark;
- (void) didFailWithLatestLocation:(CLLocation *)location;
- (void) didFinishWithSuccess:(BOOL)success location:(CLLocation *)location reverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark;
@property (copy) NSString * foundLocationAddress;
@end

@implementation KwiqetLocationManager

@synthesize locationManager=locationManager_, foundLocationRecencyRequirementPreTimer=foundLocationRecencyRequirementPreTimer_, foundLocationRecencyRequirementPostTimer=foundLocationRecencyRequirementPostTimer_, foundLocationAccuracyRequirementPreTimer=foundLocationAccuracyRequirementPreTimer_, foundLocationAccuracyRequirementPostTimer=foundLocationAccuracyRequirementPostTimer_;
@synthesize locationManagerTimer=locationManagerTimer_, timeoutLength=timeoutLength_;
@synthesize foundLocation=foundLocation_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize foundLocationAddress=foundLocationAddress_;
@synthesize coreDataModel=coreDataModel_;
@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        
        self.timeoutLength = 5.0;
        self.foundLocationRecencyRequirementPreTimer = 30.0;
        self.foundLocationRecencyRequirementPostTimer = 30.0;
        self.foundLocationAccuracyRequirementPreTimer = 75.0;
        self.foundLocationAccuracyRequirementPostTimer = 250.0;
        
    }
    return self;
}

- (void)dealloc {
    [locationManager_ release];
    [locationManagerTimer_ release];
    [foundLocation_ release];
    [reverseGeocoder_ release];
    [foundLocationAddress_ release];
    [coreDataModel_ release];
}

- (CLLocationManager *)locationManager {
    if (locationManager_ == nil) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return locationManager_;
}

- (NSTimer *)freshScheduledLocationManagerTimer {
    return [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationManagerTimerDidFire:) userInfo:nil repeats:NO];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    NSLog(@"KwiqetLocationManager - reverse geocoder success");
    [self didFindCurrentLocation:self.foundLocation withReverseGeocodedInfo:placemark];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    NSLog(@"KwiqetLocationManager - reverse geocoder error");
    [self didFindCurrentLocation:self.foundLocation withReverseGeocodedInfo:nil];
}

- (void)findUserLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        self.locationManagerTimer = self.freshScheduledLocationManagerTimer;
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (manager == self.locationManager &&
        status == kCLAuthorizationStatusAuthorized) {
        if (!(self.locationManagerTimer && [self.locationManagerTimer isValid])) {
            self.locationManagerTimer = self.freshScheduledLocationManagerTimer;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"SetLocationViewController locationManager didUpdateToLocation");
    NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
    BOOL isRecent = (abs(howRecent) <= self.foundLocationRecencyRequirementPreTimer);
    BOOL isAccurate = newLocation.horizontalAccuracy <= self.foundLocationAccuracyRequirementPreTimer;
    self.foundLocation = newLocation;
    self.foundLocationAddress = nil;
    if (isRecent && isAccurate) {
        NSLog(@"Location with lat/lon (%+.6f, %+.6f) accepted ::: howRecent=%f, howAccurate=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, howRecent, newLocation.horizontalAccuracy);
        // Accept this event
        [self.locationManager stopUpdatingLocation];
        // Turn off the timer
        [self.locationManagerTimer invalidate];
        self.locationManagerTimer = nil;
        // Reverse geocode the location
        self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:self.foundLocation.coordinate] autorelease];
        self.reverseGeocoder.delegate = self;
        [self.reverseGeocoder start];
    } else {
        // Skip this event (though we're holding onto the location anyway) and wait for the next (hopefully more accurate) one...
        NSLog(@"Location with lat/lon (%+.6f, %+.6f) not accepted ::: howRecent=%f, howAccurate=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, howRecent, newLocation.horizontalAccuracy);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"SetLocationViewController locationManager didFailWithError:%@ %d", error, error.code);
    if (error.code == kCLErrorLocationUnknown) {
        // Simply wasn't able to receive location right away. Just sit tight. (Could we be waiting forever though, or would a different error fire eventually? Look into this.)
    } else {
        if (error.code == kCLErrorDenied) {
            [self.delegate kwiqetLocationManager:self didFailWithAccessDeniedError:error.code];
        } else if (error.code == kCLErrorNetwork) {
            [self.delegate kwiqetLocationManager:self didFailWithNetworkError:error.code];
        } else {
            [self.delegate kwiqetLocationManager:self didFailWithAssortedError:error.code];
        }
    }
}

- (void)locationManagerTimerDidFire:(NSTimer *)theTimer {
    [self.locationManager stopUpdatingLocation];
    self.foundLocation = self.locationManager.location;
    self.foundLocationAddress = nil;
    if (self.foundLocation != nil) {
        NSTimeInterval howRecent = [self.foundLocation.timestamp timeIntervalSinceNow];
        BOOL isRecent = (abs(howRecent) <= self.foundLocationRecencyRequirementPostTimer);
        BOOL isModeratelyAccurate = self.foundLocation.horizontalAccuracy <= self.foundLocationAccuracyRequirementPostTimer;
        BOOL isAcceptable = (isRecent && isModeratelyAccurate);
        if (isAcceptable) {
            self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:self.foundLocation.coordinate] autorelease];
            self.reverseGeocoder.delegate = self;
            [self.reverseGeocoder start];
        } else {
            [self didFailWithLatestLocation:self.foundLocation];
        }
    } else {
        [self.delegate kwiqetLocationManager:self didFailWithAssortedError:kCLErrorLocationUnknown];
    }
}

- (void) didFindCurrentLocation:(CLLocation *)location withReverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark {
    
    [self didFinishWithSuccess:YES location:location reverseGeocodedInfo:reverseGeocodedPlacemark];
    
}

- (void) didFailWithLatestLocation:(CLLocation *)location {
    [self didFinishWithSuccess:NO location:location reverseGeocodedInfo:nil];
}

- (void) didFinishWithSuccess:(BOOL)success location:(CLLocation *)location reverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark {
    
    UserLocation * userLocationObject = nil;
    
    if (location) {
        
        NSMutableString * addressFormatted = [NSMutableString string];
        
        if (reverseGeocodedPlacemark) {
            BOOL first = YES;
            for (NSString * addressLine in [reverseGeocodedPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"]) {
                [addressFormatted appendFormat:@"%@%@", first ? @"" : @", ", addressLine];
                first = NO;
            }
        }
        
        userLocationObject = [self.coreDataModel addUserLocationThatIsManual:NO withLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:[NSNumber numberWithDouble:location.horizontalAccuracy] addressFormatted:addressFormatted typeGoogle:@"unknown-unknown-unknown"];
        [self.coreDataModel coreDataSave];
        
    }
    
    if (success) {
        [self.delegate kwiqetLocationManager:self didFindUserLocation:userLocationObject];
    } else {
        [self.delegate kwiqetLocationManager:self didFailWithLatestUserLocation:userLocationObject];
    }
    
}

@end
