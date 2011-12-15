//
//  VenueViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueViewController.h"

@interface VenueViewController()
- (IBAction)backButtonTouched:(UIButton *)button;
- (IBAction)logoButtonTouched:(UIButton *)button;
- (IBAction)followButtonTouched:(UIButton *)button;
- (IBAction)phoneNumberButtonTouched:(UIButton *)button;
- (IBAction)mapButtonTouched:(UIButton *)button;
@end

@implementation VenueViewController
@synthesize delegate;
@synthesize navBarContainer=navBarContainer_;
@synthesize backButton=backButton_;
@synthesize logoButton=logoButton_;
@synthesize followButton=followButton_;
@synthesize eventsTableView=eventsTableView_;
@synthesize nameBar=nameBar_;
@synthesize imageView=imageView_;
@synthesize infoContainer=infoContainer_;
@synthesize addressLabel=addressLabel_;
@synthesize cityStateZipLabel=cityStateZipLabel_;
@synthesize phoneNumberButton=phoneNumberButton_;
@synthesize mapButton=mapButton_;
@synthesize descriptionContainer=descriptionContainer_;
@synthesize descriptionLabel=descriptionLabel_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setLogoButton:nil];
    [self setFollowButton:nil];
    [self setNameBar:nil];
    [self setNavBarContainer:nil];
    [self setImageView:nil];
    [self setInfoContainer:nil];
    [self setDescriptionContainer:nil];
    [self setAddressLabel:nil];
    [self setCityStateZipLabel:nil];
    [self setPhoneNumberButton:nil];
    [self setMapButton:nil];
    [self setDescriptionLabel:nil];
    [self setEventsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [backButton_ release];
    [logoButton_ release];
    [followButton_ release];
    [nameBar_ release];
    [navBarContainer_ release];
    [imageView_ release];
    [infoContainer_ release];
    [descriptionContainer_ release];
    [addressLabel_ release];
    [cityStateZipLabel_ release];
    [phoneNumberButton_ release];
    [mapButton_ release];
    [descriptionLabel_ release];
    [eventsTableView_ release];
    [super dealloc];
}

- (void)backButtonTouched:(UIButton *)button {
    [self.delegate venueViewControllerDidFinish:self];
}

- (void)logoButtonTouched:(UIButton *)button {
    [self.delegate venueViewControllerDidRequestStackCollapse:self];
}

- (void)followButtonTouched:(UIButton *)button {
    NSLog(@"followButtonTouched");
}

- (void)phoneNumberButtonTouched:(UIButton *)button {
    NSLog(@"phoneNumberButtonTouched");
}

- (void)mapButtonTouched:(UIButton *)button {
    NSLog(@"mapButtonTouched");
}

@end
