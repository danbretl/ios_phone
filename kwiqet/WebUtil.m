//
//  WebUtil.m
//  Abextra
//
//  Created by Dan Bretl on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebUtil.h"


@implementation WebUtil

+ (NSArray *) arrayOfStringsFromURI:(NSString *)uri {
    return [[NSURL URLWithString:uri] componentsSeparatedByString:@"/"];
}

+ (NSString *) lastComponentInURI:(NSString *)uri {
    NSString * lastComponent = nil;
    NSArray * array = [WebUtil arrayOfStringsFromURI:uri];
    if (array && [array count] > 0) {
        lastComponent = [array objectAtIndex:[array count]-1];
    }
    return lastComponent;
}

+ (UIColor *) colorFromHexString:(NSString *)hexString {
	NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	if([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@", 
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}
	if([cleanString length] == 6) {
		cleanString = [cleanString stringByAppendingString:@"ff"];
	}
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
	
	float red =   ((baseValue >> 24) & 0xFF) / 255.0f;
	float green = ((baseValue >> 16) & 0xFF) / 255.0f;
	float blue =  ((baseValue >> 8)  & 0xFF) / 255.0f;
	float alpha = ((baseValue >> 0)  & 0xFF) / 255.0f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (BOOL)isStringEmpty:(NSString *)string {
    return ([string isEqual:[NSNull null]] || [string length] == 0);
}

+ (NSString *)stringOrNil:(NSString *)string {
    NSString * returnString = nil;
    if (![WebUtil isStringEmpty:string]) {
        returnString = string;
    }
    return returnString;
}

+ (BOOL)isNumberEmpty:(NSNumber *)number {
    return ([number isEqual:[NSNull null]]);
}

+ (NSNumber *)numberOrNil:(NSNumber *)number {
    NSNumber * returnNumber = nil;
    if (![WebUtil isNumberEmpty:number]) {
        returnNumber = number;
    }
    return returnNumber;
}

@end
