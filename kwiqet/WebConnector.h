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
#import "JSON.h"
#import "ASIFormDataRequest.h"

extern int const WEB_CONNECTOR_TIMEOUT_LENGTH_DEFAULT;
extern BOOL const WEB_CONNECTOR_ALLOW_SIMULTANEOUS_CONNECTIONS_DEFAULT;

@protocol WebConnectorDelegate;

@interface WebConnector : NSObject {
    URLBuilder * urlBuilder;
    int timeoutLength;
    id<WebConnectorDelegate> delegate;
    BOOL connectionInProgress;
    BOOL allowSimultaneousConnections;
    
}

@property (nonatomic, readonly) URLBuilder * urlBuilder;
@property int timeoutLength;
@property (assign) id<WebConnectorDelegate> delegate;
@property (readonly) BOOL connectionInProgress;
@property BOOL allowSimultaneousConnection;
@property (nonatomic, readonly) BOOL availableToMakeWebConnection;

- (void) getCategoryTree;
- (void) getFeaturedEvent;
- (void) getEventsListWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
- (void) getEventsListForSearchString:(NSString *)searchString;
- (void) sendLearnedDataAboutEvent:(NSString *)eventURI withUserAction:(NSString *)userAction;

@end

@protocol WebConnectorDelegate <NSObject>
@optional
- (void) webConnector:(WebConnector *)webConnector getCategoryTreeSuccess:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getCategoryTreeFailure:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getFeaturedEventSuccess:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getFeaturedEventFailure:(ASIHTTPRequest *)request;
//- (void) webConnector:(WebConnector *)webConnector getEventsListRecommendedSuccess:(ASIHTTPRequest *)request;
//- (void) webConnector:(WebConnector *)webConnector getEventsListRecommendedFailure:(ASIHTTPRequest *)request;
- (void) webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request withFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
- (void) webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request withFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
- (void) webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString;
- (void) webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
- (void) webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction;
@end