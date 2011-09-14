//
//  Event.m
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "Category.h"
#import "CategoryBreadcrumb.h"
#import "EventSummary.h"
#import "Occurrence.h"
#import "Place.h"

@interface Event()
- (NSSet *) occurrencesFilteredWithPredicate:(NSPredicate *)predicate;
@end

@implementation Event
@dynamic eventDescription;
@dynamic url;
@dynamic featured;
@dynamic fromSearch;
@dynamic imageLocation;
@dynamic uri;
@dynamic title;
@dynamic summary;
@dynamic concreteParentCategory;
@dynamic occurrences;
@dynamic concreteCategoryBreadcrumbs;
@dynamic queryResultInclusions;

- (NSArray *) occurrencesChronological {
    return [self.occurrences sortedArrayUsingDescriptors:
            [NSArray arrayWithObjects:
             [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES], 
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

- (NSArray *) occurrencesByDateVenueTime {
    return [self.occurrences sortedArrayUsingDescriptors:
            [NSArray arrayWithObjects:
             [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"place.title" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

- (NSSet *)occurrencesFilteredWithPredicate:(NSPredicate *)predicate {
    NSSet * filteredSet = [self.occurrences filteredSetUsingPredicate:predicate];
    return filteredSet;
}

- (NSSet *) occurrencesNotOnDate:(NSDate *)dateNotToMatch {
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate != %@", dateNotToMatch]];
}

- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch notAtPlace:(Place *)placeNotToMatch {
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate == %@ && place != %@", dateToMatch, placeNotToMatch]];
}

- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch atPlace:(Place *)placeToMatch notAtTime:(NSDate *)timeNotToMatch {
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate == %@ && place == %@ && startTime != %@", dateToMatch, placeToMatch, timeNotToMatch]];
}

@end
