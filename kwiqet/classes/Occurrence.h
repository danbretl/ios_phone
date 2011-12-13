//
//  Occurrence.h
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Place, Price;

@interface Occurrence : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSString * oneOffPlace;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSSet * prices;
@property (nonatomic, retain) Event * event;
@property (nonatomic, retain) Place * place;

@property (nonatomic, readonly) NSArray * pricesLowToHigh;
@property (nonatomic, readonly) NSDate * startDatetimeComposite;
@property (nonatomic, readonly) NSDate * endDatetimeComposite;

+ (NSDate *)compositeDatetimeFromDate:(NSDate *)date time:(NSDate *)time;

@end

@interface Occurrence (CoreDataGeneratedAccessors)

- (void)addPricesObject:(Price *)value;
- (void)removePricesObject:(Price *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;
@end
