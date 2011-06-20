//
//  FeaturedEventManager.m
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedEventManager.h"
#import "WebUtil.h"

@implementation FeaturedEventManager

@synthesize coreDataModel;

- (Event *)featuredEvent {
    return [self.coreDataModel getFeaturedEvent];
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

- (void)processAndAddOrUpdateFeaturedEventCoreDataObjectFromFeaturedEventJSONDictionary:(NSDictionary *)jsonDictionary {
        
    NSDictionary * firstOccurrenceDictionary = [[jsonDictionary valueForKey:@"occurrences"] objectAtIndex:0];

    NSString * uri = [WebUtil stringOrNil:[jsonDictionary objectForKey:@"resource_uri"]];
    NSString * titleText = [WebUtil stringOrNil:[jsonDictionary objectForKey:@"title"]];
    NSString * descriptionText = [WebUtil stringOrNil:[jsonDictionary objectForKey:@"description"]];
    
    NSString * startDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_date"]];
    NSLog(@"startDate:%@", startDate);
    NSString * endDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_date"]];
    NSLog(@"endDate:%@", endDate);
    NSString * startTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_time"]];
    NSLog(@"startTime:%@", startTime);
    NSString * endTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_time"]];
    NSLog(@"endTime:%@", endTime);

    // Date and time
    NSDictionary * startAndEndDatetimesDictionary = [self.webDataTranslator datetimesSummaryFromStartTime:startTime endTime:endTime startDate:startDate endDate:endDate];
    NSLog(@"%@", startAndEndDatetimesDictionary);
    NSDate * startDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_START_DATETIME_KEY];
    NSDate * endDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_END_DATETIME_KEY];
    NSNumber * startDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_DATE_VALID_KEY];
    NSNumber * startTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_TIME_VALID_KEY];
    NSNumber * endDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_DATE_VALID_KEY];
    NSNumber * endTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_TIME_VALID_KEY];
    
    // Price
    NSArray * priceArray = [firstOccurrenceDictionary objectForKey:@"prices"];
    NSDictionary * pricesMinMaxDictionary = [self.webDataTranslator pricesSummaryFromPriceArray:priceArray];
    NSNumber * priceMinimum = [pricesMinMaxDictionary objectForKey:@"minimum"];
    NSNumber * priceMaximum = [pricesMinMaxDictionary objectForKey:@"maximum"];

    // Address first line
    NSString * addressLineFirst = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"address"]];

    // Address second line
    NSString * cityString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"city"]];
    NSString * stateString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"state"]];
    NSString * zipCodeString = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"zip"]];

    // Latitude & Longitude
    NSNumber * latitudeValue  = [WebUtil numberOrNil:[[[[[jsonDictionary valueForKey:@"occurrences"] objectAtIndex:0]valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"latitude"]];
    NSNumber * longitudeValue = [WebUtil numberOrNil:[[[[[jsonDictionary valueForKey:@"occurrences"] objectAtIndex:0] valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"longitude"]];

    // Phone Number
    NSString * eventPhoneString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"phone"]];

    // Venue
    NSString * venueString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"title"]];

    // Image location
    NSString * imageLocation = [WebUtil stringOrNil:[jsonDictionary valueForKey:@"image"]];
    if (!imageLocation) {
        imageLocation = [WebUtil stringOrNil:[jsonDictionary valueForKey:@"thumbnail_detail"]];
    }
    
    // Concrete parent category
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[jsonDictionary objectForKey:@"resource_uri"]];

    // Add to/update core data
    Event * featured = [self.coreDataModel getOrCreateFeaturedEvent];
    featured.uri = uri;
    featured.concreteParentCategoryURI = concreteParentCategoryURI;
    Category * concreteParentCategory = [self.coreDataModel getCategoryWithURI:concreteParentCategoryURI];
    featured.concreteParentCategory = concreteParentCategory;
    featured.title = titleText;
    featured.startDatetime = startDatetime;
    featured.endDatetime = endDatetime;
    featured.startDateValid = startDateValid;
    featured.startTimeValid = startTimeValid;
    featured.endDateValid = endDateValid;
    featured.endTimeValid = endTimeValid;
    featured.venue = venueString;
    featured.address = addressLineFirst;
    featured.city = cityString;
    featured.state = stateString;
    featured.zip = zipCodeString;
    featured.latitude = latitudeValue;
    featured.longitude = longitudeValue;
    featured.priceMinimum = priceMinimum;
    featured.priceMaximum = priceMaximum;
    featured.phone = eventPhoneString;
    featured.details = descriptionText;
    featured.imageLocation = imageLocation;
    featured.featured = [NSNumber numberWithBool:YES];

    [self.coreDataModel coreDataSave];

}

- (void)dealloc {
    [coreDataModel release];
    [super dealloc];
}

@end
