//
//  UIFont+Kwiqet.h
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LightCondensed = 101,
    RegularCondensed = 102,
    BoldCondensed = 103,
    LightNormal = 201,
    RegularNormal = 202,
    BoldNormal = 203,
    HelveticaNeue = 9991
} KwiqetFontType;

@interface UIFont (UIFont_Kwiqet)

+ (UIFont *) kwiqetFontOfType:(KwiqetFontType)kwiqetFontType size:(CGFloat)fontSize;
+ (void) logListOfAllAvailableFonts;

@end
