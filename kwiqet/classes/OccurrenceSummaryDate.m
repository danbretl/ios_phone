//
//  OccurrenceSummaryDate.m
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "OccurrenceSummaryDate.h"

@implementation OccurrenceSummaryDate

@synthesize date;
@synthesize venues;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// THIS SHOULD BE UPDATED: The bulk of the implementation of this method is repeated in Event.m
- (void)resortVenuesByProximityToCoordinate:(CLLocationCoordinate2D)coordinate {

    CLLocation * userLocationCL = [[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] autorelease];
    
    NSComparator locationsComparator = ^(id a, id b){
        OccurrenceSummaryVenue * osvA = a;
        OccurrenceSummaryVenue * osvB = b;
        CLLocation * locationACL = [[CLLocation alloc] initWithLatitude:osvA.place.latitude.doubleValue longitude:osvA.place.longitude.doubleValue];
        CLLocation * locationBCL = [[CLLocation alloc] initWithLatitude:osvB.place.latitude.doubleValue longitude:osvB.place.longitude.doubleValue];
        CLLocationDistance distanceA = [locationACL distanceFromLocation:userLocationCL];
        CLLocationDistance distanceB = [locationBCL distanceFromLocation:userLocationCL];
        [locationACL release];
        [locationBCL release];
        NSComparisonResult result = NSOrderedSame;
        if (distanceA < distanceB){
            result = NSOrderedAscending;
        } else if (distanceA > distanceB){
            result = NSOrderedDescending;
        }
        return result;
    };
    
    [self.venues sortUsingComparator:locationsComparator];
    
}

- (void)dealloc {
    [date release];
    [venues release];
    [super dealloc];
}

@end
