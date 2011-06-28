//
//  SettingsViewController.m
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "DefaultsModel.h"
#import "ASIHTTPRequest.h"
#import "URLBuilder.h"
#import "Contact.h"

@interface SettingsViewController()
@property (nonatomic, retain) IBOutlet UIButton * loginButton;
@property (nonatomic, retain) IBOutlet UIButton * resetLearningButton;
@property (nonatomic, retain) IBOutlet FBLoginButton * linkFacebookButton;
@property (retain) UITableView * tableView;

//@property (retain) NSArray * sections;
//@property (retain) NSDictionary * accountSection;
//@property (retain) NSDictionary * sharingSection;
//@property (retain) NSDictionary * learningSection;

@end

@implementation SettingsViewController

@synthesize coreDataModel;
@synthesize facebookManager;
@synthesize loginButton,resetLearningButton, linkFacebookButton;
@synthesize tableView;
//@synthesize sections, accountSection, sharingSection, learningSection;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [loginButton release];
    [resetLearningButton release];
    [linkFacebookButton release];
    [facebookManager release];
    [coreDataModel release];
    [tableView release];
//    [sections release];
//    [accountSection release];
//    [sharingSection release];
//    [learningSection release];
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
    
//    self.accountSection = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                           @"Account", @"headerTitle", 
//                           nil];
//    self.sharingSection = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                           @"Sharing", @"headerTitle", 
//                           nil];
//    self.learningSection = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"Learning", @"headerTitle", 
//                            nil];
//    self.sections = [NSArray arrayWithObjects:self.accountSection, self.sharingSection, self.learningSection, nil];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Do any additional setup after loading the view from its nib.
    //check if api key is present in user default. if so, show logout message.
    NSString * apiKey = [DefaultsModel retrieveAPIFromUserDefaults];
    
    if (apiKey) {
        [loginButton setTitle:@"Logout" forState: UIControlStateNormal];
        loginButton.tag = 1;
    } else {
        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
        loginButton.tag = 2;
    }
        
    //setup fonts for uilabels
    UILabel *accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 200, 40)];
    accountLabel.backgroundColor = [UIColor clearColor];
    accountLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 20];
    accountLabel.text = @"User Account";
    [self.view addSubview:accountLabel];
    
    UILabel *loginMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 115, 280, 120)];
    loginMessageLabel.backgroundColor = [UIColor clearColor];
    loginMessageLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size: 16];
    loginMessageLabel.text = @"Creating a Kwiqet account enables you to use extended features such as sending invites and making your event feed much more personal. Accounts are completely free.";
    loginMessageLabel.numberOfLines = 5;
    [self.view addSubview:loginMessageLabel];
    
    UILabel *behaviorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 250, 200, 40)];
    behaviorLabel.backgroundColor = [UIColor clearColor];
    behaviorLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 20];
    behaviorLabel.text = @"Reset Behavior";
    [self.view addSubview:behaviorLabel];
    
    UILabel *resetMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 300, 280, 45)];
    resetMessageLabel.backgroundColor = [UIColor clearColor];
    resetMessageLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size: 16];
    resetMessageLabel.text = @"Erase all history and user preferences. Resetting data is not reversible.";
    resetMessageLabel.numberOfLines = 2;
    [self.view addSubview:resetMessageLabel];
    
    [accountLabel release];
    [behaviorLabel release];
    [loginMessageLabel release];
    [resetMessageLabel release];
    
    self.linkFacebookButton = [[[FBLoginButton alloc] initWithFrame:CGRectZero] autorelease];
    self.linkFacebookButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.linkFacebookButton addTarget:self action:@selector(linkFacebookButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.linkFacebookButton.isLoggedIn = NO; // This changes the image of the button appropriately, and also sets the size of the button accordingly.
    self.linkFacebookButton.frame = CGRectMake(self.view.bounds.size.width - self.linkFacebookButton.bounds.size.width - 7, self.view.bounds.size.height - self.linkFacebookButton.bounds.size.height - 20, self.linkFacebookButton.frame.size.width, self.linkFacebookButton.frame.size.height);
    [self.view addSubview:self.linkFacebookButton];
    [self.view bringSubviewToFront:self.linkFacebookButton];
    
    [self.facebookManager pullAuthenticationInfoFromDefaults];

}

-(void)viewDidAppear:(BOOL)animated {
    NSString * apiKey = [DefaultsModel retrieveAPIFromUserDefaults];
    
    if (apiKey) {
        [loginButton setTitle:@"Logout" forState: UIControlStateNormal];
        loginButton.tag = 1;
    } else {
        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
        loginButton.tag = 2;
    }
    
    [self updateFacebookButtonIsLoggedIn:[self.facebookManager.fb isSessionValid]];
    
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

- (IBAction) attemptLoginButtonTouched:(id)sender  {
    NSLog(@"SettingsViewController attemptLoginButtonTouched");
    if ([sender tag] == 1) {
        
        [DefaultsModel deleteAPIKey];
                
        NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"logout", @"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
        
        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
        loginButton.tag = 2;
        
        //show logout message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged Out!" 
                                                        message:@"Log back in later to retrieve your personalized recommendations." delegate:self 
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
        [alert show];
        [alert release];
    }
    else if ([sender tag] == 2) {
        LoginViewController *lViewController = [[LoginViewController alloc]init];
        [self presentModalViewController:lViewController animated:YES];
        [lViewController release]; 
    }
}


- (IBAction) resetMachineLearningButtonTouched:(id)sender  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning:" 
                                                    message:@"Reseting behavior will erase all history, thus losing your personalized recommendations. Are you sure you want to proceed?" delegate:self 
                                          cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil]; 
    [alert show]; 
    [alert release];
}

- (void) linkFacebookButtonTouched {
    NSLog(@"linkFacebookButtonTouched");
    if (!self.linkFacebookButton.isLoggedIn) {
        NSLog(@"not logged in, logging in");
        [self.facebookManager pullAuthenticationInfoFromDefaults];
        if (![self.facebookManager.fb isSessionValid]) {
            NSLog(@"session is not valid, authorizing");
            [self.facebookManager authorizeWithStandardPermissionsAndDelegate:self];
        } else {
            [self updateFacebookButtonIsLoggedIn:YES];
        }
    } else {
        NSLog(@"logged in, logging out");
        [self.facebookManager.fb logout:self];
    }
}

- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    [self.facebookManager pushAuthenticationInfoToDefaults];
    [self updateFacebookButtonIsLoggedIn:YES];
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
    [self updateFacebookButtonIsLoggedIn:NO];
}

- (void) fbDidLogout {
    [self updateFacebookButtonIsLoggedIn:NO];
    NSLog(@"fbDidLogin");
    // We don't really NEED to do the following, but I think it provides a "more trustworthy" user experience. If we didn't do the following, then the user could touch to disconnect facebook, then touch to connect facebook again, and they might automatically be connected without any sort of dialog or anything (because the access token was still valid for the given expiration date). That is convenient, but a user would rarely be trying to do this, and I would argue that it would be more likely that logout and login would be touched in a way that would expect a dialog. (Bad sentence, but hopefully you get my point.)
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
}

- (void) updateFacebookButtonIsLoggedIn:(BOOL)isLoggedIn {
    self.linkFacebookButton.isLoggedIn = isLoggedIn;
    self.linkFacebookButton.frame = CGRectMake(self.view.bounds.size.width - self.linkFacebookButton.bounds.size.width - 7, self.view.bounds.size.height - self.linkFacebookButton.bounds.size.height - 20, self.linkFacebookButton.frame.size.width, self.linkFacebookButton.frame.size.height);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	//disable button
    
	if ([alertView.title isEqualToString:@"Warning:"]) {
		if (buttonIndex == 0) {
            [self startResetingBehavior];
            resetLearningButton.userInteractionEnabled = NO;
		}
		if (buttonIndex == 1) {	
            //do nothing
        }
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
    resetLearningButton.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"learningBehaviorWasReset" object:nil];
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
    resetLearningButton.userInteractionEnabled = YES;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [self.sections count];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [[self.sections objectAtIndex:section] valueForKey:@"sectionTitle"];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 0;
//}

@end
