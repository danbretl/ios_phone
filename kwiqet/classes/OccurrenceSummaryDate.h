//
//  OccurrenceSummaryDate.h
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OccurrenceSummaryVenue.h"
#import <CoreLocation/CoreLocation.h>

@interface OccurrenceSummaryDate : NSObject {
    
    NSDate * date;
    NSMutableArray * venues; // Array of OccurrenceSummaryVenue objects
    
}

@property (retain) NSDate * date;
@property (retain) NSMutableArray * venues;

- (void) resortVenuesByProximityToCoordinate:(CLLocationCoordinate2D)coordinate;

@end
