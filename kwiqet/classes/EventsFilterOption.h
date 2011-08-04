//
//  EventsFilterOption.h
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButtonWithOverlayView.h"

@interface EventsFilterOption : NSObject {
 
    NSString * code_;
    NSString * readable_;
    NSString * buttonText_;
    UIButtonWithOverlayView * buttonView_;
    
}

@property (copy) NSString * code;
@property (copy) NSString * readable;
@property (copy) NSString * buttonText;
@property (retain) UIButtonWithOverlayView * buttonView;

+ (EventsFilterOption *) eventsFilterOptionWithCode:(NSString *)code readableString:(NSString *)readable buttonText:(NSString *)buttonText buttonView:(UIButtonWithOverlayView *)buttonView;
+ (NSString *) eventsFilterOptionIconFilenameForCode:(NSString *)code grayscale:(BOOL)grayscale;

@end
