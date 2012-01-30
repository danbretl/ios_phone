//
//  Place.m
//  Kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "Place.h"
#import "Occurrence.h"


@implementation Place
@dynamic state;
@dynamic unit;
@dynamic phone;
@dynamic zip;
@dynamic uri;
@dynamic longitude;
@dynamic url;
@dynamic latitude;
@dynamic title;
@dynamic address;
@dynamic city;
@dynamic email;
@dynamic placeDescription;
@dynamic imageLocation;
@dynamic occurrences;
@dynamic queries;
@dynamic eventSummaries;

- (BOOL)coordinateAvailable {
    return (self.latitude && self.longitude);
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    if (self.coordinateAvailable) {
        coordinate = CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
    }
    return coordinate;
}

@end
