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

@interface SettingsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, UITableViewDelegate, UITableViewDataSource> {

    FacebookManager * facebookManager;
    CoreDataModel * coreDataModel;
    
    IBOutlet UITableView * _tableView;
    
    NSArray * settingsModel;
    
    NSString * loggedInKwiqetDisplayIdentifier;
    
    BOOL facebookLoggedIn;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;

- (IBAction) attemptLoginButtonTouched:(id)sender;

- (IBAction) resetMachineLearningButtonTouched;
- (void) facebookConnectButtonTouched;

- (void) startResetingBehavior;
@property (nonatomic, retain) FacebookManager * facebookManager;
- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn;

- (void) loginActivity:(NSNotification *)notification;

- (void) configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end