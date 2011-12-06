//
//  AccountPromptViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountPromptViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Kwiqet.h"
#import "DefaultsModel.h"

double const AP_NAV_BUTTONS_ANIMATION_DURATION = 0.25;

@interface AccountPromptViewController()

@property (retain) UIView * navBar;
@property (retain) UIButton * logoButton;
@property (retain) UIButton * cancelButton;
@property (retain) UIButton * doneButton;
@property (retain) UIImageView * titleImageView;

@property (retain) UIView * mainViewsContainer;

@property (retain) UIView *accountOptionsContainer;
@property (retain) UILabel * blurbLabel;
@property (retain) UILabel * loginCreateLabel;
@property (retain) UIButton * emailButton;
@property (retain) UIButton * facebookButton;
@property (retain) UIButton * twitterButton;

@property (retain) UIView * inputContainer;
@property (retain) UILabel * accountCreationPromptLabel;
@property (retain) UIView * namePictureContainer;
@property (retain) UIView * pictureContainer;
@property (retain) UIButton * pictureButton;
@property (retain) UIImageView * pictureImageView;
@property (retain)  UITextField * firstNameTextField;
@property (retain)  UITextField * lastNameTextField;
@property (retain) UIView * emailPasswordContainer;
@property (retain) UITextField * emailTextField;
@property (retain) UITextField * passwordTextField;
@property (retain) UITextField * confirmPasswordTextField;
@property (retain) UILabel * emailAccountAssuranceLabel;

- (IBAction) cancelButtonTouched:(id)sender;
- (IBAction) doneButtonTouched:(id)sender;
- (IBAction) accountOptionButtonTouched:(id)accountOptionButton;
- (void) connectionAttemptRequested;

- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated;
- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation animated:(BOOL)animated;

@property (retain) WebActivityView * webActivityView;
- (void) showWebActivityView;
- (void) hideWebActivityView;

@property (nonatomic, readonly) WebConnector * webConnector;

@end

@implementation AccountPromptViewController

@synthesize navBar, logoButton, cancelButton, doneButton;
@synthesize titleImageView;
@synthesize mainViewsContainer;
@synthesize accountOptionsContainer, blurbLabel, loginCreateLabel, emailButton, facebookButton, twitterButton;
@synthesize inputContainer;
@synthesize accountCreationPromptLabel;
@synthesize namePictureContainer, pictureContainer, pictureButton, pictureImageView, firstNameTextField, lastNameTextField;
@synthesize emailPasswordContainer, emailTextField, passwordTextField, confirmPasswordTextField;
@synthesize emailAccountAssuranceLabel;
@synthesize webActivityView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [navBar release];
    [titleImageView release];
    [blurbLabel release];
    [emailButton release];
    [facebookButton release];
    [twitterButton release];
    [loginCreateLabel release];
    [cancelButton release];
    [doneButton release];
    [logoButton release];
    [mainViewsContainer release];
    [accountOptionsContainer release];
    [inputContainer release];
    [emailTextField release];
    [passwordTextField release];
    [emailPasswordContainer release];
    [emailAccountAssuranceLabel release];
    [webActivityView release];
    [webConnector release];
    [confirmPasswordTextField release];
    [namePictureContainer release];
    [pictureImageView release];
    [firstNameTextField release];
    [lastNameTextField release];
    [pictureContainer release];
    [pictureButton release];
    [accountCreationPromptLabel release];
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
    
    accountCreationViewsVisible = YES;
    emailPasswordOriginYPartOfForm = self.emailPasswordContainer.frame.origin.y; // Just making dev easier. Otherwise would probably just be hard coded. We could be smarter here, but this is OK for now.
    emailPasswordOriginYMainStage = 74; // HARD CODED VALUE
    
    
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    self.mainViewsContainer.backgroundColor = [UIColor clearColor];
    self.accountOptionsContainer.backgroundColor = [UIColor clearColor];
    self.inputContainer.backgroundColor = [UIColor clearColor];
    
    self.blurbLabel.font = [UIFont kwiqetFontOfType:LightNormal size:16];
    self.loginCreateLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:16];
    UIFont * inputFont = [UIFont kwiqetFontOfType:RegularNormal size:16];
    self.firstNameTextField.font = inputFont;
    self.lastNameTextField.font = inputFont;
    self.emailTextField.font = inputFont;
    self.passwordTextField.font = inputFont;
    self.confirmPasswordTextField.font = inputFont;
    self.accountCreationPromptLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.emailAccountAssuranceLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    
    self.namePictureContainer.layer.cornerRadius = 10;
    self.namePictureContainer.layer.masksToBounds = YES;
    self.namePictureContainer.layer.borderColor = [[UIColor colorWithWhite:0.65 alpha:1.0] CGColor];
    self.namePictureContainer.layer.borderWidth = 1.0;
    
    self.emailPasswordContainer.layer.cornerRadius = 10;
    self.emailPasswordContainer.layer.masksToBounds = YES;
    self.emailPasswordContainer.layer.borderColor = [[UIColor colorWithWhite:0.65 alpha:1.0] CGColor];
    self.emailPasswordContainer.layer.borderWidth = 1.0;
    
    self.pictureContainer.layer.cornerRadius = 5;
    self.pictureContainer.layer.masksToBounds = YES;
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds];
    [self.view addSubview:self.webActivityView];
    [self hideWebActivityView];
    
    [self.mainViewsContainer addSubview:self.accountOptionsContainer];
    self.accountOptionsContainer.frame = CGRectMake(0, 0, self.accountOptionsContainer.frame.size.width, self.accountOptionsContainer.frame.size.height);
    [self.mainViewsContainer addSubview:self.inputContainer];
    self.inputContainer.frame = CGRectMake(self.mainViewsContainer.frame.size.width, 0, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
    
    [self showAccountCreationInputViews:NO showPasswordConfirmation:NO animated:NO];
    [self showContainer:self.accountOptionsContainer animated:NO];
    
}

- (void)viewDidUnload
{
    [navBar release];
    navBar = nil;
    [titleImageView release];
    titleImageView = nil;
    [blurbLabel release];
    blurbLabel = nil;
    [emailButton release];
    emailButton = nil;
    [facebookButton release];
    facebookButton = nil;
    [twitterButton release];
    twitterButton = nil;
    [loginCreateLabel release];
    loginCreateLabel = nil;
    [cancelButton release];
    cancelButton = nil;
    [doneButton release];
    doneButton = nil;
    [logoButton release];
    logoButton = nil;
    [mainViewsContainer release];
    mainViewsContainer = nil;
    [accountOptionsContainer release];
    accountOptionsContainer = nil;
    [inputContainer release];
    inputContainer = nil;
    [emailTextField release];
    emailTextField = nil;
    [passwordTextField release];
    passwordTextField = nil;
    [emailPasswordContainer release];
    emailPasswordContainer = nil;
    [emailAccountAssuranceLabel release];
    emailAccountAssuranceLabel = nil;
    [webActivityView release];
    webActivityView = nil;
    [confirmPasswordTextField release];
    confirmPasswordTextField = nil;
    [namePictureContainer release];
    namePictureContainer = nil;
    [pictureImageView release];
    pictureImageView = nil;
    [firstNameTextField release];
    firstNameTextField = nil;
    [lastNameTextField release];
    lastNameTextField = nil;
    [pictureContainer release];
    pictureContainer = nil;
    [pictureButton release];
    pictureButton = nil;
    [accountCreationPromptLabel release];
    accountCreationPromptLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.facebookButton.enabled = NO;
    self.twitterButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)accountOptionButtonTouched:(id)accountOptionButton {
    if (accountOptionButton == self.emailButton) {
        [self showContainer:self.inputContainer animated:YES];
    } else if (accountOptionButton == self.facebookButton) {
        NSLog(@"Facebook button touched");
    } else if (accountOptionButton == self.twitterButton) {
        NSLog(@"Twitter button touched");
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized accountOptionButton %@", accountOptionButton);
    }
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self showContainer:self.accountOptionsContainer animated:YES];
}

- (IBAction) doneButtonTouched:(id)sender {
    NSLog(@"Done button touched - connectionAttemptRequested");
    [self showAccountCreationInputViews:!accountCreationViewsVisible showPasswordConfirmation:YES animated:YES];
//    [self connectionAttemptRequested];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.returnKeyType = confirmPasswordVisible ? UIReturnKeyNext : UIReturnKeySend;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        if (confirmPasswordVisible) {
            [self.confirmPasswordTextField becomeFirstResponder];
        } else {
            NSLog(@"Done on password text field");
//            [self connectionAttemptRequested];
        }
    } else if (textField == self.confirmPasswordTextField) {
        NSLog(@"Done on confirm password text field");
//        [self connectionAttemptRequested];
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized textField");
    }
    return NO;
}

//-(IBAction)forgotPasswordButtonTouched:(id)sender {
//    
//    if ([self.emailTextField.text length] > 0) {
//        
//        [self.emailTextField resignFirstResponder];
//        [self.passwordTextField resignFirstResponder];
//        
//        URLBuilder *urlBuilder = [[URLBuilder alloc]init];
//        NSURL *url = [urlBuilder buildForgotPasswordURL];
//        
//        //build json with {"email": email.text}
//        NSString * usernameValue = [NSString stringWithString:self.emailTextField.text];
//        NSDictionary *jsonDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:usernameValue,@"email", nil];
//        NSString *jsonString = [jsonDictionary JSONRepresentation];
//        [jsonDictionary release];
//        NSLog(@"json: %@",jsonString);
//        NSLog(@"url: %@",url);
//        
//        ASIFormDataRequest * forgotPasswordRequest = [ASIFormDataRequest requestWithURL:url];
//        [forgotPasswordRequest addRequestHeader:@"Content-Type" value:@"application/json"];
//        [forgotPasswordRequest appendPostData:[jsonString  dataUsingEncoding:NSUTF8StringEncoding]];
//        [forgotPasswordRequest setDelegate:self];
//        [forgotPasswordRequest setDidFinishSelector:@selector(passwordRequestFinished:)];
//        [forgotPasswordRequest setDidFailSelector:@selector(passwordRequestFailed:)];
//        [forgotPasswordRequest startAsynchronous];
//        
//        [urlBuilder release];
//        
//        [self showWebActivityView];
//        
//    } else {
//        
//        [self.emailTextField becomeFirstResponder];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
//                                                        message:@"You must enter a valid email."
//                                                       delegate:nil 
//                                              cancelButtonTitle:@"OK" 
//                                              otherButtonTitles:nil];
//        [alert show]; 
//        [alert release];
//        
//    }
//    
//}
//
//- (void)passwordRequestFinished:(ASIHTTPRequest *)request {
//    
//    [self hideWebActivityView];
//    NSLog(@"LoginViewController passwordRequestFinished:");
//    
//	NSString *responseString = [[NSString alloc]initWithString:[request responseString]];
//	NSLog(@"%@",responseString);
//    
//    NSError *error = nil;
//    NSDictionary *dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
//    NSLog(@"%@",dictionaryFromJSON);
//    NSString * responseMessage = [[dictionaryFromJSON valueForKey:@"email"]objectAtIndex:0];
//    NSLog(@"%@",responseMessage);
//    
//    //show alert
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" 
//                                                    message:@"Check your email and follow the link provided to set a new password." delegate:nil 
//                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert show]; 
//    [alert release];
//    [responseString release];
//}
//
//- (void)passwordRequestFailed:(ASIHTTPRequest *)request
//{
//    NSLog(@"LoginViewController passwordRequestFailed:");
//    [self hideWebActivityView];
//    
//	NSError *error = [request error];
//	NSLog(@"%@",error);
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
//}



-(void) connectionAttemptRequested {
    NSLog(@"LoginViewController connectionAttemptRequested");
    
    if ([self.passwordTextField.text length] > 0 &&
        [self.emailTextField.text length] > 0) {
        
        [self.webConnector accountConnectWithEmail:self.emailTextField.text password:self.passwordTextField.text];
        [self showWebActivityView];
        
    } else {
        
        if ([self.emailTextField.text length] == 0) {
            [self.emailTextField becomeFirstResponder];
        } else if ([self.passwordTextField.text length] == 0) {
            [self.passwordTextField becomeFirstResponder];
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

- (void)webConnector:(WebConnector *)webConnector accountConnectSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString kwiqetIdentifier:(NSString *)identifierString apiKey:(NSString *)apiKey {
    
    [self hideWebActivityView];
    
    [DefaultsModel saveAPIToUserDefaults:apiKey];
    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:identifierString];
    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
    
    //alert user that they logged in
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged In!" 
                                                    message:@"Have fun at the events!" delegate:self 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
    [alert show]; 
    [alert release];
    
}

- (void)webConnector:(WebConnector *)webConnector accountConnectFailure:(ASIHTTPRequest *)request withEmail:(NSString *)emailString {

    [self hideWebActivityView];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Log In Error!" 
                                                     message:@"Your password and/or username was not found. Please try again."
                                                    delegate:self 
                                           cancelButtonTitle:@"Ok" 
                                           otherButtonTitles:nil];
    [alert show]; 
    [alert release];
    
}

- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated {
    
    BOOL shouldShowInputViews = (viewsContainer == self.inputContainer);
    
    void(^titleAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.titleImageView.alpha = shouldShow ? 1.0 : 0.0;
    };
    
    void(^buttonsAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat buttonAlpha = shouldShow ? 1.0 : 0.0;
        self.cancelButton.alpha = buttonAlpha;
        self.doneButton.alpha = buttonAlpha;
    };
    
    void(^accountOptionsBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat alpha = shouldShow ? 1.0 : 0.0;
        self.accountOptionsContainer.alpha = alpha;
    };
    
    void(^emailOptionBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat alpha = shouldShow ? 1.0 : 0.0;
        self.inputContainer.alpha = alpha;
        CGRect inputContainerFrame = self.inputContainer.frame;
        inputContainerFrame.origin.x = shouldShow ? 0 : self.mainViewsContainer.frame.size.width;
        self.inputContainer.frame = inputContainerFrame;
    };
    
    void(^resetInputBlock)(void) = ^{
        self.firstNameTextField.text = @"";
        self.lastNameTextField.text = @"";
        self.emailTextField.text = @"";
        self.passwordTextField.text = @"";
        self.confirmPasswordTextField.text = @"";
    };

    self.cancelButton.userInteractionEnabled = shouldShowInputViews;
    self.doneButton.userInteractionEnabled = shouldShowInputViews;
    if (animated) {
        [UIView animateWithDuration:AP_NAV_BUTTONS_ANIMATION_DURATION 
                              delay:0 
                            options:0 
                         animations:^{
                             titleAlphaBlock(YES);
                             accountOptionsBlock(!shouldShowInputViews);
                             emailOptionBlock(shouldShowInputViews);
                             buttonsAlphaBlock(shouldShowInputViews);
                         }
                         completion:^(BOOL finished) {
                             if (!shouldShowInputViews) {
                                 resetInputBlock();
                                 [self showAccountCreationInputViews:NO showPasswordConfirmation:NO animated:NO];
                             }
                         }];
    } else {
        titleAlphaBlock(YES);
        accountOptionsBlock(!shouldShowInputViews);
        emailOptionBlock(shouldShowInputViews);
        buttonsAlphaBlock(shouldShowInputViews);
        if (!shouldShowInputViews) {
            resetInputBlock();
            [self showAccountCreationInputViews:NO showPasswordConfirmation:NO animated:NO];
        }
    }
    if (shouldShowInputViews) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [self.firstNameTextField resignFirstResponder];
        [self.lastNameTextField resignFirstResponder];
        [self.emailTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
}

- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation animated:(BOOL)animated {
    
    shouldShowPasswordConfirmation &= shouldShowCreationViews;
    
    void(^kwiqetLogoAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.titleImageView.alpha = shouldShow ? 1.0 : 0.0;
    };
    
    void(^promptNamePictureAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        CGFloat alpha = shouldShow ? 1.0 : 0.0;
        self.accountCreationPromptLabel.alpha = alpha;
        self.namePictureContainer.alpha = alpha;
    };
    
    void(^emailPasswordBlock)(BOOL, BOOL) = ^(BOOL shouldShiftDown, BOOL shouldExpand){
        CGRect emailPasswordContainerFrame = self.emailPasswordContainer.frame;
        emailPasswordContainerFrame.origin.y = shouldShiftDown ? emailPasswordOriginYPartOfForm : emailPasswordOriginYMainStage;
        CGFloat calculatedHeight = CGRectGetMaxY(self.passwordTextField.frame);
        if (shouldExpand) { 
            calculatedHeight += self.confirmPasswordTextField.frame.size.height;
        }
        emailPasswordContainerFrame.size.height = calculatedHeight;
        self.emailPasswordContainer.frame = emailPasswordContainerFrame;
        self.passwordTextField.returnKeyType = shouldExpand ? UIReturnKeyNext : UIReturnKeySend;
    };
    
    void(^emailAccountAssuranceAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.emailAccountAssuranceLabel.alpha = shouldShow ? 1.0 : 0.0;
    };
    
    if (animated) {
        [UIView animateWithDuration:AP_NAV_BUTTONS_ANIMATION_DURATION 
                              delay:0.0 
                            options:0 
                         animations:^{
                             kwiqetLogoAlphaBlock(!shouldShowCreationViews);
                             promptNamePictureAlphaBlock(shouldShowCreationViews);
                             emailPasswordBlock(shouldShowCreationViews, shouldShowPasswordConfirmation);
                             emailAccountAssuranceAlphaBlock(!shouldShowCreationViews);
                         }
                         completion:^(BOOL finished){
                             accountCreationViewsVisible = shouldShowCreationViews;
                             confirmPasswordVisible = shouldShowPasswordConfirmation;

                         }];
    } else {
        kwiqetLogoAlphaBlock(!shouldShowCreationViews);
        promptNamePictureAlphaBlock(shouldShowCreationViews);
        emailPasswordBlock(shouldShowCreationViews, shouldShowPasswordConfirmation);
        emailAccountAssuranceAlphaBlock(!shouldShowCreationViews);
        accountCreationViewsVisible = shouldShowCreationViews;
        confirmPasswordVisible = shouldShowPasswordConfirmation;
    }
    
}

- (void) showWebActivityView  {
    if (self.view.window) {
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        // USER INTERACTION
        self.cancelButton.userInteractionEnabled = NO;
        self.doneButton.userInteractionEnabled = NO;
    }
}

- (void) hideWebActivityView  {
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.cancelButton.userInteractionEnabled = YES;
    self.doneButton.userInteractionEnabled = YES;
}

- (WebConnector *) webConnector {
    if (webConnector == nil) {
        webConnector = [[WebConnector alloc] init];
        webConnector.delegate = self;
    }
    return webConnector;
}

@end
