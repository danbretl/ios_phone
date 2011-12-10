//
//  SettingsViewController.m
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "SettingsViewController.h"
#import "DefaultsModel.h"
#import "ASIHTTPRequest.h"
#import "URLBuilder.h"
#import "Contact.h"
#import <QuartzCore/QuartzCore.h>
#import "FacebookViewController.h"

@interface SettingsViewController()
@property (retain) UITableView * tableView;
@property (retain) NSArray * settingsModel;
@property (readonly) UIAlertView * accountLogoutWarningAlertView;
@property (readonly) UIAlertView * resetMachineLearningWarningAlertView;
- (void) accountButtonTouched;
- (void) resetMachineLearningButtonTouched;
- (void) facebookConnectButtonTouched;
- (void) startResetingBehavior;
- (void) loginActivity:(NSNotification *)notification;
- (void) facebookAccountActivity:(NSNotification *)notification;
- (void) configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@property (retain) NSIndexPath * kwiqetAccountIndexPath;
@property (retain) NSIndexPath * resetMachineLearningIndexPath;
@property (retain) NSIndexPath * facebookIndexPath;
@property (nonatomic) BOOL facebookCellEnabled;
@property (retain) UIAlertView * facebookConnectFailureAlertView;
@end

@implementation SettingsViewController

@synthesize tableView = _tableView;
@synthesize settingsModel;
@synthesize coreDataModel;
@synthesize kwiqetAccountIndexPath, resetMachineLearningIndexPath, facebookIndexPath;
@synthesize facebookCellEnabled = facebookCellEnabled_;
@synthesize facebookConnectFailureAlertView;

- (void)dealloc
{
    [_tableView release];
    [settingsModel release];
    [facebookManager release];
    [coreDataModel release];
    [accountLogoutWarningAlertView release];
    [resetMachineLearningWarningAlertView release];
    [kwiqetAccountIndexPath release];
    [resetMachineLearningIndexPath release];
    [facebookIndexPath release];
    [facebookConnectFailureAlertView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.kwiqetAccountIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.resetMachineLearningIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    self.facebookIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    
    self.settingsModel = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Reset Recommendations", @"textLabel", 
                           @"apple_settings_30.png", @"imageName",
                           [NSValue valueWithPointer:@selector(resetMachineLearningButtonTouched)], @"selector",
                           [NSNumber numberWithBool:NO], @"showAccessoryArrow",
                           nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Facebook", @"textLabel", 
                           @"f_logo_30.png", @"imageName",
                           [NSValue valueWithPointer:@selector(facebookConnectButtonTouched)], @"selector",
                           [NSNumber numberWithBool:NO], @"showAccessoryArrow",
                           [NSNumber numberWithBool:YES], @"showAccessoryArrowWhenBooleanYes",
                           @"Connected", @"detailTextLabelWhenBooleanYes",
                           nil],
                          nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActivity:) name:@"loginActivity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAccountActivity:) name:FBM_ACCOUNT_ACTIVITY_KEY object:nil];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"SettingsViewController viewWillAppear");
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData]; // Heavyweight
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (FacebookManager *)facebookManager {
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
        [facebookManager pullAuthenticationInfoFromDefaults];
    }
    return facebookManager;
}

- (void)loginActivity:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString * action = [userInfo valueForKey:@"action"];
    if ([action isEqualToString:@"logout"]) {
        // If user signs out of Kwiqet, then their potential Facebook connection should also be undone. We should in this case however, hang on to the Facebook access token attached to their kwiqet id though, so that if they reconnect their kwiqet account, their Facebook connection will come back along for the ride as well.
//        [self.facebookManager logoutAndForgetFacebookAccessToken:NO associatedWithKwiqetIdentfier:nil];
        self.facebookManager.fb.accessToken = nil;
        self.facebookManager.fb.expirationDate = nil;
    }
    [self.tableView reloadData]; // Heavyweight
}

- (void)facebookAccountActivity:(NSNotification *)notification {
    NSLog(@"SettingsViewController facebookAccountActivity %@", notification);
    NSString * action = [[notification userInfo] valueForKey:FBM_ACCOUNT_ACTIVITY_ACTION_KEY];
    
    if ([action isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT]) {
        [self.tableView reloadData]; // Heavyweight
    } else if ([action isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN]) {
        [self.tableView reloadData]; // Heavyweight        
    } else if ([action isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_FAILURE]) {
        if (![self.facebookConnectFailureAlertView isVisible] && self.view.window) {
            self.facebookConnectFailureAlertView = [[[UIAlertView alloc] initWithTitle:@"Facebook Connect Error" message:@"There was a problem while trying to connect with Facebook. Please check your settings and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [self.facebookConnectFailureAlertView show];
        }
        [self.tableView reloadData];
    }
}

- (void) accountButtonTouched {
    
    BOOL loggedInWithKwiqet = [DefaultsModel loadAPIKey] != nil;
    
    if (loggedInWithKwiqet) {
        
        [self.accountLogoutWarningAlertView show];
        
    } else {
        
        LoginViewController * loginViewController = [[LoginViewController alloc] init];
        loginViewController.delegate = self;
        [self presentModalViewController:loginViewController animated:YES];
        [loginViewController release];

    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.resetMachineLearningWarningAlertView) {
        
        if (buttonIndex == 0) {
            [self startResetingBehavior];
            self.view.userInteractionEnabled = NO;
        } else if (buttonIndex == 1) {
            // Do nothing
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        } else {
            NSLog(@"ERROR in SettingsViewController - unrecognized alert view button index %d", buttonIndex);
        }
        
    } else if (alertView == self.accountLogoutWarningAlertView) {
        
        if (buttonIndex == 0) {
            [DefaultsModel deleteAPIKey];
            [DefaultsModel deleteKwiqetUserIdentifier];
            NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"logout", @"action", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged Out" 
                                                            message:@"Log back in later to retrieve your personalized recommendations."
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if (buttonIndex == 1) {
            // Do nothing
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        } else {
            NSLog(@"ERROR in SettingsViewController - unrecognized alert view button index %d", buttonIndex);
        }
        
    } else {
        NSLog(@"Anonymous alert view in SettingsViewController - %@", alertView);
    }
    
}

- (void) resetMachineLearningButtonTouched {
    [self.resetMachineLearningWarningAlertView show];
}

- (void) facebookConnectButtonTouched {
    [self.facebookManager pullAuthenticationInfoFromDefaults];
    if (![self.facebookManager.fb isSessionValid]) {
        [self.facebookManager login];
    } else {
        FacebookViewController * fvc = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:[NSBundle mainBundle]];
//        fvc.facebookManager = self.facebookManager;
        [self.navigationController pushViewController:fvc animated:YES];
        [fvc release];
    }
}

-(void)startResetingBehavior  {
    //reset aggregate
    URLBuilder *urlBuilder = [[URLBuilder alloc]init];
    NSURL *url = [urlBuilder buildResetAggregateURL];
    NSLog(@"aggregate url: %@",url);
    ASIHTTPRequest *myRequest = [ASIHTTPRequest requestWithURL:url];
    [myRequest setDelegate:self];
    [myRequest setRequestMethod:@"DELETE"];
    [myRequest setDidFinishSelector:@selector(resetAggregateSuccess:)];
    [myRequest setDidFailSelector:@selector(resetAggregateOrActionFailure:)];
    
    [myRequest startAsynchronous];
    
    [urlBuilder release];
}

- (void)resetAggregateSuccess:(ASIHTTPRequest *)request  {
    NSLog(@"SettingsViewController resetAggregateSuccess");
	// reset action
    URLBuilder *urlBuilder = [[URLBuilder alloc]init];
    NSURL *url = [urlBuilder buildResetActionURL];
    ASIHTTPRequest *myRequest = [ASIHTTPRequest requestWithURL:url];
    [myRequest setDelegate:self];
    [myRequest setRequestMethod:@"DELETE"];
    [myRequest setDidFinishSelector:@selector(resetActionSuccess:)];
    [myRequest setDidFailSelector:@selector(resetAggregateOrActionFailure:)];
    
    [myRequest startAsynchronous];
    
    [urlBuilder release];
}

- (void)resetActionSuccess:(ASIHTTPRequest *)request  {
    NSLog(@"SettingsViewController resetActionSuccess");
    //show alert
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Behavior Reset Successful"
                          message:nil
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
//    resetLearningButton.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"learningBehaviorWasReset" object:nil];
    self.view.userInteractionEnabled = YES;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)resetAggregateOrActionFailure:(ASIHTTPRequest *)request  {
	NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Connection Error"
                          message:@"An error occured while trying to reset behavior."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
//    resetLearningButton.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (UIAlertView *)resetMachineLearningWarningAlertView {
    if (resetMachineLearningWarningAlertView == nil) {
        resetMachineLearningWarningAlertView = 
        [[UIAlertView alloc] initWithTitle:@"Warning" 
                                   message:@"Resetting recommendations will erase your entire history, and we'll forget everything we've learned about you! Are you sure you want to proceed?" 
                                  delegate:self 
                         cancelButtonTitle:@"Yes" 
                         otherButtonTitles:@"No",nil];
    }
    return resetMachineLearningWarningAlertView;
}

- (UIAlertView *) accountLogoutWarningAlertView {
    if (accountLogoutWarningAlertView == nil) {
        accountLogoutWarningAlertView = 
        [[UIAlertView alloc] initWithTitle:@"Log out?" 
                                   message:@"Are you sure you want to log out of your Kwiqet account?" 
                                  delegate:self 
                         cancelButtonTitle:@"Yes" 
                         otherButtonTitles:@"No",nil];
    }
    return accountLogoutWarningAlertView;
}

- (void)loginViewController:(LoginViewController *)loginViewController didFinishWithLogin:(BOOL)didLogin {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1 : [self.settingsModel count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? 64 : 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = nil;
    
    if (tableView == self.tableView) {
        
        NSString * cellIdentifier;
        UITableViewCellStyle cellStyle;
        if (indexPath.section == 0) {
            cellIdentifier = @"AccountCell";
            cellStyle = UITableViewCellStyleSubtitle;
        } else {
            cellIdentifier = @"SettingsCell";
            cellStyle = UITableViewCellStyleValue1;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier] autorelease];
        }
        [self configureCell:cell forRowAtIndexPath:indexPath];
        
    }
    
    return cell;
        
}

- (void) configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"SettingsViewController configureCell forRowAtIndexPath:%@", indexPath);

    cell.userInteractionEnabled = YES;
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.layer.cornerRadius = 6.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 1.0;
    cell.imageView.layer.borderColor = [[UIColor colorWithWhite:0.75 alpha:0.5] CGColor];
    cell.imageView.alpha = 1.0;
    cell.textLabel.enabled = YES;
    cell.detailTextLabel.enabled = YES;
    
    NSString * textLabelText = nil;
    NSString * detailTextLabelText = nil;
    NSString * imageName = nil;
    UITableViewCellAccessoryType accessoryType;
    if (indexPath.section == 0) {
        NSString * apiKey = [DefaultsModel loadAPIKey];
        if (apiKey) {
            NSString * identifier = [DefaultsModel retrieveKwiqetUserIdentifierFromUserDefaults];
            textLabelText = identifier ? identifier : @"Logged In";
            detailTextLabelText = @"Touch to log out";
        } else {
            textLabelText = @"Kwiqet Account";
            detailTextLabelText = @"Touch to log in / sign up";
        }
        imageName = @"kwiqet_colors_50.png";
        accessoryType = UITableViewCellAccessoryNone;
    } else {
        textLabelText = [[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"textLabel"];
        imageName = [[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"imageName"];
        accessoryType = [[[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"showAccessoryArrow"] boolValue] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        if ([indexPath isEqual:self.facebookIndexPath]) {
            [self.facebookManager pullAuthenticationInfoFromDefaults];
            NSLog(@"indexPath=self.facebookIndexPath ::: self.facebookManager.fb isSessionValid=%d", [self.facebookManager.fb isSessionValid]);
            NSLog(@"SettingsViewController set self.facebookCellEnabled=%d", self.facebookCellEnabled);
            if ([self.facebookManager.fb isSessionValid]) {
                self.facebookCellEnabled = YES;
                detailTextLabelText = [[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"detailTextLabelWhenBooleanYes"];
                accessoryType = [[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"showAccessoryArrowWhenBooleanYes"] ? UITableViewCellAccessoryDisclosureIndicator : accessoryType;
                [self setTableViewCell:cell atIndexPath:indexPath appearanceEnabled:self.facebookCellEnabled];
            } else {
                self.facebookCellEnabled = ([DefaultsModel loadAPIKey] != nil);
                detailTextLabelText = @"Touch to connect";
                [self setTableViewCell:cell atIndexPath:indexPath appearanceEnabled:self.facebookCellEnabled];
            }
        }
    }
    
    cell.textLabel.text = textLabelText;
    cell.detailTextLabel.text = detailTextLabelText;
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.accessoryType = accessoryType;
    
}

- (void)setTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath appearanceEnabled:(BOOL)appearanceEnabled {
    
    cell.contentView.alpha = appearanceEnabled ? 1.0 : 0.5;
    cell.selectionStyle = appearanceEnabled ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
//    
//    if (appearanceEnabled) {
//        
//    }
//    
//    facebookCellEnabled_ = facebookCellEnabled;
//    NSLog(@"Foofoofooo - %d", self.facebookCellEnabled);
//    UITableViewCell * facebookCell = [self.tableView cellForRowAtIndexPath:self.facebookIndexPath];
//    NSLog(@"%@", facebookCell);
//    float alpha = self.facebookCellEnabled ? 1.0 : 0.5;
//    facebookCell.imageView.alpha = alpha;
//    facebookCell.textLabel.alpha = alpha;
//    NSLog(@"%f %f", facebookCell.imageView.alpha, facebookCell.textLabel.alpha);
//    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * returnPath = indexPath;
    if ([indexPath isEqual:self.facebookIndexPath] &&
        !self.facebookCellEnabled) {
        NSLog(@"SettingsViewController willSelectRowAtIndexPath=self.facebookIndexPath when self.facebookCellEnabled=%d", self.facebookCellEnabled);
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Enable Facebook Connect" message:@"You must log in with a Kwiqet account before you can enable Facebook Connect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        returnPath = nil;
    }
    return returnPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"SettingsViewController didSelectRowAtIndexPath");
    if (indexPath.section == 0) {
        [self accountButtonTouched];
    } else {
        SEL selector = [[[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"selector"] pointerValue];
        [self performSelector:selector];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * footerView = nil;
    if (section == 0) {
        if ([DefaultsModel loadAPIKey] == nil) {
            footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:tableView heightForFooterInSection:section])] autorelease]; // HACK, hardcoded duplicate value from heightForFooterInSection... Not sure what the proper way to do this is yet.
            UILabel * theLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, footerView.frame.size.width - 40, footerView.frame.size.height - 20)];
            theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            theLabel.numberOfLines = 0;
            theLabel.text = @"Creating a Kwiqet account enables you to use extended features such as sending invites and making your event feed much more personal. Best of all, accounts are completely free!";
            theLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16.0];
            theLabel.backgroundColor = tableView.backgroundColor;
//            theLabel.lineBreakMode = UILineBreakModeClip;
//            theLabel.clipsToBounds = NO;
            [footerView addSubview:theLabel];
            [theLabel release];
        }
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        if ([DefaultsModel loadAPIKey] == nil) {
            height = 110;
        }
    }
    return height;
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
//    //@"Erase all history and user preferences. Resetting data is not reversible."
//    NSString * title = nil;
//    if (section == 0) {
//        title = @"Creating a Kwiqet account enables you to use extended features such as sending invites and making your event feed much more personal. Accounts are completely free.";
//    } else {
//        title = @"Foo";
//    }
//    return title;
//}

@end
