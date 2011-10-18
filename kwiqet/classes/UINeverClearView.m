//
//  UINeverClearView.m
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "UINeverClearView.h"


@implementation UINeverClearView

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (![backgroundColor isEqual:[UIColor clearColor]]) {
        [super setBackgroundColor:backgroundColor];
    }
}

@end
