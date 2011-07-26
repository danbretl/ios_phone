//
//  NewEventsFilter.m
//  kwiqet
//
//  Created by Dan Bretl on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewEventsFilter.h"

NSString * const EVENTS_NEWFILTER_CATEGORIES = @"categories";
NSString * const EVENTS_NEWFILTER_PRICE = @"price";
NSString * const EVENTS_NEWFILTER_DATE = @"date";
NSString * const EVENTS_NEWFILTER_LOCATION = @"location";
NSString * const EVENTS_NEWFILTER_TIME = @"time";

@implementation NewEventsFilter
@synthesize button=button_, drawerView=drawerView_, code=code_;

+ (NewEventsFilter *)newEventsFilterWithCode:(NSString *)filterCode button:(UIButton *)button drawerView:(UIView *)drawerView {
    NewEventsFilter * filter = [[NewEventsFilter alloc] init];
    filter.code = filterCode;
    filter.button = button;
    filter.drawerView = drawerView;
    return [filter autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [button_ release];
    [drawerView_ release];
    [code_ release];
    [super dealloc];
}

@end
