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
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER = @"filterString";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY = @"categoryURI";
static NSString * const WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING = @"searchString";
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
- (void) getEventsListSuccess:(ASIHTTPRequest *)request;
- (void) getEventsListFailure:(ASIHTTPRequest *)request;
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

- (void) getEventsListWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI {
    if (self.availableToMakeWebConnection) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetEventsListURLWithFilter:filterString categoryURI:categoryURI]];
        [self.connectionsInProgress addObject:request];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(getEventsListSuccess:)];
        [request setDidFailSelector:@selector(getEventsListFailure:)];
        [request setTimeOutSeconds:self.timeoutLength];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:filterString, WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER, categoryURI, WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY, nil];
        request.userInfo = userInfo;
        [request startAsynchronous];
    }
}

- (void) getEventsListSuccess:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];

    NSDictionary * userInfo = request.userInfo;
    NSString * filterString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER];
    NSString * categoryURI = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY];
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getEventsListSuccess:request withFilter:filterString categoryURI:categoryURI];
    } else {
        [self.delegate webConnector:self getEventsListFailure:request withFilter:filterString categoryURI:categoryURI];
    }
}

- (void) getEventsListFailure:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * filterString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_FILTER];
    NSString * categoryURI = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_CATEGORY];
    
    [self.delegate webConnector:self getEventsListFailure:request withFilter:filterString categoryURI:categoryURI];
    
}

- (void)getEventsListForSearchString:(NSString *)searchString {
    if (self.availableToMakeWebConnection) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[self.urlBuilder buildGetEventsListSearchURLWithSearchString:searchString]];
        [self.connectionsInProgress addObject:request];
        [request setRequestMethod:@"GET"];
        [request setDelegate:self];
        [request setUsername:@"tester_api"]; 
        [request setPassword:@"abexapi"];
        [request setTimeOutSeconds:self.timeoutLength];
        [request setDidFinishSelector:@selector(getEventsListForSearchStringSuccess:)];
        [request setDidFailSelector:@selector(getEventsListForSearchStringFailure:)];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:searchString, WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING, nil];
        request.userInfo = userInfo;
        [request startAsynchronous];
    }
}

- (void)getEventsListForSearchStringSuccess:(ASIHTTPRequest *)request {
    
    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * searchString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING];
    
    // There is still a possibility that we successfully got a response, but that that response is nil. We should check for this, and switch our assessment to "failure" if necessary.
    if (request) {
        [self.delegate webConnector:self getEventsListSuccess:request forSearchString:searchString];
    } else {
        [self.delegate webConnector:self getEventsListFailure:request forSearchString:searchString];
    }
}

- (void)getEventsListForSearchStringFailure:(ASIHTTPRequest *)request {

    [self.connectionsInProgress removeObject:request];
    
    NSDictionary * userInfo = request.userInfo;
    NSString * searchString = [userInfo objectForKey:WEB_CONNECTOR_GET_EVENTS_LIST_USER_INFO_KEY_SEARCH_STRING];
    
    [self.delegate webConnector:self getEventsListFailure:request forSearchString:searchString];
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
