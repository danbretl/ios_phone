//
//  ActionsManagement.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionsManagement.h"

@implementation ActionsManagement

+ (MFMailComposeViewController *) makeEmailViewControllerForEvent:(Event *)event withMailComposeDelegate:(id<MFMailComposeViewControllerDelegate>)mailComposeDelegate usingWebDataTranslator:(WebDataTranslator *)webDataTranslator {
    
    NSLog(@"Email"); // Email
    
    NSString * emailTitle = event.title ? [NSString stringWithFormat:@"    <b>%@</b><br><br>", event.title] : @"";
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

@end
