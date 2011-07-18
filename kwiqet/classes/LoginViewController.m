//
//  LoginViewController.m
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "URLBuilder.h"
#import <YAJL/YAJL.h>
#import "RegistrationViewController.h"
#import "DefaultsModel.h"
#import "WebUtil.h"
#import "JSON.h"

@interface LoginViewController()
@property (retain) UIScrollView * scrollViewContainer;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) shiftViewsDirectionIsUpward:(BOOL)directionIsUpward keyboardNotificationInfo:(NSDictionary *)info;
@property (retain) UILabel * messageLabel;
@property (retain) UILabel * infoLabel;
@end

@implementation LoginViewController
@synthesize scrollViewContainer;
@synthesize usernameField, passwordField;
@synthesize messageLabel, infoLabel;
@synthesize delegate;

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
    [messageLabel release];
    [infoLabel release];
    [usernameField release];
    [passwordField release];
    [scrollViewContainer release];
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
    // Do any additional setup after loading the view from its nib.
    usernameField.delegate = self;
    passwordField.delegate = self;
    
    self.scrollViewContainer.contentSize = self.scrollViewContainer.bounds.size;
    self.scrollViewContainer.userInteractionEnabled = YES;
    self.scrollViewContainer.scrollEnabled = YES;
    
    self.messageLabel = [[[UILabel alloc]initWithFrame:CGRectMake(35, 23, 250, 40)] autorelease];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 20];
    self.messageLabel.text = @"Log into Your Kwiqet Account";
    self.messageLabel.numberOfLines = 1;
    [self.scrollViewContainer addSubview:self.messageLabel];
    
    self.infoLabel = [[[UILabel alloc]initWithFrame:CGRectMake(35, 226, 245, 126)] autorelease];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size: 16];
    self.infoLabel.text = @"Creating a Kwiqet account allows you to send invitations to the people you care about most in order to do the things you love best. This is your ticket to the world—the ultimate mobile invitation.";
    self.infoLabel.numberOfLines = 0;
    [self.scrollViewContainer addSubview:self.infoLabel];
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == passwordField) {
        if ([passwordField.text length] > 0 &&
            [usernameField.text length] > 0) {
            [self makeLoginRequest];
            [textField resignFirstResponder];            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Fields" 
                                                            message:@"You must enter a valid email and password."
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
            [alert show]; 
            [alert release];
        }
    } else if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    }
    return NO;
}

-(IBAction)cancelButtonTouched:(id)sender  {
    if ([usernameField isFirstResponder] ||
        [passwordField isFirstResponder]) {
        [usernameField resignFirstResponder];
        [passwordField resignFirstResponder];
    } else {
        [self.delegate loginViewController:self didFinishWithLogin:NO];
    }
}

-(IBAction)registerButtonTouched:(id)sender  {
    if ([usernameField isFirstResponder] ||
        [passwordField isFirstResponder]) {
        [usernameField resignFirstResponder];
        [passwordField resignFirstResponder];
    }
    // Registration disabled for alpha *******
//    RegistrationViewController *registrationViewController = [[RegistrationViewController alloc]init];
//    [self presentModalViewController:registrationViewController animated:YES];
//    [registrationViewController release];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action not possible." 
                                                    message:@"You are unable to register from within the app during the alpha phase." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles:nil];
    [alert show]; 
    [alert release];
}


#pragma login dialog
-(IBAction)forgotPasswordButtonTouched:(id)sender {
    
    [passwordField resignFirstResponder];
    [usernameField resignFirstResponder];
    
    URLBuilder *urlBuilder = [[URLBuilder alloc]init];
    NSURL *url = [urlBuilder buildForgotPasswordURL];

    //build json with {"email": email.text}
    NSString * usernameValue = [NSString stringWithString:usernameField.text];
    NSDictionary *jsonDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:usernameValue,@"email", nil];
    NSString *jsonString = [jsonDictionary JSONRepresentation];
    [jsonDictionary release];
    NSLog(@"json: %@",jsonString);
    NSLog(@"url: %@",url);
    
    ASIFormDataRequest * forgotPasswordRequest = [ASIFormDataRequest requestWithURL:url];
	[forgotPasswordRequest addRequestHeader:@"Content-Type" value:@"application/json"];
    [forgotPasswordRequest appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
    [forgotPasswordRequest setDelegate:self];
    [forgotPasswordRequest setDidFinishSelector:@selector(passwordRequestFinished:)];
    [forgotPasswordRequest setDidFailSelector:@selector(passwordRequestFailed:)];
    [forgotPasswordRequest startAsynchronous];
    
    [urlBuilder release];
}

- (void)passwordRequestFinished:(ASIHTTPRequest *)request {
    NSLog(@"LoginViewController passwordRequestFinished:");
    
	NSString *responseString = [[NSString alloc]initWithString:[request responseString]];
	NSLog(@"%@",responseString);
        
    NSError *error = nil;
    NSDictionary *dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSLog(@"%@",dictionaryFromJSON);
    NSString * responseMessage = [[dictionaryFromJSON valueForKey:@"email"]objectAtIndex:0];
    NSLog(@"%@",responseMessage);
    
    //show alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" 
                                                    message:@"Check your email and follow the link provided to set a new password." delegate:nil 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show]; 
    [alert release];
    [responseString release];
}

- (void)passwordRequestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"LoginViewController passwordRequestFailed:");
          
	NSError *error = [request error];
	NSLog(@"%@",error);
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


-(IBAction)loginButtonTouched:(id)sender  {
    [self makeLoginRequest];
}

-(void)makeLoginRequest {
    NSLog(@"LoginViewController makeLoginRequest");
    
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSString *usernameValue = [[NSString alloc]initWithString:usernameField.text];
    NSString *passwordValue = [[NSString alloc]initWithString:passwordField.text];
    
    URLBuilder *urlBuilder = [[URLBuilder alloc]init];
    NSURL *url = [urlBuilder buildLoginURL];
    NSLog(@"LoginViewController makeLoginRequest - url is %@", url);
    NSLog(@"username: %@",usernameValue);
    NSLog(@"password: %@",passwordValue);
    
    ASIHTTPRequest *loginRequest = [[ASIHTTPRequest alloc]initWithURL:url];
    [loginRequest setUsername:usernameValue];
    [loginRequest setPassword:passwordValue];
    [loginRequest setRequestMethod:@"GET"];
    loginRequest.useSessionPersistence = NO;
    [loginRequest setDelegate:self];
    [loginRequest setDidFinishSelector:@selector(loginRequestFinished:)];
    [loginRequest setDidFailSelector:@selector(loginRequestFailed:)];
    [loginRequest startAsynchronous];
    
    [usernameValue release];
    [passwordValue release];
    [urlBuilder release];
    [loginRequest release];
}

- (void)loginRequestFinished:(ASIHTTPRequest *)request {
    NSLog(@"LoginViewController loginRequestFinished:%@", request);
    
    NSLog(@"code: %i",[request responseStatusCode]);
	NSString * responseString = [request responseString];
    NSLog(@"response: %@",responseString);
    NSError *error = nil;
	NSDictionary *dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSString * apiKey = [[[dictionaryFromJSON valueForKey:@"objects"] objectAtIndex:0] valueForKey:@"key"];
    NSString * fullName = [[[dictionaryFromJSON valueForKey:@"objects"] objectAtIndex:0] valueForKey:@"full_name"];
//    fullName = nil; // DISABLING THIS FUNCTIONALITY UNTIL WE CAN LOOK INTO IT MORE. Going back to email for now.
    NSString * kwiqetIdentifier = fullName && [fullName length] > 0 ? fullName : self.usernameField.text;
    
    [DefaultsModel saveAPIToUserDefaults:apiKey];
    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:kwiqetIdentifier]; // TEMPORARY HACK - IN FUTURE, WE WILL GET THE USER IDENTIFIER FROM OUR WEB CALL RESPONSE, JUST THE SAME AS HOW WE'RE GETTING THE API KEY // This has now been implemented. We are still however falling back on email address, in the case of no identifier being given. // TEMPORARILY DISABLING THIS FUNCTIONALITY UNTIL LATER
    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
    
    //alert user that they logged in
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged In!" 
                                                    message:@"Have fun at the events!" delegate:self 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
    [alert show]; 
    [alert release];
    
//    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.usernameField.text, @"email", nil];
    
    //go back to settings page
    [self.delegate loginViewController:self didFinishWithLogin:YES];
     
}

- (void)loginRequestFailed:(ASIHTTPRequest *)request {
    NSLog(@"LoginViewController requestFailed:");
    
    int responseCode = [request responseStatusCode];
    NSLog(@"code: %i",responseCode);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error!" 
                                                    message:@"Your password and/or username was not found. Please try again." delegate:self 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
    [alert show]; 
    [alert release];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self shiftViewsDirectionIsUpward:YES keyboardNotificationInfo:[notification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self shiftViewsDirectionIsUpward:NO keyboardNotificationInfo:[notification userInfo]];
}

- (void) shiftViewsDirectionIsUpward:(BOOL)directionIsUpward keyboardNotificationInfo:(NSDictionary *)info {

    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat contentOffsetY = directionIsUpward ? 40.0 : 0.0;
    CGFloat contentInsetBottom = directionIsUpward ? keyboardSize.height - (self.scrollViewContainer.frame.size.height - CGRectGetMaxY(self.infoLabel.frame)) : 0.0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        UIEdgeInsets contentInset = self.scrollViewContainer.contentInset;
        contentInset.bottom = contentInsetBottom;
        self.scrollViewContainer.contentInset = contentInset;
        self.scrollViewContainer.contentOffset = CGPointMake(0, contentOffsetY);
    }];
}


@end
