//
//  EventsWebQuery.m
//  Kwiqet
//
//  Created by Dan Bretl on 9/13/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "EventsWebQuery.h"
#import "Category.h"
#import "EventResult.h"
#import "EventsFilterOption.h"

@implementation EventsWebQuery
@dynamic filterTimeBucketString;
@dynamic filterDateBucketString;
@dynamic filterDistanceBucketString;
@dynamic filterPriceBucketString;
@dynamic filterLocationString;
@dynamic datetimeQueryExecuted;
@dynamic datetimeQueryCreated;
@dynamic searchTerm;
@dynamic eventResults;
@dynamic filterCategories;
@dynamic filterLocation;
@dynamic queryType;
@dynamic filterVenue;

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

- (NSNumber *)filterPriceMinimum {
    return [EventsFilterOption priceMinimumForCode:self.filterPriceBucketString];
}

- (NSNumber *)filterPriceMaximum {
    return [EventsFilterOption priceMaximumForCode:self.filterPriceBucketString];
}

- (NSDate *)filterDateEarliest {
    return [EventsFilterOption dateEarliestForCode:self.filterDateBucketString withUserDate:[NSDate date]];
}

- (NSDate *)filterDateLatest {
    return [EventsFilterOption dateLatestForCode:self.filterDateBucketString withUserDate:[NSDate date]];
}

- (NSDate *)filterTimeEarliest {
    return [EventsFilterOption timeEarliestForCode:self.filterTimeBucketString withUserTime:[NSDate date]];
}

- (NSDate *)filterTimeLatest {
    return [EventsFilterOption timeLatestForCode:self.filterTimeBucketString withUserTime:[NSDate date]];
}

- (NSString *)geoQueryString {
    return [EventsFilterOption locationGeoQueryStringForCode:self.filterDistanceBucketString];
}

- (QueryType)queryTypeScalar {
    return self.queryType.intValue;
}

@end
