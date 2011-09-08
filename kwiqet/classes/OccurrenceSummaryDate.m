//
//  OccurrenceSummaryDate.m
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

- (void)dealloc {
    [date release];
    [venues release];
    [super dealloc];
}

@end
