//
//  EventsFilterOption.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "EventsFilterOption.h"

static NSString * const EFO_ICON_PREFIX = @"ico_";
static NSString * const EFO_ICON_LARGER_PREFIX = @"larger_";
static NSString * const EFO_ICON_BW_PREFIX = @"bw_";
static NSString * const EFO_ICON_EXT = @".png";

@interface EventsFilterOption(Private)
+ (NSNumber *)filterPriceForCode:(NSString *)priceCode lookingForMinimum:(BOOL)lookingForMinimum;
+ (NSDate *)filterDateForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate lookingForEarliest:(BOOL)lookingForEarliest;
+ (NSDate *)filterTimeForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime lookingForEarliest:(BOOL)lookingForEarliest;
@end

@implementation EventsFilterOption

@synthesize code = code_;
@synthesize readable = readable_;
@synthesize buttonText = buttonText_;
@synthesize buttonView = buttonView_;
@synthesize isMostGeneralOption = isMostGeneralOption_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *) eventsFilterOptionCategoryCodeForCategoryURI:(NSString *)categoryURI {
    NSString * postfix = EFO_CODE_CATEGORY_POSTFIX_ALL;
    if (categoryURI != nil) {
        postfix = categoryURI;
    }
    return [NSString stringWithFormat:@"%@%@", EFO_CODE_CATEGORY_PREFIX, postfix];
}

+ (NSString *) categoryURIForEventsFilterOptionCategoryCode:(NSString *)codeForCategoryEFO {
    NSString * categoryURI = nil;
    NSString * strippedString = [codeForCategoryEFO stringByReplacingOccurrencesOfString:EFO_CODE_CATEGORY_PREFIX withString:@""];
    if (![strippedString isEqualToString:EFO_CODE_CATEGORY_POSTFIX_ALL]) {
        categoryURI = strippedString;
    }
    return categoryURI;
}

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonText:(NSString *)buttonText {// buttonView:(UIButtonWithOverlayView *)buttonView {
    
    EventsFilterOption * option = [[EventsFilterOption alloc] init];
    option.code = code;
    if (readable) {
        option.readable = readable;
    }
    option.buttonText = buttonText;
//    option.buttonView = buttonView;
    option.isMostGeneralOption = ([code isEqualToString:EFO_CODE_PRICE_ANY] ||
                                  [code isEqualToString:EFO_CODE_DATE_ANY] ||
                                  [code isEqualToString:EFO_CODE_LOCATION_METRO] ||
                                  [code isEqualToString:EFO_CODE_TIME_ANY] ||
                                  [code isEqualToString:[NSString stringWithFormat:@"%@%@", EFO_CODE_CATEGORY_PREFIX, EFO_CODE_CATEGORY_POSTFIX_ALL]]);
    return [option autorelease];
    
}

+ (NSString *)eventsFilterOptionIconFilenameForCode:(NSString *)code grayscale:(BOOL)grayscale larger:(BOOL)larger {
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", 
            EFO_ICON_PREFIX,
            larger ? EFO_ICON_LARGER_PREFIX : @"",
            grayscale ? EFO_ICON_BW_PREFIX : @"",
            code,
            EFO_ICON_EXT];
    
}

+ (NSNumber *)filterPriceForCode:(NSString *)priceCode lookingForMinimum:(BOOL)lookingForMinimum {
    NSNumber * filterPrice = nil;
    if (priceCode != nil) {
        if ([priceCode isEqualToString:EFO_CODE_PRICE_ANY]) {
            // ...do nothing...
        } else if ([priceCode isEqualToString:EFO_CODE_PRICE_FREE]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:0];
        } else if ([priceCode isEqualToString:EFO_CODE_PRICE_UNDER20]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:20];
        } else if ([priceCode isEqualToString:EFO_CODE_PRICE_UNDER50]) {
            filterPrice = lookingForMinimum ? nil : [NSNumber numberWithInt:50];
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter price bucket string");
        }
    }
    return filterPrice;
}

+ (NSDate *)filterDateForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate lookingForEarliest:(BOOL)lookingForEarliest {
    
    NSDate * filterDate = nil;
    if (dateCode != nil) {
        NSCalendar * gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate * today = userDate;
        NSDateComponents * todayDateOnlyComps = [gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
        today = [gregorianCalendar dateFromComponents:todayDateOnlyComps];
        NSTimeInterval secondsInDay = 60 /* seconds in a minute */ * 60 /* minutes in an hour */ * 24 /* hours in a day */;
        if ([dateCode isEqualToString:EFO_CODE_DATE_ANY]) {
            // ...do nothing...
        } else if ([dateCode isEqualToString:EFO_CODE_DATE_TODAY]) {
            filterDate = lookingForEarliest ? today : today;
        } else if ([dateCode isEqualToString:EFO_CODE_DATE_WEEKEND]) {
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
        } else if ([dateCode isEqualToString:EFO_CODE_DATE_NEXT7DAYS]) {
            filterDate = lookingForEarliest ? today : [today dateByAddingTimeInterval:secondsInDay * 7];
        } else if ([dateCode isEqualToString:EFO_CODE_DATE_NEXT30DAYS]) {
            filterDate = lookingForEarliest ? today : [today dateByAddingTimeInterval:secondsInDay * 30];
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter date bucket string");
        }
        [gregorianCalendar release];
    }
    NSLog(@"Translated %@ to %@ (when looking for earliest? %d)", dateCode, filterDate, lookingForEarliest);
    return filterDate;
    
}

+ (NSDate *)filterTimeForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime lookingForEarliest:(BOOL)lookingForEarliest {
    
    NSDate * filterTime = nil;
    if (timeCode != nil) {
        NSInteger hour = 0;
        NSInteger minute = 0;
        if ([timeCode isEqualToString:EFO_CODE_TIME_ANY]) {
            NSLog(@"%@", EFO_CODE_TIME_ANY);
            // ...do nothing...
        } else if ([timeCode isEqualToString:EFO_CODE_TIME_MORNING]) {
            hour = lookingForEarliest ? 9 : 11;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([timeCode isEqualToString:EFO_CODE_TIME_AFTERNOON]) {
            hour = lookingForEarliest ? 12 : 17;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([timeCode isEqualToString:EFO_CODE_TIME_EVENING]) {
            hour = lookingForEarliest ? 18 : 20;
            minute = lookingForEarliest ? 0 : 59;
        } else if ([timeCode isEqualToString:EFO_CODE_TIME_NIGHT]) {
            hour = lookingForEarliest ? 21 : 23;
            minute = lookingForEarliest ? 0 : 59;
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter time bucket string");
        }
        if (![timeCode isEqualToString:EFO_CODE_TIME_ANY]) {
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
    NSLog(@"Translated %@ to %@", timeCode, filterTime);
    return filterTime;
    
}

+ (NSNumber *)priceMinimumForCode:(NSString *)priceCode {
    return [self filterPriceForCode:priceCode lookingForMinimum:YES];
}

+ (NSNumber *)priceMaximumForCode:(NSString *)priceCode {
    return [self filterPriceForCode:priceCode lookingForMinimum:NO];
}

+ (NSDate *)dateEarliestForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate {
    return [self filterDateForCode:dateCode withUserDate:userDate lookingForEarliest:YES];
}

+ (NSDate *)dateLatestForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate {
    return [self filterDateForCode:dateCode withUserDate:userDate lookingForEarliest:NO];
}

+ (NSDate *)timeEarliestForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime {
    return [self filterTimeForCode:timeCode withUserTime:userTime lookingForEarliest:YES];
}

+ (NSDate *)timeLatestForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime {
    return [self filterTimeForCode:timeCode withUserTime:userTime lookingForEarliest:NO];
}

+ (NSString *)locationGeoQueryStringForCode:(NSString *)locationCode {
    NSLog(@"Looking for geoQueryString matching distance bucket string of %@", locationCode);
    NSString * geoQueryString = nil;
    if (locationCode != nil) {
        if ([locationCode isEqualToString:EFO_CODE_LOCATION_METRO]) {
            geoQueryString = @"m";
        } else if ([locationCode isEqualToString:EFO_CODE_LOCATION_CITY]) {
            geoQueryString = @"c";
        } else if ([locationCode isEqualToString:EFO_CODE_LOCATION_BOROUGH]) {
            geoQueryString = @"b";
        } else if ([locationCode isEqualToString:EFO_CODE_LOCATION_NEIGHBORHOOD]) {
            geoQueryString = @"n";
        } else if ([locationCode isEqualToString:EFO_CODE_LOCATION_WALKING]) {
            geoQueryString = @"r";
        } else {
            NSLog(@"ERROR in EventsWebQuery - unrecognized filter location distance bucket string");
        }
    }
    NSLog(@"Found geoQueryString of %@", geoQueryString);
    return geoQueryString;
}

// Remember that what we used to be referring to as borough is becoming city, and what we used to refer to as city is becoming metropolitan area. // UPDATE: No, not really. Really, there should be five options - walking, neighborhood, borough, city, and metro. There should only ever be four active / shown to the user though. When we're dealing in NYC-area, borough and metro area will show. Otherwise, city and metro area will show.
+ (NSSet *) acceptableLocationFilterOptionCodesForUserLocation:(UserLocation *)userLocation {
    NSMutableSet * acceptableLocationFilterOptionCodes = [NSMutableSet setWithObjects:EFO_CODE_LOCATION_WALKING, EFO_CODE_LOCATION_NEIGHBORHOOD, EFO_CODE_LOCATION_BOROUGH, EFO_CODE_LOCATION_METRO, nil];
    BOOL biggerThanMetroArea = NO; // We don't let the user select a location that is "bigger" than a metro area, so this option should always be available/acceptable.
    BOOL biggerThanBorough = biggerThanMetroArea || ([userLocation.typeGoogle isEqualToString:@"locality"] || [userLocation.typeGoogle isEqualToString:@"postal_code"]);
    BOOL biggerThanNeighborhood = biggerThanBorough || ([userLocation.typeGoogle isEqualToString:@"sublocality"]);
    BOOL biggerThanWalking = biggerThanNeighborhood || ([userLocation.typeGoogle isEqualToString:@"neighborhood"]);
    if (biggerThanBorough) {
        [acceptableLocationFilterOptionCodes removeObject:EFO_CODE_LOCATION_BOROUGH];
    }
    if (biggerThanNeighborhood) {
        [acceptableLocationFilterOptionCodes removeObject:EFO_CODE_LOCATION_NEIGHBORHOOD];
    }
    if (biggerThanWalking) {
        [acceptableLocationFilterOptionCodes removeObject:EFO_CODE_LOCATION_WALKING];
    }
    return acceptableLocationFilterOptionCodes;
}
                                                            


- (void)dealloc {
    [code_ release];
    [readable_ release];
    [buttonText_ release];
//    [buttonView_ release];
    [super dealloc];
}

@end
