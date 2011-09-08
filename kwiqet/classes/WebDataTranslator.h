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
- (NSDate *) dateDatetimeFromDateString:(NSString *)dateString;
- (NSDate *) timeDatetimeFromTimeString:(NSString *)timeString;
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
- (NSString *) priceRangeStringFromMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice dataUnavailableString:(NSString *)dataUnavailableString; // Prices are currently rounded to display as integers
// Address
- (NSString *) addressSecondLineStringFromCity:(NSString *)city state:(NSString *)state zip:(NSString *)zip;
+ (NSString *) addressSecondLineStringFromCity:(NSString *)city state:(NSString *)state zip:(NSString *)zip;
+ (NSString *) fullLocationStringFromAddress:(NSString *)address city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

/////////////////////////////////
// DISPLAYING events list data //
/////////////////////////////////

- (NSString *) eventsListDateRangeStringFromEventDateEarliest:(NSDate *)eventDateEarliest eventDateLatest:(NSDate *)eventDateLatest eventDateCount:(NSNumber *)eventDateCount relativeDates:(BOOL)relativeDates dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) eventsListTimeRangeStringFromEventTimeEarliest:(NSDate *)eventTimeEarliest eventTimeLatest:(NSDate *)eventTimeLatest eventTimeCount:(NSNumber *)eventTimeCount dataUnavailableString:(NSString *)dataUnavailableString;
- (NSString *) eventsListDateStringFromDate:(NSDate *)date relativeDates:(BOOL)relativeDates;
- (NSString *) eventsListTimeStringFromTime:(NSDate *)time;

@end
