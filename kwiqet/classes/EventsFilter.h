//
//  NewEventsFilter.h
//  kwiqet
//
//  Created by Dan Bretl on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const EVENTS_FILTER_CATEGORIES;
extern NSString * const EVENTS_FILTER_PRICE;
extern NSString * const EVENTS_FILTER_DATE;
extern NSString * const EVENTS_FILTER_LOCATION;
extern NSString * const EVENTS_FILTER_TIME;

@interface EventsFilter : NSObject {
    
    UIButton * button_;
    UIView * drawerView_;
    NSString * code_;
    
}

+ (EventsFilter *) eventsFilterWithCode:(NSString *)filterCode button:(UIButton *)button drawerView:(UIView *)drawerView;

@property (copy) NSString * code;
@property (retain) UIButton * button;
@property (retain) UIView * drawerView;

@end