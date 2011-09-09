//
//  UIFont+Kwiqet.m
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIFont+Kwiqet.h"

@implementation UIFont (UIFont_Kwiqet)

+ (UIFont *) kwiqetFontOfType:(KwiqetFontType)kwiqetFontType size:(CGFloat)fontSize {
    NSString * fontName = nil;
    switch (kwiqetFontType) {
        case BoldCompressedKwiqetFont:
            fontName = @"HelveticaLT-Condensed-Bold";
            break;
        case RegularCompressedKwiqetFont:
            fontName = @"HelveticaLT-Condensed";
            break;
        case LightCompressedKwiqetFont:
            fontName = @"HelveticaLT-Condensed-Light";
            break;
        case HelveticaNeueRegular:
        default:
            fontName = @"HelveticaNeue";
            break;
    }
    return [UIFont fontWithName:fontName size:fontSize];
}

@end
