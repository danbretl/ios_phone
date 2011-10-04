//
//  WebConnector.h
//  Abextra
//
//  Created by Dan Bretl on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLBuilder.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <YAJL/YAJL.h>

extern int const WEB_CONNECTOR_TIMEOUT_LENGTH_DEFAULT;
extern BOOL const WEB_CONNECTOR_ALLOW_SIMULTANEOUS_CONNECTIONS_DEFAULT;

@protocol WebConnectorDelegate;

@interface WebConnector : NSObject {
    URLBuilder * urlBuilder;
    int timeoutLength;
    id<WebConnectorDelegate> delegate;
    BOOL allowSimultaneousConnections;
    NSMutableArray * connectionsInProgress;
    
}

@property (nonatomic, readonly) URLBuilder * urlBuilder;
@property int timeoutLength;
@property (assign) id<WebConnectorDelegate> delegate;
@property BOOL allowSimultaneousConnection;
@property (nonatomic, readonly) BOOL availableToMakeWebConnection;
@property (nonatomic, readonly) BOOL connectionInProgress;

- (void) getCategoryTree;
- (void) getEventWithURI:(NSString *)eventURI;
- (void) getAllOccurrencesForEventWithURI:(NSString *)eventURI;
- (void) getFeaturedEvent;
- (void) getRecommendedEventsWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
//- (void) getRecommendedEventsWithMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice categoryURI:(NSString *)categoryURI;
//- (void) getEventsListWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
//- (void) getEventsListForSearchString:(NSString *)searchString;
- (void) getEventsListForSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) sendLearnedDataAboutEvent:(NSString *)eventURI withUserAction:(NSString *)userAction;

@end

@protocol WebConnectorDelegate <NSObject>
@optional
- (void) webConnector:(WebConnector *)webConnector getCategoryTreeSuccess:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getCategoryTreeFailure:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getEventSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI;
- (void) webConnector:(WebConnector *)webConnector getEventFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI;
- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI;
- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI;
- (void) webConnector:(WebConnector *)webConnector getFeaturedEventSuccess:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getFeaturedEventFailure:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getRecommendedEventsSuccess:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) webConnector:(WebConnector *)webConnector getRecommendedEventsFailure:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
@end