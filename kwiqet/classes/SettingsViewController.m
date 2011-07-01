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

@interface SettingsViewController()
@property (retain) UITableView * tableView;
@property (retain) NSArray * settingsModel;
@property (readonly) UIAlertView * resetMachineLearningWarningAlertView;
- (void) accountButtonTouched;
- (void) resetMachineLearningButtonTouched;
- (void) facebookConnectButtonTouched;
- (void) startResetingBehavior;
- (void) loginActivity:(NSNotification *)notification;
- (void) configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SettingsViewController

@synthesize tableView = _tableView;
@synthesize settingsModel;
@synthesize coreDataModel, facebookManager;

- (void)dealloc
{
    [_tableView release];
    [settingsModel release];
    [facebookManager release];
    [coreDataModel release];
    [resetMachineLearningWarningAlertView release];
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
    
    self.settingsModel = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Reset Machine Learning", @"textLabel", 
                           @"apple_settings_30.png", @"imageName",
                           [NSValue valueWithPointer:@selector(resetMachineLearningButtonTouched)], @"selector",
                           [NSNumber numberWithBool:NO], @"showAccessoryArrow",
                           nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Facebook", @"textLabel", 
                           @"f_logo_30.png", @"imageName",
                           [NSValue valueWithPointer:@selector(facebookConnectButtonTouched)], @"selector",
                           [NSNumber numberWithBool:NO], @"showAccessoryArrow",
                           @"Connected", @"detailTextLabelWhenBooleanYes",
                           nil],
                          nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActivity:) name:@"loginActivity" object:nil];

}

-(void)viewDidAppear:(BOOL)animated {
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

- (void)loginActivity:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString * action = [userInfo valueForKey:@"action"];
    if ([action isEqualToString:@"logout"]) {
        [self.facebookManager.fb logout:self]; // If user signs out of Kwiqet, then their potential Facebook connection should also be undone.
    }
    [self.tableView reloadData]; // Heavyweight
}

- (void) accountButtonTouched {
    
    BOOL loggedInWithKwiqet = [DefaultsModel retrieveAPIFromUserDefaults] != nil;
    
    if (loggedInWithKwiqet) {
        
        [DefaultsModel deleteAPIKey];
        
        NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"logout", @"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
                
        //show logout message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged Out" 
                                                        message:@"Log back in later to retrieve your personalized recommendations."
                                                       delegate:self 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    } else {
        
        LoginViewController * loginViewController = [[LoginViewController alloc] init];
        loginViewController.delegate = self;
        [self presentModalViewController:loginViewController animated:YES];
        [loginViewController release];

    }
    
}


- (void) resetMachineLearningButtonTouched {
    [self.resetMachineLearningWarningAlertView show];
}

- (void) facebookConnectButtonTouched {
    [self.facebookManager pullAuthenticationInfoFromDefaults];
    if (![self.facebookManager.fb isSessionValid]) {
        [self.facebookManager authorizeWithStandardPermissionsAndDelegate:self];
    } else {
        [self.facebookManager.fb logout:self];
    }
}

- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    [self.facebookManager pushAuthenticationInfoToDefaults];
    [self.tableView reloadData]; // Heavyweight
    [self.facebookManager.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)requestLoading:(FBRequest *)request {
    NSLog(@"FB request loading...");
}

- (void) request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"FB request success %@ - %@", request, result);
    [self.coreDataModel addOrUpdateContactsFromFacebook:[result objectForKey:@"data"]];
    [self.coreDataModel coreDataSave];
    NSLog(@"%@", [self.coreDataModel getAllContacts]);
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"FB request failed - %@", error);
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    //[self.tableView reloadData]; // Heavyweight
}

- (void) fbDidLogout {
    [self.tableView reloadData]; // Heavyweight
    NSLog(@"fbDidLogout");
    // We don't really NEED to do the following, but I think it provides a "more trustworthy" user experience. If we didn't do the following, then the user could touch to disconnect facebook, then touch to connect facebook again, and they might automatically be connected without any sort of dialog or anything (because the access token was still valid for the given expiration date). That is convenient, but a user would rarely be trying to do this, and I would argue that it would be more likely that logout and login would be touched in a way that would expect a dialog. (Bad sentence, but hopefully you get my point.)
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
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
    } else {
        NSLog(@"ERROR in SettingsViewController - unrecognized alert view %@", alertView);
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
                          cancelButtonTitle:@"Ok"
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
                          cancelButtonTitle:@"Ok"
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
                                   message:@"Resetting machine learning will erase your entire history, thus losing your personalized recommendations. Are you sure you want to proceed?" 
                                  delegate:self 
                         cancelButtonTitle:@"Yes" 
                         otherButtonTitles:@"No",nil];
    }
    return resetMachineLearningWarningAlertView;
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
            cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:cellIdentifier];
        }
        [self configureCell:cell forRowAtIndexPath:indexPath];
        
    }
    
    return cell;
        
}

- (void) configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

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
        NSString * apiKey = [DefaultsModel retrieveAPIFromUserDefaults];
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
        if ([textLabelText isEqualToString:@"Facebook"]) {
            [self.facebookManager pullAuthenticationInfoFromDefaults];
            if ([self.facebookManager.fb isSessionValid]) {
                detailTextLabelText = [[self.settingsModel objectAtIndex:indexPath.row] valueForKey:@"detailTextLabelWhenBooleanYes"];
            } else {
                if ([DefaultsModel retrieveAPIFromUserDefaults]) {
                    detailTextLabelText = @"Touch to connect";
                } else {
                    cell.imageView.alpha = 0.5;
                    cell.textLabel.enabled = NO;
                    cell.userInteractionEnabled = NO;
                }
            }
        }
    }
    
    cell.textLabel.text = textLabelText;
    cell.detailTextLabel.text = detailTextLabelText;
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.accessoryType = accessoryType;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        if ([DefaultsModel retrieveAPIFromUserDefaults] == nil) {
            footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, [self tableView:tableView heightForFooterInSection:section])] autorelease]; // HACK, hardcoded duplicate value from heightForFooterInSection... Not sure what the proper way to do this is yet.
            UILabel * theLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, footerView.frame.size.width - 40, footerView.frame.size.height - 20)];
            theLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            theLabel.numberOfLines = 0;
            theLabel.text = @"Creating a Kwiqet account enables you to use extended features such as sending invites and making your event feed much more personal. Best of all, accounts are completely free!";
            theLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16.0];
            theLabel.backgroundColor = tableView.backgroundColor;
            [footerView addSubview:theLabel];
            [theLabel release];
        }
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        if ([DefaultsModel retrieveAPIFromUserDefaults] == nil) {
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
