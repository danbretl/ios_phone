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

@interface AccountPromptViewController : UIViewController <UITextFieldDelegate, WebConnectorDelegate, UIAlertViewDelegate> {
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * logoButton;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * doneButton;
    IBOutlet UIImageView * titleImageView;

    IBOutlet UIView * mainViewsContainer;
    
    IBOutlet UIView *accountOptionsContainer;
    IBOutlet UILabel * blurbLabel;
    IBOutlet UILabel * loginCreateLabel;
    IBOutlet UIButton * emailButton;
    IBOutlet UIButton * facebookButton;
    IBOutlet UIButton * twitterButton;
    
    IBOutlet UIView * inputContainer;
    IBOutlet UILabel * accountCreationPromptLabel;
    IBOutlet UIView * namePictureContainer;
    IBOutlet UIView * pictureContainer;
    IBOutlet UIButton * pictureButton;
    IBOutlet UIImageView * pictureImageView;
    IBOutlet UITextField * firstNameTextField;
    IBOutlet UITextField * lastNameTextField;
    CGFloat emailPasswordOriginYMainStage;
    CGFloat emailPasswordOriginYPartOfForm;
    IBOutlet UIView * emailPasswordContainer;
    IBOutlet UITextField * emailTextField;
    IBOutlet UITextField * passwordTextField;
    IBOutlet UITextField *confirmPasswordTextField;
    IBOutlet UILabel * emailAccountAssuranceLabel;
    
    BOOL accountCreationViewsVisible;
    BOOL confirmPasswordVisible;
    
    WebActivityView * webActivityView;
    UIAlertView * passwordIncorrectAlertView;
    UIAlertView * forgotPasswordConnectionErrorAlertView;
    
    WebConnector * webConnector;
    
}

@end
