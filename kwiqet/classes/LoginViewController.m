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
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController()
@property (retain) UIScrollView * scrollViewContainer;
//- (void) keyboardWillShow:(NSNotification *)notification;
//- (void) keyboardWillHide:(NSNotification *)notification;
//- (void) shiftViewsDirectionIsUpward:(BOOL)directionIsUpward keyboardNotificationInfo:(NSDictionary *)info;
@property (retain) IBOutlet UIView * inputContainerView;
@property (retain) IBOutlet UITextField * usernameField;
@property (retain) IBOutlet UITextField * passwordField;
@property (retain) IBOutlet UITextView * messageTextView;
@property (retain) WebActivityView * webActivityView;
@property (retain) IBOutlet UIButton * cancelButton;
@property (retain) IBOutlet UIButton * loginButton;
- (void) showWebActivityView;
- (void) hideWebActivityView;
@end

@implementation LoginViewController
@synthesize scrollViewContainer;
@synthesize cancelButton, loginButton;
@synthesize inputContainerView, usernameField, passwordField;
@synthesize messageTextView;
@synthesize delegate;
@synthesize webActivityView;

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
    [cancelButton release];
    [loginButton release];
    [messageTextView release];
    [inputContainerView release];
    [usernameField release];
    [passwordField release];
    [scrollViewContainer release];
    [webActivityView release];
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
    
    self.inputContainerView.layer.cornerRadius = 10;
    self.inputContainerView.layer.masksToBounds = YES;
    self.inputContainerView.layer.borderColor = [[UIColor colorWithWhite:0.65 alpha:1.0] CGColor];
    self.inputContainerView.layer.borderWidth = 1.0;
        
    self.messageTextView.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size: 16];
    self.messageTextView.text = @"Creating a Kwiqet account allows you to send invitations to the people you care about most in order to do the things you love best. This is your ticket to the world - the ultimate mobile invitation.";
    [self.scrollViewContainer addSubview:self.messageTextView];
    
    // Register for keyboard events
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds];
    [self.view addSubview:self.webActivityView];
    [self hideWebActivityView];

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
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self makeLoginRequest];
    } else {
        NSLog(@"ERROR in LoginViewController - unrecognized textField");
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Disabled" 
                                                    message:@"You can't register a new account from within the App during Alpha. Check your email for account activation and login details."
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show]; 
    [alert release];
}


#pragma login dialog
-(IBAction)forgotPasswordButtonTouched:(id)sender {
    
    if ([self.usernameField.text length] > 0) {
        
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
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
        
        [self showWebActivityView];

    } else {
        
        [self.usernameField becomeFirstResponder];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"You must enter a valid email."
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; 
        [alert release];
        
    }
    
}

- (void)passwordRequestFinished:(ASIHTTPRequest *)request {
    
    [self hideWebActivityView];
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
    [self hideWebActivityView];
          
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
    
    if ([passwordField.text length] > 0 &&
        [usernameField.text length] > 0) {
        
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
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
        [self showWebActivityView];
        
    } else {
        
        if ([self.usernameField.text length] == 0) {
            [self.usernameField becomeFirstResponder];
        } else if ([self.passwordField.text length] == 0) {
            [self.passwordField becomeFirstResponder];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"You must enter a valid email and password."
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; 
        [alert release];
        
    }

}

- (void)loginRequestFinished:(ASIHTTPRequest *)request {
    NSLog(@"LoginViewController loginRequestFinished:%@", request);
    [self hideWebActivityView];
    
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
    [self hideWebActivityView];
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

//- (void)keyboardWillShow:(NSNotification *)notification {
//    [self shiftViewsDirectionIsUpward:YES keyboardNotificationInfo:[notification userInfo]];
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//    [self shiftViewsDirectionIsUpward:NO keyboardNotificationInfo:[notification userInfo]];
//}

//- (void) shiftViewsDirectionIsUpward:(BOOL)directionIsUpward keyboardNotificationInfo:(NSDictionary *)info {
//
//    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    CGFloat contentOffsetY = directionIsUpward ? 40.0 : 0.0;
//    CGFloat contentInsetBottom = directionIsUpward ? keyboardSize.height - (self.scrollViewContainer.frame.size.height - CGRectGetMaxY(self.messageTextView.frame)) : 0.0;
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        UIEdgeInsets contentInset = self.scrollViewContainer.contentInset;
//        contentInset.bottom = contentInsetBottom;
//        self.scrollViewContainer.contentInset = contentInset;
//        self.scrollViewContainer.contentOffset = CGPointMake(0, contentOffsetY);
//    }];
//}

- (void) showWebActivityView  {
    if (self.view.window) {
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        // USER INTERACTION
        self.scrollViewContainer.userInteractionEnabled = NO;
        self.cancelButton.userInteractionEnabled = NO;
        self.loginButton.userInteractionEnabled = NO;
    }
}

- (void) hideWebActivityView  {
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.scrollViewContainer.userInteractionEnabled = YES;
    self.cancelButton.userInteractionEnabled = YES;
    self.loginButton.userInteractionEnabled = YES;
}


@end
