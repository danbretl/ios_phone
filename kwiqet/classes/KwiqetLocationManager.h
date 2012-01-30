//
//  KwiqetLocationManager.h
//  Kwiqet
//
//  Created by Dan Bretl on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CoreDataModel.h"

@protocol KwiqetLocationManagerDelegate;

@interface KwiqetLocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
    
    CLLocationManager * locationManager_;
    NSTimeInterval foundLocationRecencyRequirementPreTimer_;
    NSTimeInterval foundLocationRecencyRequirementPostTimer_;
    CLLocationAccuracy foundLocationAccuracyRequirementPreTimer_;
    CLLocationAccuracy foundLocationAccuracyRequirementPostTimer_;
    NSTimer * locationManagerTimer_;
    NSTimeInterval timeoutLength_;
    CLLocation * foundLocation_;
    MKReverseGeocoder * reverseGeocoder_;
    NSString * foundLocationAddress_;
    BOOL isFindingLocation_;
    
    CoreDataModel * coreDataModel_;
    
    id<KwiqetLocationManagerDelegate> delegate;
    
}

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (assign) id<KwiqetLocationManagerDelegate> delegate;
@property NSTimeInterval timeoutLength;
@property NSTimeInterval foundLocationRecencyRequirementPreTimer;
@property NSTimeInterval foundLocationRecencyRequirementPostTimer;
@property CLLocationAccuracy foundLocationAccuracyRequirementPreTimer;
@property CLLocationAccuracy foundLocationAccuracyRequirementPostTimer;
@property (readonly) BOOL isFindingLocation;

- (void) findUserLocation;

@end

@protocol KwiqetLocationManagerDelegate <NSObject>
- (void) kwiqetLocationManager:(KwiqetLocationManager *)kwiqetLocationManager didFindUserLocation:(UserLocation *)location;
- (void) kwiqetLocationManager:(KwiqetLocationManager *)kwiqetLocationManager didFailWithLatestUserLocation:(UserLocation *)location;
- (void) kwiqetLocationManager:(KwiqetLocationManager *)kwiqetLocationManager didFailWithAccessDeniedError:(CLError)errorCode;
- (void) kwiqetLocationManager:(KwiqetLocationManager *)kwiqetLocationManager didFailWithNetworkError:(CLError)errorCode;
- (void) kwiqetLocationManager:(KwiqetLocationManager *)kwiqetLocationManager didFailWithAssortedError:(CLError)errorCode;
@end