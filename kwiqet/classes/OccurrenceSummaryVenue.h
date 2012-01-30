//
//  OccurrenceSummaryVenue.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Occurrence.h"
#import "Place.h"

@interface OccurrenceSummaryVenue : NSObject {
    
    Place * place_;
    
    NSArray * occurrences_; // Array of Occurrence objects
    NSString * timesString_;
    
}

@property (retain) Place * place;
@property (readonly) NSArray * occurrences;
@property (readonly) NSString * timesString;
- (void) setOccurrences:(NSArray *)occurrences makeTimesSummaryUsingTimeFormatter:(NSDateFormatter *)timeFormatter;

@end
