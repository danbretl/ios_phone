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
#import <QuartzCore/QuartzCore.h>

double const VVC_ANIMATION_DURATION = 0.25;

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
@property (retain, nonatomic) IBOutlet UIView * infoContainerShadowView;
@property (retain, nonatomic) IBOutlet UIView * infoContainerBackgroundView;
@property (retain, nonatomic) IBOutlet UILabel * addressLabel;
@property (retain, nonatomic) IBOutlet UILabel * cityStateZipLabel;
@property (retain, nonatomic) IBOutlet UIButton * phoneNumberButton;
@property (retain, nonatomic) IBOutlet UIButton * mapButton;
@property (retain, nonatomic) IBOutlet MKMapView * mapView;
@property (retain, nonatomic) IBOutlet UIView * descriptionContainer;
@property (retain, nonatomic) IBOutlet UILabel * descriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton * descriptionReadMoreButton;
@property (retain, nonatomic) IBOutlet GradientView * descriptionReadMoreCoverView;

@property (retain, nonatomic) IBOutlet UIView * eventsHeaderContainer;
@property (retain, nonatomic) IBOutlet UILabel * eventsHeaderLabel;
@property (retain, nonatomic) IBOutlet UITableView * eventsTableView;

@property (retain) MapViewController * mapViewController;

@property (retain) UISwipeGestureRecognizer * swipeToGoBack;

- (IBAction)backButtonTouched:(UIButton *)button;
- (IBAction)logoButtonTouched:(UIButton *)button;
- (IBAction)followButtonTouched:(UIButton *)button;
- (IBAction)phoneNumberButtonTouched:(UIButton *)button;
- (IBAction)mapButtonTouched:(UIButton *)button;
- (void)swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture;
- (IBAction)descriptionReadMoreButtonTouched:(id)sender;


- (void) updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) updateDescriptionTextFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) updateDescriptionContainerSizeToFitLabelAfterExpansion:(BOOL)shouldExpandLabel animated:(BOOL)animated;
- (void) setDescriptionReadMoreIsVisible:(BOOL)isVisible animated:(BOOL)animated;
- (void) updateMapViewToCenterOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void) updateImageFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated;
- (void) setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated;
- (void)updateViewsVerticalPositionsIncludingDescriptionContainer:(BOOL)shouldUpdateDescriptionContainer animated:(BOOL)animated;
//- (void) updateViewsVerticalPositionsAll;
//- (void) updateViewsVerticalPositionsForScroll;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation VenueViewController
@synthesize mainContainer;
@synthesize mapView=mapView_;
@synthesize eventsHeaderContainer=eventsHeaderContainer_;
@synthesize eventsHeaderLabel=eventsHeaderLabel_;
@synthesize descriptionReadMoreCoverView=descriptionReadMoreCoverView_;
@synthesize descriptionReadMoreButton=descriptionReadMoreButton_;
@synthesize infoContainerShadowView=infoContainerShadowView_;
@synthesize infoContainerBackgroundView=infoContainerBackgroundView_;
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
@synthesize swipeToGoBack=swipeToGoBack_;

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
    imageViewNormalHeight = self.imageView.frame.size.height;
    [self setImageViewIsVisible:NO animated:NO];
    
    // Venue info views
    // Background
    self.infoContainerBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_venue_location_info.png"]];
    // Shadow
    self.infoContainerShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoContainerShadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.infoContainerShadowView.layer.shadowOpacity = 0.55;
    self.infoContainerShadowView.layer.shouldRasterize = YES;
    // Subviews
    self.addressLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    // Description view
    self.descriptionLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14];
    self.descriptionReadMoreButton.titleLabel.font = /*[UIFont kwiqetFontOfType:RegularNormal size:self.descriptionLabel.font.pointSize];*/self.descriptionLabel.font;
    self.descriptionReadMoreCoverView.colorEnd = self.descriptionContainer.backgroundColor;
    self.descriptionReadMoreCoverView.endX = 20;
    
    // Table header views
    self.eventsHeaderContainer.backgroundColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
    self.eventsHeaderLabel.backgroundColor = [UIColor clearColor];
    self.eventsHeaderLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:16.0];
    self.eventsHeaderLabel.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.eventsTableView.backgroundColor = [UIColor clearColor];
    self.eventsTableView.tableHeaderView = self.mainContainer;
    
    // Gesture recognizers
    swipeToGoBack_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack:)];
    self.swipeToGoBack.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeToGoBack.delegate = self;
    [self.mainContainer addGestureRecognizer:self.swipeToGoBack];
    
    // Update views from data
    if (self.venue) {
        [self updateInfoViewsFromVenue:self.venue animated:NO];
        [self updateDescriptionTextFromVenue:self.venue animated:NO];
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
        self.descriptionLabel.backgroundColor = [UIColor greenColor];
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
    [self setSwipeToGoBack:nil];
    [self setDescriptionReadMoreCoverView:nil];
    [self setDescriptionReadMoreButton:nil];
    [self setInfoContainerBackgroundView:nil];
    [self setInfoContainerShadowView:nil];
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
    [swipeToGoBack_ release];
    [descriptionReadMoreCoverView_ release];
    [descriptionReadMoreButton_ release];
    [infoContainerBackgroundView_ release];
    [infoContainerShadowView_ release];
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
            [self updateDescriptionTextFromVenue:self.venue animated:YES];
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
        CGSize cityStateZipTextSize = [cityStateZipText sizeWithFont:self.cityStateZipLabel.font];
        CGSize phoneTextSize = [phoneText sizeWithFont:self.phoneNumberButton.titleLabel.font];
        // Address lines
        CGRect addressLabelFrame = self.addressLabel.frame;
        CGRect cityStateZipLabelFrame = self.cityStateZipLabel.frame;
        addressLabelFrame.size.width = MIN(addressTextSize.width, labelsRightmostAllowableX - addressLabelFrame.origin.x);
        cityStateZipLabelFrame.size.width = MIN(cityStateZipTextSize.width, labelsRightmostAllowableX - cityStateZipLabelFrame.origin.x);
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
    
    NSString * nameText = @"";
    NSString * addressText = @"";
    NSString * cityStateZipText = @"";
    NSString * phoneText = @"";

    BOOL phoneAvailable = venue && venue.phone && venue.phone.length > 0;
    BOOL locationAvailable = venue && venue.latitude && venue.longitude;
    if (venue != nil) {
        nameText = venue.title;
        addressText = venue.address;
        cityStateZipText = [self.webDataTranslator addressSecondLineStringFromCity:venue.city state:venue.state zip:venue.zip];
        phoneText = phoneAvailable ? venue.phone : @"Phone number not available";
    }
    
    self.nameBar.text = nameText;
    self.addressLabel.text = addressText;
    self.cityStateZipLabel.text = cityStateZipText;
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateNormal];
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateHighlighted];
    self.phoneNumberButton.enabled = phoneAvailable;
    self.mapButton.enabled = locationAvailable;
    
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
        }];
        [self updateViewsVerticalPositionsIncludingDescriptionContainer:NO animated:YES];
    } else {
        infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
        [self updateViewsVerticalPositionsIncludingDescriptionContainer:NO animated:NO];
    }

}


- (void) updateDescriptionTextFromVenue:(Place *)venue animated:(BOOL)animated {
    
    NSString * descriptionText = @"";
    if (venue != nil) {
        descriptionText = venue.placeDescription;
    }
    self.descriptionLabel.text = descriptionText;
    
    CGFloat descriptionContainerCurrentHeight = self.descriptionContainer.frame.size.height;
    CGFloat descriptionContainerNeededHeight = 0;
    CGSize descriptionLabelTextSize = CGSizeMake(self.descriptionLabel.frame.size.width, 0);
    CGFloat descriptionLabelVerticalPadding = self.descriptionLabel.frame.origin.y;
    if (self.descriptionLabel.text.length > 0) {
        descriptionLabelTextSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
        descriptionContainerNeededHeight = descriptionLabelTextSize.height + 2 * descriptionLabelVerticalPadding;
    }
    
    void(^descriptionLabelHeightAdjustmentBlock)(CGFloat) = ^(CGFloat givenHeight){
        CGRect descriptionLabelFrame = self.descriptionLabel.frame;
        descriptionLabelFrame.size.height = givenHeight;
        self.descriptionLabel.frame = descriptionLabelFrame;
    };
    
    if (descriptionContainerNeededHeight <= descriptionContainerCurrentHeight) {
        
        [self updateDescriptionContainerSizeToFitLabelAfterExpansion:YES animated:animated];
        
    } else {
        
        NSLog(@"Description label text is longer than the description container can currently handle.");
        NSLog(@"Description label text needs container of %f pixels, description container is currently %f pixels.", descriptionContainerNeededHeight, descriptionContainerCurrentHeight);
        
        void(^roundedDescriptionLabelHeightAdjustmentBlock)(void) = ^{
            CGFloat lineHeight = self.descriptionLabel.font.lineHeight;
            CGFloat numberOfLinesThatFit = floorf((descriptionContainerCurrentHeight - 2 * descriptionLabelVerticalPadding) / lineHeight);
            NSLog(@"Line height is %f, and the number of lines that fit in the current container is %f.", lineHeight, numberOfLinesThatFit);
            descriptionLabelHeightAdjustmentBlock(numberOfLinesThatFit * lineHeight);
        };
        
        if (animated) {
            [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
                roundedDescriptionLabelHeightAdjustmentBlock();
            }];
        } else {
            roundedDescriptionLabelHeightAdjustmentBlock();
        }
        [self updateDescriptionContainerSizeToFitLabelAfterExpansion:NO animated:animated];
        
    }

}

- (void) updateDescriptionContainerSizeToFitLabelAfterExpansion:(BOOL)shouldExpandLabel animated:(BOOL)animated {
    
    void(^descriptionLabelExpandBlock)(void) = ^{
        NSLog(@"descriptionLabelExpandBlock");
        NSLog(@"%@", self.descriptionLabel.text);
        [self.descriptionLabel setNeedsDisplay];
        CGSize descriptionLabelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
        CGRect descriptionLabelFrame = self.descriptionLabel.frame;
        descriptionLabelFrame.size = descriptionLabelSize;
        self.descriptionLabel.frame = descriptionLabelFrame;
        NSLog(@"%@", NSStringFromCGRect(self.descriptionLabel.frame));
    };
    
    void(^descriptionContainerFitBlock)(void) = ^{
        NSLog(@"descriptionContainerFitBlock");
        CGFloat descriptionContainerHeight = 0;
        if (self.descriptionLabel.frame.size.height > 0) {
            CGFloat descriptionLabelVerticalPadding = self.descriptionLabel.frame.origin.y;
            descriptionContainerHeight = CGRectGetMaxY(self.descriptionLabel.frame) + descriptionLabelVerticalPadding;            
        }
        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
        descriptionContainerFrame.size.height = descriptionContainerHeight;
        self.descriptionContainer.frame = descriptionContainerFrame;
        NSLog(@"%@", NSStringFromCGRect(self.descriptionContainer.frame));
    };
    
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            if (shouldExpandLabel) { descriptionLabelExpandBlock(); }
            descriptionContainerFitBlock();
        }];
    } else {
        if (shouldExpandLabel) { descriptionLabelExpandBlock(); }
        descriptionContainerFitBlock();
    }
    [self setDescriptionReadMoreIsVisible:!shouldExpandLabel animated:animated];
    [self updateViewsVerticalPositionsIncludingDescriptionContainer:NO animated:animated];
    
}

- (void) setDescriptionReadMoreIsVisible:(BOOL)isVisible animated:(BOOL)animated {
    CGFloat alpha = isVisible ? 1.0 : 0.0;
    void(^alphaBlock)(CGFloat) = ^(CGFloat alpha){
        self.descriptionReadMoreButton.alpha = alpha;
        self.descriptionReadMoreCoverView.alpha = alpha;
    };
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            alphaBlock(alpha);
            self.descriptionReadMoreButton.userInteractionEnabled = isVisible;
        }];
    } else {
        alphaBlock(alpha);
        self.descriptionReadMoreButton.userInteractionEnabled = isVisible;        
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
    if (self.venue.imageLocation) {
        NSURL * imageURL = [URLBuilder imageURLForImageLocation:self.venue.imageLocation];
        SDWebImageManager * webImageManager = [SDWebImageManager sharedManager];
        UIImage * cachedImage = [webImageManager imageWithURL:imageURL];
        if (cachedImage) {
            [self showImageViewWithImage:cachedImage animated:animated];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [webImageManager downloadWithURL:imageURL delegate:self];
        }
    }
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    NSLog(@"webImageManager:didFinishWithImage:");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self showImageViewWithImage:image animated:(self.view.window != nil)];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    NSLog(@"webImageManager:didFailWithError:");
    // Do nothing, really... Just chill, sans image in the venue card. Maybe ensure that the image view is hidden.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self setImageViewIsVisible:NO animated:(self.view.window != nil)];
}

- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated {
    NSLog(@"showImageViewWithImage:");
    self.imageView.image = image;
    [self setImageViewIsVisible:YES animated:animated];
}

- (void)setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated {
    NSLog(@"setImageViewIsVisible:%d", visible);
    void(^imageViewSizeBlock)(BOOL)=^(BOOL makeVisible){
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.size.height = makeVisible ? imageViewNormalHeight : 0;
        self.imageView.frame = imageViewFrame;
    };
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            imageViewSizeBlock(visible);
        }];
        [self updateViewsVerticalPositionsIncludingDescriptionContainer:YES animated:animated];
    } else {
        imageViewSizeBlock(visible);
        [self updateViewsVerticalPositionsIncludingDescriptionContainer:YES animated:NO];
    }
}

- (void)updateViewsVerticalPositionsIncludingDescriptionContainer:(BOOL)shouldUpdateDescriptionContainer animated:(BOOL)animated {
    
    void(^adjustmentsBlock)(void) = ^{
        CGRect nameBarFrame = self.nameBar.frame;
        nameBarFrame.origin.y = MAX(0, self.eventsTableView.contentOffset.y);
        self.nameBar.frame = nameBarFrame;
        CGRect infoContainerFrame = self.infoContainer.frame;
        infoContainerFrame.origin.y = MAX(CGRectGetMaxY(nameBarFrame), CGRectGetMaxY(self.imageView.frame));
        self.infoContainer.frame = infoContainerFrame;
        if (shouldUpdateDescriptionContainer) {
            CGRect descriptionContainerFrame = self.descriptionContainer.frame;
            descriptionContainerFrame.origin.y = CGRectGetMaxY(self.imageView.frame) + self.infoContainer.frame.size.height;
            self.descriptionContainer.frame = descriptionContainerFrame;
        }
        CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
        eventsHeaderContainerFrame.origin.y = MAX(CGRectGetMaxY(self.descriptionContainer.frame), CGRectGetMaxY(infoContainerFrame));
        self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
    };
    
    void(^totalSizeChangeCheckBlock)(CGFloat) = ^(CGFloat originalHeight){
        CGFloat mainContainerShouldBeHeight = CGRectGetMaxY(self.descriptionContainer.frame) + self.eventsHeaderContainer.frame.size.height;
        if (originalHeight != mainContainerShouldBeHeight) {
            CGRect mainContainerFrame = self.mainContainer.frame;
            mainContainerFrame.size.height = mainContainerShouldBeHeight;
            self.mainContainer.frame = mainContainerFrame;
            if (animated) { [self.eventsTableView beginUpdates]; }
            self.eventsTableView.tableHeaderView = self.mainContainer;
            if (animated) { [self.eventsTableView endUpdates]; }
        }
    };
    
    CGFloat originalHeight = self.eventsTableView.tableHeaderView.frame.size.height;
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            adjustmentsBlock();
            totalSizeChangeCheckBlock(originalHeight);
        }];
    } else {
        adjustmentsBlock();
        totalSizeChangeCheckBlock(originalHeight);
    }
    
}

//- (void) updateViewsVerticalPositionsAll {
//    CGRect nameBarFrame = self.nameBar.frame;
//    nameBarFrame.origin.y = 0;
//    self.nameBar.frame = nameBarFrame;
//    CGRect imageViewFrame = self.imageView.frame;
//    imageViewFrame.origin.y = CGRectGetMaxY(nameBarFrame);
//    self.imageView.frame = imageViewFrame;
//    CGRect infoContainerFrame = self.infoContainer.frame;
//    infoContainerFrame.origin.y = CGRectGetMaxY(imageViewFrame);
//    self.infoContainer.frame = infoContainerFrame;
//    CGRect descriptionContainerFrame = self.descriptionContainer.frame;
//    descriptionContainerFrame.origin.y = CGRectGetMaxY(infoContainerFrame);
//    self.descriptionContainer.frame = descriptionContainerFrame;
//    CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
//    eventsHeaderContainerFrame.origin.y = CGRectGetMaxY(descriptionContainerFrame);
//    self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
//    [self updateViewsVerticalPositionsForScroll];
//}

//- (void) updateViewsVerticalPositionsForScroll {
//    CGRect nameBarFrame = self.nameBar.frame;
//    if (self.eventsTableView.contentOffset.y >= 0) {
//        nameBarFrame.origin.y = self.eventsTableView.contentOffset.y;
//        CGFloat infoContainerOriginalOriginY = self.nameBar.frame.size.height + self.imageView.frame.size.height;
//        CGRect infoContainerFrame = self.infoContainer.frame;
//        CGFloat infoContainerAdjustedOriginY = infoContainerOriginalOriginY;
//        if (self.eventsTableView.contentOffset.y + self.nameBar.frame.size.height >= infoContainerOriginalOriginY) {
//            infoContainerAdjustedOriginY = nameBarFrame.origin.y + nameBarFrame.size.height;
//        }
//        infoContainerFrame.origin.y = infoContainerAdjustedOriginY;
//        self.infoContainer.frame = infoContainerFrame;
//        CGRect eventsHeaderContainerFrame = self.eventsHeaderContainer.frame;
//        eventsHeaderContainerFrame.origin.y = MAX(CGRectGetMaxY(self.descriptionContainer.frame), CGRectGetMaxY(self.infoContainer.frame));
//        self.eventsHeaderContainer.frame = eventsHeaderContainerFrame;
//    } else {
//        nameBarFrame.origin.y = 0;
//    }
//    self.nameBar.frame = nameBarFrame;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.eventsTableView) {
        [self updateViewsVerticalPositionsIncludingDescriptionContainer:NO animated:NO];
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
        cell.shouldShowVenue = NO;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    if (gestureRecognizer == self.swipeToGoBack) {
        if ([touch.view isDescendantOfView:self.nameBar]) {
            shouldReceive = NO;
        }
    }
    return shouldReceive;
}

- (void)swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
}

- (IBAction)descriptionReadMoreButtonTouched:(UIButton *)button {
    [self updateDescriptionContainerSizeToFitLabelAfterExpansion:YES animated:YES];
}

@end
