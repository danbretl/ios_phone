//
//  LocationUtil.h
//  kwiqet
//
//  Created by Dan Bretl on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationUtil : NSObject

+ (NSString *) unitedStatesStateAbbreviationForStateName:(NSString *)stateName; // If this function can not find a matching state abbreviation, merely returns the state name given.

@end
