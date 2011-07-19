//
//  ActionsManagement.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionsManagement.h"

@interface ActionsManagement()
@property (retain) UIActionSheet * letsGoActionSheet;
@property (retain) NSMutableArray * letsGoActionSheetSelectors;
@end

@implementation ActionsManagement
@synthesize letsGoActionSheet, letsGoActionSheetSelectors;

- (void)dealloc {
    [letsGoActionSheet release];
    [letsGoActionSheetSelectors release];
    [super dealloc];
}

//- (void) showLetsGoActionSheetFromRect:(CGRect)sourceRect inView:(UIView *)viewContainer withCalendar:(BOOL)calendar facebook:(BOOL)facebook {
//    
//    // Lets go choices
//    self.letsGoActionSheet = [[[UIActionSheet alloc] initWithTitle:@"What would you like to do with this event?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
//    self.letsGoActionSheetSelectors = [NSMutableArray array];
//    BOOL moreSocialChoicesToBeHad = NO;
//    // Add to calendar
//    if (calendar) {
//        [self.letsGoActionSheet addButtonWithTitle:@"Add to Calendar"];
//        [letsGoActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToAddToCalendar)]];        
//    }
//    // Create Facebook event
//    if (facebook) {
//        [self.letsGoActionSheet addButtonWithTitle:@"Create Facebook Event"];
//        [letsGoActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToCreateFacebookEvent)]];
//    } else {
//        moreSocialChoicesToBeHad = YES;
//    }
//    // Post to Twitter
//    // ...
//    // Cancel button
//    [self.letsGoActionSheet addButtonWithTitle:@"Cancel"];
//    self.letsGoActionSheet.cancelButtonIndex = self.letsGoActionSheet.numberOfButtons - 1;
//    // Title modification
//    if (moreSocialChoicesToBeHad) {
//        self.letsGoActionSheet.title = [self.letsGoActionSheet.title stringByAppendingString:@" Connect your social networks in the 'Settings' tab for even more options."];
//    }
//    // Show action sheet
//    [self.letsGoActionSheet showFromRect:sourceRect inView:viewContainer animated:YES];
//    
//}
//
//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    
//}
//
//- (void) pushedToAddToCalendar {
//    // Add to calendar
//    [ActionsManagement addEventToCalendar:self.event usingWebDataTranslator:self.webDataTranslator];
//    // Show confirmation alert
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//    
//}
//- (void) pushedToCreateFacebookEvent {
//    ContactsSelectViewController * contactsSelectViewController = [[ContactsSelectViewController alloc] initWithNibName:@"ContactsSelectViewController" bundle:[NSBundle mainBundle]];
//    //            contactsSelectViewController.contactsAll = [self.coreDataModel getAllFacebookContacts];
//    contactsSelectViewController.delegate = self;
//    contactsSelectViewController.coreDataModel = self.coreDataModel;
//    [self presentModalViewController:contactsSelectViewController animated:YES];
//    [contactsSelectViewController release];
//}

+ (MFMailComposeViewController *) makeEmailViewControllerForEvent:(Event *)event withMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)mailComposeDelegate usingWebDataTranslator:(WebDataTranslator *)webDataTranslator {
    
    NSLog(@"Email"); // Email
    
    NSString * emailLinkOpen = event.url ? [NSString stringWithFormat:@"<a href='%@'>", event.url] : @"";
    NSString * emailLinkClose = event.url ? @"</a>" : @"";
    NSString * emailTitle = event.title ? [NSString stringWithFormat:@"    <b>%@%@%@</b><br><br>", emailLinkOpen, event.title, emailLinkClose] : @"";
    NSString * emailLocation = event.venue ? [NSString stringWithFormat:@"    Location: %@<br>", event.venue] : @"";
    NSString * emailAddressFirst = event.address ? event.address : @"";
    NSString * emailAddressSecond = [webDataTranslator addressSecondLineStringFromCity:event.city state:event.state zip:event.zip];
    if (event.address && emailAddressSecond) { emailAddressFirst = [emailAddressFirst stringByAppendingString:@", "]; }
    if (!emailAddressSecond) { emailAddressSecond = @""; }
    NSString * emailAddressFull = ([emailAddressFirst isEqualToString:@""] && [emailAddressSecond isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"    Address: %@%@<br>", emailAddressFirst, emailAddressSecond];
    NSString * emailTime = [webDataTranslator timeSpanStringFromStartDatetime:event.startTimeDatetime endDatetime:event.endTimeDatetime dataUnavailableString:@""];
    if (![emailTime length] == 0) {
        emailTime = [NSString stringWithFormat:@"    Time: %@<br>", emailTime];
    }
    NSString * emailDate = [webDataTranslator dateSpanStringFromStartDatetime:event.startDateDatetime endDatetime:event.endDateDatetime relativeDates:YES dataUnavailableString:@""];
    if (![emailDate length] == 0) {
        emailDate = [NSString stringWithFormat:@"    Date: %@<br>", emailDate];
    }
    NSString * emailPrice = [webDataTranslator priceRangeStringFromMinPrice:event.priceMinimum maxPrice:event.priceMaximum dataUnavailableString:@""];
    if (![emailPrice length] == 0) {
        emailPrice = [NSString stringWithFormat:@"    Price: %@", emailPrice];
    }
    NSString * emailDescription = event.details ? event.details : @"";
    emailDescription = !([emailDescription length] == 0) ? [NSString stringWithFormat:@"<br><br>%@", emailDescription] : @"";
    
    NSString * emailMap = @"";
    if (event.latitude && event.longitude) {
        NSString * mapSearchQuery = [[[NSString stringWithFormat:@"%@ %@ %@", (event.venue ? event.venue : @""), emailAddressFirst, emailAddressSecond] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%f,%f", mapSearchQuery, [event.latitude floatValue], [event.longitude floatValue]];
        emailMap = [NSString stringWithFormat:@"    <a href='%@'>Click here for map</a><br>", urlString];
    }
    
    //create message body with event title and description
    NSString *mailString = [NSString stringWithFormat:@"Hey! I found this event on Kwiqet. We should go!<br><br>%@%@%@%@%@%@%@%@", emailTitle, emailLocation, emailAddressFull, emailMap, emailTime, emailDate, emailPrice, emailDescription];
    
    //call mail app to front as modal window
    MFMailComposeViewController * controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = mailComposeDelegate;
    [controller setSubject:@"You're Invited via Kwiqet"];
    [controller setMessageBody:mailString isHTML:YES];
    return [controller autorelease];
    
}

+ (void)addEventToCalendar:(Event *)event usingWebDataTranslator:(WebDataTranslator *)webDataTranslator {
    
    // Add event to the device's iCal
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEvent * newEvent = [EKEvent eventWithEventStore:eventStore];
    
    newEvent.title = event.title;
    newEvent.startDate = event.startDatetime;
    NSLog(@"%@", newEvent.startDate);
    newEvent.allDay = ![event.startTimeValid boolValue];
    if ([event.endDateValid boolValue]) {
        newEvent.endDate = event.endDatetime;
    } else {
        newEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:newEvent.startDate];
    }
    newEvent.location = event.venue;
    NSMutableString * iCalEventNotes = [NSMutableString string];
    NSString * addressLineFirst = event.address;
    NSString * addressLineSecond = [webDataTranslator addressSecondLineStringFromCity:event.city state:event.state zip:event.zip];
    if (addressLineFirst) { 
        [iCalEventNotes appendFormat:@"%@\n", addressLineFirst]; 
    }
    if (addressLineSecond) {
        [iCalEventNotes appendFormat:@"%@\n", addressLineSecond];
    }
    if (addressLineFirst || addressLineSecond) {
        [iCalEventNotes appendString:@"\n"];
    }
    [iCalEventNotes appendString:event.details];
    newEvent.notes = iCalEventNotes;
    
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError * err;
    [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&err];
    if (err != nil) { NSLog(@"error"); }
    [eventStore release];
    
}

+ (NSDictionary *)makeFacebookEventParametersFromEvent:(Event *)event eventImage:(UIImage *)eventImage {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    NSString * title = event.title;
    [parameters setObject:title forKey:@"name"];
    
    NSDate * startDate = event.startDatetime;
    NSDate * endDate = [startDate dateByAddingTimeInterval:3600];
    if ([event.endTimeValid boolValue]) {
        endDate = event.endDatetime;
    }
    NSTimeInterval startDateTimeInterval = [startDate timeIntervalSince1970];
    NSTimeInterval endDateTimeInterval = [endDate timeIntervalSince1970];
    // TEMPORARY HACK FIX FOR FACEBOOK TIMEZONE PROBLEM
    {
        NSTimeZone * pacificTimeZone = [NSTimeZone timeZoneWithName:@"US/Pacific"];
        NSTimeZone * easternTimeZone = [NSTimeZone timeZoneWithName:@"US/Eastern"]; // THIS SHOULD NOT BE HARDCODED AS THE EASTERN TIME ZONE - IT SHOULD BE THE TIME ZONE OF WHEREVER THE EVENT IS TAKING PLACE.
        NSTimeInterval pacificInterval = [pacificTimeZone secondsFromGMT];
        NSTimeInterval easternInterval = [easternTimeZone secondsFromGMT];
        NSLog(@"%f %f", pacificInterval, easternInterval);
        startDateTimeInterval += (easternInterval - pacificInterval);
        endDateTimeInterval += (easternInterval - pacificInterval);
    }
    [parameters setObject:[NSString stringWithFormat:@"%.0f", startDateTimeInterval] forKey:@"start_time"];
    [parameters setObject:[NSString stringWithFormat:@"%.0f", endDateTimeInterval] forKey:@"end_time"];
    
    NSString * locationName = event.venue;
    if (locationName) {
        [parameters setObject:locationName forKey:@"location"];
    }
    
    if (event.address) { 
        [parameters setObject:event.address forKey:@"street"];
    }
    if (event.city) { 
        [parameters setObject:event.city forKey:@"city"];
    }
    if (event.state) { 
        [parameters setObject:event.state forKey:@"state"];
    }
    if (event.zip) { 
        [parameters setObject:event.zip forKey:@"zip"];
    }
    [parameters setValue:@"USA" forKey:@"country"];
    if (event.latitude) {
        [parameters setObject:[NSString stringWithFormat:@"%@", event.latitude] forKey:@"latitude"];
    }
    if (event.longitude) {
        [parameters setObject:[NSString stringWithFormat:@"%@", event.longitude] forKey:@"longitude"];
    }
    if (event.details) {
        [parameters setObject:event.details forKey:@"description"];
    }
    if (eventImage) {
        [parameters setObject:eventImage forKey:@"picture"];
    }
    
    NSLog(@"facebook event parameters: %@", parameters);
    
    return parameters;
    
}

@end
