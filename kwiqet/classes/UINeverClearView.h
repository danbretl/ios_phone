//
//  UINeverClearView.h
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// This class was only made because when a UITableViewCell is set to selected, it sets the background color of all subviews to clear to show the selectedBackgroundView. There may be other (smarter) ways around this problem, but my solution was to subclass the UIView whose background I did NOT want to be set to clear in that instance, and just override the setBackgroundColor method for that subclass - telling it to ignore calls requesting to set its background color to clear.

@interface UINeverClearView : UIView {
    
}

@end
