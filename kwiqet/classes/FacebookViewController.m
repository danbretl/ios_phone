//
//  FacebookViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"

@interface FacebookViewController()

@property (retain) IBOutlet UIView * navBar;
@property (retain) IBOutlet UIButton * backButton;
@property (retain) IBOutlet UIButton * logoButton;
@property (retain) IBOutlet UILabel * messageLabel;
@property (retain) IBOutlet UIButton * disconnectButton;

- (IBAction) backButtonTouched;
- (IBAction) disconnectFacebookButtonTouched;
- (void) facebookAccountActivity:(NSNotification *)notification;

@end

@implementation FacebookViewController

@synthesize navBar, backButton, logoButton;
@synthesize messageLabel;
@synthesize disconnectButton;
@synthesize facebookManager;

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
    [navBar release];
    [backButton release];
    [logoButton release];
    [messageLabel release];
    [disconnectButton release];
    [facebookManager release];
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
    
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    
    self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAccountActivity:) name:FBM_ACCOUNT_ACTIVITY_KEY object:nil];
    
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

- (void)backButtonTouched {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disconnectFacebookButtonTouched {
    [self.facebookManager logout];
}

- (void) facebookAccountActivity:(NSNotification *)notification {
    NSLog(@"FacebookViewController facebookAccountActivity");
    if ([[[notification userInfo] valueForKey:FBM_ACCOUNT_ACTIVITY_ACTION_KEY] isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT]) {
        if (self.view.window) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
