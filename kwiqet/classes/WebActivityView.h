//
//  WebActivityView.h
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebActivityView : UIView {

    UIActivityIndicatorView * activityView;
    
}

- initWithSize:(CGSize)size centeredInFrame:(CGRect)frame;

- (void) showAnimated:(BOOL)animated;
- (void) hideAnimated:(BOOL)animated;
- (void) recenterInFrame:(CGRect)parentFrame;

@end
