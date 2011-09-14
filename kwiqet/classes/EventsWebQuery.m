//
//  EventsWebQuery.m
//  kwiqet
//
//  Created by Dan Bretl on 9/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsWebQuery.h"
#import "Category.h"
#import "EventResult.h"


@implementation EventsWebQuery
@dynamic filterTimeBucketString;
@dynamic filterDateBucketString;
@dynamic filterDistanceBucketString;
@dynamic filterPriceBucketString;
@dynamic filterLocationString;
@dynamic queryDatetime;
@dynamic searchTerm;
@dynamic eventResults;
@dynamic filterCategories;

- (NSArray *)eventResultsInOrder {
    return [self.eventResults sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

- (NSArray *)eventResultsEventsInOrder {
    NSMutableArray * eventsInOrder = [NSMutableArray array];
    for (EventResult * eventResult in self.eventResultsInOrder) {
        [eventsInOrder addObject:eventResult.event];
    }
    return eventsInOrder;
}

@end