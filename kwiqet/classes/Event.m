//
//  Event.m
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"


@implementation Event
@dynamic uri;
@dynamic address;
@dynamic venue;
@dynamic imageLocation;
@dynamic title;
@dynamic latitude;
@dynamic longitude;
@dynamic phone;
@dynamic details;
@dynamic startDatetime;
@dynamic endDatetime;
@dynamic startDateValid;
@dynamic startTimeValid;
@dynamic endDateValid;
@dynamic endTimeValid;
@dynamic priceMinimum;
@dynamic priceMaximum;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic featured;
@dynamic concreteParentCategoryURI;
@dynamic concreteParentCategory;
@dynamic fromSearch;

@dynamic summaryAddress;
@dynamic summaryStartDateEarliestString;
@dynamic summaryStartTimeEarliestString;
@dynamic summaryStartDateDistinctCount;
@dynamic summaryStartDateLatestString;
@dynamic summaryStartTimeDistinctCount;
@dynamic summaryStartTimeLatestString;

@dynamic concreteCategoryBreadcrumbs;

- (void)addConcreteCategoryBreadcrumbsObject:(CategoryBreadcrumb *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"concreteCategoryBreadcrumbs"] addObject:value];
    [self didChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeConcreteCategoryBreadcrumbsObject:(CategoryBreadcrumb *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"concreteCategoryBreadcrumbs"] removeObject:value];
    [self didChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addConcreteCategoryBreadcrumbs:(NSSet *)value {    
    [self willChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"concreteCategoryBreadcrumbs"] unionSet:value];
    [self didChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeConcreteCategoryBreadcrumbs:(NSSet *)value {
    [self willChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"concreteCategoryBreadcrumbs"] minusSet:value];
    [self didChangeValueForKey:@"concreteCategoryBreadcrumbs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (NSDate *)startTimeDatetime {
    return ([self.startTimeValid boolValue] ? self.startDatetime : nil);
}

- (NSDate *)endTimeDatetime {
    return ([self.endTimeValid boolValue] ? self.endDatetime : nil);
}

- (NSDate *)startDateDatetime {
    return ([self.startDateValid boolValue] ? self.startDatetime : nil);
}

- (NSDate *)endDateDatetime {
    return ([self.endDateValid boolValue] ? self.endDatetime : nil);
}

@end
