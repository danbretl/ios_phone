//
//  WebDataTranslator.m
//  Abextra
//
//  Created by Dan Bretl on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebDataTranslator.h"
#import "WebUtil.h"

static NSString * const WDT_DATA_UNAVAILABLE_PRICE = @"No price available";
static NSString * const WDT_DATA_UNAVAILABLE_TIME  = @"Time not available";
static NSString * const WDT_DATA_UNAVAILABLE_DATE  = @"Date not available";

static NSString * const WDT_DATA_UNAVAILABLE_EVENT_LIST_DATE  = @"";
static NSString * const WDT_DATA_UNAVAILABLE_EVENT_LIST_TIME  = @"";

@interface WebDataTranslator()
@property (nonatomic, readonly) NSDateFormatter * dateFormatter;
@end

@implementation WebDataTranslator

- (void)dealloc {
    [dateFormatter release];
    [super dealloc];
}

- (NSDateFormatter *)dateFormatter {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    return dateFormatter;
}

///////////////////////////////////////////////////////
// TAKING IN web data and translating to native data //
///////////////////////////////////////////////////////

- (NSDictionary *) datetimesSummaryFromStartTime:(NSString *)timeStart endTime:(NSString *)timeEnd startDate:(NSString *)dateStart endDate:(NSString *)dateEnd {
    
    NSDictionary * tempDict;
    
    [self.dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate * startDatetime = nil;
    NSString * startDateTemp = dateStart;
    NSString * startTimeTemp = timeStart;
    if (!startDateTemp) { startDateTemp = @"2000-01-01"; }        
    if (!startTimeTemp) { startTimeTemp = @"00:00:00"; }
    startDatetime = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", startDateTemp, startTimeTemp]];

    NSDate * endDatetime = nil;
    NSString * endDateTemp = dateEnd;
    NSString * endTimeTemp = timeEnd;
    if (!endDateTemp) { endDateTemp = @"2000-01-01"; }
    if (!endTimeTemp) { endTimeTemp = @"00:00:00"; }
    endDatetime = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", endDateTemp, endTimeTemp]];
    
    tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                startDatetime, WDT_START_DATETIME_KEY,
                endDatetime  , WDT_END_DATETIME_KEY,
                [NSNumber numberWithBool:(timeStart != nil)], WDT_START_TIME_VALID_KEY,
                [NSNumber numberWithBool:(timeEnd   != nil)], WDT_END_TIME_VALID_KEY,
                [NSNumber numberWithBool:(dateStart != nil)], WDT_START_DATE_VALID_KEY,
                [NSNumber numberWithBool:(dateEnd   != nil)], WDT_END_DATE_VALID_KEY,
                nil];
    
    return tempDict;
    
}

- (NSDictionary *) pricesSummaryFromPriceArray:(NSArray *)priceArray {
    
    NSNumber * minPriceValue = nil;
    NSNumber * maxPriceValue = nil;
    NSDictionary * dictionary = nil;
    
    if ([priceArray count] == 1) {
        NSNumber * priceValue = [[priceArray objectAtIndex:0] valueForKey:@"quantity"];
        minPriceValue = priceValue;
        maxPriceValue = priceValue;
    } else if ([priceArray count] > 1) {
        NSNumber * tempMinPriceValue = [NSNumber numberWithInt: 1000000];
        NSNumber * tempMaxPriceValue = [NSNumber numberWithInt:-1000000];
        for (int i=0; i < [priceArray count]; i++) {
            NSNumber * priceValue = [WebUtil numberOrNil:[[priceArray objectAtIndex:i] valueForKey:@"quantity"]];
            if (priceValue) {
                NSComparisonResult comparisonResultToMin = [tempMinPriceValue compare:priceValue];
                NSComparisonResult comparisonResultToMax = [tempMaxPriceValue compare:priceValue];
                if (comparisonResultToMin == NSOrderedDescending) {
                    tempMinPriceValue = priceValue;
                }
                if (comparisonResultToMax == NSOrderedAscending) {
                    tempMaxPriceValue = priceValue;
                }                
            }
        }
        minPriceValue = tempMinPriceValue;
        maxPriceValue = tempMaxPriceValue;
    }
    
    dictionary = [NSDictionary dictionaryWithObjectsAndKeys:minPriceValue, WDT_PRICE_MINIMUM_KEY, maxPriceValue, WDT_PRICE_MAXIMUM_KEY, nil];
    
    return dictionary;
    
}

////////////////////////////////////
// DISPLAYING general native data //
////////////////////////////////////

- (NSString *)dateSpanStringFromStartDatetime:(NSDate *)startDatetime endDatetime:(NSDate *)endDatetime relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString {
    
    [self.dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSLog(@"dateSpanStringFromStartDatetime start:%@ end:%@", [self.dateFormatter stringFromDate:startDatetime], [self.dateFormatter stringFromDate:endDatetime]);
    
    NSString * dateDisplayString = nil;
    
    if (startDatetime && endDatetime) {
        [self.dateFormatter setDateFormat:@"YYYY"];
        NSString * yearStart = [self.dateFormatter stringFromDate:startDatetime];
        NSString * yearEnd = [self.dateFormatter stringFromDate:endDatetime];
        NSString * dateFormat = [yearStart isEqualToString:yearEnd] ? @"MMM d": @"MMM d, YYYY";
        [self.dateFormatter setDateFormat:dateFormat];
        dateDisplayString = [NSString stringWithFormat:@"%@ - %@", [self.dateFormatter stringFromDate:startDatetime], [self.dateFormatter stringFromDate:endDatetime]];
        if ([yearStart isEqualToString:yearEnd]) {
            dateDisplayString = [dateDisplayString stringByAppendingFormat:@", %@", yearStart];
        }
    } else if (startDatetime) {
        if (!relativeDates) { // If relativeDates are on, we are going to wait to construct the dateDisplay string until later in this case. This is because instead of saying something like "Saturday, June 25, 2012", we would like to say "Tomorrow, June 25, 2012".
            [self.dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];
            dateDisplayString = [self.dateFormatter stringFromDate:startDatetime];
        }
    } else {
        dateDisplayString = dataUnavailableString ? dataUnavailableString : WDT_DATA_UNAVAILABLE_DATE;
    }
    
    if (relativeDates) {
                
        [self.dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate * startDateOnly = startDatetime ? [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:startDatetime]] : nil;
        NSDate * endDateOnly = endDatetime ? [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:endDatetime]] : nil;
        NSDate * todayDateOnly = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:[NSDate date]]];
        NSDate * tomorrowDateOnly = [NSDate dateWithTimeInterval:86400 sinceDate:todayDateOnly];
        
        NSComparisonResult todayVersusStart, todayVersusEnd, tomorrowVersusStart, tomorrowVersusEnd;

        if (startDatetime) {
            todayVersusStart = [todayDateOnly compare:startDateOnly];
            tomorrowVersusStart = [tomorrowDateOnly compare:startDateOnly];
        }
        if (endDatetime) {
            todayVersusEnd = [todayDateOnly compare:endDateOnly];
            tomorrowVersusEnd = [tomorrowDateOnly compare:endDateOnly];
        }
        
        if (startDatetime && endDatetime) {
            
            if ((todayVersusStart == NSOrderedSame || todayVersusStart == NSOrderedDescending) && (todayVersusEnd == NSOrderedSame || todayVersusEnd == NSOrderedAscending)) {
                dateDisplayString = [NSString stringWithFormat:@"Today, %@", dateDisplayString];
            } else if ((tomorrowVersusStart == NSOrderedSame || tomorrowVersusStart == NSOrderedDescending) && (tomorrowVersusEnd == NSOrderedSame || tomorrowVersusEnd == NSOrderedAscending)) {
                dateDisplayString = [NSString stringWithFormat:@"Tomorrow, %@", dateDisplayString];
            }
            
        } else if (startDatetime) {
            
            [self.dateFormatter setDateFormat:@"MMM d, YYYY"];
            NSString * relativePreString = @"";
            
            if (todayVersusStart == NSOrderedSame) {
                relativePreString = @"Today, ";
            } else if (tomorrowVersusStart == NSOrderedSame) {
                relativePreString = @"Tomorrow, ";
            } else {
                [self.dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];
            }
            
            dateDisplayString = [NSString stringWithFormat:@"%@%@", relativePreString, [self.dateFormatter stringFromDate:startDatetime]];
            
        }
    }
    
    return dateDisplayString;
    
}

- (NSString *)dateSpanStringFromStartDateString:(NSString *)dateStart endDateString:(NSString *)dateEnd relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString {
        
    [self.dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate * datetimeStart = dateStart ? [self.dateFormatter dateFromString:dateStart] : nil;
    NSDate * datetimeEnd   = dateEnd   ? [self.dateFormatter dateFromString:dateEnd]   : nil;
    
    return [self dateSpanStringFromStartDatetime:datetimeStart endDatetime:datetimeEnd relativeDates:relativeDates dataUnavailableString:dataUnavailableString];
    
}

- (NSString *)timeSpanStringFromStartDatetime:(NSDate *)startDatetime endDatetime:(NSDate *)endDatetime dataUnavailableString:(NSString *)dataUnavailableString {
    
    NSString * timeDisplayString = nil;
    
    [self.dateFormatter setDateFormat:@"h:mm a"];
    
    if (startDatetime) {
        timeDisplayString = [self.dateFormatter stringFromDate:startDatetime];
        if (endDatetime) {
            timeDisplayString = [NSString stringWithFormat:@"%@ - %@", timeDisplayString, [dateFormatter stringFromDate:endDatetime]];
        }
    }
    
    if (!timeDisplayString) {
        timeDisplayString = dataUnavailableString ? dataUnavailableString : WDT_DATA_UNAVAILABLE_TIME;
    }
    
    return timeDisplayString;
    
}

- (NSString *)timeSpanStringFromStartTimeString:(NSString *)timeStart endTimeString:(NSString *)timeEnd dataUnavailableString:(NSString *)dataUnavailableString {
    
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate * datetimeStart = timeStart ? [self.dateFormatter dateFromString:timeStart] : nil;
    NSDate * datetimeEnd = timeEnd ? [self.dateFormatter dateFromString:timeEnd] : nil;
    
    return [self timeSpanStringFromStartDatetime:datetimeStart endDatetime:datetimeEnd dataUnavailableString:dataUnavailableString];
    
}

- (NSString *)priceRangeStringFromMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice dataUnavailableString:(NSString *)dataUnavailableString {
    
    NSString * priceRange = @"";
    
    minPrice = [WebUtil numberOrNil:minPrice];
    maxPrice = [WebUtil numberOrNil:maxPrice];
    
    BOOL twoDistinctPrices = (minPrice && maxPrice && ![maxPrice isEqualToNumber:minPrice]);
    
    BOOL noPrices = (!(minPrice || maxPrice));
    
    if (twoDistinctPrices) {
        priceRange = [NSString stringWithFormat:@"$%@ - $%@", minPrice, maxPrice];
    } else if (noPrices) {
        priceRange = dataUnavailableString ? dataUnavailableString : WDT_DATA_UNAVAILABLE_PRICE;
    } else {
        NSNumber * keyPrice = (maxPrice) ? maxPrice : minPrice;
        if ([keyPrice intValue] == 0) {
            priceRange = @"Free";
        } else {
            priceRange = [NSString stringWithFormat:@"$%@", keyPrice];
        }
    }
    
    return priceRange;
    
}

- (NSString *)addressSecondLineStringFromCity:(NSString *)city state:(NSString *)state zip:(NSString *)zip {
    
    NSString * addressSecondLine = nil;
    NSMutableString * addressLineSecondTemp = [NSMutableString stringWithString:@""];
    
    if (city) {
        [addressLineSecondTemp appendString:city];
        if (state || zip) {
            [addressLineSecondTemp appendString:@", "];
        }
    }
    if (state) {
        [addressLineSecondTemp appendString:state];
        if (zip) {
            [addressLineSecondTemp appendString:@" "];
        }
    }
    if (zip) {
        [addressLineSecondTemp appendString:zip];
    }
    
    if (![addressLineSecondTemp isEqualToString:@""]) {
        addressSecondLine = addressLineSecondTemp;
    }
    
    return addressSecondLine;
}

/////////////////////////////////
// DISPLAYING events list data //
/////////////////////////////////

- (NSString *) eventsListDateRangeStringFromEventDateEarliest:(NSString *)eventDateEarliestString eventDateLatest:(NSString *)eventDateLatestString eventDateDistinctCount:(NSNumber *)eventDateDistinctCount relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString {
    
    NSString * returnDateString = nil;
    
    if (eventDateEarliestString) {
        
        returnDateString = [self eventsListDateStringFromSQLDateString:eventDateEarliestString relativeDates:relativeDates];
        
        if (eventDateDistinctCount && 
            [eventDateDistinctCount intValue] > 1 && 
            eventDateLatestString) {
            returnDateString = [returnDateString stringByAppendingFormat:@" - %@", [self eventsListDateStringFromSQLDateString:eventDateLatestString relativeDates:relativeDates]];
        }
        
    }
    
    if (!returnDateString) {
        returnDateString = dataUnavailableString ? dataUnavailableString : WDT_DATA_UNAVAILABLE_EVENT_LIST_DATE;
    }
    
    return returnDateString;
    
}

- (NSString *) eventsListTimeRangeStringFromEventTimeEarliest:(NSString *)eventTimeEarliestString eventTimeLatest:(NSString *)eventTimeLatestString eventTimeDistinctCount:(NSNumber *)eventTimeDistinctCount dataUnavailableString:(NSString *)dataUnavailableString {
    
    NSString * returnTimeString = nil;
    
    if (eventTimeEarliestString) {
        returnTimeString = [self eventsListTimeStringFromSQLTimeString:eventTimeEarliestString];
        if ([eventTimeDistinctCount intValue] > 1) {
            returnTimeString = @"Various times";
        }
    }
    
    if (!returnTimeString) {
        returnTimeString = dataUnavailableString ? dataUnavailableString : WDT_DATA_UNAVAILABLE_EVENT_LIST_TIME;
    }
    
    return returnTimeString;
    
}

- (NSString *) eventsListDateStringFromSQLDateString:(NSString *)sqlDateString relativeDates:(BOOL)relativeDates {
    
    [self.dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate * eventDate = [self.dateFormatter dateFromString:sqlDateString];
    NSString * todayDateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString * tomorrowDateString = [self.dateFormatter stringFromDate:[NSDate dateWithTimeInterval:86400 sinceDate:[NSDate date]]];
    
    [self.dateFormatter setDateFormat:@"MMM d"];
    NSString * returnDateString = [self.dateFormatter stringFromDate:eventDate];
    
    if (relativeDates) {
        if ([sqlDateString isEqualToString:todayDateString]) {
            returnDateString = @"Today";
        } else if ([sqlDateString isEqualToString:tomorrowDateString]) {
            returnDateString = @"Tomorrow";
        }
    }
    
    return returnDateString;
    
}

- (NSString *) eventsListTimeStringFromSQLTimeString:(NSString *)sqlTimeString {
    
    return [self timeSpanStringFromStartTimeString:sqlTimeString endTimeString:nil dataUnavailableString:WDT_DATA_UNAVAILABLE_EVENT_LIST_TIME];
    
}

@end
