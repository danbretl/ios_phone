//
//  UIFont+Kwiqet.h
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BoldCompressedKwiqetFont = 110,
    RegularCompressedKwiqetFont = 105,
    LightCompressedKwiqetFont = 102,
    HelveticaNeueRegular = 5
} KwiqetFontType;

@interface UIFont (UIFont_Kwiqet)

+ (UIFont *) kwiqetFontOfType:(KwiqetFontType)kwiqetFontType size:(CGFloat)fontSize;

@end
