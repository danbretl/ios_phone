//
//  EventInfo.h
//  Abextra
//
//  Created by John Nichols on 3/8/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface EventInfo :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * categoryTitle;
@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSString * categoryColor;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * eventEndTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * eventDate;
@property (nonatomic, retain) NSString * eventTime;
@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * eventCost;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSString * country;

@end



