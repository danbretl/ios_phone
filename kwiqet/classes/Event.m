//
//  Event.m
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "Event.h"
#import "Category.h"
#import "CategoryBreadcrumb.h"
#import "EventSummary.h"
#import "Occurrence.h"
#import "Place.h"
#import <CoreLocation/CoreLocation.h>

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
             [NSSortDescriptor sortDescriptorWithKey:@"isAllDay" ascending:YES], 
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

- (NSArray *) occurrencesByDateVenueTime {
    return [self.occurrences sortedArrayUsingDescriptors:
            [NSArray arrayWithObjects:
             [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"place.title" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"isAllDay" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

// THIS SHOULD BE UPDATED: The bulk of the implementation of this method is repeated in OccurrenceSummaryDate.m
- (NSArray *) occurrencesByDateVenueTimeNearUserLocation:(UserLocation *)userLocation {
    
    if (userLocation != nil) {
        
        CLLocation * userLocationCL = [[[CLLocation alloc] initWithLatitude:userLocation.latitude.doubleValue longitude:userLocation.longitude.doubleValue] autorelease];
        
        NSComparator locationsComparator = ^(id a, id b){
            Place * placeA = a;
            Place * placeB = b;
            CLLocation * locationACL = [[CLLocation alloc] initWithLatitude:placeA.latitude.doubleValue longitude:placeA.longitude.doubleValue];
            CLLocation * locationBCL = [[CLLocation alloc] initWithLatitude:placeB.latitude.doubleValue longitude:placeB.longitude.doubleValue];
            CLLocationDistance distanceA = [locationACL distanceFromLocation:userLocationCL];
            CLLocationDistance distanceB = [locationBCL distanceFromLocation:userLocationCL];
            [locationACL release];
            [locationBCL release];
            NSComparisonResult result = NSOrderedSame;
            if (distanceA < distanceB){
                result = NSOrderedAscending;
            } else if (distanceA > distanceB){
                result = NSOrderedDescending;
            }
            return result;
        };
        
        return [self.occurrences sortedArrayUsingDescriptors:
                [NSArray arrayWithObjects:
                 [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
                 [NSSortDescriptor sortDescriptorWithKey:@"place" ascending:YES comparator:locationsComparator],
                 [NSSortDescriptor sortDescriptorWithKey:@"isAllDay" ascending:YES],
                 [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
                 nil]];
        
    } else {
        return self.occurrencesByDateVenueTime;
    }
    
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
