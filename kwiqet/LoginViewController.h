//
//  LoginViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIScrollView * scrollViewContainer;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    UILabel * messageLabel;
    UILabel * infoLabel;
}

@property (nonatomic,retain) IBOutlet UITextField *usernameField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;

-(IBAction)loginButtonTouched:(id)sender;
-(IBAction)cancelButtonTouched:(id)sender;
-(IBAction)registerButtonTouched:(id)sender;
-(IBAction)forgotPasswordButtonTouched:(id)sender;
-(void)makeLoginRequest;

@end
