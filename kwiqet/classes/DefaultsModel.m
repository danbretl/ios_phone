//
//  DefaultsModel.m
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

static NSString * const DM_FACEBOOK_ACCESS_INFO_POSTFIX = @"_fbAccessInfo";
static NSString * const DM_FACEBOOK_ACCESS_TOKEN_POSTFIX = @"_accessToken";
static NSString * const DM_FACEBOOK_EXPIRATION_DATE_POSTFIX = @"_expirationDate";
static NSString * const DM_TAB_BAR_SELECTED_INDEX_KEY = @"DM_TAB_BAR_SELECTED_INDEX_KEY";

#import "DefaultsModel.h"
#import "CryptoUtilities.h"

@implementation DefaultsModel

+ (BOOL) synchronize {
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLoggedInWithKwiqet {
    return [DefaultsModel loadAPIKey] != nil;
}

//login methods
+ (void)saveAPIKey:(NSString*)loginString {
    NSLog(@"DefaultsModel saveAPIKey - loginString=%@", loginString);

    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:loginString forKey:@"API"];
    }
}

+ (NSString*)loadAPIKey {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    
    if (standardUserDefaults) {
        val = [standardUserDefaults objectForKey:@"API"];
    }
    
//    NSLog(@"DefaultsModel loadAPIKey - returnValue=%@", val);
    
    return val;
    
}

+ (BOOL)loadIsUserLoggedIn {
    return ([DefaultsModel loadAPIKey] != nil);
}

+ (void)deleteAPIKey  {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"API"];
    
}

+ (void) saveKwiqetUserIdentifierToUserDefaults:(NSString *)identifier {
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"KwiqetUserIdentifier"];
}
+ (NSString *) retrieveKwiqetUserIdentifierFromUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"KwiqetUserIdentifier"];
}
+ (void) deleteKwiqetUserIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"KwiqetUserIdentifier"];
}

+ (void) saveFacebookAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate attachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_ACCESS_TOKEN_POSTFIX]];
    [defaults setObject:expirationDate forKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_EXPIRATION_DATE_POSTFIX]];
//    NSLog(@"*** *** *** facebook accessToken %@", accessToken);
//    NSLog(@"*** *** *** facebook expirationDate %@", expirationDate);
}
+ (NSDictionary *) retrieveFacebookAccessInfoAttachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier {
    NSString * accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_ACCESS_TOKEN_POSTFIX]];
    NSDate * expirationDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_EXPIRATION_DATE_POSTFIX]];
    return [NSDictionary dictionaryWithObjectsAndKeys:accessToken, DM_FACEBOOK_ACCESS_INFO_DICTIONARY_ACCESS_TOKEN_KEY, expirationDate, DM_FACEBOOK_ACCESS_INFO_DICTIONARY_EXPIRATION_DATE_KEY, nil];
}
+ (void) deleteFacebookAccessInfoAttachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_ACCESS_TOKEN_POSTFIX]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_EXPIRATION_DATE_POSTFIX]];
}

+ (void)saveBackgroundDate:(NSString*)date  {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:date forKey:@"BackgroundDate"];
    }
}

+ (NSString*)retrieveBackgroundDate  {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    if (standardUserDefaults) {
        val = [standardUserDefaults objectForKey:@"BackgroundDate"];
    }
    return val;
}

+ (void) saveCategoryTreeHasBeenRetrieved:(BOOL)hasBeenRetrieved {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setBool:hasBeenRetrieved forKey:@"CategoryTreeRetrieved"];
    }
}

+ (BOOL)loadCategoryTreeHasBeenRetrieved {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = false;
    if (standardUserDefaults) {
        value = [standardUserDefaults boolForKey:@"CategoryTreeRetrieved"];
    }
    return value;
}

//+ (void) saveEventsListMostRecentMode:(EventsListMode)eventsListMode {
//    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    if (standardUserDefaults) {
//        [standardUserDefaults setInteger:eventsListMode forKey:@"EventsListMostRecentMode"];
//    }
//    NSLog(@"DefaultsModel saveEventsListMostRecentMode:%@", [DefaultsModel descriptionOfEventsListMode:eventsListMode]);
//}
//+ (EventsListMode) loadEventsListMostRecentMode {
//    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    EventsListMode eventsListMode = ModeNotSet;
//    if (standardUserDefaults) {
//        eventsListMode = [standardUserDefaults integerForKey:@"EventsListMostRecentMode"];
//    }
//    NSLog(@"DefaultsModel loadEventsListMostRecentMode %@", [DefaultsModel descriptionOfEventsListMode:eventsListMode]);
//    return eventsListMode;
//}

//+ (NSString *)descriptionOfEventsListMode:(EventsListMode)eventsListMode {
//    NSString * descriptionString = nil;
//    switch (eventsListMode) {
//        case ModeNotSet: descriptionString = @"ModeNotSet"; break;
//        case ModeBrowse: descriptionString = @"ModeBrowse"; break;
//        case ModeSearch: descriptionString = @"ModeSearch"; break;
//        default: break;
//    }
//    return descriptionString;
//}


+ (void) saveCategoryTreeMostRecentRetrievalDate:(NSDate *)date {
    [self saveDate:date withKey:@"CategoryTreeMostRecentRetrievalDate"];
}
+ (NSDate *) loadCategoryTreeMostRecentRetrievalDate {
    return [self loadDateWithKey:@"CategoryTreeMostRecentRetrievalDate"];
}

+ (void)saveLastFeaturedEventGetDate:(NSDate *)date {
    [self saveDate:date withKey:@"LastFeaturedEventGetDate"];
}

+ (NSDate *)loadLastFeaturedEventGetDate {
    return [self loadDateWithKey:@"LastFeaturedEventGetDate"];
}

+ (void) saveLastEventsListGetDate:(NSDate *)date {
    [self saveDate:date withKey:@"LastEventsListGetDate"];
}

+ (NSDate *)loadLastEventsListGetDate {
    return [self loadDateWithKey:@"LastEventsListGetDate"];
}

+ (void)saveDate:(NSDate *)date withKey:(NSString *)key {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:date forKey:key];
    }
}

+ (NSDate *)loadDateWithKey:(NSString *)key {
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDate * lastFeaturedEventGetDate = nil;
    if (standardUserDefaults) {
        lastFeaturedEventGetDate = (NSDate*)[standardUserDefaults objectForKey:key];
    }
    return lastFeaturedEventGetDate;
}

+ (void) saveTabBarSelectedIndex:(NSUInteger)index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:DM_TAB_BAR_SELECTED_INDEX_KEY];
}

+ (NSUInteger) loadTabBarSelectedIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:DM_TAB_BAR_SELECTED_INDEX_KEY];
}

@end
