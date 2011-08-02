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

- (NSArray *)occurrencesChronological {
    return [self.occurrences sortedArrayUsingDescriptors:
            [NSArray arrayWithObjects:
             [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES], 
             [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES],
             nil]];
}

@end
