//
//  WebConnector.m
//  Abextra
//
//  Created by Dan Bretl on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebConnector.h"
#import "JSON.h"

int const WEB_CONNECTOR_TIMEOUT_LENGTH_DEFAULT = 20; // Had this at 5, but it seemed to be causing a lot of dropped connections. Maybe it was, maybe it wasn't - but for now we're going to have a ridiculously long timeout length.
BOOL const WEB_CONNECTOR_ALLOW_SIMULTANEOUS_CONNECTIONS_DEFAULT = YES;
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_FILTER_RECOMMENDED = @"recommended";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_FILTER_FREE = @"free";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_FILTER_POPULAR = @"popular";
static NSString * const WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI = @"WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY = @"categoryURI";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING = @"searchString";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MIN = @"filterPriceMin";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MAX = @"filterPriceMax";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST = @"filterDateEarliest";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST = @"filterDateLatest";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST = @"filterTimeEarliest";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST = @"filterTimeLatest";
static NSString * const WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_EVENT_URI = @"eventURI";
static NSString * const WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_ACTION = @"action";

@interface WebConnector()
@property (retain) NSMutableArray * connectionsInProgress;
- (void) getCategoryTreeSuccess:(ASIHTTPRequest *)request;
- (void) getCategoryTreeFailure:(ASIHTTPRequest *)request;
- (void) getEventSuccess:(ASIHTTPRequest *)request;
- (void) getEventFailure:(ASIHTTPRequest *)request;
- (void) getAllOccurrencesForEventSuccess:(ASIHTTPRequest *)request;
- (void) getAllOccurrencesForEventFailure:(ASIHTTPRequest *)request;
- (void) getFeaturedEventSuccess:(ASIHTTPRequest *)request;
- (void) getFeaturedEventFailure:(ASIHTTPRequest *)request;
- (void) getRecommendedEventsSuccess:(ASIHTTPRequest *)request;
- (void) getRecommendedEventsFailure:(ASIHTTPRequest *)request;
- (void) getEventsListForSearchStringSuccess:(ASIHTTPRequest *)request;
- (void) getEventsListForSearchStringFailure:(ASIHTTPRequest *)request;
- (void) sendLearnedDataAboutEventSuccess:(ASIHTTPRequest *)request;
- (void) sendLearnedDataAboutEventFailure:(ASIHTTPRequest *)request;
@end

@implementation WebConnector

@synthesize timeoutLength;
@synthesize delegate;
@synthesize allowSimultaneousConnection;
@synthesize connectionsInProgress;

- (id)init {
    self = [super init];
    if (self) {
        self.timeoutLength = WEB_CONNECTOR_TIMEOUT_LENGTH_DEFAULT;
        self.connectionsInProgress = [NSMutableArray array];
        self.allowSimultaneousConnection = WEB_CONNECTOR_ALLOW_SIMULTANEOUS_CONNECTIONS_DEFAULT;
    }
    return self;
}

- (void)dealloc {    
    [connectionsInProgress release];
    [urlBuilder release];
    [super dealloc];
}

- (URLBuilder *) urlBuilder {
    if (urlBuilder == nil) {
        urlBuilder = [[URLBuilder alloc] init];
    }
    return urlBuilder;
}

- (BOOL)availableToMakeWebConnection {
    return (self.allowSimultaneousConnection || !self.connectionInProgress);
}

- (BOOL)connectionInProgress {
    return self.connectionsInProgress.count > 0;
}

///////////////////
// CATEGORY TREE //
///////////////////

- (void) getCategoryTree {
    if (self.availableToMakeWebConnection) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetCategoryTreeURL]];
        [self.connectionsInProgress addObject:request];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(getCategoryTreeSuccess:)];
        [request setDidFailSelector:@selector(getCategoryTreeFailure:)];
        [request setTimeOutSeconds:self.timeoutLength];
        [request startAsynchronous];
    }
}

- (void) getCategoryTreeSuccess:(ASIHTTPRequest *)request {
    [self.connectionsInProgress removeObject:request];
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getCategoryTreeSuccess:request];
    } else {
        [self.delegate webConnector:self getCategoryTreeFailure:request];
    }
}

- (void) getCategoryTreeFailure:(ASIHTTPRequest *)request {
    [self.connectionsInProgress removeObject:request];
    [self.delegate webConnector:self getCategoryTreeFailure:request];    
}

////////////
// EVENTS //
////////////

- (void) getEventWithURI:(NSString *)eventURI {
    if (self.availableToMakeWebConnection) {
        NSURL * url = [self.urlBuilder buildCardURLWithID:eventURI];
        NSLog(@"getEventWithURI - url is %@", url);
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
        [self.connectionsInProgress addObject:request];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDelegate:self];
        [request setRequestMethod:@"GET"];
        [request setDidFinishSelector:@selector(getEventSuccess:)];
        [request setDidFailSelector:@selector(getEventFailure:)];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:eventURI, WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI, nil];
        request.userInfo = userInfo;
        [request startAsynchronous];
    }
}

- (void)getEventSuccess:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo valueForKey:WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI];
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getEventSuccess:request forEventURI:eventURI];
    } else {
        [self.delegate webConnector:self getEventFailure:request forEventURI:eventURI];
    }

}

- (void)getEventFailure:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo valueForKey:WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI];
    
    [self.delegate webConnector:self getEventFailure:request forEventURI:eventURI];
    
}

- (void)getAllOccurrencesForEventWithURI:(NSString *)eventURI {
    if (self.availableToMakeWebConnection) {
        NSURL * url = [self.urlBuilder buildOccurrencesURLForEventID:eventURI];
        NSLog(@"getAllOccurrencesForEventWithURI - url is %@", url);
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
        [self.connectionsInProgress addObject:request];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDelegate:self];
        [request setRequestMethod:@"GET"];
        [request setDidFinishSelector:@selector(getAllOccurrencesForEventSuccess:)];
        [request setDidFailSelector:@selector(getAllOccurrencesForEventFailure:)];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:eventURI, WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI, nil];
        request.userInfo = userInfo;
        [request startAsynchronous];
    }
}

- (void) getAllOccurrencesForEventSuccess:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo valueForKey:WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI];
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getAllOccurrencesSuccess:request forEventURI:eventURI];
    } else {
        [self.delegate webConnector:self getAllOccurrencesFailure:request forEventURI:eventURI];
    }
    
}

- (void) getAllOccurrencesForEventFailure:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo valueForKey:WEB_CONNECTOR_USER_INFO_KEY_EVENT_URI];
    
    [self.delegate webConnector:self getAllOccurrencesFailure:request forEventURI:eventURI];
    
}

////////////////////
// FEATURED EVENT //
////////////////////

- (void) getFeaturedEvent {
    if (self.availableToMakeWebConnection) {
        NSURL * url = [self.urlBuilder buildGetFeaturedEventURL];
        NSLog(@"getFeaturedEvent - %@", url);
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
        [self.connectionsInProgress addObject:request];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDelegate:self];
        [request setRequestMethod:@"GET"];
        [request setDidFinishSelector:@selector(getFeaturedEventSuccess:)];
        [request setDidFailSelector:@selector(getFeaturedEventFailure:)];
        [request startAsynchronous];
    }
}

- (void) getFeaturedEventSuccess:(ASIHTTPRequest *)request {
    [self.connectionsInProgress removeObject:request];
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getFeaturedEventSuccess:request];
    } else {
        [self.delegate webConnector:self getFeaturedEventFailure:request];
    }
}

- (void) getFeaturedEventFailure:(ASIHTTPRequest *)request {
    [self.connectionsInProgress removeObject:request];
    [self.delegate webConnector:self getFeaturedEventFailure:request];
}

//////////////////
// EVENTS LISTS //
//////////////////

- (void)getRecommendedEventsWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    
    if (self.availableToMakeWebConnection) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetRecommendedEventsURLWithCategoryURI:categoryURI minPrice:minPriceInclusive maxPrice:maxPriceInclusive startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive]];
        [self.connectionsInProgress addObject:request];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(getRecommendedEventsSuccess:)];
        [request setDidFailSelector:@selector(getRecommendedEventsFailure:)];
        [request setTimeOutSeconds:self.timeoutLength];
        /* THE FOLLOWING CODE IS DUPLICATED (IN PART) FOR SEARCH */
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        if (categoryURI != nil) { 
            [userInfo setObject:categoryURI forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY];
        }
        if (minPriceInclusive != nil) { 
            [userInfo setObject:minPriceInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MIN];
        }
        if (maxPriceInclusive != nil) { 
            [userInfo setObject:maxPriceInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MAX];
        }
        if (startDateEarliestInclusive != nil) { 
            [userInfo setObject:startDateEarliestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
        }
        if (startDateLatestInclusive != nil) { 
            [userInfo setObject:startDateLatestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
        }
        if (startTimeEarliestInclusive != nil) { 
            [userInfo setObject:startTimeEarliestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
        }
        if (startTimeLatestInclusive != nil) { 
            [userInfo setObject:startTimeLatestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
        }
        request.userInfo = userInfo;
        /* THE PREVIOUS CODE IS DUPLICATED (IN PART) FOR SEARCH */
        [request startAsynchronous];
    }
    
}

//- (void) getEventsListWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI {
//    if (self.availableToMakeWebConnection) {
//        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetEventsListURLWithFilter:filterString categoryURI:categoryURI]];
//        [self.connectionsInProgress addObject:request];
//        [request setRequestMethod:@"GET"];
//        [request setDelegate:self];
//        [request setDidFinishSelector:@selector(getEventsListSuccess:)];
//        [request setDidFailSelector:@selector(getEventsListFailure:)];
//        [request setTimeOutSeconds:self.timeoutLength];
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:filterString, WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER, categoryURI, WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY, nil];
//        request.userInfo = userInfo;
//        [request startAsynchronous];
//    }
//}

- (void) getRecommendedEventsSuccess:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];

    /* THE FOLLOWING CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    NSDictionary * userInfo = request.userInfo;
    NSString * categoryURI = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY];
    NSNumber * minPriceInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MIN];
    NSNumber * maxPriceInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MAX];
    NSDate * startDateEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
    NSDate * startDateLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
    NSDate * startTimeEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
    NSDate * startTimeLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
    /* THE PREVIOUS CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getRecommendedEventsSuccess:request withCategoryURI:categoryURI minPrice:minPriceInclusive maxPrice:maxPriceInclusive startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
    } else {
        [self.delegate webConnector:self getRecommendedEventsFailure:request withCategoryURI:categoryURI minPrice:minPriceInclusive maxPrice:maxPriceInclusive startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
    }
}

- (void) getRecommendedEventsFailure:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];

    /* THE FOLLOWING CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    NSDictionary * userInfo = request.userInfo;
    NSString * categoryURI = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY];
    NSNumber * minPriceInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MIN];
    NSNumber * maxPriceInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_PRICE_MAX];
    NSDate * startDateEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
    NSDate * startDateLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
    NSDate * startTimeEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
    NSDate * startTimeLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
    /* THE PREVIOUS CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    
    [self.delegate webConnector:self getRecommendedEventsFailure:request withCategoryURI:categoryURI minPrice:minPriceInclusive maxPrice:maxPriceInclusive startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
    
}

- (void)getEventsListForSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    if (self.availableToMakeWebConnection) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetEventsListSearchURLWithSearchString:searchString startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive]];
        [self.connectionsInProgress addObject:request];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setUsername:@"tester_api"]; 
        [request setPassword:@"abexapi"];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDidFinishSelector:@selector(getEventsListForSearchStringSuccess:)];
        [request setDidFailSelector:@selector(getEventsListForSearchStringFailure:)];
        /* THE FOLLOWING CODE IS DUPLICATED (IN PART) FOR BROWSE (RECOMMENDED) */
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:searchString forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING];
        if (startDateEarliestInclusive != nil) { 
            [userInfo setObject:startDateEarliestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
        }
        if (startDateLatestInclusive != nil) { 
            [userInfo setObject:startDateLatestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
        }
        if (startTimeEarliestInclusive != nil) { 
            [userInfo setObject:startTimeEarliestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
        }
        if (startTimeLatestInclusive != nil) { 
            [userInfo setObject:startTimeLatestInclusive forKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
        }
        request.userInfo = userInfo;
        /* THE PREVIOUS CODE IS DUPLICATED (IN PART) FOR BROWSE (RECOMMENDED) */
        [request startAsynchronous];
    }
}

- (void)getEventsListForSearchStringSuccess:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    /* THE FOLLOWING CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    NSDictionary * userInfo = request.userInfo;
    NSString * searchString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING];
    NSDate * startDateEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
    NSDate * startDateLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
    NSDate * startTimeEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
    NSDate * startTimeLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
    /* THE PREVIOUS CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getEventsListSuccess:request forSearchString:searchString startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
    } else {
        [self.delegate webConnector:self getEventsListFailure:request forSearchString:searchString startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
    }
}

- (void)getEventsListForSearchStringFailure:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];
    
    /* THE FOLLOWING CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    NSDictionary * userInfo = request.userInfo;
    NSString * searchString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING];
    NSDate * startDateEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_EARLIEST];
    NSDate * startDateLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_DATE_LATEST];
    NSDate * startTimeEarliestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_EARLIEST];
    NSDate * startTimeLatestInclusive = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER_TIME_LATEST];
    /* THE PREVIOUS CODE IS DUPLICATED IN FAILURE CALLBACK METHOD, AND (IN PART) IN SEARCH SUCCESS & FAILURE METHODS */
    
    [self.delegate webConnector:self getEventsListFailure:request forSearchString:searchString startDateEarliest:startDateEarliestInclusive startDateLatest:startDateLatestInclusive startTimeEarliest:startTimeEarliestInclusive startTimeLatest:startTimeLatestInclusive];
}

//////////////
// LEARNING //
//////////////

- (void)sendLearnedDataAboutEvent:(NSString *)eventURI withUserAction:(NSString *)userAction {

    if (self.availableToMakeWebConnection) {
        
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildLearnURL]];
        [self.connectionsInProgress addObject:request];
        
        // Build JSON
        NSDictionary * jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:eventURI, @"event", userAction, @"action", nil];
        NSString * jsonString = [jsonDictionary JSONRepresentation];
        
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [request setDelegate:self];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDidFinishSelector:@selector(sendLearnedDataAboutEventSuccess:)];
        [request setDidFailSelector:@selector(sendLearnedDataAboutEventFailure:)];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:eventURI, WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_EVENT_URI, userAction, WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_ACTION, nil];
        request.userInfo = userInfo;
        [request startAsynchronous];

    }
    
}

- (void)sendLearnedDataAboutEventSuccess:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo objectForKey:WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_EVENT_URI];
    NSString * userAction = [userInfo objectForKey:WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_ACTION];
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self sendLearnedDataSuccess:request aboutEvent:eventURI userAction:userAction];
    } else {
        [self.delegate webConnector:self sendLearnedDataFailure:request aboutEvent:eventURI userAction:userAction];
    }
    
}

- (void)sendLearnedDataAboutEventFailure:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * eventURI = [userInfo objectForKey:WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_EVENT_URI];
    NSString * userAction = [userInfo objectForKey:WEB_CONNECTOR_SEND_LEARNED_DATA_ABOUT_EVENT_USER_INFO_KEY_ACTION];
    
    [self.delegate webConnector:self sendLearnedDataFailure:request aboutEvent:eventURI userAction:userAction];
    
}

@end
