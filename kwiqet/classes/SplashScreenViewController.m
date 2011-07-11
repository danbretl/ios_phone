//
//  SplashScreenViewController.m
//  Abextra
//
//  Created by Dan Bretl on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplashScreenViewController.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const SPLASH_SCREEN_EXPLOSION_SCALE = 120.0/320.0;
CGFloat const SPLASH_SCREEN_EXPLOSION_ANIMATION_DURATION = 0.5;
CGFloat const SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_ALPHA = 0.9;
CGFloat const SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_SHOW_ANIMATION_DURATION = 0.25;

@interface SplashScreenViewController()
@property (retain) UIImageView * imageView;
@property (retain) UITextView * connectionErrorTextView;
@end

@implementation SplashScreenViewController

@synthesize imageView, connectionErrorTextView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.connectionErrorTextView.layer.cornerRadius = 10.0;
    self.connectionErrorTextView.layer.masksToBounds = YES;
    [self showConnectionErrorTextView:NO animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Custom methods

- (void)explodeAndFadeViewAnimated {
//    NSLog(@"SplashScreenViewController explodeAndFadeViewAnimated");
    CGRect imageViewFrame = self.imageView.frame;
    CGFloat imageViewFrameExplodedWidth = floorf(imageViewFrame.size.width * SPLASH_SCREEN_EXPLOSION_SCALE);
    CGFloat imageViewFrameExplodedHeight = floorf(imageViewFrame.size.height * SPLASH_SCREEN_EXPLOSION_SCALE);
    imageViewFrame.origin.x -= imageViewFrameExplodedWidth / 2.0;
    imageViewFrame.origin.y -= imageViewFrameExplodedHeight / 2.0;
    imageViewFrame.size.width += imageViewFrameExplodedWidth;
    imageViewFrame.size.height += imageViewFrameExplodedHeight;
    [UIView animateWithDuration:SPLASH_SCREEN_EXPLOSION_ANIMATION_DURATION 
                     animations:^{
                         self.imageView.frame = imageViewFrame;
                         self.imageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self.delegate splashScreenViewControllerExplodeAndFadeViewAnimationCompleted:self];
                     }];
}

- (void)showConnectionErrorTextView:(BOOL)show animated:(BOOL)animated {
    void (^connectionErrorTextViewAlphaChangeBlock)(void) = ^{
        self.connectionErrorTextView.alpha = show ? SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_ALPHA : 0.0;
    };
    if (animated) {
        [UIView animateWithDuration:SPLASH_SCREEN_ERROR_CONNECTION_MESSAGE_SHOW_ANIMATION_DURATION animations:connectionErrorTextViewAlphaChangeBlock];
    } else {
        connectionErrorTextViewAlphaChangeBlock();
    }
}

- (BOOL)connectionErrorTextViewVisible {
    return (self.connectionErrorTextView.alpha != 0.0);
}

@end
