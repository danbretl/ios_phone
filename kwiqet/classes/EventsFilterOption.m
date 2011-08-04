//
//  EventsFilterOption.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsFilterOption.h"

static NSString * const EFO_ICON_PREFIX = @"ico_";
static NSString * const EFO_ICON_BW_PREFIX = @"bw_";
static NSString * const EFO_ICON_EXT = @".png";

@implementation EventsFilterOption

@synthesize code = code_;
@synthesize readable = readable_;
@synthesize buttonText = buttonText_;
@synthesize buttonView = buttonView_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonText:(NSString *)buttonText buttonView:(UIButtonWithOverlayView *)buttonView {
    
    EventsFilterOption * option = [[EventsFilterOption alloc] init];
    option.code = code;
    if (readable) {
        option.readable = readable;
    }
    option.buttonText = buttonText;
    option.buttonView = buttonView;
    return [option autorelease];
    
}

+ (NSString *)eventsFilterOptionIconFilenameForCode:(NSString *)code grayscale:(BOOL)grayscale {
    
    return [NSString stringWithFormat:@"%@%@%@%@", 
            EFO_ICON_PREFIX,
            grayscale ? EFO_ICON_BW_PREFIX : @"",
            code,
            EFO_ICON_EXT];
    
}

- (void)dealloc {
    [code_ release];
    [readable_ release];
    [buttonText_ release];
    [buttonView_ release];
    [super dealloc];
}

@end
