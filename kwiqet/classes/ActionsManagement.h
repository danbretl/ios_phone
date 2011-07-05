//
//  ActionsManagement.h
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import <MessageUI/MessageUI.h>
#import "WebDataTranslator.h"
#import <EventKit/EventKit.h>

@interface ActionsManagement : NSObject {
    
}

+ (MFMailComposeViewController *) makeEmailViewControllerForEvent:(Event *)event withMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)mailComposeDelegate usingWebDataTranslator:(WebDataTranslator *)webDataTranslator;

+ (void) addEventToCalendar:(Event *)event usingWebDataTranslator:(WebDataTranslator *)webDataTranslator;

@end
