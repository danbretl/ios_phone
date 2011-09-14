//
//  EventResult.h
//  kwiqet
//
//  Created by Dan Bretl on 9/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, EventsWebQuery;

@interface EventResult : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) EventsWebQuery *query;
@property (nonatomic, retain) Event *event;

@end
