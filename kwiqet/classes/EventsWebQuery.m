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
- (NSDate *) filterDateLookingForEarliest:(BOOL)lookingForEarliest;
- (NSDate *) filterTimeLookingForEarliest:(BOOL)lookingForEarliest;
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

- (NSDate *)filterDateLookingForEarliest:(BOOL)lookingForEarliest {
    NSDate * filterDate = nil;
    if (self.filterDateBucketString != nil) {
        NSCalendar * gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate * today = [NSDate date];
        NSDateComponents * todayDateOnlyComps = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
        today = [gregorianCalendar dateFromComponents:todayDateOnlyComps];
        NSTimeInterval secondsInDay = 60 /* seconds in a minute */ * 60 /* minutes in an hour */ * 24 /* hours in a day */;
        if ([self.filterDateBucketString isEqualToString:EFO_CODE_DATE_ANY]) {
            // ...do nothing...
        } else if ([self.filterDateBucketString isEqualToString:EFO_CODE_DATE_TODAY]) {
            filterDate = lookingForEarliest ? today : today;
        } else if ([self.filterDateBucketString isEqualToString:EFO_CODE_DATE_WEEKEND]) {
            // Get the weekday component of the current date
            NSDateComponents * weekdayComponents = [gregorianCalendar components:NSWeekdayCalendarUnit fromDate:today];
            // Create a date components to represent the number of days to subtract from the current date. The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today is Sunday, subtract 0 days.)
            NSDateComponents * componentsToSubtract = [[NSDateComponents alloc] init];
            [componentsToSubtract setDay: 0 - (weekdayComponents.weekday - 7)];
            NSDate * saturday = [gregorianCalendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
            [componentsToSubtract release];
            // Optional step: beginningOfWeek now has the same hour, minute, and second as the original date (today). To normalize to midnight, extract the year, month, and day components and create a new date from those components.
            NSDateComponents * saturdayDateOnlyComps = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:saturday];
            saturday = [gregorianCalendar dateFromComponents:saturdayDateOnlyComps];
            // If today is Sunday, roll back our calculated saturday by a week, so that we end up with the saturday of the current weekend, and not the saturday of next weekend.
            if (weekdayComponents.weekday == 1) {
                saturday = [saturday dateByAddingTimeInterval:-(secondsInDay * 7)];
            }
            filterDate = lookingForEarliest ? saturday : [saturday dateByAddingTimeInterval:secondsInDay];
        } else if ([self.filterDateBucketString isEqualToString:EFO_CODE_DATE_NEXT7DAYS]) {
            filterDate = lookingForEarliest ? today : [today dateByAddingTimeInterval:secondsInDay * 7];
        } else if ([self.filterDateBucketString isEqualToString:EFO_CODE_DATE_NEXT30DAYS]) {
            filterDate = lookingForEarliest ? today : [today dateByAddingTimeInterval:secondsInDay * 30];
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter date bucket string");
        }
        [gregorianCalendar release];
    }
    NSLog(@"Translated %@ to %@ (when looking for earliest? %d)", self.filterDateBucketString, filterDate, lookingForEarliest);
    return filterDate;
}

- (NSDate *) filterTimeLookingForEarliest:(BOOL)lookingForEarliest {
    NSDate * filterTime = nil;
    if (self.filterTimeBucketString != nil) {
        NSInteger hour = 0;
        NSInteger minute = 0;
        if ([self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_ANY]) {
            NSLog(@"%@", EFO_CODE_TIME_ANY);
            // ...do nothing...
        } else if ([self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_MORNING]) {
            hour = lookingForEarliest ? 9 : 11;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_AFTERNOON]) {
            hour = lookingForEarliest ? 12 : 17;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_EVENING]) {
            hour = lookingForEarliest ? 18 : 20;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_NIGHT]) {
            hour = lookingForEarliest ? 21 : 23;
            minute = lookingForEarliest ? 0 : 59;
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter time bucket string");
        }
        if (![self.filterTimeBucketString isEqualToString:EFO_CODE_TIME_ANY]) {
            NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setHour:0];
            [dateComponents setMinute:0];
            [dateComponents setSecond:0];
            [dateComponents setHour:hour];
            [dateComponents setMinute:minute];
            filterTime = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
            [dateComponents release];
        }
    }
    NSLog(@"Translated %@ to %@", self.filterTimeBucketString, filterTime);
    return filterTime;
}

- (NSNumber *)filterPriceMinimum {
    return [self filterPriceLookingForMinimum:YES];
}

- (NSNumber *)filterPriceMaximum {
    return [self filterPriceLookingForMinimum:NO];
}

- (NSDate *)filterDateEarliest {
    return [self filterDateLookingForEarliest:YES];
}

- (NSDate *)filterDateLatest {
    return [self filterDateLookingForEarliest:NO];
}

- (NSDate *)filterTimeEarliest {
    return [self filterTimeLookingForEarliest:YES];
}

- (NSDate *)filterTimeLatest {
    return [self filterTimeLookingForEarliest:NO];
}

@end
