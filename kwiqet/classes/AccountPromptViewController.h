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

@protocol AccountPromptViewControllerDelegate;

@interface AccountPromptViewController : UIViewController <UITextFieldDelegate, WebConnectorDelegate, UIAlertViewDelegate> {
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * logoButton;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * doneButton;
    IBOutlet UIImageView * titleImageView;

    IBOutlet UIView * mainViewsContainer;
    
    IBOutlet UIView *accountOptionsContainer;
    IBOutlet UILabel * blurbLabel;
    IBOutlet UIButton * emailButton;
    IBOutlet UIButton * facebookButton;
    IBOutlet UIButton * twitterButton;
    
    IBOutlet UIScrollView * inputContainer;
    IBOutlet UILabel * accountCreationPromptLabel;
    IBOutlet UIView * namePictureContainer;
    IBOutlet UIImageView * namePictureContainerImageView;
    IBOutlet UIButton * pictureButton;
    IBOutlet UITextField * firstNameTextField;
    IBOutlet UITextField * lastNameTextField;
    CGFloat emailPasswordOriginYMainStage;
    CGFloat emailPasswordOriginYPartOfForm;
    IBOutlet UIView * emailPasswordContainer;
    IBOutlet UIImageView * emailPasswordContainerImageView;
    IBOutlet UITextField * emailTextField;
    IBOutlet UITextField * passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    IBOutlet UILabel * emailAccountAssuranceLabel;
    
    UISwipeGestureRecognizer * swipeDownGestureRecognizer;
    
    BOOL initialPromptScreenVisible;
    BOOL accountCreationViewsVisible;
    BOOL confirmPasswordVisible;
    BOOL waitingForFacebookAuthentication;
    BOOL waitingForFacebookInfo;
    
    WebActivityView * webActivityView;
    UIAlertView * passwordIncorrectAlertView;
    UIAlertView * forgotPasswordConnectionErrorAlertView;
    UIAlertView * anotherAccountWithEmailExistsAlertView;
    
    WebConnector * webConnector;
    FacebookManager * facebookManager;
    
    id<AccountPromptViewControllerDelegate> delegate;
    
}

@property (assign) id<AccountPromptViewControllerDelegate> delegate;
@property (nonatomic, readonly) FacebookManager * facebookManager;

@end

@protocol AccountPromptViewControllerDelegate <NSObject>

- (void) accountPromptViewController:(AccountPromptViewController *)accountPromptViewController didFinishWithConnection:(BOOL)finishedWithConnection;

@end