//
//  LocationUtil.h
//  Kwiqet
//
//  Created by Dan Bretl on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LocationModeAuto = 1,
    LocationModeManual = 2,
} LocationMode;

@interface LocationUtil : NSObject

+ (NSString *) unitedStatesStateAbbreviationForStateName:(NSString *)stateName; // If this function can not find a matching state abbreviation, merely returns the state name given.

@end
