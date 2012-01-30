//
//  KwiqetGeocoder.h
//  Kwiqet
//
//  Created by Dan Bretl on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  This class provides a thin layer of abstraction over geocoding services. It takes advantage of CLGeocoder, which is only available in iOS 5, and falls back on a combination of BSForwardGeocoder & MKReverseGeocoder for users with older versions of iOS. It models its methods on those from the new iOS 5 CLGeocoder class, but uses a delegate pattern.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"

@interface KwiqetGeocoder : NSObject <MKReverseGeocoderDelegate, BSForwardGeocoderDelegate> {
    
    CLGeocoder * geocoderNew;
    MKReverseGeocoder * reverseGeocoderOld;
    BSForwardGeocoder * forwardGeocoderOld;
    
}

- (void) reverseGeocodeLocation:(CLLocation *)location;
- (void) forwardGeocodeString:(NSString *)locationString;
- (void) forwardGeocodeString:(NSString *)locationString inRegion:(CLRegion *)region;

@end

@protocol KwiqetGeocoderDelegate <NSObject>

- (void) forwardGeocoder:(KwiqetGeocoder *)geocoder foundLocations:(NSArray *)locations;
- (void) forwardGeocoderFailed:(KwiqetGeocoder *)geocoder;
//- (void) reverseGeocoder:(KwiqetGeocoder *)geocoder ...
//- (void) reverseGeocoder:(KwiqetGeocoder *)geocoder ...

@end
