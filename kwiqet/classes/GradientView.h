//
//  GradientView.h
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GradientView : UIView {
    UIColor * colorEnd;
    CGFloat endX_;
}

@property (nonatomic, retain) UIColor * colorEnd;
@property (nonatomic) CGFloat endX;

@end
