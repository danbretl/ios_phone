//
//  Price.h
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Occurrence;

@interface Price : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) Occurrence *occurrence;

@end
