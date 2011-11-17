//
//  UserLocation.h
//  kwiqet
//
//  Created by Dan Bretl on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventsWebQuery;

@interface UserLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * accuracy;
@property (nonatomic, retain) NSString * addressFormatted;
@property (nonatomic, retain) NSString * typeGoogle;
@property (nonatomic, retain) NSString * typeKwiqet;
@property (nonatomic, retain) NSSet * queries;
@property (nonatomic, retain) NSNumber * isManual;
@property (nonatomic, retain) NSDate * datetimeRecorded;
@property (nonatomic, retain) NSDate * datetimeLastUsed;
@end

@interface UserLocation (CoreDataGeneratedAccessors)

- (void)addQueriesObject:(EventsWebQuery *)value;
- (void)removeQueriesObject:(EventsWebQuery *)value;
- (void)addQueries:(NSSet *)values;
- (void)removeQueries:(NSSet *)values;
@end
