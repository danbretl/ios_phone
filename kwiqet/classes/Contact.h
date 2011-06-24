//
//  Contact.h
//  kwiqet
//
//  Created by Dan Bretl on 6/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * fbID;
@property (nonatomic, retain) NSString * fbName;

@end
