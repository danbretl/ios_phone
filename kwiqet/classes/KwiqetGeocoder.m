//
//  KwiqetGeocoder.m
//  Kwiqet
//
//  Created by Dan Bretl on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KwiqetGeocoder.h"
#import <CoreLocation/CoreLocation.h>

@interface KwiqetGeocoder()
@property (nonatomic, readonly) CLGeocoder * geocoderNew;
@property (nonatomic, readonly) MKReverseGeocoder * reverseGeocoderOld;
@property (nonatomic, readonly) BSForwardGeocoder * forwardGeocoderOld;
@end

@implementation KwiqetGeocoder

- (CLGeocoder *) geocoderNew {
    if (geocoderNew == nil) {
        geocoderNew = [[CLGeocoder alloc] init];
    }
    return geocoderNew;
}

- (MKReverseGeocoder *)reverseGeocoderOld {
    if (reverseGeocoderOld == nil) {
        reverseGeocoderOld = [[MKReverseGeocoder alloc] init];
    }
    return reverseGeocoderOld;
}

- (BSForwardGeocoder *)forwardGeocoderOld {
    if (forwardGeocoderOld == nil) {
        forwardGeocoderOld = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    return forwardGeocoderOld;
}

- (void) reverseGeocodeLocation:(CLLocation *)location {
    if (NSClassFromString(@"CLGeocoder")) {
        // iOS 5...
        
    } else {
        // Older iOS...
        
    }
}

- (void) forwardGeocodeString:(NSString *)locationString {
    if (NSClassFromString(@"CLGeocoder")) {
        // iOS 5...
        
    } else {
        // Older iOS...
        
    }
}

- (void)forwardGeocodeString:(NSString *)locationString inRegion:(CLRegion *)region {
    if (NSClassFromString(@"CLGeocoder")) {
        // iOS 5...
        
    } else {
        // Older iOS...
        
    }    
}

- (void)forwardGeocoderFoundLocation:(BSForwardGeocoder *)geocoder {
    
}

- (void)forwardGeocoderError:(BSForwardGeocoder *)geocoder errorMessage:(NSString *)errorMessage {
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    
}

@end
