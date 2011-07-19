//
//  WebDataTranslator.h
//  Abextra
//
//  Created by Dan Bretl on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Date & Time
static NSString * const WDT_START_DATETIME_KEY = @"startDatetime";
static NSString * const WDT_END_DATETIME_KEY = @"endDatetime";
static NSString * const WDT_START_TIME_VALID_KEY = @"startTimeIsValid";
static NSString * const WDT_END_TIME_VALID_KEY = @"endTimeIsValid";
static NSString * const WDT_START_DATE_VALID_KEY = @"startDateIsValid";
static NSString * const WDT_END_DATE_VALID_KEY = @"endDateIsValid";
// Price
static NSString * const WDT_PRICE_MINIMUM_KEY = @"minimum";
static NSString * const WDT_PRICE_MAXIMUM_KEY = @"maximum";

@interface WebDataTranslator : NSObject {
    
    NSDateFormatter * dateFormatter;
    
}

///////////////////////////////////////////////////////
// TAKING IN web data and translating to native data //
///////////////////////////////////////////////////////

- (NSDictionary *) datetimesSummaryFromStartTime:(NSString *)timeStart endTime:(NSString *)timeEnd startDate:(NSString *)dateStart endDate:(NSString *)dateEnd;
- (NSDictionary *) pricesSummaryFromPriceArray:(NSArray *)priceArray;

////////////////////////////////////
// DISPLAYING general native data //
////////////////////////////////////

// Date
- (NSString *) dateSpanStringFromStartDatetime:(NSDate *)startDatetime endDatetime:(NSDate *)endDatetime relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) dateSpanStringFromStartDateString:(NSString *)dateStart endDateString:(NSString *)dateEnd relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString;
// Time
- (NSString *) timeSpanStringFromStartDatetime:(NSDate *)startDatetime endDatetime:(NSDate *)endDatetime dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) timeSpanStringFromStartTimeString:(NSString *)timeStart endTimeString:(NSString *)timeEnd dataUnavailableString:(NSString *)dataUnavailableString;
// Price
- (NSString *) priceRangeStringFromMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice dataUnavailableString:(NSString *)dataUnavailableString;
// Address
- (NSString *) addressSecondLineStringFromCity:(NSString *)city state:(NSString *)state zip:(NSString *)zip;
+ (NSString *) addressSecondLineStringFromCity:(NSString *)city state:(NSString *)state zip:(NSString *)zip;
+ (NSString *) fullLocationStringFromAddress:(NSString *)address city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

/////////////////////////////////
// DISPLAYING events list data //
/////////////////////////////////

- (NSString *) eventsListDateRangeStringFromEventDateEarliest:(NSString *)eventDateEarliestString eventDateLatest:(NSString *)eventDateLatestString eventDateDistinctCount:(NSNumber *)eventDateDistinctCount relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) eventsListTimeRangeStringFromEventTimeEarliest:(NSString *)eventTimeEarliestString eventTimeLatest:(NSString *)eventTimeLatestString eventTimeDistinctCount:(NSNumber *)eventTimeDistinctCount dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) eventsListDateStringFromSQLDateString:(NSString *)sqlDateString relativeDates:(BOOL)relativeDates;
- (NSString *) eventsListTimeStringFromSQLTimeString:(NSString *)sqlTimeString;

@end
