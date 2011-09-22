//
//  EventsFilterOption.m
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsFilterOption.h"

static NSString * const EFO_ICON_PREFIX = @"ico_";
static NSString * const EFO_ICON_LARGER_PREFIX = @"larger_";
static NSString * const EFO_ICON_BW_PREFIX = @"bw_";
static NSString * const EFO_ICON_EXT = @".png";

@implementation EventsFilterOption

@synthesize code = code_;
@synthesize readable = readable_;
@synthesize buttonText = buttonText_;
@synthesize buttonView = buttonView_;
@synthesize isMostGeneralOption = isMostGeneralOption_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *) eventsFilterOptionCategoryCodeForCategoryURI:(NSString *)categoryURI {
    NSString * postfix = EFO_CODE_CATEGORY_POSTFIX_ALL;
    if (categoryURI != nil) {
        postfix = categoryURI;
    }
    return [NSString stringWithFormat:@"%@%@", EFO_CODE_CATEGORY_PREFIX, postfix];
}

+ (NSString *) categoryURIForEventsFilterOptionCategoryCode:(NSString *)codeForCategoryEFO {
    NSString * categoryURI = nil;
    NSString * strippedString = [codeForCategoryEFO stringByReplacingOccurrencesOfString:EFO_CODE_CATEGORY_PREFIX withString:@""];
    if (![strippedString isEqualToString:EFO_CODE_CATEGORY_POSTFIX_ALL]) {
        categoryURI = strippedString;
    }
    return categoryURI;
}

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonText:(NSString *)buttonText buttonView:(UIButtonWithOverlayView *)buttonView {
    
    EventsFilterOption * option = [[EventsFilterOption alloc] init];
    option.code = code;
    if (readable) {
        option.readable = readable;
    }
    option.buttonText = buttonText;
    option.buttonView = buttonView;
    option.isMostGeneralOption = ([code isEqualToString:EFO_CODE_PRICE_ANY] ||
                                  [code isEqualToString:EFO_CODE_DATE_ANY] ||
                                  [code isEqualToString:EFO_CODE_LOCATION_CITY] ||
                                  [code isEqualToString:EFO_CODE_TIME_ANY] ||
                                  [code isEqualToString:[NSString stringWithFormat:@"%@%@", EFO_CODE_CATEGORY_PREFIX, EFO_CODE_CATEGORY_POSTFIX_ALL]]);
    return [option autorelease];
    
}

+ (NSString *)eventsFilterOptionIconFilenameForCode:(NSString *)code grayscale:(BOOL)grayscale larger:(BOOL)larger {
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", 
            EFO_ICON_PREFIX,
            larger ? EFO_ICON_LARGER_PREFIX : @"",
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
