//
//  Event.h
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, CategoryBreadcrumb, EventSummary, Occurrence, Place;

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
@property (nonatomic, retain) EventSummary *summary;
@property (nonatomic, retain) Category *concreteParentCategory;
@property (nonatomic, retain) NSSet * occurrences;
@property (nonatomic, retain) NSSet * concreteCategoryBreadcrumbs;

@property (nonatomic, readonly) NSArray * occurrencesChronological;
- (NSSet *) occurrencesNotOnDate:(NSDate *)dateNotToMatch;
- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch notAtPlace:(Place *)placeNotToMatch;
- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch atPlace:(Place *)placeToMatch notAtTime:(NSDate *)timeNotToMatch;

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
@end
