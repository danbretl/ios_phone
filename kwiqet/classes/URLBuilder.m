//
//  URLBuilder.m
//  Abextra
//
//  Created by John Nichols on 4/29/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "URLBuilder.h"
#import "DefaultsModel.h"

#if !(TARGET_IPHONE_SIMULATOR)
#define COMPILING_FOR_SIMULATOR 0
#else
#define COMPILING_FOR_SIMULATOR 1
#endif

static NSString * const URL_BUILDER_GET_EVENTS_LIST_FILTER_RECOMMENDED = @"recommended";
static NSString * const URL_BUILDER_GET_EVENTS_LIST_FILTER_FREE = @"free";
static NSString * const URL_BUILDER_GET_EVENTS_LIST_FILTER_POPULAR = @"popular";

@implementation URLBuilder

////////////
// GENERAL

- (NSString *)baseURLKey {
    return [URLBuilder baseURLKey];
}

- (NSString *)baseURL {
    return [URLBuilder baseURL];
}

+ (NSString *)baseURLKey {
    NSString * baseURLKey = nil;
    if (COMPILING_FOR_SIMULATOR == 1) {
        baseURLKey = @"base_url_local";
    } else {
        baseURLKey = @"base_url";
    }
    return baseURLKey;
}

+ (NSString *) baseURL {
    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"]];
    NSString * baseURL = [urlDictionary valueForKey:[URLBuilder baseURLKey]];
    return baseURL;
}

///////////
// IMAGES

+ (NSURL *)imageURLForImageLocation:(NSString *)imageLocation {
    NSMutableString * urlString = [NSMutableString string];
    NSURL * url = nil;
    if (imageLocation) {
        [urlString appendString:[URLBuilder baseURL]];
        [urlString appendString:imageLocation];
        url = [NSURL URLWithString:urlString];
//        NSLog(@"EventViewController imageURLForEvent %@", urlString);        
    }
//    NSLog(@"URLBuilder imageURLForImageLocation %@", urlString);
    return url;
}

/////////////
// SECURITY

- (NSString*) buildCredentialString  {

    //find if api key is present. if so, append to credentials
    NSString *apiKey = [DefaultsModel retrieveAPIFromUserDefaults];
//    NSLog(@"URLBuilder buildCredentialString - apiKey=%@", apiKey);
    
    NSString * urlplist = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
	NSDictionary *urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlplist];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *consumerKey = [urlDictionary valueForKey:@"consumer_key"];
    NSString *consumerSecret = [urlDictionary valueForKey:@"consumer_secret"];
    
    NSString * apiKeyInURL = apiKey ? [NSString stringWithFormat:@"&api_key=%@", apiKey] : @"";
    NSString * credentials = [NSString stringWithFormat:@"consumer_key=%@&consumer_secret=%@&udid=%@%@", consumerKey, consumerSecret, udid, apiKeyInURL];
    
//    NSLog(@"URLBuilder buildCredentialString - credentials=%@", credentials);
    
    return credentials;
}

/////////////
// ACCOUNTS

- (NSURL*) buildLoginURL  {
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"login_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

- (NSURL*) buildRegistrationURL  {
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"registration_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

- (NSURL*) buildForgotPasswordURL  {
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"forgot_password_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

/////////////
// LEARNING

- (NSURL*) buildLearnURL  {
    
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"teaching_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    NSLog(@"URLBuilder buildLearnURL - url is %@", url);
    
    return url;
    
}

- (NSURL*) buildResetAggregateURL  {
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"aggregate_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

- (NSURL*) buildResetActionURL  {
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"action_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

//////////////////
// CATEGORY TREE

- (NSURL*) buildGetCategoryTreeURL  {
    //make call for categories
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *URI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"base_category_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,URI,credentials];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"URLBuilder buildGetCategoryTreeURL - url is %@", url);
    
    [urlDictionary release];
    [baseURL release];
    [URI release];
    [credentials release];
    
    return url;
}

////////////////
// EVENTS LIST

//- (NSURL *) buildGetEventsListURLWithFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI {
//    
//    NSString * urlPList = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
//    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlPList];
//    
//    NSString * baseURL = [urlDictionary valueForKey:self.baseURLKey];
//    NSString * listURI = [urlDictionary valueForKey:@"list_uri"];
//    NSString * credentials = [self buildCredentialString];
//    
//    // Filters - recommended (default), free, popular
//    filterString = [filterString lowercaseString];
//    NSString * filterVariableForURL = @""; // Straight up "recommended" events lists are our bread and butter, and API calls for those don't require any variable.
//    if (filterString && ![filterString isEqualToString:URL_BUILDER_GET_EVENTS_LIST_FILTER_RECOMMENDED]) {
//        filterVariableForURL = [NSString stringWithFormat:@"&view=%@", filterString];
//    }
//    
//    // Categories
//    NSString * categoryVariableForURL = @"";
//    if (categoryURI && [categoryURI length] > 0) {
//        categoryVariableForURL = [NSString stringWithFormat:@"&concrete_parent_category=%@", categoryURI];
//    }
//    
//    
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@", baseURL, listURI, credentials, filterVariableForURL, categoryVariableForURL]];
//    
//    NSLog(@"URLBuilder buildGetEventsListURLWithFilter - url is %@", url);
//    return url;
//    
//}

//- (NSString *) buildGetRecommendedEventsURLBasicString {
//    
//    NSString * urlPList = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
//    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlPList];
//    
//    NSString * baseURL = [urlDictionary valueForKey:self.baseURLKey];
//    NSString * listURI = [urlDictionary valueForKey:@"list_uri"];
//    NSString * credentials = [self buildCredentialString];
//    
//    NSString * basicURLString = [NSString stringWithFormat:@"%@%@%@", baseURL, listURI, credentials];
//    
//    return basicURLString;
//
//}

//- (NSURL *) buildGetEventsListRecommendedURL {
//    return [self buildGetEventsListURLWithFilter:@"recommended" categoryURI:nil];
//}

- (NSURL *) buildGetRecommendedEventsURLWithCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    
    NSString * urlPList = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlPList];
    
    NSString * baseURL = [urlDictionary valueForKey:self.baseURLKey];
    NSString * listURI = [urlDictionary valueForKey:@"list_uri"];
    
    NSMutableString * urlString = [NSMutableString stringWithFormat:@"%@%@", baseURL, listURI];
    
    // Credentials - defer adding this to the URL string
    NSString * credentials = [self buildCredentialString];
    [urlString appendString:credentials];
    
    // Categories
    NSString * categoryVariableForURL = nil;
    if (categoryURI && [categoryURI length] > 0) {
        categoryVariableForURL = [NSString stringWithFormat:@"&concrete_parent_category=%@", categoryURI];
    }
    if (categoryVariableForURL != nil) { [urlString appendString:categoryVariableForURL]; }
    
    // Price filters
    NSString * (^priceStringBlock)(NSNumber *, NSString *)=^(NSNumber * price, NSString * minOrMax){
        NSString * priceString = nil;
        if (price != nil) {
            priceString = [NSString stringWithFormat:@"&%@=%d", [urlDictionary valueForKey:[NSString stringWithFormat:@"filter_price_%@_key", minOrMax]], price.intValue];
        }
        return priceString;
    };
    NSString * minPriceString = priceStringBlock(minPriceInclusive, @"min");
    NSString * maxPriceString = priceStringBlock(maxPriceInclusive, @"max");
    if (minPriceString != nil) { [urlString appendString:minPriceString]; }
    if (maxPriceString != nil) { [urlString appendString:maxPriceString]; }
    
    // Date and time filters
    NSString * (^dateOrTimeStringBlock)(NSDate *, BOOL, BOOL) = ^(NSDate * datetime, BOOL isDate, BOOL isEarliest) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        NSString * dateFormat = isDate ? @"YYYY-MM-dd" : @"HHmm";
        [dateFormatter setDateFormat:dateFormat];
        NSString * dateString = nil;
        if (datetime != nil) {
            NSString * prefix = isDate ? @"dt" : @"t";
            NSString * earliestLatest = isEarliest ? @"earliest" : @"latest";
            dateString = [NSString stringWithFormat:@"&%@start_%@=%@", prefix, earliestLatest, [dateFormatter stringFromDate:datetime]];
        }
        [dateFormatter release];
        return dateString;
    };
    // Date filters
    NSString * earliestDateString = dateOrTimeStringBlock(startDateEarliestInclusive, YES, YES);
    NSString * latestDateString = dateOrTimeStringBlock(startDateEarliestInclusive, YES, NO);
    if (earliestDateString != nil) { [urlString appendString:earliestDateString]; }
    if (latestDateString != nil) { [urlString appendString:latestDateString]; }
    // Time filters
    NSString * earliestTimeString = dateOrTimeStringBlock(startTimeEarliestInclusive, NO, YES);
    NSString * latestTimeString = dateOrTimeStringBlock(startTimeLatestInclusive, NO, NO);
    if (earliestTimeString != nil) { [urlString appendString:earliestTimeString]; }
    if (latestTimeString != nil) { [urlString appendString:latestTimeString]; }
    
    NSURL * url = [NSURL URLWithString:urlString];
    NSLog(@"%@", url);
    
    return url;

}

//- (NSURL *) buildGetEventsListFreeURL {
//    return [self buildGetEventsListURLWithFilter:@"free" categoryURI:nil];
//}

//- (NSURL *) buildGetEventsListPopularURL {
//    return [self buildGetEventsListURLWithFilter:@"popular" categoryURI:nil];
//}

- (NSURL *) buildGetEventsListSearchURLWithSearchString:(NSString *)searchString {
    
    NSString * urlPList = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlPList];
    
    // Remove spaces in search string
    NSString * searchParameterSafe = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; // NOTE - THIS DOES NOT SEEM EVEN REMOTELY ROBUST ENOUGH TO HANDLE STRANGE INPUT FROM USERS. THIS WILL ALMOST UNQUESTIONABLY NEED TO BE GREATLY IMPROVEN UPON IN THE FUTURE.
    NSString * searchVariableForURL = [NSString stringWithFormat:@"&q=%@", searchParameterSafe];
    
    NSString * baseURL = [urlDictionary valueForKey:self.baseURLKey];
    NSString * searchURI = [urlDictionary valueForKey:@"event_summary_search_uri"];
    NSString * credentials = [self buildCredentialString];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", baseURL, searchURI, credentials, searchVariableForURL]];
    
    return url;
    
}

//////////
// EVENT

- (NSURL*) buildCardURLWithID:(NSString*)eventID  { 
    NSString *urlplist = [[NSBundle mainBundle]
                          pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *eventURI = [[NSString alloc]initWithString:eventID];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@",baseURL,eventURI,credentials];
    NSURL *url = [NSURL URLWithString:urlString];
    [urlDictionary release];
    [baseURL release];
    [eventURI release];
    [credentials release];
    
    return url;
}

- (NSURL *) buildOccurrencesURLForEventID:(NSString *)eventID {
    
    NSString * urlplist = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlplist];

    NSString * baseURL = [urlDictionary valueForKey:self.baseURLKey];
    NSString * URI = [urlDictionary valueForKey:@"occurrence_uri"];
    NSString * credentials = [self buildCredentialString];

    NSString * urlString = [NSString stringWithFormat:@"%@%@event=%@&%@", baseURL, URI, eventID, credentials];
	NSURL *url = [NSURL URLWithString:urlString];
    
    return url;
    
}

///////////////////
// FEATURED EVENT

- (NSURL*) buildGetFeaturedEventURL  {
    NSString *urlplist = [[NSBundle mainBundle]
						  pathForResource:@"urls" ofType:@"plist"];
	NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    
    NSString *baseURL = [[NSString alloc]initWithString:[urlDictionary valueForKey:self.baseURLKey]];
    NSString *featuredURI = [[NSString alloc]initWithString:[urlDictionary valueForKey:@"featured_uri"]];
    NSString *credentials = [[NSString alloc]initWithString:[self buildCredentialString]];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",baseURL,featuredURI,credentials];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [urlDictionary release];
    [baseURL release];
    [featuredURI release];
    [credentials release];
    
    return url;
}

@end
