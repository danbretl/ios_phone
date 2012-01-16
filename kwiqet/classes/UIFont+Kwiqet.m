//
//  UIFont+Kwiqet.m
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "UIFont+Kwiqet.h"

@implementation UIFont (UIFont_Kwiqet)

+ (UIFont *) kwiqetFontOfType:(KwiqetFontType)kwiqetFontType size:(CGFloat)fontSize {
    NSString * fontName = nil;
    switch (kwiqetFontType) {
        case BoldCondensed:
            fontName = @"HelveticaLT-Condensed-Bold";
            break;
        case SemiBoldCondensed:
            fontName = @"HelveticaNeueLTCom-MdCn";
            break;
        case RegularCondensed:
            fontName = @"HelveticaLT-Condensed";
            break;
        case LightCondensed:
            fontName = @"HelveticaLT-Condensed-Light";
            break;
        case BoldNormal:
            fontName = @"HelveticaLT-Bold";
            break;
        case RegularNormal:
            fontName = @"HelveticaLT";
            break;
        case LightNormal:
            fontName = @"HelveticaLT-Light";
            break;
        case HelveticaNeue:
        default:
            fontName = @"HelveticaNeue";
            break;
    }
    return [UIFont fontWithName:fontName size:fontSize];
    
}

+ (void) logListOfAllAvailableFonts {
    for (NSString * familyName in [UIFont familyNames]) {
        NSLog(@"%@:", familyName);
        for (NSString * fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"%@", fontName);
        }
    }
}

@end
