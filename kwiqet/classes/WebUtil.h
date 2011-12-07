//
//  WebUtil.h
//  Abextra
//
//  Created by Dan Bretl on 6/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const WEB_CONNECTION_ERROR_MESSAGE_STANDARD = @"There seems to be something wrong with your internet connection. Please check your settings and try again.";

@interface WebUtil : NSObject {
    
}

+ (NSArray *) arrayOfStringsFromURI:(NSString *)uri;
+ (NSString *) lastComponentInURI:(NSString *)uri;

+ (UIColor *) colorFromHexString:(NSString *)hexString;

+ (BOOL) isStringEmpty:(NSString *)string;
+ (NSString *) stringOrNil:(NSString *)string;
+ (BOOL) isNumberEmpty:(NSNumber *)number;
+ (NSNumber *) numberOrNil:(NSNumber *)number;

+ (BOOL) isValidEmailAddress:(NSString *)emailAddressString;

// The following functions take raw web input, and provide good output (good real values, or nil)
// Dealing with event summary dictionaries
//+ (NSString *)validTitleFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//+ (NSString *)validAddressFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//+ (NSString *)validVenueFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//+ (NSString *)validDateFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//+ (NSString *)validTimeFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//+ (NSString *)validPriceRangeFromEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary;
//// General
//+ (NSString *)validDateStringFromDateString:(NSString *)dateString;
//+ (NSDate *)validNSDateFromDateString:(NSString *)dateString;
//+ (NSString *)validTimeStringFromTimeString:(NSString *)timeString;
//+ (NSDate *)validNSDateFromTimeString:(NSString *)timeString;
//+ (NSNumber *)validPriceFromPrice:(NSNumber *)price;


@end
