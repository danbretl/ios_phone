//
//  Occurrence.m
//  Kwiqet
//
//  Created by Dan Bretl on 8/1/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "Occurrence.h"
#import "Event.h"

@implementation Occurrence
@dynamic endDate;
@dynamic endTime;
@dynamic startDate;
@dynamic isAllDay;
@dynamic oneOffPlace;
@dynamic startTime;
@dynamic uri;
@dynamic prices;
@dynamic event;
@dynamic place;

- (NSArray *)pricesLowToHigh {
    return [self.prices sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]]];
}

- (NSDate *)startDatetimeComposite {
    return [Occurrence compositeDatetimeFromDate:self.startDate time:self.startTime];
}

- (NSDate *)endDatetimeComposite {
    return [Occurrence compositeDatetimeFromDate:self.endDate time:self.endTime];
}

+ (NSDate *)compositeDatetimeFromDate:(NSDate *)date time:(NSDate *)time {
    
    NSDate * composite = nil;
    
    if (date && time) {
        
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        NSDateComponents * comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
        composite = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:time];
        composite = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:composite options:0];
   
    } else {
        
        if (date) {
            composite = date;
        } else {
            composite = time;
        }
        
    }
    
    return composite;
    
}

@end
