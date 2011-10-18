//
//  CategoryBreadcrumb.h
//  kwiqet
//
//  Created by Dan Bretl on 6/27/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Event;

@interface CategoryBreadcrumb : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Event * event;
@property (nonatomic, retain) Category * category;

@end
