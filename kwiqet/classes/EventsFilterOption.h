//
//  EventsFilterOption.h
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButtonWithOverlayView.h"
#import "Category.h"

// Price filter option codes
static NSString * const EFO_CODE_PRICE_FREE = @"free";
static NSString * const EFO_CODE_PRICE_UNDER20 = @"under20";
static NSString * const EFO_CODE_PRICE_UNDER50 = @"under50";
static NSString * const EFO_CODE_PRICE_ANY = @"anyprice"; // Most general price
// Date filter option codes
static NSString * const EFO_CODE_DATE_TODAY = @"today";
static NSString * const EFO_CODE_DATE_WEEKEND = @"weekend";
static NSString * const EFO_CODE_DATE_NEXT7DAYS = @"next7days";
static NSString * const EFO_CODE_DATE_NEXT30DAYS = @"next30days";
static NSString * const EFO_CODE_DATE_ANY = @"anydate"; // Most general date
// Location filter option codes
static NSString * const EFO_CODE_LOCATION_WALKING = @"walking";
static NSString * const EFO_CODE_LOCATION_NEIGHBORHOOD = @"neighborhood";
static NSString * const EFO_CODE_LOCATION_BOROUGH = @"borough";
static NSString * const EFO_CODE_LOCATION_CITY = @"city"; // Most general location
// Time filter option codes
static NSString * const EFO_CODE_TIME_MORNING = @"morning";
static NSString * const EFO_CODE_TIME_AFTERNOON = @"afternoon";
static NSString * const EFO_CODE_TIME_EVENING = @"evening";
static NSString * const EFO_CODE_TIME_NIGHT = @"night";
static NSString * const EFO_CODE_TIME_ANY = @"anytime"; // Most general time
// Category filter option codes
static NSString * const EFO_CODE_CATEGORY_PREFIX = @"category_";
static NSString * const EFO_CODE_CATEGORY_POSTFIX_ALL = @"all"; // Most general category

@interface EventsFilterOption : NSObject {
 
    NSString * code_;
    NSString * readable_;
    NSString * buttonText_;
    UIButtonWithOverlayView * buttonView_;
    BOOL isMostGeneralOption_;
    
}

@property (copy) NSString * code;
@property (copy) NSString * readable;
@property (copy) NSString * buttonText;
@property (retain) UIButtonWithOverlayView * buttonView;
@property BOOL isMostGeneralOption;

+ (NSString *) eventsFilterOptionCategoryCodeForCategoryURI:(NSString *)categoryURI;
+ (NSString *) categoryURIForEventsFilterOptionCategoryCode:(NSString *)codeForCategoryEFO;
+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonText:(NSString *)buttonText buttonView:(UIButtonWithOverlayView *)buttonView;
+ (NSString *)eventsFilterOptionIconFilenameForCode:(NSString *)code grayscale:(BOOL)grayscale larger:(BOOL)larger;

+ (NSNumber *) priceMinimumForCode:(NSString *)priceCode;
+ (NSNumber *) priceMaximumForCode:(NSString *)priceCode;
+ (NSDate *) dateEarliestForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate;
+ (NSDate *) dateLatestForCode:(NSString *)dateCode withUserDate:(NSDate *)userDate;
+ (NSDate *) timeEarliestForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime;
+ (NSDate *) timeLatestForCode:(NSString *)timeCode withUserTime:(NSDate *)userTime;

@end
