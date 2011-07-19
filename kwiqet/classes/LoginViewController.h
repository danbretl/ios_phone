//
//  LoginViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebActivityView.h"

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIScrollView * scrollViewContainer;
    IBOutlet UIView * inputContainerView;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * loginButton;
    IBOutlet UITextField * usernameField;
    IBOutlet UITextField * passwordField;
    IBOutlet UITextView * messageTextView;
    id<LoginViewControllerDelegate> delegate;
    WebActivityView * webActivityView;
}

@property (assign) id<LoginViewControllerDelegate> delegate;

-(IBAction)loginButtonTouched:(id)sender;
-(IBAction)cancelButtonTouched:(id)sender;
-(IBAction)registerButtonTouched:(id)sender;
-(IBAction)forgotPasswordButtonTouched:(id)sender;
-(void)makeLoginRequest;

@end

@protocol LoginViewControllerDelegate <NSObject>
- (void) loginViewController:(LoginViewController *)loginViewController didFinishWithLogin:(BOOL)didLogin;
@end
