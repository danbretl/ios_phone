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
#import "EventsFilterOption.h"

@interface EventsWebQuery (Private)
- (NSNumber *)filterPriceLookingForMinimum:(BOOL)lookingForMinimum;
@end

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

- (NSNumber *)filterPriceLookingForMinimum:(BOOL)lookingForMinimum {
    NSNumber * filterPrice = nil;
    if (self.filterPriceBucketString != nil) {
        if ([self.filterPriceBucketString isEqualToString:EFO_CODE_PRICE_ANY]) {
            // ...do nothing...
        } else if ([self.filterPriceBucketString isEqualToString:EFO_CODE_PRICE_FREE]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:0];
        } else if ([self.filterPriceBucketString isEqualToString:EFO_CODE_PRICE_UNDER20]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:20];
        } else if ([self.filterPriceBucketString isEqualToString:EFO_CODE_PRICE_UNDER50]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:50];
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter price bucket string");
        }
    }
    return filterPrice;
}

- (NSNumber *)filterPriceMinimum {
    return [self filterPriceLookingForMinimum:YES];
}

- (NSNumber *)filterPriceMaximum {
    return [self filterPriceLookingForMinimum:NO];
}

@end
