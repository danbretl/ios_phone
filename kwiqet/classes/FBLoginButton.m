/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "FBLoginButton.h"
#import "Facebook.h"

@interface FBLoginButton()
@property (nonatomic, readonly) UIImage * buttonImageNormal;
@property (nonatomic, readonly) UIImage * buttonImageHighlighted;
- (void) updateImage;
@end

@implementation FBLoginButton
@synthesize isLoggedIn=_isLoggedIn;

- (UIImage *) buttonImageNormal {
    if (self.isLoggedIn) {
        //return [UIImage imageNamed:@"FBConnect.bundle/images/LogoutNormal.png"];
          return [UIImage imageNamed:@"fbConnected.png"];
    } else {
        //return [UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"];
          return [UIImage imageNamed:@"fbConnect.png"];
    }
}

- (UIImage *) buttonImageHighlighted {
    if (self.isLoggedIn) {
        //return [UIImage imageNamed:@"FBConnect.bundle/images/LogoutPressed.png"];
    } else {
        //return [UIImage imageNamed:@"FBConnect.bundle/images/LoginPressed.png"];
    }
    return nil;
}

- (void)updateImage {
    self.imageView.image = self.buttonImageNormal; // Not sure why we do this... Maybe old versions of iOS?
    [self setImage:self.buttonImageNormal forState:UIControlStateNormal];
    //[self setImage:self.buttonImageHighlighted forState:UIControlStateSelected];
    CGRect frame = self.frame;
    frame.size = self.buttonImageNormal.size;
    self.frame = frame;
}

- (void) setIsLoggedIn:(BOOL)isLoggedIn {
    _isLoggedIn = isLoggedIn;
    [self updateImage];
}

@end 
