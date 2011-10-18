//
//  NewEventsFilter.m
//  kwiqet
//
//  Created by Dan Bretl on 7/26/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "EventsFilter.h"

NSString * const EVENTS_FILTER_CATEGORIES = @"categories";
NSString * const EVENTS_FILTER_PRICE = @"price";
NSString * const EVENTS_FILTER_DATE = @"date";
NSString * const EVENTS_FILTER_LOCATION = @"location";
NSString * const EVENTS_FILTER_TIME = @"time";

@interface EventsFilter()
@property (retain) NSMutableArray * optionsPrivate;
@end

@implementation EventsFilter
@synthesize button=button_, drawerView=drawerView_, code=code_, buttonText=buttonText_;
@synthesize optionsPrivate=options_, mostGeneralOption=mostGeneralOption_;

+ (EventsFilter *) eventsFilterWithCode:(NSString *)filterCode buttonText:(NSString *)buttonText button:(UIButton *)button drawerView:(UIView *)drawerView options:(NSArray *)options mostGeneralOption:(EventsFilterOption *)mostGeneralOption {
    
    EventsFilter * filter = [[EventsFilter alloc] init];
    filter.code = filterCode;
    filter.button = button;
    filter.buttonText = buttonText;
    filter.drawerView = drawerView;
    if (options) {
        NSMutableArray * optionsMutable = [options mutableCopy];
        filter.optionsPrivate = optionsMutable;
        [optionsMutable release];
    }
    filter.mostGeneralOption = mostGeneralOption;
    
    return [filter autorelease];
}

- (NSMutableArray *) options {
    return self.optionsPrivate;
}

- (EventsFilterOption *)mostGeneralOption {
    EventsFilterOption * returnOption = mostGeneralOption_;
    if (returnOption == nil &&
        self.options &&
        self.options.count > 0) {
        returnOption = self.options.lastObject;
    }
    return returnOption;
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
    [buttonText_ release];
    [drawerView_ release];
    [code_ release];
    [options_ release];
    [mostGeneralOption_ release];
    [super dealloc];
}

@end
