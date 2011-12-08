//
//  WebConnector.h
//  Abextra
//
//  Created by Dan Bretl on 6/3/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLBuilder.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <YAJL/YAJL.h>

extern int const WEB_CONNECTOR_TIMEOUT_LENGTH_DEFAULT;
extern BOOL const WEB_CONNECTOR_ALLOW_SIMULTANEOUS_CONNECTIONS_DEFAULT;

typedef enum {
    GeneralFailure = 001,
    AccountConnectPasswordIncorrect = 500,
    AccountConnectAccountDoesNotExist = 501,
    AccountCreateEmailAssociatedWithAnotherAccount = 600,
} WebConnectorFailure;

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
//- (void) getRecommendedEventsWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive;
- (void) getRecommendedEventsWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
//- (void) getRecommendedEventsWithMinPrice:(NSNumber *)minPrice maxPrice:(NSNumber *)maxPrice categoryURI:(NSString *)categoryURI;
//- (void) getEventsListWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
//- (void) getEventsListForSearchString:(NSString *)searchString;
- (void) getEventsListForSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
- (void) sendLearnedDataAboutEvent:(NSString *)eventURI withUserAction:(NSString *)userAction;
// ACCOUNT
- (void) accountConnectWithEmail:(NSString *)emailString password:(NSString *)passwordString;
- (void) accountCreateWithEmail:(NSString *)emailString password:(NSString *)passwordString firstName:(NSString *)nameFirst lastName:(NSString *)nameLast image:(UIImage *)image; // Currently ignores image (Dec 7, 2011)
- (void) forgotPasswordForAccountAssociatedWithEmail:(NSString *)emailString;

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
- (void) webConnector:(WebConnector *)webConnector getRecommendedEventsSuccess:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
- (void) webConnector:(WebConnector *)webConnector getRecommendedEventsFailure:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
- (void) webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
- (void) webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive locationLatitude:(NSNumber *)locationLatitude locationLongitude:(NSNumber *)locationLongitude geoQueryString:(NSString *)geoQueryString;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
- (void) webConnector:(WebConnector *)webConnector accountConnectSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString kwiqetIdentifier:(NSString *)identifierString apiKey:(NSString *)apiKey;
- (void) webConnector:(WebConnector *)webConnector accountConnectFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString;
- (void) webConnector:(WebConnector *)webConnector forgotPasswordSuccess:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString;
- (void) webConnector:(WebConnector *)webConnector forgotPasswordFailure:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString;
- (void) webConnector:(WebConnector *)webConnector accountCreateSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString kwiqetIdentifier:(NSString *)identifierString apiKey:(NSString *)apiKey;
- (void) webConnector:(WebConnector *)webConnector accountCreateFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString;
@end