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
@synthesize buttonView = buttonView_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonView:(UIButtonWithOverlayView *)buttonView {
    EventsFilterOption * option = [[EventsFilterOption alloc] init];
    option.code = code;
    if (readable) {
        option.readable = readable;
    }
    option.buttonView = buttonView;
    return [option autorelease];
}

- (void)dealloc {
    [code_ release];
    [readable_ release];
    [buttonView_ release];
    [super dealloc];
}

@end
