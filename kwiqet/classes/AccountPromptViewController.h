//
//  AccountPromptViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebActivityView.h"
#import "WebConnector.h"
#import "FacebookManager.h"
#import "UIButtonWithDynamicBackgroundColor.h"

@protocol AccountPromptViewControllerDelegate;

@interface AccountPromptViewController : UIViewController <UITextFieldDelegate, WebConnectorDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    
    BOOL initialPromptScreenVisible;
    BOOL accountCreationViewsVisible;
    BOOL confirmPasswordVisible;
    BOOL waitingForFacebookAuthentication;
    BOOL waitingForFacebookInfo;
    
    NSString * firstNameInputString;
    NSString * lastNameInputString;
    NSString * emailInputString;
    NSString * passwordInputString;
    NSString * confirmPasswordInputString;
    UIImage * pictureInputImage;
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * logoButton;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * doneButton;
    IBOutlet UIImageView * titleImageView;

    IBOutlet UIView * mainViewsContainer;
    
    IBOutlet UIView * accountOptionsContainer;
    IBOutlet UILabel * blurbLabel;
    IBOutlet UIButton * emailButton;
    IBOutlet UIButton * facebookButton;
    IBOutlet UIButton * twitterButton;
    
    IBOutlet UIScrollView * inputContainer;
    IBOutlet UILabel * accountCreationPromptLabel;
    IBOutlet UIView * namePictureContainer;
    UIView * namePictureContainerHighlight;
    IBOutlet UIImageView * namePictureContainerImageView;
    IBOutlet UIButtonWithDynamicBackgroundColor * pictureButton;
    IBOutlet UITextField * firstNameTextField;
    IBOutlet UITextField * lastNameTextField;
    CGFloat emailPasswordOriginYMainStage;
    CGFloat emailPasswordOriginYPartOfForm;
    IBOutlet UIView * emailPasswordContainer;
    UIView * emailPasswordContainerHighlight;
    IBOutlet UIImageView * emailPasswordContainerImageView;
    IBOutlet UITextField * emailTextField;
    IBOutlet UITextField * passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    IBOutlet UILabel * emailAccountAssuranceLabel;
    
    UISwipeGestureRecognizer * swipeDownGestureRecognizer;
        
    WebActivityView * webActivityView;
    UIAlertView * passwordIncorrectAlertView;
    UIAlertView * emailInvalidAlertView;
    UIAlertView * forgotPasswordConnectionErrorAlertView;
    UIAlertView * anotherAccountWithEmailExistsAlertView;
    UIActionSheet * imagePickerActionSheet;
    
    WebConnector * webConnector;
    FacebookManager * facebookManager;
    
    UIImagePickerController * imagePickerController_;
    
    id<AccountPromptViewControllerDelegate> delegate;
    
}

@property (assign) id<AccountPromptViewControllerDelegate> delegate;
@property (nonatomic, readonly) FacebookManager * facebookManager;

@end

@protocol AccountPromptViewControllerDelegate <NSObject>

- (void) accountPromptViewController:(AccountPromptViewController *)accountPromptViewController didFinishWithConnection:(BOOL)finishedWithConnection;

@end