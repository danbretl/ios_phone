//
//  DefaultsModel.h
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DefaultsModel : NSObject {
    
}

+ (void)saveAPIToUserDefaults:(NSString*)loginString;
+ (NSString*)retrieveAPIFromUserDefaults;
+ (void)deleteAPIKey;

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
