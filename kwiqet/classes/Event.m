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
@dynamic summaryStartDateString;
@dynamic summaryStartTimeString;

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
