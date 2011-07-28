//
//  EventsFilterOption.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsFilterOption.h"

@implementation EventsFilterOption

@synthesize code = code_;
@synthesize readable = readable_;
@synthesize button = button_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable button:(UIButton *)button {
    EventsFilterOption * option = [[EventsFilterOption alloc] init];
    option.code = code;
    if (readable) {
        option.readable = readable;
    }
    option.button = button;
    return [option autorelease];
}

@end
