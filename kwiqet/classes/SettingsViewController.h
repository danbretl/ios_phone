//
//  SettingsViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"
#import "FBLoginButton.h"

@interface SettingsViewController : UIViewController <FBSessionDelegate> {

    IBOutlet UIButton * attemptLoginButton;
    IBOutlet UIButton * resetMachineLearningButton;
    FBLoginButton * linkFacebookButton;
    FacebookManager * facebookManager;
    
}

- (IBAction) attemptLoginButtonTouched:(id)sender;

- (IBAction) resetMachineLearningButtonTouched:(id)sender;
- (void) startResetingBehavior;

- (void) linkFacebookButtonTouched;
@property (nonatomic, retain) FacebookManager * facebookManager;
- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn;

@end