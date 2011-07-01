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
- (NSURL *) buildGetEventsListURLWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI;
- (NSURL *) buildGetEventsListRecommendedURL;
- (NSURL *) buildGetEventsListFreeURL;
- (NSURL *) buildGetEventsListPopularURL;
- (NSURL *) buildGetEventsListSearchURLWithSearchString:(NSString *)searchString;

// Event
-(NSURL*)buildCardURLWithID:(NSString*)eventID;

// Featured Event
-(NSURL*)buildGetFeaturedEventURL;

@end
