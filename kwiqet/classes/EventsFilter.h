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
    NSString * buttonText_;
    
    NSMutableArray * options_;
    
}

+ (EventsFilter *) eventsFilterWithCode:(NSString *)filterCode buttonText:(NSString *)buttonText button:(UIButton *)button drawerView:(UIView *)drawerView options:(NSArray *)options;

@property (copy) NSString * code;
@property (copy) NSString * buttonText;
@property (retain) UIButton * button;
@property (retain) UIView * drawerView;
@property (readonly) NSMutableArray * options;

@end