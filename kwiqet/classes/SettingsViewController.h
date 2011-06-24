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
#import "CoreDataModel.h"

@interface SettingsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate> {

    IBOutlet UIButton * attemptLoginButton;
    IBOutlet UIButton * resetMachineLearningButton;
    FBLoginButton * linkFacebookButton;
    FacebookManager * facebookManager;
    CoreDataModel * coreDataModel;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;

- (IBAction) attemptLoginButtonTouched:(id)sender;

- (IBAction) resetMachineLearningButtonTouched:(id)sender;
- (void) startResetingBehavior;

- (void) linkFacebookButtonTouched;
@property (nonatomic, retain) FacebookManager * facebookManager;
- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn;

@end