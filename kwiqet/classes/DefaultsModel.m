//
//  DefaultsModel.m
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "DefaultsModel.h"

@implementation DefaultsModel

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
