//
//  URLBuilder.h
//  Abextra
//
//  Created by John Nichols on 4/29/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLBuilder : NSObject {
    
}

@property (readonly) NSString * baseURLKey;
@property (readonly) NSString * baseURL;

// General
+ (NSString *) baseURLKey;
+ (NSString *) baseURL;

// Images
+ (NSURL *)imageURLForImageLocation:(NSString *)imageLocation;

// Security
-(NSString*)buildCredentialString;

// Accounts
-(NSURL*)buildLoginURL;
-(NSURL*)buildRegistrationURL;
-(NSURL*)buildForgotPasswordURL;

// Learning
-(NSURL*)buildLearnURL;
-(NSURL*)buildResetAggregateURL;
-(NSURL*)buildResetActionURL;

// Category Tree
-(NSURL*)buildGetCategoryTreeURL;

// Events List
//- (NSURL *) buildGetEventsListURLWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
//- (NSString *) buildGetRecommendedEventsURLBasicString;
//- (NSURL *) buildGetEventsListRecommendedURL;
- (NSURL *) buildGetRecommendedEventsURLWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
//- (NSURL *) buildGetRecommendedEventsURLWithMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice categoryURI:(NSString *)categoryURI;
//- (NSURL *) buildGetEventsListFreeURL;
//- (NSURL *) buildGetEventsListPopularURL;
- (NSURL *) buildGetEventsListSearchURLWithSearchString:(NSString *)searchString;

// Event
-(NSURL*)buildCardURLWithID:(NSString*)eventID;
- (NSURL *) buildOccurrencesURLForEventID:(NSString *)eventID;

// Featured Event
-(NSURL*)buildGetFeaturedEventURL;

@end
