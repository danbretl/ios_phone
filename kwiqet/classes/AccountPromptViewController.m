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
#import "WebUtil.h"
#import "Facebook+Cancel.h"

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
@property (nonatomic, retain) UIImageView * namePictureContainerImageView;
@property (retain) UIView * pictureContainer;
@property (retain) UIButton * pictureButton;
@property (retain) UIImageView * pictureImageView;
@property (retain)  UITextField * firstNameTextField;
@property (retain)  UITextField * lastNameTextField;
@property (retain) UIView * emailPasswordContainer;
@property (nonatomic, retain) UIImageView * emailPasswordContainerImageView;
@property (retain) UITextField * emailTextField;
@property (retain) UITextField * passwordTextField;
@property (retain) UITextField * confirmPasswordTextField;
@property (retain) UILabel * emailAccountAssuranceLabel;

@property (retain) UISwipeGestureRecognizer * swipeDownGestureRecognizer;

- (IBAction) cancelButtonTouched:(id)sender;
- (IBAction) doneButtonTouched:(id)sender;
- (IBAction) accountOptionButtonTouched:(id)accountOptionButton;
- (void) swipedDown:(UISwipeGestureRecognizer *)swipeGestureRecognizer;
- (void) userInputSubmissionAttemptRequested;
- (void) accountConnectionAttemptRequested;
- (void) accountCreationAttemptRequested;
- (void) resignFirstResponderForAllTextFields;

- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated;
- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation activateAppropriateFirstResponder:(BOOL)shouldActivateFirstResponder animated:(BOOL)animated;

@property (retain) WebActivityView * webActivityView;
- (void) showWebActivityView;
- (void) hideWebActivityView;
@property (nonatomic, readonly) UIAlertView * passwordIncorrectAlertView;
@property (nonatomic, readonly) UIAlertView * forgotPasswordConnectionErrorAlertView;
@property (nonatomic, readonly) UIAlertView * anotherAccountWithEmailExistsAlertView;

@property (nonatomic, readonly) WebConnector * webConnector;
- (void) facebookAccountActivity:(NSNotification *)notification;
- (void) facebookGetBasicInfoSuccess:(NSNotification *)notification;
- (void) facebookGetBasicInfoFailure:(NSNotification *)notification;

@end

@implementation AccountPromptViewController

@synthesize navBar, logoButton, cancelButton, doneButton;
@synthesize titleImageView;
@synthesize mainViewsContainer;
@synthesize accountOptionsContainer, blurbLabel, loginCreateLabel, emailButton, facebookButton, twitterButton;
@synthesize inputContainer;
@synthesize accountCreationPromptLabel;
@synthesize namePictureContainer, namePictureContainerImageView, pictureContainer, pictureButton, pictureImageView, firstNameTextField, lastNameTextField;
@synthesize emailPasswordContainer, emailPasswordContainerImageView, emailTextField, passwordTextField, confirmPasswordTextField;
@synthesize emailAccountAssuranceLabel;
@synthesize swipeDownGestureRecognizer;
@synthesize webActivityView;
@synthesize delegate;

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
    [passwordIncorrectAlertView release];
    [forgotPasswordConnectionErrorAlertView release];
    [anotherAccountWithEmailExistsAlertView release];
    [webConnector release];
    [facebookManager release];
    [confirmPasswordTextField release];
    [namePictureContainer release];
    [pictureImageView release];
    [firstNameTextField release];
    [lastNameTextField release];
    [pictureContainer release];
    [pictureButton release];
    [accountCreationPromptLabel release];
    [swipeDownGestureRecognizer release];
    [namePictureContainerImageView release];
    [emailPasswordContainerImageView release];
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
    
    CALayer * backgroundImageLayer = [CALayer layer];
    CGRect viewFrameInWindow = [self.view convertRect:self.view.frame toView:nil];
    backgroundImageLayer.frame = CGRectMake(0, -viewFrameInWindow.origin.y, viewFrameInWindow.size.width, viewFrameInWindow.size.height);
    backgroundImageLayer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_patch_light.png"]].CGColor;
    backgroundImageLayer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0);
    [self.view.layer insertSublayer:backgroundImageLayer below:self.navBar.layer];
    
    UILabel * orLine = [[UILabel alloc] initWithFrame:CGRectMake(self.emailButton.frame.origin.x, CGRectGetMaxY(self.emailButton.frame), self.emailButton.frame.size.width, CGRectGetMinY(self.facebookButton.frame) - CGRectGetMaxY(self.emailButton.frame))];
    orLine.font = [UIFont kwiqetFontOfType:ObliqueNormal size:17];
    orLine.textColor = [WebUtil colorFromHexString:@"898989"];
    orLine.autoresizingMask = self.emailButton.autoresizingMask;
    orLine.backgroundColor = [UIColor clearColor];
    orLine.text = @"or";
    orLine.textAlignment = UITextAlignmentCenter;
    CGSize orSize = [orLine.text sizeWithFont:orLine.font];
    CGFloat orStartXPadding = 3;
    CGFloat orEndXPadding = 4;
    CGFloat orStartX = (orLine.frame.size.width - orSize.width) / 2.0 - orStartXPadding;
    CGFloat orEndX = orStartX + + orStartXPadding + orSize.width + orEndXPadding;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.frame = orLine.bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, nil, CGRectMake(0, 0, orStartX, maskLayer.frame.size.height));
    CGPathAddRect(maskPath, nil, CGRectMake(orEndX, 0, maskLayer.frame.size.width - orEndX, maskLayer.frame.size.height));
    maskLayer.path = maskPath;
    CGPathRelease(maskPath);
    CALayer * dividerGrayLayer = [CALayer layer];
    dividerGrayLayer.frame = CGRectMake(0, floorf(orLine.frame.size.height / 2.0) + 1, orLine.frame.size.width, 1);
    dividerGrayLayer.backgroundColor = [WebUtil colorFromHexString:@"9f9f9f"].CGColor;
    dividerGrayLayer.mask = maskLayer;
    CALayer * dividerWhiteLayer = [CALayer layer];
    dividerWhiteLayer.frame = CGRectOffset(dividerGrayLayer.frame, 0, 1);
    dividerWhiteLayer.backgroundColor = [WebUtil colorFromHexString:@"f7f7f7"].CGColor;
    CAShapeLayer * maskLayerCopy = [CAShapeLayer layer];
    maskLayerCopy.frame = maskLayer.frame;
    maskLayerCopy.fillColor = maskLayer.fillColor;
    maskLayerCopy.path = [UIBezierPath bezierPathWithCGPath:maskLayer.path].CGPath;
    maskLayerCopy.backgroundColor = maskLayer.backgroundColor;
    dividerWhiteLayer.mask = maskLayerCopy;
    [orLine.layer addSublayer:dividerGrayLayer];
    [orLine.layer addSublayer:dividerWhiteLayer];
    [self.accountOptionsContainer addSubview:orLine];
    
    accountCreationViewsVisible = YES;
    emailPasswordOriginYPartOfForm = self.emailPasswordContainer.frame.origin.y; // Just making dev easier. Otherwise would probably just be hard coded. We could be smarter here, but this is OK for now.
    emailPasswordOriginYMainStage = 74; // HARD CODED VALUE
    
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    self.mainViewsContainer.backgroundColor = [UIColor clearColor];
    self.accountOptionsContainer.backgroundColor = [UIColor clearColor];
    self.inputContainer.backgroundColor = [UIColor clearColor];
    
    self.blurbLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:18];
    self.blurbLabel.textColor = [UIColor colorWithRed:.33 green:.35 blue:.36 alpha:1.0];
    self.blurbLabel.shadowColor = [UIColor whiteColor];
    self.blurbLabel.shadowOffset = CGSizeMake(0, 1);
    self.loginCreateLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:16];
    UIFont * inputFont = [UIFont kwiqetFontOfType:RegularNormal size:16];
    self.firstNameTextField.font = inputFont;
    self.lastNameTextField.font = inputFont;
    self.emailTextField.font = inputFont;
    self.passwordTextField.font = inputFont;
    self.confirmPasswordTextField.font = inputFont;
    self.accountCreationPromptLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.emailAccountAssuranceLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
        
    UIImage * inputSectionBackgroundImage = [UIImage imageNamed:@"input_section_stretch_transparent.png"];
    if ([inputSectionBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        inputSectionBackgroundImage = [inputSectionBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    } else {
        inputSectionBackgroundImage = [inputSectionBackgroundImage stretchableImageWithLeftCapWidth:6 topCapHeight:6];
    }
    self.namePictureContainerImageView.contentMode = UIViewContentModeScaleToFill;
    self.emailPasswordContainerImageView.contentMode = UIViewContentModeScaleToFill;
    self.namePictureContainerImageView.image = inputSectionBackgroundImage;
    self.emailPasswordContainerImageView.image = inputSectionBackgroundImage;
    
    self.namePictureContainer.backgroundColor = [UIColor whiteColor];
    self.emailPasswordContainer.backgroundColor = [UIColor whiteColor];
    self.emailTextField.backgroundColor = self.emailPasswordContainer.backgroundColor;
    self.passwordTextField.backgroundColor = self.emailPasswordContainer.backgroundColor;
    self.confirmPasswordTextField.backgroundColor = self.emailPasswordContainer.backgroundColor;
    
    self.namePictureContainer.layer.cornerRadius = 5;
    self.namePictureContainer.layer.masksToBounds = YES;    
    self.emailPasswordContainer.layer.cornerRadius = 5;
    self.emailPasswordContainer.layer.masksToBounds = YES;
    
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
    
    initialPromptScreenVisible = YES;
    [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:NO animated:NO];
    [self showContainer:self.accountOptionsContainer animated:NO];
    
    swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    self.swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.swipeDownGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAccountActivity:) name:FBM_ACCOUNT_ACTIVITY_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoSuccess:) name:FBM_GET_BASIC_INFO_AND_EMAIL_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoFailure:) name:FBM_GET_BASIC_INFO_AND_EMAIL_FAILURE_KEY object:nil];
    
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
    [emailPasswordContainerImageView release];
    emailPasswordContainerImageView = nil;
    [namePictureContainerImageView release];
    namePictureContainerImageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.facebookButton.enabled = NO;
    self.facebookButton.alpha = 0.5;    
    self.twitterButton.enabled = NO;
    self.twitterButton.alpha = 0.5;
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
        
        [self showWebActivityView];
        [self.facebookManager pullAuthenticationInfoFromDefaults];
        if (![self.facebookManager.fb isSessionValid]) {
            waitingForFacebookAuthentication = YES;
            [self.facebookManager login];
            
            // Wait for a notification about succeeding or failing to Facebook-authenticate.
            
        } else {
            
            // Get from Facebook, using the authenticated Facebook account:
            // - the account ID
            // - the email(s) associated with that account
            waitingForFacebookInfo = YES;
            [self.facebookManager getBasicInfoAndEmail];
            
            // Wait for a notification about succeeding or failing to get that info. Allow for a user cancel.
            
        }
        
    } else if (accountOptionButton == self.twitterButton) {
        NSLog(@"Twitter button touched");
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized accountOptionButton %@", accountOptionButton);
    }
}

- (void)facebookAccountActivity:(NSNotification *)notification {
    if (waitingForFacebookAuthentication) {
        waitingForFacebookAuthentication = NO;
        // Check the notification.
        NSString * action = [notification.userInfo objectForKey:FBM_ACCOUNT_ACTIVITY_ACTION_KEY];
        if ([action isEqualToString:FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN]) {
            [self.facebookManager pullAuthenticationInfoFromDefaults];
            // Get from Facebook, using the authenticated Facebook account:
            // - the account ID
            // - the email(s) associated with that account
            waitingForFacebookInfo = YES;
            [self.facebookManager getBasicInfoAndEmail];
        } else {
            [self hideWebActivityView];
            BOOL userCancelled = [[notification.userInfo objectForKey:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT_IS_DUE_TO_CANCEL_KEY] boolValue];
            if (!userCancelled) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Connect" message:@"Could not connect to Facebook. Please try again, or try connecting to Kwiqet another way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
    }
}

- (void)facebookGetBasicInfoSuccess:(NSNotification *)notification {
    if (waitingForFacebookInfo) {
        waitingForFacebookInfo = NO;
        [self hideWebActivityView];
        // Call our server with the Facebook account ID and associated email, and wait for one of a few responses:
        // - Kwiqet account exists that is associated either with given Facebook account ID or email ; Will receive an API key, should log in the user.
        // - Associated Kwiqet account does not exist ; should send the user to the Kwiqet account creation screen (either with Facebook info we already grabbed, or start grabbing it then)
        NSString * fbID = [notification.userInfo objectForKey:FBM_BASIC_INFO_FACEBOOK_ID_KEY];
        NSString * fbEmail = [notification.userInfo objectForKey:FBM_BASIC_INFO_EMAIL_KEY];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not Implemented" message:[NSString stringWithFormat:@"At this point, we should call our server, with the Facebook account ID %@ and associated email %@.", fbID, fbEmail] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)facebookGetBasicInfoFailure:(NSNotification *)notification {
    if (waitingForFacebookInfo) {
        waitingForFacebookInfo = NO;
        [self hideWebActivityView];
        // Report back to the user that we failed to authenticate via Facebook. Instruct to try again or choose another avenue.
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Facebook Connect" message:@"Could not connect to Facebook. Please try again, or try connecting to Kwiqet another way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }    
}

- (IBAction)cancelButtonTouched:(id)sender {
    if (initialPromptScreenVisible) {
        if (waitingForFacebookAuthentication || waitingForFacebookInfo) {
            [self hideWebActivityView];
            waitingForFacebookAuthentication = NO;
            waitingForFacebookInfo = NO;
            [self.facebookManager.fb cancelPendingRequest];
        } else {
            [self.delegate accountPromptViewController:self didFinishWithConnection:NO];
        }
    } else {
        [self showContainer:self.accountOptionsContainer animated:YES];
    }
}

- (void)userInputSubmissionAttemptRequested {
    if (accountCreationViewsVisible) {
        [self accountCreationAttemptRequested];
    } else {
        [self accountConnectionAttemptRequested];
    }    
}

- (IBAction) doneButtonTouched:(id)sender {
    [self userInputSubmissionAttemptRequested];
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
            [self userInputSubmissionAttemptRequested];
        }
    } else if (textField == self.confirmPasswordTextField) {
        NSLog(@"Done on confirm password text field");
        [self userInputSubmissionAttemptRequested];
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized textField");
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.passwordIncorrectAlertView ||
        alertView == self.forgotPasswordConnectionErrorAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Start 'forgot password' flow.
            [self.webConnector forgotPasswordForAccountAssociatedWithEmail:self.emailTextField.text];
            [self showWebActivityView];
        } else {
            // Do nothing.
        }
    } else if (alertView == self.anotherAccountWithEmailExistsAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Change email
            [self.emailTextField becomeFirstResponder];
        } else {
            // Log in
            self.passwordTextField.text = @"";
            [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:YES animated:YES];
        }
    }
}

- (void)webConnector:(WebConnector *)webConnector forgotPasswordSuccess:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString {
    
    [self hideWebActivityView];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:[NSString stringWithFormat:@"Check your email at %@ and follow the link provided to set a new password.", emailString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show]; 
    [alert release];
    
    [self.passwordTextField becomeFirstResponder];
    self.passwordTextField.text = @"";
    self.confirmPasswordTextField.text = @""; // Sort of silly.
    
}

- (void)webConnector:(WebConnector *)webConnector forgotPasswordFailure:(ASIHTTPRequest *)request forAccountAssociatedWithEmail:(NSString *)emailString {
    
    [self hideWebActivityView];
    [self.forgotPasswordConnectionErrorAlertView show];
    
}

- (void) accountConnectionAttemptRequested {
    
    BOOL emailEntered = self.emailTextField.text.length > 0;
    BOOL emailValid = emailEntered && [WebUtil isValidEmailAddress:self.emailTextField.text];
    
    if (emailEntered) {
        if (emailValid) {
            [self.webConnector accountConnectWithEmail:self.emailTextField.text password:self.passwordTextField.text];
            [self showWebActivityView];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" 
                                                             message:@"You must enter a valid email address."
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
            [alert show]; 
            [alert release];
        }
    } else {
        [self.emailTextField becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" 
                                                        message:@"You must enter at least an email address."
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; 
        [alert release];
    }
    
}

- (void)accountCreationAttemptRequested {
    
    BOOL nameEntered = self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length > 0;
    BOOL emailEntered = self.emailTextField.text.length > 0;
    BOOL emailValid = emailEntered && [WebUtil isValidEmailAddress:self.emailTextField.text];
    BOOL passwordsEntered = self.passwordTextField.text.length > 0 && (!confirmPasswordVisible || self.confirmPasswordTextField.text.length > 0);
    BOOL passwordsMatch = passwordsEntered && (!confirmPasswordVisible || [self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]);
    
    if (!(nameEntered && emailEntered && emailValid && passwordsEntered && passwordsMatch)) {
        
        NSString * alertTitle = nil;
        NSString * alertMessage = nil;
        UITextField * nextFirstResponder = nil;
        if (!nameEntered) {
            // Missing Information
            // Enter your name, so that we'll know who to expect at events!
            // -> Make name (first or last) first responder
            alertTitle = @"Missing Information";
            alertMessage = @"Enter your name, so that we'll know who to expect at events!";
            nextFirstResponder = self.firstNameTextField.text.length == 0 ? self.firstNameTextField : self.lastNameTextField;
        } else if (!emailValid) {
            // Invalid Email
            // You must enter a valid email address.
            // -> Make email first responder
            alertTitle = @"Invalid Email";
            alertMessage = @"You must enter a valid email address.";
            nextFirstResponder = self.emailTextField;
        } else if (!passwordsEntered) {
            // Missing Information
            // You must enter a password.
            // -> Make password first responder
            // Please confirm your password.
            // -> Make confirm password first responder
            alertTitle = @"Missing Information";
            if (self.passwordTextField.text.length == 0) {
                alertMessage = @"You must enter a password.";
                nextFirstResponder = self.passwordTextField;
            } else {
                alertMessage = @"Please confirm your password.";
                nextFirstResponder = self.confirmPasswordTextField;
            }
        } else if (!passwordsMatch) {
            // Password Unconfirmed
            // Your password confirmation does not match. Please try again.
            // -> Clear confirm password, make confirm password first responder.
            alertTitle = @"Password Unconfirmed";
            alertMessage = @"Your password confirmation does not match. Please try again.";
            nextFirstResponder = self.confirmPasswordTextField;
            self.confirmPasswordTextField.text = @"";
        }
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        [nextFirstResponder becomeFirstResponder];
        
    } else {
        
        [self.webConnector accountCreateWithEmail:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text image:self.pictureImageView.image];
        [self showWebActivityView];
        
    }
    
}

- (void)webConnector:(WebConnector *)webConnector accountConnectSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString firstName:(NSString *)nameFirst lastName:(NSString *)nameLast apiKey:(NSString *)apiKey {
    
    [self hideWebActivityView];
    
    NSLog(@"AccountPromptViewController accountConnectSuccess email=%@ first=%@ last=%@ apiKey=%@", emailString, nameFirst, nameLast, apiKey);
    
    [DefaultsModel saveAPIKey:apiKey];
    NSString * identifierString = (nameFirst && nameFirst.length > 0) || (nameLast && nameLast.length > 0) ? [NSString stringWithFormat:@"%@%@%@", nameFirst, nameFirst != nil ? @" " : @"", nameLast] : emailString;
    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:identifierString];

    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
    
    [self.delegate accountPromptViewController:self didFinishWithConnection:YES];
    
}

//- (void)webConnector:(WebConnector *)webConnector accountConnectSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString kwiqetIdentifier:(NSString *)identifierString apiKey:(NSString *)apiKey {
//    
//    [self hideWebActivityView];
//    
//    [DefaultsModel saveAPIKey:apiKey];
//    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:identifierString];
//    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
//    
//    [self.delegate accountPromptViewController:self didFinishWithConnection:YES];
//    
//}

- (void) webConnector:(WebConnector *)webConnector accountConnectFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString {

    [self hideWebActivityView];
    
    if (failureCode == AccountConnectPasswordIncorrect) {
        [self.passwordIncorrectAlertView show];
    } else if (failureCode == AccountConnectAccountDoesNotExist) {
        [self showAccountCreationInputViews:YES showPasswordConfirmation:YES activateAppropriateFirstResponder:YES animated:YES];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Kwiqet. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
        [alert release];
    }
    
}

//- (void)webConnector:(WebConnector *)webConnector accountCreateSuccess:(ASIHTTPRequest *)request withEmail:(NSString *)emailString kwiqetIdentifier:(NSString *)identifierString apiKey:(NSString *)apiKey {
//    
//    [self hideWebActivityView];
//    
//    [DefaultsModel saveAPIKey:apiKey];
//    [DefaultsModel saveKwiqetUserIdentifierToUserDefaults:emailString]; // THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER. THIS SHOULD BE UPDATED. ONCE THE USER HAS AN API KEY, WE SHOULD USE IT TO GET INFORMATION ABOUT THAT USER.
//    NSDictionary * infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"login", @"action", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginActivity" object:self userInfo:infoDictionary];
//        
//    [self.delegate accountPromptViewController:self didFinishWithConnection:YES];
//    
//}

- (void)webConnector:(WebConnector *)webConnector accountCreateFailure:(ASIHTTPRequest *)request failureCode:(WebConnectorFailure)failureCode withEmail:(NSString *)emailString {
    
    [self hideWebActivityView];
    
    if (failureCode == AccountCreateEmailAssociatedWithAnotherAccount) {
        
        [self.anotherAccountWithEmailExistsAlertView show];
        
    } else {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry - there was a problem connecting with Kwiqet. Please check your connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
        [alert release];
        
    }
    
}

- (void) showContainer:(UIView *)viewsContainer animated:(BOOL)animated {
    
    BOOL shouldShowInputViews = (viewsContainer == self.inputContainer);
    
    void(^titleAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.titleImageView.alpha = shouldShow ? 1.0 : 0.0;
    };
    
    void(^buttonsAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.cancelButton.alpha = 1.0;
        self.doneButton.alpha = shouldShow ? 1.0 : 0.0;
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

    initialPromptScreenVisible = !shouldShowInputViews;
    self.cancelButton.userInteractionEnabled = YES;
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
                                 [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:NO animated:NO];
                             }
                         }];
    } else {
        titleAlphaBlock(YES);
        accountOptionsBlock(!shouldShowInputViews);
        emailOptionBlock(shouldShowInputViews);
        buttonsAlphaBlock(shouldShowInputViews);
        if (!shouldShowInputViews) {
            resetInputBlock();
            [self showAccountCreationInputViews:NO showPasswordConfirmation:NO activateAppropriateFirstResponder:NO animated:NO];
        }
    }
    if (shouldShowInputViews) {
        [self.emailTextField becomeFirstResponder];
    } else {
        [self resignFirstResponderForAllTextFields];
    }
    
}

- (void) resignFirstResponderForAllTextFields {
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

- (void) showAccountCreationInputViews:(BOOL)shouldShowCreationViews showPasswordConfirmation:(BOOL)shouldShowPasswordConfirmation activateAppropriateFirstResponder:(BOOL)shouldActivateFirstResponder animated:(BOOL)animated {
    
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
//        NSLog(@"%d", self.passwordTextField.returnKeyType);
        self.passwordTextField.returnKeyType = shouldExpand ? UIReturnKeyNext : UIReturnKeySend; // If passwordTextField is first responder when this call is made, the returnKeyType does not get updated until another text field becomes first responder, and then this one becomes it once again. It does not help to quickly switch to another and come back right here, either. Strange bug.
//        NSLog(@"passwordTextField.returnKeyType=%d (where 'Next'=%d & 'Send'=%d)", self.passwordTextField.returnKeyType, UIReturnKeyNext, UIReturnKeySend);
    };
    
    void(^emailAccountAssuranceAlphaBlock)(BOOL) = ^(BOOL shouldShow){
        self.emailAccountAssuranceLabel.alpha = shouldShow ? 1.0 : 0.0;
    };
    
    void(^firstResponderBlock)(void) = ^{
        if (shouldShowCreationViews) {
            NSArray * inputTextFields = [NSArray arrayWithObjects:self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, nil];
            for (UITextField * inputTextField in inputTextFields) {
                if (inputTextField.text.length == 0) {
                    [inputTextField becomeFirstResponder];
                    break;
                }
            }
        } else {
            if (self.emailTextField.text.length == 0) {
                [self.emailTextField becomeFirstResponder];
            } else {
                [self.passwordTextField becomeFirstResponder];
            }
            
        }
    };
    
    void(^resetCreationInputBlock)(BOOL) = ^(BOOL resetConfirmPassword){
        self.firstNameTextField.text = @"";
        self.lastNameTextField.text = @"";
        if (resetConfirmPassword) {
            self.confirmPasswordTextField.text = @"";
        }
    };
    
    accountCreationViewsVisible = shouldShowCreationViews;
    confirmPasswordVisible = shouldShowPasswordConfirmation;    
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
                             if (!shouldShowCreationViews) {
                                 resetCreationInputBlock(!confirmPasswordVisible);
                             }
                         }];
    } else {
        kwiqetLogoAlphaBlock(!shouldShowCreationViews);
        promptNamePictureAlphaBlock(shouldShowCreationViews);
        emailPasswordBlock(shouldShowCreationViews, shouldShowPasswordConfirmation);
        emailAccountAssuranceAlphaBlock(!shouldShowCreationViews);
        if (!shouldShowCreationViews) {
            resetCreationInputBlock(!confirmPasswordVisible);
        }
    }
    if (shouldActivateFirstResponder) {
        firstResponderBlock();
    }
    
}

- (void) showWebActivityView  {
    if (self.view.window) {
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        // USER INTERACTION
//        self.cancelButton.userInteractionEnabled = NO;
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

- (FacebookManager *)facebookManager {
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
        [facebookManager pullAuthenticationInfoFromDefaults];
    }
    return facebookManager;
}

- (UIAlertView *) passwordIncorrectAlertView {
    if (passwordIncorrectAlertView == nil) {
        passwordIncorrectAlertView = [[UIAlertView alloc] initWithTitle:@"Wrong Password" message:@"Your password was incorrect. Please try again." delegate:self cancelButtonTitle:@"Forgot" otherButtonTitles:@"Try Again", nil];
        passwordIncorrectAlertView.delegate = self;
    }
    return passwordIncorrectAlertView;
}

- (UIAlertView *) forgotPasswordConnectionErrorAlertView {
    if (forgotPasswordConnectionErrorAlertView == nil) {
        forgotPasswordConnectionErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Something went wrong while trying to reset your password. Check your connection and try again." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:@"OK", nil];
        forgotPasswordConnectionErrorAlertView.delegate = self;
    }
    return forgotPasswordConnectionErrorAlertView;
}

- (UIAlertView *) anotherAccountWithEmailExistsAlertView {
    if (anotherAccountWithEmailExistsAlertView == nil) {
        anotherAccountWithEmailExistsAlertView = [[UIAlertView alloc] initWithTitle:@"Account with Email Exists" message:@"There is already a Kwiqet account associated with that email. Please try logging in with that email address, or enter a different one." delegate:self cancelButtonTitle:@"Change Email" otherButtonTitles:@"Log In", nil];
        anotherAccountWithEmailExistsAlertView.delegate = self;
    }
    return anotherAccountWithEmailExistsAlertView;
}

- (void)swipedDown:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (swipeGestureRecognizer == self.swipeDownGestureRecognizer) {
        if (initialPromptScreenVisible) {
            [self.delegate accountPromptViewController:self didFinishWithConnection:NO];
        }
    }
}

@end
