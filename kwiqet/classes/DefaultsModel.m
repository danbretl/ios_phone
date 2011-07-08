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

#import "DefaultsModel.h"
#import "CryptoUtilities.h"

@implementation DefaultsModel

+ (BOOL)isLoggedInWithKwiqet {
    return [DefaultsModel retrieveAPIFromUserDefaults] != nil;
}

//login methods
+ (void)saveAPIToUserDefaults:(NSString*)loginString {
    NSLog(@"DefaultsModel saveAPIToUserDefaults - loginString=%@", loginString);

    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:loginString forKey:@"API"];
    }
}

+ (NSString*)retrieveAPIFromUserDefaults {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *val = nil;
    
    if (standardUserDefaults) {
        val = [standardUserDefaults objectForKey:@"API"];
    }
    
//    NSLog(@"DefaultsModel retrieveAPIFromUserDefaults - returnValue=%@", val);
    
    return val;
    
}

+ (void)deleteAPIKey  {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"API"];
    
}

+ (void) saveKwiqetUserIdentifierToUserDefaults:(NSString *)identifier {
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:@"kwiqetUserIdentifier"];
}
+ (NSString *) retrieveKwiqetUserIdentifierFromUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kwiqetUserIdentifier"];
}
+ (void) deleteKwiqetUserIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kwiqetUserIdentifier"];
}

+ (void) saveFacebookAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate attachedToKwiqetIdentifier:(NSString *)kwiqetIdentifier {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_ACCESS_TOKEN_POSTFIX]];
    [defaults setObject:expirationDate forKey:[[CryptoUtilities md5Encrypt:kwiqetIdentifier] stringByAppendingFormat:@"%@%@", DM_FACEBOOK_ACCESS_INFO_POSTFIX, DM_FACEBOOK_EXPIRATION_DATE_POSTFIX]];
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

@end
