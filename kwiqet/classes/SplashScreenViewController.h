//
//  SplashScreenViewController.h
//  Abextra
//
//  Created by Dan Bretl on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SplashScreenViewControllerDelegate;

extern CGFloat const SPLASH_SCREEN_EXPLOSION_SCALE;
extern CGFloat const SPLASH_SCREEN_EXPLOSION_ANIMATION_DURATION;
extern CGFloat const SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_ALPHA;
extern CGFloat const SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_SHOW_ANIMATION_DURATION;

@interface SplashScreenViewController : UIViewController {
    IBOutlet UIImageView * imageView;
    id<SplashScreenViewControllerDelegate> delegate;
    IBOutlet UITextView * connectionErrorTextView;
    IBOutlet UIActivityIndicatorView * spinner;
}

@property (assign) id<SplashScreenViewControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL connectionErrorTextViewVisible;

- (void) explodeAndFadeViewAnimated;
- (void) showConnectionErrorTextView:(BOOL)show animated:(BOOL)animated;

@end

@protocol SplashScreenViewControllerDelegate <NSObject>

- (void) splashScreenViewControllerExplodeAndFadeViewAnimationCompleted:(SplashScreenViewController*)splashScreenViewController;

@end