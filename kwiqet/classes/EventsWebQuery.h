//
//  EventsWebQuery.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/13/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    RecommendedQuery = 1,
    SearchQuery = 2,
    VenueQuery = 3,
} QueryType;

@class Category, EventResult, UserLocation, Place;

@interface EventsWebQuery : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * filterTimeBucketString;
@property (nonatomic, retain) NSString * filterDateBucketString;
@property (nonatomic, retain) NSString * filterDistanceBucketString;
@property (nonatomic, retain) NSString * filterPriceBucketString;
@property (nonatomic, retain) NSString * filterLocationString;
@property (nonatomic, retain) NSDate * datetimeQueryExecuted;
@property (nonatomic, retain) NSDate * datetimeQueryCreated;
@property (nonatomic, retain) NSString * searchTerm;
@property (nonatomic, retain) NSSet * eventResults;
@property (nonatomic, retain) NSSet * filterCategories;
@property (nonatomic, retain) UserLocation * filterLocation;
@property (nonatomic, retain) NSNumber * queryType;
@property (nonatomic, retain) Place * filterVenue;

@end

@interface EventsWebQuery (CoreDataGeneratedAccessors)
- (void)addEventResultsObject:(EventResult *)value;
- (void)removeEventResultsObject:(EventResult *)value;
- (void)addEventResults:(NSSet *)values;
- (void)removeEventResults:(NSSet *)values;
- (void)addFilterCategoriesObject:(Category *)value;
- (void)removeFilterCategoriesObject:(Category *)value;
- (void)addFilterCategories:(NSSet *)values;
- (void)removeFilterCategories:(NSSet *)values;
@end

@interface EventsWebQuery (ConvenienceMethods)
@property (nonatomic, readonly) NSArray * eventResultsInOrder;
@property (nonatomic, readonly) NSArray * eventResultsEventsInOrder;
@property (nonatomic, readonly) QueryType queryTypeScalar;
@end

@interface EventsWebQuery (Translations)
@property (nonatomic, readonly) NSNumber * filterPriceMinimum;
@property (nonatomic, readonly) NSNumber * filterPriceMaximum;
@property (nonatomic, readonly) NSDate * filterDateEarliest;
@property (nonatomic, readonly) NSDate * filterDateLatest;
@property (nonatomic, readonly) NSDate * filterTimeEarliest;
@property (nonatomic, readonly) NSDate * filterTimeLatest;
@property (nonatomic, readonly) NSString * geoQueryString;
@end