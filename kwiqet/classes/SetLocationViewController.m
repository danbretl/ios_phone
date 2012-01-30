//
//  SetLocationViewController.m
//  Kwiqet
//
//  Created by Dan Bretl on 10/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SetLocationViewController.h"
#import "UIFont+Kwiqet.h"
#import "Analytics.h"

@interface SetLocationViewController()

@property (retain) UIView * headerBar;
@property (retain) UIButton * cancelButton;
@property (retain) UITextField * locationTextField;
//@property (retain) UIButton * currentLocationButton;

@property (retain) UIView * locationsContainer;
@property (retain) UITableView * locationsTableView;
@property (retain) UIImageView * locationsWindowImageView;

@property (nonatomic, readonly) UIAlertView * locationManagerTimerAlertView;
@property (retain) WebActivityView * webActivityView;

@property (retain) NSTimer * locationManagerTimer;
- (void) locationManagerTimerDidFire:(NSTimer *)theTimer;
@property (nonatomic, readonly) BSForwardGeocoder * forwardGeocoder;
@property (retain) MKReverseGeocoder * reverseGeocoder;
@property (retain) NSArray * matchedLocations; // Array of BSKmlResult objects
@property BOOL matchLocationsRequestMade;
@property (retain) NSArray * recentLocations; // Array of UserLocation objects
@property (retain) CLLocation * currentLocation;
//@property (copy) NSString * currentLocationAddress;

@property (nonatomic, readonly) NSDateFormatter * recentLocationsDateFormatter;
@property (nonatomic, readonly) NSDateFormatter * recentLocationsTimeFormatter;

- (IBAction) cancelButtonTouched:(UIButton *)sender;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;

- (void) setWebActivityViewIsVisible:(BOOL)isVisible;

- (void) releaseReconstructableViews;

- (void) didSelectCurrentLocation:(CLLocation *)location withReverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark;
- (void) didSelectNewMatchedLocation:(BSKmlResult *)location;
- (void) didSelectOldRecentLocation:(UserLocation *)location;

@end

@implementation SetLocationViewController

@synthesize headerBar=headerBar_;
@synthesize cancelButton=cancelButton_;
@synthesize locationTextField=locationTextField_;
//@synthesize currentLocationButton=currentLocationButton_;

@synthesize locationsContainer=locationsContainer_;
@synthesize locationsTableView=locationsTableView_;
@synthesize locationsWindowImageView=locationsWindowImageView_;

@synthesize locationManagerTimerAlertView=locationManagerTimerAlertView_;
@synthesize webActivityView=webActivityView_;

@synthesize delegate=delegate_;

@synthesize locationManager=locationManager_;
@synthesize locationManagerTimer=locationManagerTimer_;
@synthesize forwardGeocoder=forwardGeocoder_;
@synthesize reverseGeocoder=reverseGeocoder_;
@synthesize matchedLocations=matchedLocations_;
@synthesize matchLocationsRequestMade=matchLocationsRequestMade_;
@synthesize recentLocations=recentLocations_;
@synthesize currentLocation=currentLocation_;
//@synthesize currentLocationAddress=currentLocationAddress_;

@synthesize recentLocationsDateFormatter=recentLocationsDateFormatter_;
@synthesize recentLocationsTimeFormatter=recentLocationsTimeFormatter_;

@synthesize coreDataModel=coreDataModel_;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.matchLocationsRequestMade = NO;
    }
    return self;
}

- (void) dealloc {
    [self releaseReconstructableViews];
    [locationManager_ release];
    [locationManagerTimer_ release];
    [matchedLocations_ release];
    [recentLocations_ release];
    [forwardGeocoder_ release];
    [reverseGeocoder_ release];
    [currentLocation_ release];
//    [currentLocationAddress_ release];
    [coreDataModel_ release];
    [recentLocationsDateFormatter_ release];
    [recentLocationsTimeFormatter_ release];
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
    
    [locationManagerTimerAlertView_ release];
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
    
    self.recentLocations = [self.coreDataModel getRecentManualUserLocations];
    [self.locationsTableView reloadData];
    
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

- (NSDateFormatter *)recentLocationsDateFormatter {
    if (recentLocationsDateFormatter_ == nil) {
        recentLocationsDateFormatter_ = [[NSDateFormatter alloc] init];
        [self.recentLocationsDateFormatter setDateFormat:@"MMM d, YYYY"];
    }
    return recentLocationsDateFormatter_;
}

- (NSDateFormatter *)recentLocationsTimeFormatter {
    if (recentLocationsTimeFormatter_ == nil) {
        recentLocationsTimeFormatter_ = [[NSDateFormatter alloc] init];
        [self.recentLocationsTimeFormatter setDateFormat:@"h:mm a"];
    }
    return recentLocationsTimeFormatter_;
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
    NSMutableArray * filteredArray = [NSMutableArray arrayWithCapacity:geocoder.results.count]; // We should do a more intelligent filter soon, where we compare the city to the cities that we are currently operating in. We should also do this filter on Google's side, if they let you, so that it's easier for them to geocode. (If we switch over to Apple's iOS5 geocoder, we can provide an acceptable region.)
    for (BSKmlResult * location in geocoder.results) {
        NSArray * countryComponents = [location findAddressComponent:@"country"];
        BSAddressComponent * countryComponent = [countryComponents objectAtIndex:0];
        // Filter out...
        // - locations outside of USA
        // - locations that are of type "route", "country", "administrative_area_level_1", "administrative_area_level_2", administrative_area_level_3", "natural_feature", "colloquial_area", "park"
        // - ignore type "political"
        NSMutableArray * locationTypes = [location.types mutableCopy];
        [locationTypes removeObject:@"route"];
        [locationTypes removeObject:@"country"];
        [locationTypes removeObject:@"administrative_area_level_1"];
        [locationTypes removeObject:@"administrative_area_level_2"];
        [locationTypes removeObject:@"administrative_area_level_3"];
        [locationTypes removeObject:@"natural_feature"];
        [locationTypes removeObject:@"colloquial_area"];
        [locationTypes removeObject:@"park"];
        [locationTypes removeObject:@"political"];
        BOOL shouldAccept = (locationTypes.count > 0 &&
                             [countryComponent.shortName isEqualToString:@"US"]);
        [locationTypes release];
        if (shouldAccept) {
            [filteredArray addObject:location];
            NSLog(@"ACCEPTED matched location:");
            NSLog(@"  location.address=%@", location.address);
            NSLog(@"  type:");
            for (NSString * type in location.types) {
                NSLog(@"    %@", type);
            }
            NSLog(@"  address components:");
            for (BSAddressComponent * component in location.addressComponents) {
                NSLog(@"    %@ (%@)", component.longName, component.shortName);
                for (NSString * theType in component.types) {
                    NSLog(@"      type:");
                    NSLog(@"        %@", theType);
                }
            }
        } else {
            NSLog(@"FILTERED OUT matched location:");
            NSLog(@"  location.address=%@", location.address);
            NSLog(@"  type:");
            for (NSString * type in location.types) {
                NSLog(@"    %@", type);
            }
            NSLog(@"  address components:");
            for (BSAddressComponent * component in location.addressComponents) {
                NSLog(@"    %@ (%@)", component.longName, component.shortName);
                for (NSString * theType in component.types) {
                    NSLog(@"      type:");
                    NSLog(@"        %@", theType);
                }
            }
        }
    }
    self.matchedLocations = filteredArray;
    self.matchLocationsRequestMade = YES;
    [self.locationsTableView reloadData];
    [self.locationsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self setWebActivityViewIsVisible:NO];
}

- (void)forwardGeocoderError:(BSForwardGeocoder *)geocoder errorMessage:(NSString *)errorMessage {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error matching location" message:errorMessage delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self setWebActivityViewIsVisible:NO];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    NSLog(@"Reverse geocoder success");
    [self didSelectCurrentLocation:self.currentLocation withReverseGeocodedInfo:placemark];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    NSLog(@"Reverse geocoder error");
    [self didSelectCurrentLocation:self.currentLocation withReverseGeocodedInfo:nil];
}

- (CLLocationManager *)locationManager {
    if (locationManager_ == nil) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.delegate = self;
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return locationManager_;
}

- (UIAlertView *)locationManagerTimerAlertView {
    if (locationManagerTimerAlertView_ == nil) {
        locationManagerTimerAlertView_ = [[UIAlertView alloc] initWithTitle:@"Error finding location" message:@"We are having trouble finding your current location. Would you like to keep trying, or else enter your location manually?" delegate:self cancelButtonTitle:@"Manual" otherButtonTitles:@"Keep Trying", nil];
    }
    return locationManagerTimerAlertView_;
}

- (void)locationManagerTimerDidFire:(NSTimer *)theTimer {
    [self.locationManager stopUpdatingLocation];
    self.currentLocation = self.locationManager.location;
//    self.currentLocationAddress = nil;
    BOOL showAlertView = self.currentLocation == nil;
    if (self.currentLocation != nil) {
        NSTimeInterval howRecent = [self.currentLocation.timestamp timeIntervalSinceNow];
        BOOL isRecent = (abs(howRecent) < 30.0); // Locations from the last 15 seconds are considered to be "recent enough" to be accurate.
        BOOL isModeratelyAccurate = self.currentLocation.horizontalAccuracy <= 250; // Locations with an accuracy less than or equal to 250 meters are considered to be accurate. (We have lowered our standards since the timer has fired.)
        BOOL isAcceptable = (isRecent && isModeratelyAccurate);
        showAlertView = !isAcceptable;
        if (isAcceptable) {
            NSLog(@"SetLocationViewController locationManager took too long to determine current location. Timer fired, current location with lat/lon (%+.6f, %+.6f) accepted (howRecent=%f, howAccurate=%f) is good enough.", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, howRecent, self.currentLocation.horizontalAccuracy);
            self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate] autorelease];
            self.reverseGeocoder.delegate = self;
            [self.reverseGeocoder start];        
        } else {
            NSLog(@"SetLocationViewController locationManager took too long to determine current location. Timer fired, current location with lat/lon (%+.6f, %+.6f) not accepted (howRecent=%f, howAccurate=%f) - still not good enough. Providing user with some options on how to proceed.", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, howRecent, self.currentLocation.horizontalAccuracy);
        }
    }
    if (showAlertView) {
        if (self.currentLocation == nil) {
            NSLog(@"SetLocationViewController locationManager took too long to determine current location, and we don't have a fallback location to use. Providing the user with some options on how to proceed.");
        }
        [self.locationManagerTimerAlertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.locationManagerTimerAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // Enter manual location
            [self setWebActivityViewIsVisible:NO];
            [self.locationsTableView deselectRowAtIndexPath:self.locationsTableView.indexPathForSelectedRow animated:NO];
        } else {
            // Keep trying to determine current location
            [self setWebActivityViewIsVisible:YES];
            self.locationManagerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationManagerTimerDidFire:) userInfo:nil repeats:NO];
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"SetLocationViewController locationManager didChangeAuthorizationStatus=%d whichIsAuthorized?=%d", status, status == kCLAuthorizationStatusAuthorized);
    if (manager == self.locationManager &&
        status == kCLAuthorizationStatusAuthorized) {
        if (!(self.locationManagerTimer && [self.locationManagerTimer isValid])) {
            self.locationManagerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationManagerTimerDidFire:) userInfo:nil repeats:NO];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"SetLocationViewController locationManager didUpdateToLocation");
    NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
    BOOL isRecent = (abs(howRecent) < 30.0); // Locations from the last 15 seconds are considered to be "recent enough" to be accurate.
    BOOL isAccurate = newLocation.horizontalAccuracy <= 75; // Locations with an accuracy less than or equal to 50 meters are considered to be accurate.
    self.currentLocation = newLocation;
    if (isRecent && isAccurate) {
        NSLog(@"Location with lat/lon (%+.6f, %+.6f) accepted ::: howRecent=%f, howAccurate=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, howRecent, newLocation.horizontalAccuracy);
        // Accept this event
        [self.locationManager stopUpdatingLocation];
        // Turn off the timer
        [self.locationManagerTimer invalidate];
        self.locationManagerTimer = nil;
        // Reverse geocode the location
//        self.currentLocationAddress = nil;
        self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:self.currentLocation.coordinate] autorelease];
        self.reverseGeocoder.delegate = self;
        [self.reverseGeocoder start];
    } else {
        // Skip this event (though we're holding onto the location anyway) and wait for the next (hopefully more accurate) one...
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
        numberOfRows = 1 + self.recentLocations.count;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL doubleRow = (indexPath.section == 0 && self.matchedLocations.count == 0) || (indexPath.section == 1 && indexPath.row != 0);
    CGFloat rowHeight = doubleRow ? 42.0 : 32.0;
    return rowHeight;    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.locationsTableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeaderView = [[UIView alloc] init];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:53.0/255.0 alpha:0.8];
    UILabel * sectionHeaderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, sectionHeaderView.frame.size.width, sectionHeaderView.frame.size.height)]; // Something weird going on with positioning / autoresizing...
    sectionHeaderTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sectionHeaderTitleLabel.textAlignment = UITextAlignmentRight;
    sectionHeaderTitleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:14.0];
    sectionHeaderTitleLabel.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    sectionHeaderTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    sectionHeaderTitleLabel.backgroundColor = [UIColor clearColor];
    [sectionHeaderView addSubview:sectionHeaderTitleLabel];
//    NSLog(@"%@ and %@", NSStringFromCGRect(sectionHeaderView.frame), NSStringFromCGRect(sectionHeaderTitleLabel.frame));
    [sectionHeaderTitleLabel release];
    return [sectionHeaderView autorelease];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * LocationCellIdentifier = @"LocationCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LocationCellIdentifier] autorelease];
        cell.textLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14.0];
        cell.detailTextLabel.font = [UIFont kwiqetFontOfType:LightNormal size:10.0];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = (indexPath.section == 0 && self.matchedLocations.count == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    if (indexPath.section == 0) {
        if (self.matchedLocations.count == 0) {
            if (!self.matchLocationsRequestMade) {
                cell.textLabel.text = @"Enter a location above";
                cell.detailTextLabel.text = @"Enter a search term, or select a recent location below";
            } else {
                cell.textLabel.text = @"No locations matched";
                cell.detailTextLabel.text = @"Adjust your search term, or select a recent location below";
            }
        } else {
            BSKmlResult * location = [self.matchedLocations objectAtIndex:indexPath.row];
            cell.textLabel.text = location.address;
            cell.detailTextLabel.text = nil;
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude]; // Debugging
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.text = @"Current Location";
            cell.detailTextLabel.text = nil;
        } else {
            UserLocation * recentLocation = [self.recentLocations objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = recentLocation.addressFormatted;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Last used %@ at %@", [self.recentLocationsDateFormatter stringFromDate:recentLocation.datetimeLastUsed], [self.recentLocationsTimeFormatter stringFromDate:recentLocation.datetimeLastUsed]];
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", recentLocation.latitude.doubleValue, recentLocation.longitude.doubleValue]; // Debugging
        }
    }
    return cell;
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
        [self didSelectNewMatchedLocation:[self.matchedLocations objectAtIndex:indexPath.row]];
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
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
                    self.locationManagerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationManagerTimerDidFire:) userInfo:nil repeats:NO];
                }
                [self.locationManager startUpdatingLocation];
            }
        } else {
            [self didSelectOldRecentLocation:[self.recentLocations objectAtIndex:indexPath.row - 1]];
        }
    }
}

- (void) didSelectCurrentLocation:(CLLocation *)location withReverseGeocodedInfo:(MKPlacemark *)reverseGeocodedPlacemark {
    
    NSMutableString * addressFormatted = [NSMutableString string];
    BOOL first = YES;
    for (NSString * addressLine in [reverseGeocodedPlacemark.addressDictionary valueForKey:@"FormattedAddressLines"]) {
        [addressFormatted appendFormat:@"%@%@", first ? @"" : @", ", addressLine];
        first = NO;
    }
    
    UserLocation * userLocationObject = [self.coreDataModel addUserLocationThatIsManual:NO withLatitude:location.coordinate.latitude longitude:location.coordinate.longitude accuracy:[NSNumber numberWithDouble:location.horizontalAccuracy] addressFormatted:addressFormatted typeGoogle:@"point"];
    [self.coreDataModel coreDataSave];
    [self.delegate setLocationViewController:self didSelectUserLocation:userLocationObject];
    
}

- (void) didSelectNewMatchedLocation:(BSKmlResult *)location {
    
    // For now, we are going to hope/assume that we can always get down to just one Google geo type. Towards this end, we are going to get rid of the following types: "political", ...
    NSMutableArray * typesGoogleFiltered = [location.types mutableCopy];
    [typesGoogleFiltered removeObject:@"political"];
    NSString * typeGoogle = [typesGoogleFiltered objectAtIndex:0];
    if (typesGoogleFiltered.count > 1) {
        NSLog(@"ERROR THAT WE NEED TO ADDRESS in SetLocationViewController, removed Google geo type 'political' but still this manual location has multiple geo types to pick from. We arbitrarily picked the first type %@, but there were %d others.", typeGoogle, typesGoogleFiltered.count - 1);
        [Analytics localyticsSendWarning:@"Google Geocode Multiple Location Types" sourceLocation:@"SetLocationViewController.m" attributes:[NSDictionary dictionaryWithObjectsAndKeys:location.address, @"location address", nil]];
    }
    [typesGoogleFiltered release];
    // Need to translate from Google geo type to Kwiqet geo type...
    
    UserLocation * userLocationObject = [self.coreDataModel addUserLocationThatIsManual:YES withLatitude:location.latitude longitude:location.longitude accuracy:nil addressFormatted:location.address typeGoogle:typeGoogle];
    [self.coreDataModel coreDataSave];
    [self.delegate setLocationViewController:self didSelectUserLocation:userLocationObject];
    
}

- (void) didSelectOldRecentLocation:(UserLocation *)location {
    
    [self.coreDataModel updateUserLocationLastUseDate:location];
    [self.coreDataModel coreDataSave];
    [self.delegate setLocationViewController:self didSelectUserLocation:location];
    
}
                 
@end
