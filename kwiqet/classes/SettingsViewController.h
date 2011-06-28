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

@interface SettingsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate/*, UITableViewDelegate, UITableViewDataSource*/> {

    IBOutlet UIButton * loginButton;
    IBOutlet UIButton * resetLearningButton;
    IBOutlet UIButton * connectFacebookButton;

    FacebookManager * facebookManager;
    CoreDataModel * coreDataModel;
    
    IBOutlet UITableView * tableView;
    
//    NSArray * sections;
//    NSDictionary * accountSection;
//    NSDictionary * sharingSection;
//    NSDictionary * learningSection;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;

- (IBAction) attemptLoginButtonTouched:(id)sender;

- (IBAction) resetMachineLearningButtonTouched:(id)sender;
- (void) startResetingBehavior;

- (void) linkFacebookButtonTouched;
@property (nonatomic, retain) FacebookManager * facebookManager;
- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn;

@end