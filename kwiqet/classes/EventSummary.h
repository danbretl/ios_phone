//
//  EventSummary.h
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface EventSummary : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * placeCount;
@property (nonatomic, retain) NSNumber * priceMinimum;
@property (nonatomic, retain) NSDate * startTimeEarliest;
@property (nonatomic, retain) NSDate * startDateEarliest;
@property (nonatomic, retain) NSDate * startTimeLatest;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * startDateLatest;
@property (nonatomic, retain) NSNumber * startDateCount;
@property (nonatomic, retain) NSString * placeAddressEtc;
@property (nonatomic, retain) NSString * placeTitle;
@property (nonatomic, retain) NSNumber * startTimeCount;
@property (nonatomic, retain) NSNumber * priceMaximum;
@property (nonatomic, retain) Event *event;

@end
