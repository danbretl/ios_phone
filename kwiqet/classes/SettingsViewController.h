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
#import "LoginViewController.h"

@interface SettingsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate, UIAlertViewDelegate> {
    
    // Views
    IBOutlet UITableView * _tableView;
    UIAlertView * accountLogoutWarningAlertView;
    UIAlertView * resetMachineLearningWarningAlertView;
    
    // View models
    NSArray * settingsModel;
    
    // Models
    FacebookManager * facebookManager;
    CoreDataModel * coreDataModel;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, retain) FacebookManager * facebookManager;

@end