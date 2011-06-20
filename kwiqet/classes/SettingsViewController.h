//
//  SettingsViewController.h
//  Abextra
//
//  Created by John Nichols on 5/4/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
    IBOutlet UIButton *attemptLoginButton;
    IBOutlet UIButton *resetMachineLearning;
    
}
@property(nonatomic,retain) IBOutlet UIButton *attemptLoginButton;
@property(nonatomic,retain) IBOutlet UIButton *resetMachineLearning;

-(IBAction)attemptLoginButtonTouched:(id)sender;
-(IBAction)resetMachineLearningButtonTouched:(id)sender;
-(void)startResetingBehavior;
@end
