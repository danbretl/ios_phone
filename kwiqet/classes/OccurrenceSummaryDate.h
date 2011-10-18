//
//  OccurrenceSummaryDate.h
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OccurrenceSummaryVenue.h"

@interface OccurrenceSummaryDate : NSObject {
    
    NSDate * date;
    NSArray * venues; // Array of OccurrenceSummaryVenue objects
    
}

@property (retain) NSDate * date;
@property (retain) NSArray * venues;

@end
