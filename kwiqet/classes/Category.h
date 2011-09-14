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
@class CategoryBreadcrumb, EventsWebQuery;

@interface Category : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * colorHex;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * buttonThumb;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSSet* breadcrumbs;
@property (nonatomic, retain) NSSet* events;
@property (nonatomic, retain) NSString * iconThumb;
@property (nonatomic, retain) NSSet *queryLinks;
@end

@interface Category (CoreDataGeneratedAccessors)
- (void)addQueryLinksObject:(EventsWebQuery *)value;
- (void)removeQueryLinksObject:(EventsWebQuery *)value;
- (void)addQueryLinks:(NSSet *)values;
- (void)removeQueryLinks:(NSSet *)values;
@end