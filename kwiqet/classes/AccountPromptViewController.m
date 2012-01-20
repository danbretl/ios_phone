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
#import "UIView+GetFirstResponder.h"
#import <MobileCoreServices/UTCoreTypes.h>

double const AP_NAV_BUTTONS_ANIMATION_DURATION = 0.25;
static NSString * AP_IMAGE_PICKER_OPTION_TEXT_CAMERA = @"Camera";
static NSString * AP_IMAGE_PICKER_OPTION_TEXT_LIBRARY = @"Photo Library";

@interface AccountPromptViewController()

@property (nonatomic, retain) NSString * firstNameInputString;
@property (nonatomic, retain) NSString * lastNameInputString;
@property (nonatomic, retain) NSString * emailInputString;
@property (nonatomic, retain) NSString * passwordInputString;
@property (nonatomic, retain) NSString * confirmPasswordInputString;
@property (nonatomic, retain) UIImage * pictureInputImage;

@property (retain) UIView * navBar;
@property (retain) UIButton * logoButton;
@property (retain) UIButton * cancelButton;
@property (retain) UIButton * doneButton;
@property (retain) UIImageView * titleImageView;

@property (retain) UIView * mainViewsContainer;

@property (retain) UIView *accountOptionsContainer;
@property (retain) UILabel * blurbLabel;
@property (retain) UIButton * emailButton;
@property (retain) UIButton * facebookButton;
@property (retain) UIButton * twitterButton;

@property (retain) UIScrollView * inputContainer;
@property (retain) UILabel * accountCreationPromptLabel;
@property (retain) UIView * namePictureContainer;
@property (retain) UIView * namePictureContainerHighlight;
@property (nonatomic, retain) UIImageView * namePictureContainerImageView;
@property (retain) UIButtonWithDynamicBackgroundColor * pictureButton;
@property (retain)  UITextField * firstNameTextField;
@property (retain)  UITextField * lastNameTextField;
@property (retain) UIView * emailPasswordContainer;
@property (retain) UIView * emailPasswordContainerHighlight;
@property (nonatomic, retain) UIImageView * emailPasswordContainerImageView;
@property (retain) UITextField * emailTextField;
@property (retain) UITextField * passwordTextField;
@property (retain) UITextField * confirmPasswordTextField;
@property (retain) UILabel * emailAccountAssuranceLabel;

@property (retain) UISwipeGestureRecognizer * swipeDownGestureRecognizer;

- (IBAction) pictureButtonTouched:(UIButton *)button;
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
- (void) setHighlighted:(BOOL)shouldHighlight forInputSectionContainer:(UIView *)inputSectionContainer animated:(BOOL)animated;
- (void) setContainerToBeVisible:(UIView *)containerView animated:(BOOL)animated;

@property (retain) WebActivityView * webActivityView;
- (void) showWebActivityView;
- (void) hideWebActivityView;
@property (nonatomic, readonly) UIAlertView * passwordIncorrectAlertView;
@property (nonatomic, readonly) UIAlertView * emailInvalidAlertView;
@property (nonatomic, readonly) UIAlertView * forgotPasswordConnectionErrorAlertView;
@property (nonatomic, readonly) UIAlertView * anotherAccountWithEmailExistsAlertView;
@property (nonatomic, readonly) UIActionSheet * imagePickerActionSheet;

- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void)setBottomInset:(CGFloat)bottomInset forScrollView:(UIScrollView *)scrollView;

@property (nonatomic, readonly) WebConnector * webConnector;
- (void) facebookAccountActivity:(NSNotification *)notification;
- (void) facebookGetBasicInfoSuccess:(NSNotification *)notification;
- (void) facebookGetBasicInfoFailure:(NSNotification *)notification;

@property (nonatomic, retain) UIImagePickerController * imagePickerController;

@end

@implementation AccountPromptViewController

@synthesize firstNameInputString, lastNameInputString, emailInputString, passwordInputString, confirmPasswordInputString, pictureInputImage;
@synthesize navBar, logoButton, cancelButton, doneButton;
@synthesize titleImageView;
@synthesize mainViewsContainer;
@synthesize accountOptionsContainer, blurbLabel, emailButton, facebookButton, twitterButton;
@synthesize inputContainer;
@synthesize accountCreationPromptLabel;
@synthesize namePictureContainer, namePictureContainerHighlight, namePictureContainerImageView, pictureButton, firstNameTextField, lastNameTextField;
@synthesize emailPasswordContainer, emailPasswordContainerHighlight, emailPasswordContainerImageView, emailTextField, passwordTextField, confirmPasswordTextField;
@synthesize emailAccountAssuranceLabel;
@synthesize swipeDownGestureRecognizer;
@synthesize webActivityView;
@synthesize imagePickerController=imagePickerController_;
@synthesize imagePickerActionSheet;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        initialPromptScreenVisible = YES;
        accountCreationViewsVisible = NO;
        confirmPasswordVisible = NO;
    }
    return self;
}

- (void)dealloc {
    [firstNameInputString release];
    [lastNameInputString release];
    [emailInputString release];
    [passwordInputString release];
    [confirmPasswordInputString release];
    [pictureInputImage release];
    [navBar release];
    [titleImageView release];
    [blurbLabel release];
    [emailButton release];
    [facebookButton release];
    [twitterButton release];
    [cancelButton release];
    [doneButton release];
    [logoButton release];
    [mainViewsContainer release];
    [accountOptionsContainer release];
    [inputContainer release];
    [emailTextField release];
    [passwordTextField release];
    [emailPasswordContainer release];
    [emailPasswordContainerHighlight release];
    [emailAccountAssuranceLabel release];
    [webActivityView release];
    [passwordIncorrectAlertView release];
    [imagePickerActionSheet release];
    [emailInvalidAlertView release];
    [forgotPasswordConnectionErrorAlertView release];
    [anotherAccountWithEmailExistsAlertView release];
    [webConnector release];
    [facebookManager release];
    [confirmPasswordTextField release];
    [namePictureContainer release];
    [namePictureContainerHighlight release];
    [firstNameTextField release];
    [lastNameTextField release];
    [pictureButton release];
    [accountCreationPromptLabel release];
    [swipeDownGestureRecognizer release];
    [namePictureContainerImageView release];
    [emailPasswordContainerImageView release];
    [imagePickerController_ release];
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
    
    emailPasswordOriginYPartOfForm = self.emailPasswordContainer.frame.origin.y; // Just making dev easier. Otherwise would probably just be hard coded. We could be smarter here, but this is OK for now.
    emailPasswordOriginYMainStage = 64; // HARD CODED VALUE
    
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    self.mainViewsContainer.backgroundColor = [UIColor clearColor];
    self.accountOptionsContainer.backgroundColor = [UIColor clearColor];
    self.inputContainer.backgroundColor = [UIColor clearColor];
    
    UIColor * grayBlueColor = [UIColor colorWithRed:82.0/255.0 green:89.0/255.0 blue:91.0/255.0 alpha:1.0];
    self.blurbLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:18];
    self.blurbLabel.textColor = grayBlueColor;
    self.blurbLabel.shadowColor = [UIColor whiteColor];
    self.blurbLabel.shadowOffset = CGSizeMake(0, 1);
    self.emailAccountAssuranceLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:16];
    self.emailAccountAssuranceLabel.textColor = grayBlueColor;
    self.emailAccountAssuranceLabel.shadowColor = [UIColor whiteColor];
    self.emailAccountAssuranceLabel.shadowOffset = CGSizeMake(0, 1);
    self.emailAccountAssuranceLabel.numberOfLines = 0;
    self.emailAccountAssuranceLabel.text = @"If you don't have an account yet,\nwe'll make one for you!";
    CGSize emailAccountAssuranceLabelTextSize = [self.emailAccountAssuranceLabel.text  sizeWithFont:self.emailAccountAssuranceLabel.font constrainedToSize:CGSizeMake(self.inputContainer.frame.size.width, 1000)];
    NSLog(@"emailAccountAssuranceLabelTextSize=%@", NSStringFromCGSize(emailAccountAssuranceLabelTextSize));
    CGRect emailAccountAssuranceLabelFrame = self.emailAccountAssuranceLabel.frame;
    emailAccountAssuranceLabelFrame.size.width = emailAccountAssuranceLabelTextSize.width;
    emailAccountAssuranceLabelFrame.origin.x = (self.emailAccountAssuranceLabel.superview.frame.size.width - emailAccountAssuranceLabelFrame.size.width) / 2.0;
    self.emailAccountAssuranceLabel.frame = emailAccountAssuranceLabelFrame;
    self.emailAccountAssuranceLabel.textAlignment = UITextAlignmentLeft;
    self.accountCreationPromptLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:18];
    self.accountCreationPromptLabel.textColor = grayBlueColor;
    self.accountCreationPromptLabel.shadowColor = [UIColor whiteColor];
    self.accountCreationPromptLabel.shadowOffset = CGSizeMake(0, 1);
    
    UIFont * inputFont = [UIFont kwiqetFontOfType:RegularNormal size:17];
    self.firstNameTextField.font = inputFont;
    self.firstNameTextField.textColor = grayBlueColor;
    self.lastNameTextField.font = inputFont;
    self.lastNameTextField.textColor = grayBlueColor;
    self.emailTextField.font = inputFont;
    self.emailTextField.textColor = grayBlueColor;
    self.passwordTextField.font = inputFont;
    self.passwordTextField.textColor = grayBlueColor;
    self.confirmPasswordTextField.font = inputFont;
    self.confirmPasswordTextField.textColor = grayBlueColor;
        
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
    
    UIColor * inputBackgroundColor = [UIColor colorWithWhite:245.0/255.0 alpha:1.0];
    self.namePictureContainer.backgroundColor = inputBackgroundColor;
    self.emailPasswordContainer.backgroundColor = inputBackgroundColor;
    self.firstNameTextField.backgroundColor = inputBackgroundColor;
    self.lastNameTextField.backgroundColor = inputBackgroundColor;
    self.emailTextField.backgroundColor = inputBackgroundColor;
    self.passwordTextField.backgroundColor = inputBackgroundColor;
    self.confirmPasswordTextField.backgroundColor = inputBackgroundColor;
    
    UIColor * lightBlueHighlightColor = [UIColor colorWithRed:11.0/255.0 green:149.0/255.0 blue:229.0/255.0 alpha:0.25];

    self.pictureButton.layer.shadowOffset = CGSizeMake(0.5, 1.0);
    self.pictureButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pictureButton.layer.shadowOpacity = 0.4;
    self.pictureButton.layer.shadowRadius = 1.0;
    self.pictureButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.pictureButton.bounds/*CGRectMake(0, 0, self.pictureButton.frame.size.width - .5, self.pictureButton.frame.size.height)*/].CGPath;
    self.pictureButton.backgroundColorHighlight = lightBlueHighlightColor;
    
    self.namePictureContainer.layer.cornerRadius = 5;
    self.namePictureContainer.layer.masksToBounds = YES;
    self.emailPasswordContainer.layer.cornerRadius = 5;
    self.emailPasswordContainer.layer.masksToBounds = YES;
    
    namePictureContainerHighlight = [[UIView alloc] initWithFrame:CGRectInset(self.namePictureContainer.frame, -2, -2)];
    emailPasswordContainerHighlight = [[UIView alloc] initWithFrame:CGRectInset(self.emailPasswordContainer.frame, -2, -2)];
    self.namePictureContainerHighlight.backgroundColor = lightBlueHighlightColor;
    self.emailPasswordContainerHighlight.backgroundColor = lightBlueHighlightColor;
    self.namePictureContainerHighlight.alpha = 0.0;
    self.emailPasswordContainerHighlight.alpha = 0.0;
    self.namePictureContainerHighlight.layer.cornerRadius = 5 + 2;
    self.emailPasswordContainerHighlight.layer.cornerRadius = 5 + 2;
    [self.namePictureContainer.superview insertSubview:self.namePictureContainerHighlight belowSubview:self.namePictureContainer];
    [self.emailPasswordContainer.superview insertSubview:self.emailPasswordContainerHighlight belowSubview:self.emailPasswordContainer];
        
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds];
    [self.view addSubview:self.webActivityView];
    [self hideWebActivityView];
    
    [self.mainViewsContainer addSubview:self.accountOptionsContainer];
    self.accountOptionsContainer.frame = CGRectMake(0, 0, self.accountOptionsContainer.frame.size.width, self.accountOptionsContainer.frame.size.height);
    [self.mainViewsContainer addSubview:self.inputContainer];
    self.inputContainer.frame = CGRectMake(self.mainViewsContainer.frame.size.width, 0, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
    
    swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    self.swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:self.swipeDownGestureRecognizer];
    
    // Register for Facebook events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAccountActivity:) name:FBM_ACCOUNT_ACTIVITY_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoSuccess:) name:FBM_GET_BASIC_INFO_AND_EMAIL_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookGetBasicInfoFailure:) name:FBM_GET_BASIC_INFO_AND_EMAIL_FAILURE_KEY object:nil];
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // The view might have unloaded due to a memory warning. If so, get back to where we were now.
    [self showContainer:initialPromptScreenVisible ? self.accountOptionsContainer : self.inputContainer animated:NO];
    [self showAccountCreationInputViews:accountCreationViewsVisible showPasswordConfirmation:confirmPasswordVisible activateAppropriateFirstResponder:NO animated:NO];
    self.firstNameTextField.text = self.firstNameInputString;
    self.lastNameTextField.text = self.lastNameInputString;
    self.emailTextField.text = self.emailInputString;
    self.passwordTextField.text = self.passwordInputString;
    self.confirmPasswordTextField.text = self.confirmPasswordInputString;
    //self.pictureButton setImage...
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
    [emailPasswordContainerHighlight release];
    emailPasswordContainerHighlight = nil;
    [emailAccountAssuranceLabel release];
    emailAccountAssuranceLabel = nil;
    [webActivityView release];
    webActivityView = nil;
    [confirmPasswordTextField release];
    confirmPasswordTextField = nil;
    [namePictureContainer release];
    namePictureContainer = nil;
    [namePictureContainerHighlight release];
    namePictureContainerHighlight = nil;
    [firstNameTextField release];
    firstNameTextField = nil;
    [lastNameTextField release];
    lastNameTextField = nil;
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
        [self.emailTextField becomeFirstResponder];
        
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

- (void)pictureButtonTouched:(UIButton *)button {
    
    [self resignFirstResponderForAllTextFields];
    [self setHighlighted:NO forInputSectionContainer:self.namePictureContainer animated:NO];
    [self setHighlighted:NO forInputSectionContainer:self.emailPasswordContainer animated:NO];
    
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (cameraAvailable) {
        [self.imagePickerActionSheet showFromRect:self.pictureButton.bounds inView:self.pictureButton animated:YES];
    } else {
        self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController.delegate = self;
        [self presentModalViewController:self.imagePickerController animated:YES];
    }

}

- (UIActionSheet *)imagePickerActionSheet {
    if (imagePickerActionSheet == nil) {
        imagePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    }
    return imagePickerActionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSArray * mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        
        NSString * buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:AP_IMAGE_PICKER_OPTION_TEXT_CAMERA]) {
            // Camera
            sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if ([buttonTitle isEqualToString:AP_IMAGE_PICKER_OPTION_TEXT_LIBRARY]) {
            // Photo Library
            // ...
        }
        
        self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
        self.imagePickerController.sourceType = sourceType;
        self.imagePickerController.mediaTypes = mediaTypes;
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.delegate = self;
        [self presentModalViewController:self.imagePickerController animated:YES];
        
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel:");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing:%@", textField);
    
    UIView * containerView = textField.superview.superview; // HARD CODED, HACK AVOIDING THE AUTO-SCROLL BEHAVIOR INITIATED BY UITextField OBJECTS THAT ARE SUBVIEWS OF UIScrollView OBJECTS.
    
    [self setContainerToBeVisible:containerView animated:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    SEL setInputStringSelector = NULL;
    if (textField == self.firstNameTextField) {
        setInputStringSelector = @selector(setFirstNameInputString:);
    } else if (textField == self.lastNameTextField) {
        setInputStringSelector = @selector(setLastNameInputString:);
    } else if (textField == self.emailTextField) {
        setInputStringSelector = @selector(setEmailInputString:); 
    } else if (textField == self.passwordTextField) {
        setInputStringSelector = @selector(setPasswordInputString:);
    } else if (textField == self.confirmPasswordTextField) {
        setInputStringSelector = @selector(setConfirmPasswordInputString:);
    } else {
        NSLog(@"ERROR in AccountPromptViewController - unrecognized textFieldDidEndEditing:%@", textField);
    }
    [self performSelector:setInputStringSelector withObject:textField.text];
}

- (void) setContainerToBeVisible:(UIView *)containerView animated:(BOOL)animated {
    
    void(^adjustmentsBlock)(void) = ^{
        BOOL shouldScroll = NO;
        CGFloat contentOffsetY = 0;
        if (CGRectGetMinY(containerView.frame) - 10 < self.inputContainer.contentOffset.y) {
            shouldScroll = YES;
            contentOffsetY = CGRectGetMinY(containerView.frame) - 10;
        } else {
            CGFloat visibleHeightOfScrollView = self.inputContainer.frame.size.height - (self.inputContainer.contentInset.top + self.inputContainer.contentInset.bottom);
            if (CGRectGetMaxY(containerView.frame) + 10 > self.inputContainer.contentOffset.y + visibleHeightOfScrollView) {
                shouldScroll = YES;
                contentOffsetY = MIN(CGRectGetMaxY(containerView.frame) - containerView.frame.size.height - 10, self.inputContainer.contentSize.height - visibleHeightOfScrollView);
            }
        }
        if (shouldScroll) {
            self.inputContainer.contentOffset = CGPointMake(0, contentOffsetY);
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:adjustmentsBlock];
    } else {
        adjustmentsBlock();
    }
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    UIView * oldActiveInputSectionContainer = [self.inputContainer getFirstResponder].superview.superview; // HARD CODED
    UIView * newActiveInputSectionContainer = textField.superview.superview; // HARD CODED
    if (oldActiveInputSectionContainer != newActiveInputSectionContainer) {
        [self setHighlighted:NO forInputSectionContainer:oldActiveInputSectionContainer animated:NO];
        [self setHighlighted:YES forInputSectionContainer:newActiveInputSectionContainer animated:NO];
    }
    
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

- (void) setHighlighted:(BOOL)shouldHighlight forInputSectionContainer:(UIView *)inputSectionContainer animated:(BOOL)animated {
    CGFloat alpha = shouldHighlight ? 1.0 : 0.0;
    void(^alphaBlock)(void) = ^{
        if (inputSectionContainer == self.namePictureContainer) {
            self.namePictureContainerHighlight.alpha = alpha;
        }
        if (inputSectionContainer == self.emailPasswordContainer) {
            self.emailPasswordContainerHighlight.alpha = alpha;
        }        
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:alphaBlock];
    } else {
        alphaBlock();
    }
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
            [self.emailInvalidAlertView show];
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
            alertTitle = self.emailInvalidAlertView.title;
            alertMessage = self.emailInvalidAlertView.message;
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
        
        [self.webConnector accountCreateWithEmail:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text image:self.pictureButton.imageView.image];
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
        
    } else if (failureCode == AccountCreateEmailNotValid) {
        
        [self.emailInvalidAlertView show];
        [self.emailTextField becomeFirstResponder];
        
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
    if (!shouldShowInputViews) {
        [self resignFirstResponderForAllTextFields];
        [self setHighlighted:NO forInputSectionContainer:self.namePictureContainer animated:animated];
        [self setHighlighted:NO forInputSectionContainer:self.emailPasswordContainer animated:animated];
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
        self.emailPasswordContainerHighlight.frame = CGRectInset(self.emailPasswordContainer.frame, -2, -2);
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
    
    void(^inputContainerContentSizeBlock)(void) = ^{
        self.inputContainer.contentSize = CGSizeMake(self.inputContainer.frame.size.width, /*MAX(*/CGRectGetMaxY(self.emailPasswordContainer.frame)/*, CGRectGetMaxY(self.emailAccountAssuranceLabel.frame))*/ + 10);
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
                             inputContainerContentSizeBlock();
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
        inputContainerContentSizeBlock();
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

- (UIAlertView *)emailInvalidAlertView {
    if (emailInvalidAlertView == nil) {
        emailInvalidAlertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"You must enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return emailInvalidAlertView;
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

- (void) setBottomInset:(CGFloat)bottomInset forScrollView:(UIScrollView *)scrollView {
    UIEdgeInsets insets = scrollView.contentInset;
    insets.bottom = bottomInset;
    scrollView.contentInset = insets;
    UIEdgeInsets scrollInsets = scrollView.scrollIndicatorInsets;
    scrollInsets.bottom = bottomInset;
    scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow:");
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        [self setBottomInset:keyboardSize.height - self.tabBarController.tabBar.bounds.size.height forScrollView:self.inputContainer];
        [self setContainerToBeVisible:[self.inputContainer getFirstResponder].superview.superview animated:NO];
    } completion:^(BOOL finished){}];
    NSLog(@"keyboardWillShow adjustments made, inputContainerContentSize=%@, inputContainerContentInset=%@", NSStringFromCGSize(self.inputContainer.contentSize), NSStringFromUIEdgeInsets(self.inputContainer.contentInset));
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        [self setBottomInset:0 forScrollView:self.inputContainer];
    } completion:^(BOOL finished){ }];
    NSLog(@"keyboardWillHide adjustments made, inputContainerContentSize=%@, inputContainerContentInset=%@", NSStringFromCGSize(self.inputContainer.contentSize), NSStringFromUIEdgeInsets(self.inputContainer.contentInset));
}

@end
