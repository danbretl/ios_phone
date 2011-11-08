//
//  LocationUtil.m
//  kwiqet
//
//  Created by Dan Bretl on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationUtil.h"

@implementation LocationUtil

+ (NSString *)unitedStatesStateAbbreviationForStateName:(NSString *)stateName {
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSString * stateAbbreviation = [dictionary valueForKey:[stateName uppercaseString]];
    if (!(stateAbbreviation && stateAbbreviation.length > 0)) {
        stateAbbreviation = stateName;
    }
    return stateAbbreviation;
}

@end
