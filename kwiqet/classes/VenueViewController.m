//
//  VenueViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueViewController.h"
#import "URLBuilder.h"
#import "UIFont+Kwiqet.h"
#import "EventTableViewCell.h"
#import "EventLocationAnnotation.h"

@interface VenueViewController()

@property (readonly, nonatomic) WebDataTranslator * webDataTranslator;

@property (retain, nonatomic) IBOutlet UIView * navBarContainer;
@property (retain, nonatomic) IBOutlet UIButton * backButton;
@property (retain, nonatomic) IBOutlet UIButton * logoButton;
@property (retain, nonatomic) IBOutlet UIButton * followButton;

@property (retain, nonatomic) IBOutlet UIView * mainContainer;
@property (retain, nonatomic) IBOutlet ElasticUILabel * nameBar;
@property (retain, nonatomic) IBOutlet UIImageView * imageView;
@property (retain, nonatomic) IBOutlet UIView * infoContainer;
@property (retain, nonatomic) IBOutlet UILabel * addressLabel;
@property (retain, nonatomic) IBOutlet UILabel * cityStateZipLabel;
@property (retain, nonatomic) IBOutlet UIButton * phoneNumberButton;
@property (retain, nonatomic) IBOutlet UIButton * mapButton;
@property (retain, nonatomic) IBOutlet MKMapView * mapView;
@property (retain, nonatomic) IBOutlet UIView * descriptionContainer;
@property (retain, nonatomic) IBOutlet UILabel * descriptionLabel;

@property (retain, nonatomic) IBOutlet UIView * eventsHeaderContainer;
@property (retain, nonatomic) IBOutlet UILabel * eventsHeaderLabel;
@property (retain, nonatomic) IBOutlet UITableView * eventsTableView;

@property (retain) MapViewController * mapViewController;

- (IBAction)backButtonTouched:(UIButton *)button;
- (IBAction)logoButtonTouched:(UIButton *)button;
- (IBAction)followButtonTouched:(UIButton *)button;
- (IBAction)phoneNumberButtonTouched:(UIButton *)button;
- (IBAction)mapButtonTouched:(UIButton *)button;

- (void) updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) updateMapViewToCenterOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void) updateImageFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated;
- (void) setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated;
- (void) updateViewsVerticalPositionsAll;
- (void) updateViewsVerticalPositionsForScroll;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation VenueViewController
@synthesize mainContainer;
@synthesize mapView=mapView_;
@synthesize eventsHeaderContainer=eventsHeaderContainer_;
@synthesize eventsHeaderLabel=eventsHeaderLabel_;
@synthesize delegate;
@synthesize venue=venue_;
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
@synthesize mapViewController=mapViewController_;

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

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Main view
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dark_gray.jpg"]];
        
    // Nav bar views
    self.navBarContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
    // Image view
//    [self setImageViewIsVisible:NO animated:NO]; // STILL WORKING ON BUGS
    imageViewNormalHeight = self.imageView.frame.size.height;
    
    // Venue info views
    self.infoContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_venue_location_info.png"]];
    self.addressLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    // Table header views
    self.eventsHeaderContainer.backgroundColor = [UIColor colorWithWhite:53.0/255.0 alpha:0.8];
    self.eventsHeaderLabel.backgroundColor = [UIColor clearColor];
    self.eventsHeaderLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:16.0];
    self.eventsHeaderLabel.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.eventsTableView.backgroundColor = [UIColor clearColor];
    self.eventsTableView.tableHeaderView = self.mainContainer;
    
    // Update views from data
    if (self.venue) {
        [self updateInfoViewsFromVenue:self.venue animated:NO];
        if (self.venue.coordinateAvailable) {
            [self updateMapViewToCenterOnCoordinate:self.venue.coordinate animated:NO];
        }
        [self updateImageFromVenue:self.venue animated:NO];
    }
    
    BOOL debuggingFrames = NO;
    if (debuggingFrames) {
        self.addressLabel.backgroundColor = [UIColor redColor];
        self.cityStateZipLabel.backgroundColor = [UIColor orangeColor];
        self.phoneNumberButton.backgroundColor = [UIColor yellowColor];
    }
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
    [self setMainContainer:nil];
    [self setMapView:nil];
    [self setEventsHeaderContainer:nil];
    [self setEventsHeaderLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [venue_ release];
    [webDataTranslator_ release];
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
    [mainContainer release];
    [mapView_ release];
    [mapViewController_ release];
    [eventsHeaderContainer_ release];
    [eventsHeaderLabel_ release];
    [super dealloc];
}

- (void)backButtonTouched:(UIButton *)button {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
}

- (void)logoButtonTouched:(UIButton *)button {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:YES];
}

- (void)followButtonTouched:(UIButton *)button {
    NSLog(@"followButtonTouched");
}

- (void)phoneNumberButtonTouched:(UIButton *)button {
    NSLog(@"phoneNumberButtonTouched");
}

- (void)mapButtonTouched:(UIButton *)button {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    self.mapViewController.locationLatitude = self.venue.latitude;
    self.mapViewController.locationLongitude = self.venue.longitude;
    self.mapViewController.locationName = self.venue.title;
    self.mapViewController.locationAddress = self.venue.address;
    [self presentModalViewController:self.mapViewController animated:YES];
}

- (void)mapViewControllerDidPushBackButton:(MapViewController *)mapViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.mapViewController = nil;
}

- (void) setVenue:(Place *)venue {
    if (venue_ != venue) {
        [venue_ release];
        venue_ = [venue retain];
        if (self.view.window) {
            [self updateInfoViewsFromVenue:self.venue animated:YES];
            if (self.venue.coordinateAvailable) {
                [self updateMapViewToCenterOnCoordinate:self.venue.coordinate animated:YES];
            }
            [self updateImageFromVenue:self.venue animated:YES];
        }
    }
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator_ == nil) {
        webDataTranslator_ = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator_;
}

- (void)updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated {
    
    void(^infoViewsWidthsBlock)(NSString *, NSString *, NSString *) = ^(NSString * addressText, NSString * cityStateZipText, NSString * phoneText){
        // Set up
        CGFloat mapViewMaxAllowableOriginX = 207; // HARD-CODED VALUE
        CGFloat mapViewPaddingLeft = 10; // HARD-CODED MAP VIEW PADDING VALUE
        CGFloat mapViewPaddingRight = 5; // HARD-CODED MAP VIEW PADDING VALUE
        CGFloat labelsRightmostAllowableX = mapViewMaxAllowableOriginX - mapViewPaddingLeft;
        CGFloat phoneTouchPaddingRight = mapViewPaddingLeft;
        // Calculating text sizes
        CGSize addressTextSize = [addressText sizeWithFont:self.addressLabel.font];
        CGSize cityStateZipTextSize = [addressText sizeWithFont:self.cityStateZipLabel.font];
        CGSize phoneTextSize = [phoneText sizeWithFont:self.phoneNumberButton.titleLabel.font];
        // Address lines
        CGRect addressLabelFrame = self.addressLabel.frame;
        CGRect cityStateZipLabelFrame = self.cityStateZipLabel.frame;
        CGFloat addressLabelWidth = MIN(addressTextSize.width, labelsRightmostAllowableX - addressLabelFrame.origin.x);
        CGFloat cityStateZipLabelWidth = MIN(cityStateZipTextSize.width, labelsRightmostAllowableX - cityStateZipLabelFrame.origin.x);
        CGFloat maxAddressLinesWidth = MAX(addressLabelWidth, cityStateZipLabelWidth);
        addressLabelWidth = maxAddressLinesWidth;
        cityStateZipLabelWidth = maxAddressLinesWidth;
        addressLabelFrame.size.width = addressLabelWidth;
        cityStateZipLabelFrame.size.width = cityStateZipLabelWidth;
        self.addressLabel.frame = addressLabelFrame;
        self.cityStateZipLabel.frame = cityStateZipLabelFrame;
        // Phone
        CGRect phoneNumberButtonFrame = self.phoneNumberButton.frame;
        phoneNumberButtonFrame.size.width = MIN(phoneTextSize.width + self.phoneNumberButton.contentEdgeInsets.left, labelsRightmostAllowableX - phoneNumberButtonFrame.origin.x) + phoneTouchPaddingRight;
        self.phoneNumberButton.frame = phoneNumberButtonFrame;
        // Map view
        CGRect mapViewFrame = self.mapView.frame;
        mapViewFrame.origin.x = MAX(MAX(CGRectGetMaxX(addressLabelFrame), CGRectGetMaxX(cityStateZipLabelFrame)), CGRectGetMaxX(phoneNumberButtonFrame) - phoneTouchPaddingRight) + mapViewPaddingLeft;
        mapViewFrame.size.width = self.infoContainer.frame.size.width - mapViewPaddingRight - mapViewFrame.origin.x;
        self.mapView.frame = mapViewFrame;
    };
    
    void(^descriptionLabelSizeBlock)(NSString *) = ^(NSString * descriptionText){
        if (descriptionText && descriptionText.length > 0) {
            CGSize descriptionLabelSize = [descriptionText sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
            CGRect descriptionLabelFrame = self.descriptionLabel.frame;
            descriptionLabelFrame.size = descriptionLabelSize;
            self.descriptionLabel.frame = descriptionLabelFrame;
            CGRect descriptionContainerFrame = self.descriptionContainer.frame;
            descriptionContainerFrame.size.height = self.descriptionLabel.frame.size.height + 2 * self.descriptionLabel.frame.origin.y;
            self.descriptionContainer.frame = descriptionContainerFrame;
        } else {
            CGRect descriptionContainerFrame = self.descriptionContainer.frame;
            descriptionContainerFrame.size.height = 0;
            self.descriptionContainer.frame = descriptionContainerFrame;
        }
        CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
        eventsHeaderContainerFrame.origin.y = CGRectGetMaxY(self.descriptionContainer.frame);
        self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
        CGRect mainContainerFrame = self.mainContainer.frame;
        mainContainerFrame.size.height = CGRectGetMaxY(self.eventsHeaderContainer.frame);
        self.mainContainer.frame = mainContainerFrame;
        if (animated) { [self.eventsTableView beginUpdates]; }
        self.eventsTableView.tableHeaderView = self.mainContainer;
        if (animated) { [self.eventsTableView endUpdates]; }
    };
    
    NSString * nameText = @"";
    NSString * addressText = @"";
    NSString * cityStateZipText = @"";
    NSString * phoneText = @"";
    NSString * descriptionText = @"";
    BOOL phoneAvailable = venue && venue.phone && venue.phone.length > 0;
    BOOL locationAvailable = venue && venue.latitude && venue.longitude;
    if (venue != nil) {
        nameText = venue.title;
        addressText = venue.address;
        cityStateZipText = [self.webDataTranslator addressSecondLineStringFromCity:venue.city state:venue.state zip:venue.zip];
        phoneText = phoneAvailable ? venue.phone : @"Phone number not available";
        descriptionText = venue.placeDescription;
    }
    
    self.nameBar.text = nameText;
    self.addressLabel.text = addressText;
    self.cityStateZipLabel.text = cityStateZipText;
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateNormal];
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateHighlighted];
    self.descriptionLabel.text = descriptionText;
    self.phoneNumberButton.enabled = phoneAvailable;
    self.mapButton.enabled = locationAvailable;
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
            descriptionLabelSizeBlock(descriptionText);
        }];
    } else {
        infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
        descriptionLabelSizeBlock(descriptionText);
    }

}

- (void) updateMapViewToCenterOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(coordinate.latitude + .00055, coordinate.longitude), 200, 200) animated:animated];
    EventLocationAnnotation * venueLocationAnnotation = [[EventLocationAnnotation alloc] initWithName:@"" address:@"" coordinate:coordinate];
    [self.mapView addAnnotation:venueLocationAnnotation];
    [venueLocationAnnotation release];
}

// Venue image not yet available / implemented. Need to add an imageLocation attribute the Place object, and pull in that file location from the server. UPDATE: Done!
- (void) updateImageFromVenue:(Place *)venue animated:(BOOL)animated {
    NSLog(@"updateImageFromVenue:");
//    self.imageView.image = [UIImage imageNamed:@"event_img_placeholder.png"];
//    [self.imageView setImageWithURL:[URLBuilder imageURLForImageLocation:self.venue.imageLocation] placeholderImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
    NSURL * imageURL = [URLBuilder imageURLForImageLocation:self.venue.imageLocation];
    SDWebImageManager * webImageManager = [SDWebImageManager sharedManager];
    UIImage * cachedImage = [webImageManager imageWithURL:imageURL];
    if (cachedImage) {
        [self showImageViewWithImage:cachedImage animated:animated];
    } else {
        [webImageManager downloadWithURL:imageURL delegate:self];
    }
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    NSLog(@"webImageManager:didFinishWithImage:");
    [self showImageViewWithImage:image animated:(self.view.window != nil)];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    NSLog(@"webImageManager:didFailWithError:");
    // Do nothing, really... Just chill, sans image in the venue card. Maybe ensure that the image view is hidden.
//    [self setImageViewIsVisible:NO animated:(self.view.window != nil)];
}

- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated {
    NSLog(@"showImageViewWithImage:");
    self.imageView.image = image;
//    [self setImageViewIsVisible:YES animated:animated];
}

- (void)setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated {
    NSLog(@"setImageViewIsVisible:%d", visible);
    void(^imageViewSizeBlock)(BOOL)=^(BOOL makeVisible){
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.size.height = makeVisible ? imageViewNormalHeight : 0;
        self.imageView.frame = imageViewFrame;
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            imageViewSizeBlock(visible);
            [self updateViewsVerticalPositionsAll];
        }];
    } else {
        imageViewSizeBlock(visible);
        [self updateViewsVerticalPositionsAll];
    }
}

- (void) updateViewsVerticalPositionsAll {
    CGRect nameBarFrame = self.nameBar.frame;
    nameBarFrame.origin.y = 0;
    self.nameBar.frame = nameBarFrame;
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.y = CGRectGetMaxY(nameBarFrame);
    self.imageView.frame = imageViewFrame;
    CGRect infoContainerFrame = self.infoContainer.frame;
    infoContainerFrame.origin.y = CGRectGetMaxY(imageViewFrame);
    self.infoContainer.frame = infoContainerFrame;
    CGRect descriptionContainerFrame = self.descriptionContainer.frame;
    descriptionContainerFrame.origin.y = CGRectGetMaxY(infoContainerFrame);
    self.descriptionContainer.frame = descriptionContainerFrame;
    CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
    eventsHeaderContainerFrame.origin.y = CGRectGetMaxY(descriptionContainerFrame);
    self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
    [self updateViewsVerticalPositionsForScroll];
}

- (void) updateViewsVerticalPositionsForScroll {
    CGRect nameBarFrame = self.nameBar.frame;
    if (self.eventsTableView.contentOffset.y >= 0) {
        nameBarFrame.origin.y = self.eventsTableView.contentOffset.y;
        CGFloat infoContainerOriginalOriginY = self.nameBar.frame.size.height + self.imageView.frame.size.height;
        CGRect infoContainerFrame = self.infoContainer.frame;
        CGFloat infoContainerAdjustedOriginY = infoContainerOriginalOriginY;
        if (self.eventsTableView.contentOffset.y + self.nameBar.frame.size.height >= infoContainerOriginalOriginY) {
            infoContainerAdjustedOriginY = nameBarFrame.origin.y + nameBarFrame.size.height;
        }
        infoContainerFrame.origin.y = infoContainerAdjustedOriginY;
        self.infoContainer.frame = infoContainerFrame;
        CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
        eventsHeaderContainerFrame.origin.y = MAX(CGRectGetMaxY(self.descriptionContainer.frame), CGRectGetMaxY(self.infoContainer.frame));
        self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
    } else {
        nameBarFrame.origin.y = 0;
    }
    self.nameBar.frame = nameBarFrame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.eventsTableView) {
        [self updateViewsVerticalPositionsForScroll];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"EventCellGeneral";
    
    EventTableViewCell * cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Fake Event %d", indexPath.row];
    cell.categoryColor = indexPath.row % 2 == 1 ? [UIColor yellowColor] : [UIColor greenColor];
    cell.locationLabel.text = @"Redundantly Displayed Venue Name";
    cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"January %d, 2012 | %d:0%d AM", indexPath.row, indexPath.row, indexPath.row];
    cell.priceOriginalLabel.text = [NSString stringWithFormat:@"$10%d.00", indexPath.row];
    
}

- (void)viewController:(UIViewController *)viewController didFinishByRequestingStackCollapse:(BOOL)didRequestStackCollapse {
    if (didRequestStackCollapse) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }   
}

- (void) eventViewController:(EventViewController *)eventViewController didFinishByRequestingEventDeletionForEventURI:(NSString *)eventURI {
    NSLog(@"ERROR/WARNING in VenueViewController - not sure how to handle an EventViewController requesting deletion of an event. Currently, we are simply not deleting it!");
    //    [self.coreDataModel deleteRegularEventForURI:eventURI];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
