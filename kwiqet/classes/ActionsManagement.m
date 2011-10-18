//
//  ActionsManagement.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "ActionsManagement.h"
#import "Occurrence.h"
#import "Place.h"
#import "Price.h"

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
    
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    
    NSString * emailLinkOpen = event.url ? [NSString stringWithFormat:@"<a href='%@'>", event.url] : @"";
    NSString * emailLinkClose = event.url ? @"</a>" : @"";
    NSString * emailTitle = event.title ? [NSString stringWithFormat:@"    <b>%@%@%@</b><br><br>", emailLinkOpen, event.title, emailLinkClose] : @"";
    NSString * emailLocation = firstOccurrence.place.title ? [NSString stringWithFormat:@"    Location: %@<br>", firstOccurrence.place.title] : @"";
    NSString * emailAddressFirst = firstOccurrence.place.address ? firstOccurrence.place.address : @"";
    NSString * emailAddressSecond = [webDataTranslator addressSecondLineStringFromCity:firstOccurrence.place.city state:firstOccurrence.place.state zip:firstOccurrence.place.zip];
    if (firstOccurrence.place.address && emailAddressSecond) { emailAddressFirst = [emailAddressFirst stringByAppendingString:@", "]; }
    if (!emailAddressSecond) { emailAddressSecond = @""; }
    NSString * emailAddressFull = ([emailAddressFirst isEqualToString:@""] && [emailAddressSecond isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"    Address: %@%@<br>", emailAddressFirst, emailAddressSecond];
    NSString * emailTime = [webDataTranslator timeSpanStringFromStartDatetime:firstOccurrence.startTime endDatetime:firstOccurrence.endTime separatorString:nil dataUnavailableString:@""];
    if (![emailTime length] == 0) {
        emailTime = [NSString stringWithFormat:@"    Time: %@<br>", emailTime];
    }
    NSString * emailDate = [webDataTranslator dateSpanStringFromStartDatetime:firstOccurrence.startDate endDatetime:firstOccurrence.endDate relativeDates:YES dataUnavailableString:@""];
    if (![emailDate length] == 0) {
        emailDate = [NSString stringWithFormat:@"    Date: %@<br>", emailDate];
    }
    NSArray * prices = firstOccurrence.pricesLowToHigh;
    Price * minPrice = nil;
    Price * maxPrice = nil;
    if (prices && prices.count > 0) {
        minPrice = [prices objectAtIndex:0];
        maxPrice = prices.lastObject;
    }
    NSString * emailPrice = [webDataTranslator priceRangeStringFromMinPrice:minPrice.value maxPrice:maxPrice.value separatorString:nil dataUnavailableString:@""];
    if (![emailPrice length] == 0) {
        emailPrice = [NSString stringWithFormat:@"    Price: %@", emailPrice];
    }
    NSString * emailDescription = event.eventDescription ? event.eventDescription : @"";
    emailDescription = !([emailDescription length] == 0) ? [NSString stringWithFormat:@"<br><br>%@", emailDescription] : @"";
    
    NSString * emailMap = @"";
    if (firstOccurrence.place.latitude && firstOccurrence.place.longitude) {
        NSString * mapSearchQuery = [[[NSString stringWithFormat:@"%@ %@ %@", (firstOccurrence.place.title ? firstOccurrence.place.title : @""), emailAddressFirst, emailAddressSecond] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%f,%f", mapSearchQuery, [firstOccurrence.place.latitude floatValue], [firstOccurrence.place.longitude floatValue]];
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
    
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    
    // Add event to the device's iCal
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEvent * newEvent = [EKEvent eventWithEventStore:eventStore];
    
    newEvent.title = event.title;
    newEvent.startDate = firstOccurrence.startDatetimeComposite;
    NSLog(@"%@", newEvent.startDate);
    newEvent.allDay = firstOccurrence.startTime == nil;
    if (firstOccurrence.endDate != nil) {
        newEvent.endDate = firstOccurrence.endDatetimeComposite;
    } else {
        newEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:newEvent.startDate];
    }
    newEvent.location = firstOccurrence.place.title;
    NSMutableString * iCalEventNotes = [NSMutableString string];
    NSString * addressLineFirst = firstOccurrence.place.address;
    NSString * addressLineSecond = [webDataTranslator addressSecondLineStringFromCity:firstOccurrence.place.city state:firstOccurrence.place.state zip:firstOccurrence.place.zip];
    if (addressLineFirst) { 
        [iCalEventNotes appendFormat:@"%@\n", addressLineFirst]; 
    }
    if (addressLineSecond) {
        [iCalEventNotes appendFormat:@"%@\n", addressLineSecond];
    }
    if (addressLineFirst || addressLineSecond) {
        [iCalEventNotes appendString:@"\n"];
    }
    [iCalEventNotes appendString:event.eventDescription];
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
    
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    
    NSDate * startDate = firstOccurrence.startDatetimeComposite;
    NSDate * endDate = [startDate dateByAddingTimeInterval:3600];
    if (firstOccurrence.endTime != nil) {
        endDate = firstOccurrence.endDatetimeComposite;
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
    
    NSString * locationName = firstOccurrence.place.title;
    if (locationName) {
        [parameters setObject:locationName forKey:@"location"];
    }
    
    if (firstOccurrence.place.address) { 
        [parameters setObject:firstOccurrence.place.address forKey:@"street"];
    }
    if (firstOccurrence.place.city) { 
        [parameters setObject:firstOccurrence.place.city forKey:@"city"];
    }
    if (firstOccurrence.place.state) { 
        [parameters setObject:firstOccurrence.place.state forKey:@"state"];
    }
    if (firstOccurrence.place.zip) { 
        [parameters setObject:firstOccurrence.place.zip forKey:@"zip"];
    }
    [parameters setValue:@"USA" forKey:@"country"];
    if (firstOccurrence.place.latitude) {
        [parameters setObject:[NSString stringWithFormat:@"%@", firstOccurrence.place.latitude] forKey:@"latitude"];
    }
    if (firstOccurrence.place.longitude) {
        [parameters setObject:[NSString stringWithFormat:@"%@", firstOccurrence.place.longitude] forKey:@"longitude"];
    }
    NSMutableString * facebookEventDescription = [NSMutableString string];
    if (event.eventDescription) {
        [facebookEventDescription appendString:event.eventDescription];
        if (event.url) {
            [facebookEventDescription appendString:@"\n\n"];
        }
    }
    if (event.url) {
        [facebookEventDescription appendFormat:@"View this event on Kwiqet.com: %@", event.url];
    }
    [parameters setObject:facebookEventDescription forKey:@"description"];

    if (eventImage) {
        [parameters setObject:eventImage forKey:@"picture"];
    }
    
    NSLog(@"facebook event parameters: %@", parameters);
    
    return parameters;
    
}

@end
