//
//  NewEventsFilter.h
//  kwiqet
//
//  Created by Dan Bretl on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const EVENTS_NEWFILTER_CATEGORIES;
extern NSString * const EVENTS_NEWFILTER_PRICE;
extern NSString * const EVENTS_NEWFILTER_DATE;
extern NSString * const EVENTS_NEWFILTER_LOCATION;
extern NSString * const EVENTS_NEWFILTER_TIME;

@interface NewEventsFilter : NSObject {
    
    UIButton * button_;
    UIView * drawerView_;
    NSString * code_;
    
}

+ (NewEventsFilter *) newEventsFilterWithCode:(NSString *)filterCode button:(UIButton *)button drawerView:(UIView *)drawerView;

@property (copy) NSString * code;
@property (retain) UIButton * button;
@property (retain) UIView * drawerView;

@end
