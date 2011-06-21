//
//  SettingsViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FBLoginButton.h"

@interface SettingsViewController : UIViewController <FBSessionDelegate> {

    IBOutlet UIButton * attemptLoginButton;
    IBOutlet UIButton * resetMachineLearningButton;
    FBLoginButton * linkFacebookButton;
    
    Facebook * facebook;
    
}

- (IBAction) attemptLoginButtonTouched:(id)sender;

- (IBAction) resetMachineLearningButtonTouched:(id)sender;
- (void) startResetingBehavior;

- (void) linkFacebookButtonTouched;
@property (nonatomic, retain) Facebook * facebook;
- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn;

@end