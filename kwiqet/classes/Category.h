//
//  Category.h
//  Abextra
//
//  Created by Dan Bretl on 6/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventInfo;
@class CategoryBreadcrumb;

@interface Category : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * colorHex;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSSet * eventsDeprecated;
@property (nonatomic, retain) NSSet * eventsNew;

@end