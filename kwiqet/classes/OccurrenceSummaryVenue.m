//
//  OccurrenceSummaryVenue.m
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OccurrenceSummaryVenue.h"

@interface OccurrenceSummaryVenue()
@property (retain) NSArray * occurrencesPrivate;
@property (copy) NSString * timesStringPrivate;
@end

@implementation OccurrenceSummaryVenue

@synthesize place=place_;
@synthesize occurrencesPrivate=occurrences_;
@synthesize timesStringPrivate=timesString_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)timesString {
    return self.timesStringPrivate;
}

- (NSArray *)occurrences {
    return self.occurrencesPrivate;
}

- (void) setOccurrences:(NSArray *)occurrences makeTimesSummaryUsingTimeFormatter:(NSDateFormatter *)timeFormatter {
    self.occurrencesPrivate = occurrences;
    NSMutableString * developingTimesString = [NSMutableString string];
    for (Occurrence * occurrence in self.occurrences) {
        if (occurrence.startTime != nil) {
            [developingTimesString appendFormat:@"%@, ", [timeFormatter stringFromDate:occurrence.startTime]];
        }
    }
    int endCharactersToSubtract = developingTimesString.length > 0 ? 2 : 0;
    self.timesStringPrivate = [developingTimesString substringToIndex:developingTimesString.length - endCharactersToSubtract];
}

- (void)dealloc {
    [place_ release];
    [occurrences_ release];
    [timesString_ release];
    [super dealloc];
}

@end
