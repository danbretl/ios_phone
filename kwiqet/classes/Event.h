//
//  Event.h
//  Kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UserLocation.h"

@class Category, CategoryBreadcrumb, EventSummary, Occurrence, Place, EventResult;

@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * fromSearch;
@property (nonatomic, retain) NSString * imageLocation;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) EventSummary * summaryGeneral;
@property (nonatomic, retain) EventSummary * summaryVenue;
@property (nonatomic, retain) Category *concreteParentCategory;
@property (nonatomic, retain) NSSet * occurrences;
@property (nonatomic, retain) NSSet * concreteCategoryBreadcrumbs;
@property (nonatomic, retain) NSSet * queryResultInclusions;
@property (nonatomic, retain) NSSet * summariesRelativeToVenue;

@property (nonatomic, readonly) NSArray * occurrencesChronological;
@property (nonatomic, readonly) NSArray * occurrencesByDateVenueTime;
- (NSArray *) occurrencesByDateVenueTimeNearUserLocation:(UserLocation *)userLocation;
- (NSSet *) occurrencesNotOnDate:(NSDate *)dateNotToMatch;
- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch notAtPlace:(Place *)placeNotToMatch;
- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch atPlace:(Place *)placeToMatch notAtTime:(NSDate *)timeNotToMatch;
- (EventSummary *) eventSummaryRelativeToVenue:(Place *)venue;

@end

@interface Event (CoreDataGeneratedAccessors)
- (void)addOccurrencesObject:(Occurrence *)value;
- (void)removeOccurrencesObject:(Occurrence *)value;
- (void)addOccurrences:(NSSet *)values;
- (void)removeOccurrences:(NSSet *)values;
- (void)addConcreteCategoryBreadcrumbsObject:(CategoryBreadcrumb *)value;
- (void)removeConcreteCategoryBreadcrumbsObject:(CategoryBreadcrumb *)value;
- (void)addConcreteCategoryBreadcrumbs:(NSSet *)values;
- (void)removeConcreteCategoryBreadcrumbs:(NSSet *)values;
- (void)addQueryResultInclusionsObject:(EventResult *)value;
- (void)removeQueryResultInclusionsObject:(EventResult *)value;
- (void)addQueryResultInclusions:(NSSet *)values;
- (void)removeQueryResultInclusions:(NSSet *)values;
- (void)addSummariesRelativeToVenueObject:(EventSummary *)value;
- (void)removeSummariesRelativeToVenueObject:(EventSummary *)value;
- (void)addSummariesRelativeToVenue:(NSSet *)values;
- (void)removeSummariesRelativeToVenue:(NSSet *)values;
@end
