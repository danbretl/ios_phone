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

- (NSArray *) occurrencesChronological {
    return [self.occurrences sortedArrayUsingDescriptors:
            [NSArray arrayWithObjects:
             [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES], 
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

- (NSSet *)occurrencesFilteredWithPredicate:(NSPredicate *)predicate {
    NSSet * filteredSet = [self.occurrences filteredSetUsingPredicate:predicate];
    NSMutableString * (^stringFromOccurrencesSet) (NSSet * occurrencesSet) = ^(NSSet * occurrencesSet){
        NSMutableString * occurrencesString = [NSMutableString string];
        for (Occurrence * occurrence in occurrencesSet) {
            [occurrencesString appendFormat:@"\n(%@, %@, %@)", occurrence.startDate, occurrence.place.title, occurrence.startTime];
        }
        return occurrencesString;
    };
    NSLog(@"All occurrences (%d): %@", self.occurrences.count, stringFromOccurrencesSet(self.occurrences));
    NSLog(@"Filtered occurrences (%d): %@", filteredSet.count, stringFromOccurrencesSet(filteredSet));
    return filteredSet;
}

- (NSSet *) occurrencesNotOnDate:(NSDate *)dateNotToMatch {
    NSLog(@"occurrencesNotOnDate:%@", dateNotToMatch);
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate != %@", dateNotToMatch]];
}

- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch notAtPlace:(Place *)placeNotToMatch {
    NSLog(@"occurrencesOnDate:%@ notAtPlace:%@", dateToMatch, placeNotToMatch.title);
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate == %@ && place != %@", dateToMatch, placeNotToMatch]];
}

- (NSSet *) occurrencesOnDate:(NSDate *)dateToMatch atPlace:(Place *)placeToMatch notAtTime:(NSDate *)timeNotToMatch {
    NSLog(@"occurrencesOnDate:%@ atPlace:%@ notAtTime:%@", dateToMatch, placeToMatch.title, timeNotToMatch);
    return [self occurrencesFilteredWithPredicate:
            [NSPredicate predicateWithFormat:@"startDate == %@ && place == %@ && startTime != %@", dateToMatch, placeToMatch, timeNotToMatch]];
}

@end
