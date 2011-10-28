//
//  SetLocationViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 10/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SetLocationViewController.h"
#import "UIFont+Kwiqet.h"

@interface SetLocationViewController()

@property (retain) UIView * headerBar;
@property (retain) UIButton * cancelButton;
@property (retain) UITextField * locationTextField;
//@property (retain) UIButton * currentLocationButton;

@property (retain) UIView * locationsContainer;
@property (retain) UITableView * locationsTableView;
@property (retain) UIImageView * locationsWindowImageView;

@property (retain) WebActivityView * webActivityView;

@property (nonatomic, readonly) BSForwardGeocoder * forwardGeocoder;
@property (retain) NSArray * matchedLocations;

- (IBAction) cancelButtonTouched:(UIButton *)sender;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;

- (void) setWebActivityViewIsVisible:(BOOL)isVisible;

- (void) releaseReconstructableViews;

@end

@implementation SetLocationViewController

@synthesize headerBar=headerBar_;
@synthesize cancelButton=cancelButton_;
@synthesize locationTextField=locationTextField_;
//@synthesize currentLocationButton=currentLocationButton_;

@synthesize locationsContainer=locationsContainer_;
@synthesize locationsTableView=locationsTableView_;
@synthesize locationsWindowImageView=locationsWindowImageView_;

@synthesize webActivityView=webActivityView_;

@synthesize delegate=delegate_;

@synthesize locationManager=locationManager_;
@synthesize forwardGeocoder=forwardGeocoder_;
@synthesize matchedLocations=matchedLocations_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    [self releaseReconstructableViews];
    [locationManager_ release];
    [matchedLocations_ release];
    [forwardGeocoder_ release];
    [super dealloc];
}

- (void) releaseReconstructableViews {
    self.headerBar = nil;
    self.cancelButton = nil;
    self.locationTextField = nil;
//    self.currentLocationButton = nil;
    
    self.locationsContainer = nil;
    self.locationsTableView = nil;
    self.locationsWindowImageView = nil;
    
    self.webActivityView = nil;
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage * windowImageToStretch = [UIImage imageNamed:@"stretchable_faceplate.png"];
    if ([windowImageToStretch respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        windowImageToStretch = [windowImageToStretch resizableImageWithCapInsets:UIEdgeInsetsMake(26, 25, 26, 25)];
    } else {
        windowImageToStretch = [windowImageToStretch stretchableImageWithLeftCapWidth:25 topCapHeight:26];
    }
    self.locationsWindowImageView.image = windowImageToStretch;
    
    self.headerBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
    // Views allocation and settings - Web activity view
    CGFloat webActivityViewSize = 60.0;
    webActivityView_ = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.locationsContainer.frame];
    [self.view addSubview:self.webActivityView];
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Debugging...
//    self.locationsContainer.alpha = 0.0;
//    self.view.backgroundColor = [UIColor clearColor];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseReconstructableViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationTextField becomeFirstResponder];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) cancelButtonTouched:(UIButton *)sender {
    [self.delegate setLocationViewControllerDidCancel:self];
}

- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        CGRect locationsContainerFrame = self.locationsContainer.frame;
        locationsContainerFrame.size.height -= keyboardSize.height;
        self.locationsContainer.frame = locationsContainerFrame;
        [self.webActivityView recenterInFrame:self.locationsContainer.frame];
    } completion:^(BOOL finished){}];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        CGRect locationsContainerFrame = self.locationsContainer.frame;
        locationsContainerFrame.size.height = self.view.bounds.size.height - locationsContainerFrame.origin.y;
        self.locationsContainer.frame = locationsContainerFrame;
        [self.webActivityView recenterInFrame:self.locationsContainer.frame];
    } completion:^(BOOL finished){}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Location is Empty" message:@"You must enter a location in the field above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        [self setWebActivityViewIsVisible:YES];
        [self.forwardGeocoder findLocation:textField.text];
    }
    return NO;
}

- (BSForwardGeocoder *)forwardGeocoder {
    if (forwardGeocoder_ == nil) {
        forwardGeocoder_ = [[BSForwardGeocoder alloc] initWithDelegate:self];
    }
    return forwardGeocoder_;
}

- (void)forwardGeocoderFoundLocation:(BSForwardGeocoder *)geocoder {
    NSMutableArray * filteredArrayTempOnlyUSA = [NSMutableArray arrayWithCapacity:geocoder.results.count]; // We should do a more intelligent filter soon, where we compare the city to the cities that we are currently operating in. We should also do this filter on Google's side, if they let you, so that it's easier for them to geocode. (If we switch over to Apple's iOS5 geocoder, we can provide an acceptable region.)
    for (BSKmlResult * location in geocoder.results) {
//        NSLog(@"location.address=%@, location.countryNameCode=%@, location.countryName=%@, location.subAdministrativeAreaName=%@, location.localityName=%@", location.address, location.countryNameCode, location.countryName, location.subAdministrativeAreaName, location.localityName);
//        NSLog(@"%@", location.addressComponents);
//        for (BSAddressComponent * component in location.addressComponents) {
//            NSLog(@"%@ %@", component.longName, component.shortName);
//            for (NSString * theType in component.types) {
//                NSLog(@"type: %@", theType);
//            }
//        }
        NSArray * countryComponents = [location findAddressComponent:@"country"];
        BSAddressComponent * countryComponent = [countryComponents objectAtIndex:0];
        if ([countryComponent.shortName isEqualToString:@"US"]) {
            [filteredArrayTempOnlyUSA addObject:location];
        }
    }
    self.matchedLocations = filteredArrayTempOnlyUSA;
    [self.locationsTableView reloadData];
    [self setWebActivityViewIsVisible:NO];
}

- (void)forwardGeocoderError:(BSForwardGeocoder *)geocoder errorMessage:(NSString *)errorMessage {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error matching location" message:errorMessage delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self setWebActivityViewIsVisible:NO];
}

- (CLLocationManager *)locationManager {
    if (locationManager_ == nil) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return locationManager_;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"SetLocationViewController locationManager didUpdateToLocation");
    NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
    BOOL isRecent = (abs(howRecent) < 15.0); // Locations from the last 15 seconds are considered to be "recent enough" to be accurate.
    BOOL isAccurate = newLocation.horizontalAccuracy <= 400; // Locations with an accuracy less than or equal to 400 meters are considered to be accurate.
    if (isRecent && isAccurate) {
        // Accept this event
        [self.locationManager stopUpdatingLocation];
        [self.delegate setLocationViewController:self didSelectCurrentLocation:newLocation];
    } else {
        // Skip this event and wait for the next (hopefully more accurate) one...
        NSLog(@"Location with lat/lon (%+.6f, %+.6f) not accepted ::: howRecent=%f, howAccurate=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, howRecent, newLocation.horizontalAccuracy);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"SetLocationViewController locationManager didFailWithError:%@ %d", error, error.code);
    if (error.code == kCLErrorLocationUnknown) {
        // Simply wasn't able to receive location right away. Just sit tight. (Could we be waiting forever though, or would a different error fire eventually? Look into this.)
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error finding location" message:@"Your current location could not be determined. Please check your settings, or enter your location manually." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self.locationManager stopUpdatingLocation];
        [self setWebActivityViewIsVisible:NO];
        [self.locationsTableView deselectRowAtIndexPath:self.locationsTableView.indexPathForSelectedRow animated:NO];
    }
}

- (void)setWebActivityViewIsVisible:(BOOL)isVisible {
    if (isVisible) {
        [self.webActivityView showAnimated:YES];
    } else {
        [self.webActivityView hideAnimated:YES];
    }
    self.cancelButton.userInteractionEnabled = !isVisible;
//    self.currentLocationButton.userInteractionEnabled = !isVisible;
    self.locationsTableView.userInteractionEnabled = !isVisible;
}

///////////////////////
// TABLE VIEW METHODS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = MAX(1, self.matchedLocations.count);
    } else {
        numberOfRows = 1 /* + ... */;
        // ...
        // ...
        // ...
    }
    return numberOfRows;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * LocationCellIdentifier = @"LocationCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LocationCellIdentifier] autorelease];
    }
    cell.textLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont kwiqetFontOfType:LightNormal size:10.0];
    if (indexPath.section == 0) {
        if (self.matchedLocations.count == 0) {
            cell.textLabel.text = @"No locations matched";
            cell.detailTextLabel.text = @"Adjust your search term above";
        } else {
            BSKmlResult * location = [self.matchedLocations objectAtIndex:indexPath.row];
            cell.textLabel.text = location.address;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude];
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"Current Location";
            cell.detailTextLabel.text = nil;
        } else {
            // ...
            // ...
            // ...
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * sectionTitle = nil;
    if (section == 0) {
        sectionTitle = @"Matched locations";
    } else {
        sectionTitle = @"Recent locations";
    }
    return sectionTitle;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * returnIndexPath = indexPath;
    if (indexPath.section == 0 &&
        self.matchedLocations.count == 0) {
        returnIndexPath = nil;
    }
    return returnIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.delegate setLocationViewController:self didSelectLocation:[self.matchedLocations objectAtIndex:indexPath.row]];
    } else {
        if (indexPath.row == 0) {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                NSString * message = nil;
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
                    message = @"Your location services are restricted, so we can't determine your current location. Please enter your location manually.";
                } else {
                    message = @"Your location services are currently disabled. Please enable them in the 'Settings' app, or else enter your location manually.";
                }
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Location is Unavailable" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; // In iOS5, I think we are able to spruce this alert view up a little bit to provide a button that opens the "Settings" app programatically. Find the right catch for "do we have that ability", and implement this conditional behavior.
                [alert show];
                [alert release];
                [self.locationsTableView deselectRowAtIndexPath:self.locationsTableView.indexPathForSelectedRow animated:NO];
            } else {
                [self setWebActivityViewIsVisible:YES];
                [self.locationManager startUpdatingLocation];
            }
        } else {
            // ...
            // ...
            // ...
        }
    }
}
                 
@end
