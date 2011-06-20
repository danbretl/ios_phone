//
//  RegistrationViewController.m
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "RegistrationViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "URLBuilder.h"
#import <YAJL/YAJL.h>
#import "DefaultsModel.h"
#define kOFFSET_FOR_KEYBOARD 60.0
@implementation RegistrationViewController
@synthesize usernameField,passwordField,confirmPasswordField;
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
    [super dealloc];
    [usernameField release];
    [passwordField release];
    [confirmPasswordField release];
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
    confirmPasswordField.delegate = self;
    
    UILabel *emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 60, 111, 21)];
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 16];
    emailLabel.text = @"Email Address";
    emailLabel.numberOfLines = 1;
    [self.view addSubview:emailLabel];
    
    UILabel *passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 136, 111, 21)];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 16];
    passwordLabel.text = @"Password";
    passwordLabel.numberOfLines = 1;
    [self.view addSubview:passwordLabel];
    
    UILabel *REPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 215, 140, 21)];
    REPasswordLabel.backgroundColor = [UIColor clearColor];
    REPasswordLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size: 16];
    REPasswordLabel.text = @"Confirm Password";
    REPasswordLabel.numberOfLines = 1;
    [self.view addSubview:REPasswordLabel];
    
    [emailLabel release];
    [passwordLabel release];
    [REPasswordLabel release];
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

#pragma textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 40;  // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(IBAction)cancelButtonTouched:(id)sender  {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma registration

-(IBAction)doneButtonTouched:(id)sender  {
    NSString* usernameValue = [usernameField.text retain];
    NSString* passwordValue = [passwordField.text retain];
    NSString *confirmValue = [confirmPasswordField.text retain];
    if ([passwordValue isEqualToString:confirmValue]) {
        URLBuilder *urlBuilder = [[URLBuilder alloc]init];
        NSURL *url = [urlBuilder buildRegistrationURL]; 
        //build json with {"email":hhh@hhh.com, "password": "hello" "password": "hello" }
        NSDictionary *jsonDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:usernameValue,@"email",passwordValue,@"password1",passwordValue,@"password2", nil];
        NSString *jsonString = [jsonDictionary JSONRepresentation];
        
        ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:url];
        [loginRequest setRequestMethod:@"POST"];
        [loginRequest addRequestHeader:@"Content-Type" value:@"application/json"];
        [loginRequest appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
        [loginRequest setDelegate:self];
        [loginRequest startAsynchronous];
        
        [urlBuilder release];
        [jsonDictionary release];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!" 
                                                        message:@"Your passwords did not match. Re-enter please." delegate:self 
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
    }
    [usernameValue release];
    [passwordValue release];
    [confirmValue release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
    //NSLog(@"%@",responseString);
    NSError *error = nil;
    NSDictionary *dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSString *emailUsed = [dictionaryFromJSON valueForKey:@"email"];
    if (emailUsed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!" 
                                                        message:@"This email has already been registered. Please try another." delegate:self 
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
    }
    else {
        //save the api key in nsuserdefaults
        [DefaultsModel saveAPIToUserDefaults:responseString];
        NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
        
        //alert user that they logged in
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged In!" 
                                                        message:@"Have fun at the events!" delegate:self 
                                              cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
        [alert show]; 
        [alert release];
        
        //go back to settings page
        [self.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"%@",error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-Oh!" 
                                                    message:@"Something went wrong..please try again!" delegate:self 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
    [alert show]; 
    [alert release];
}

@end
