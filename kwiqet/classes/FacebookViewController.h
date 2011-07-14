//
//  FacebookViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"

@interface FacebookViewController : UIViewController <FBSessionDelegate> {
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * logoButton;
    IBOutlet UILabel * messageLabel;
    IBOutlet UIButton * disconnectButton;
    IBOutlet UIButton * doneButton;
    
    FacebookManager * facebookManager;
    
}

@property (nonatomic, readonly) FacebookManager * facebookManager;

@end
