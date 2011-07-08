//
//  DefaultsModel.h
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const DM_FACEBOOK_ACCESS_INFO_DICTIONARY_ACCESS_TOKEN_KEY = @"DM_FACEBOOK_ACCESS_INFO_DICTIONARY_ACCESS_TOKEN_KEY";
static NSString * const DM_FACEBOOK_ACCESS_INFO_DICTIONARY_EXPIRATION_DATE_KEY = @"DM_FACEBOOK_ACCESS_INFO_DICTIONARY_EXPIRATION_DATE_KEY";

@interface DefaultsModel : NSObject {
    
}

+ (BOOL) isLoggedInWithKwiqet;
+ (void) saveAPIToUserDefaults:(NSString*)loginString;
+ (NSString*) retrieveAPIFromUserDefaults;
+ (void) deleteAPIKey;

+ (void) saveKwiqetUserIdentifierToUserDefaults:(NSString *)identifier;
+ (NSString *) retrieveKwiqetUserIdentifierFromUserDefaults;
+ (void) deleteKwiqetUserIdentifier;

+ (void) saveFacebookAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate attachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier;
+ (NSDictionary *) retrieveFacebookAccessInfoAttachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier;
+ (void) deleteFacebookAccessInfoAttachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier;

+ (void)saveBackgroundDate:(NSString*)date;
+ (NSString*)retrieveBackgroundDate;

+ (void) saveCategoryTreeHasBeenRetrieved:(BOOL)hasBeenRetrieved;
+ (BOOL) loadCategoryTreeHasBeenRetrieved;

+ (void) saveLastFeaturedEventGetDate:(NSDate *)date;
+ (NSDate *) loadLastFeaturedEventGetDate;

+ (void) saveLastEventsListGetDate:(NSDate *)date;
+ (NSDate *) loadLastEventsListGetDate;

+ (void) saveDate:(NSDate *)date withKey:(NSString *)key;
+ (NSDate *) loadDateWithKey:(NSString *)key;

@end
