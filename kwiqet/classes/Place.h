//
//  Place.h
//  kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Occurrence;

@interface Place : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * placeDescription;
@property (nonatomic, retain) NSString * imageLocation;
@property (nonatomic, retain) NSSet *occurrences;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addOccurrencesObject:(Occurrence *)value;
- (void)removeOccurrencesObject:(Occurrence *)value;
- (void)addOccurrences:(NSSet *)values;
- (void)removeOccurrences:(NSSet *)values;
@end
