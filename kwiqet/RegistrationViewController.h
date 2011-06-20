//
//  RegistrationViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegistrationViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *confirmPasswordField;
}
@property(nonatomic,retain) IBOutlet UITextField *usernameField;
@property(nonatomic,retain) IBOutlet UITextField *passwordField;
@property(nonatomic,retain) IBOutlet UITextField *confirmPasswordField;

-(IBAction)doneButtonTouched:(id)sender;
-(IBAction)cancelButtonTouched:(id)sender;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
@end
