//
//  AccountInputView.h
//  kwiqet
//
//  Created by Dan Bretl on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountInputView : UIView {
    
    UILabel * headerBlurbLabel;
    UILabel * footerBlurbLabel;
    
    UIView * namePictureContainer;
    UIImageView * pictureImageView;
    UILabel * firstNameLabel;
    UILabel * lastNameLabel;
    
    UIView * emailPasswordContainer;
    UITextField * emailTextField;
    UITextField * passwordTextField;
    UITextField * confirmPasswordTextField;
    
}

@end
