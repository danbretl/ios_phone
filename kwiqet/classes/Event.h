//
//  Event.h
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;
@class CategoryBreadcrumb;

@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * venue;
@property (nonatomic, retain) NSString * imageLocation;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate   * startDatetime;
@property (nonatomic, retain) NSDate   * endDatetime;
@property (nonatomic, retain) NSNumber * startDateValid;
@property (nonatomic, retain) NSNumber * startTimeValid;
@property (nonatomic, retain) NSNumber * endDateValid;
@property (nonatomic, retain) NSNumber * endTimeValid;
@property (nonatomic, retain) NSNumber * priceMinimum;
@property (nonatomic, retain) NSNumber * priceMaximum;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * fromSearch;
@property (nonatomic, retain) NSString * concreteParentCategoryURI;
@property (nonatomic, retain) Category * concreteParentCategory;
@property (nonatomic, retain) NSSet * concreteCategoryBreadcrumbs;
@property (nonatomic, retain) NSString * url;

@property (nonatomic, retain) NSString * summaryAddress;
@property (nonatomic, retain) NSString * summaryStartDateEarliestString;
@property (nonatomic, retain) NSString * summaryStartTimeEarliestString;
@property (nonatomic, retain) NSNumber * summaryStartDateDistinctCount;
@property (nonatomic, retain) NSString * summaryStartDateLatestString;
@property (nonatomic, retain) NSNumber * summaryStartTimeDistinctCount;
@property (nonatomic, retain) NSString * summaryStartTimeLatestString;
@property (nonatomic, retain) NSNumber * summaryPlaceDistinctCount;

@property (nonatomic, readonly) NSDate * startTimeDatetime;
@property (nonatomic, readonly) NSDate * endTimeDatetime;
@property (nonatomic, readonly) NSDate * startDateDatetime;
@property (nonatomic, readonly) NSDate * endDateDatetime;

@property (nonatomic, retain) NSNumber * orderBrowse;
@property (nonatomic, retain) NSNumber * orderSearch;

@end
