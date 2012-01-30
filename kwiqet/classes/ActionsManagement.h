//
//  ActionsManagement.h
//  Kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import <MessageUI/MessageUI.h>
#import "WebDataTranslator.h"
#import <EventKit/EventKit.h>

@interface ActionsManagement : NSObject <UIActionSheetDelegate> {
    
    UIActionSheet * letsGoActionSheet;
    NSMutableArray * letsGoActionSheetSelectors;
    
}

//- (void) showLetsGoActionSheetFromRect:(CGRect)sourceRect inView:(UIView *)viewContainer withCalendar:(BOOL)calendar facebook:(BOOL)facebook;

+ (MFMailComposeViewController *) makeEmailViewControllerForEvent:(Event *)event withMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)mailComposeDelegate usingWebDataTranslator:(WebDataTranslator *)webDataTranslator;

+ (void) addEventToCalendar:(Event *)event usingWebDataTranslator:(WebDataTranslator *)webDataTranslator;

+ (NSMutableDictionary *)makeFacebookEventParametersFromEvent:(Event *)event eventImage:(UIImage *)eventImage;

@end
