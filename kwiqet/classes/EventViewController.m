//
//  CardPageViewController.m
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "EventViewController.h"
#import <EventKit/EventKit.h>
#import "EventLocationAnnotation.h"
#import <EventKit/EventKit.h>
#import "URLBuilder.h"
#import "WebUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionsManagement.h"
#import "LocalImagesManager.h"
#import "Analytics.h"
#import "Occurrence.h"
#import "Place.h"
#import "Price.h"

#define CGFLOAT_MAX_TEXT_SIZE 10000

static NSString * const EVC_OCCURRENCE_INFO_LOADING_STRING = @"Loading event details...";
static NSString * const EVC_OCCURRENCE_INFO_LOAD_FAILED_STRING = @"Failed to load event details.\nTouch here to retry.";

@interface EventViewController()

@property (retain) IBOutlet UIView   * backgroundColorView;
@property (retain) IBOutlet UIView   * navigationBar;
@property (retain) IBOutlet UIButton * backButton;
@property (retain) IBOutlet UIButton * logoButton;
@property (retain) IBOutlet UIView   * actionBar;
@property (retain) IBOutlet UIButton * letsGoButton;
@property (retain) IBOutlet UIButton * shareButton;
@property (retain) IBOutlet UIButton * deleteButton;
@property (retain) IBOutlet UIScrollView * scrollView;
@property (retain) IBOutlet ElasticUILabel * titleBar;
@property (retain) IBOutlet UIImageView * imageView;
@property (retain) IBOutlet UIView * breadcrumbsBar;
@property (retain) IBOutlet UILabel * breadcrumbsLabel;
@property (retain) IBOutlet UIView   * occurrenceInfoContainer;
@property CGFloat occurrenceInfoContainerRegularHeight;
@property CGFloat occurrenceInfoContainerCollapsedHeight;
@property (retain) IBOutlet UIView   * occurrenceInfoPlaceholderView;
@property (retain) IBOutlet UIButton * occurrenceInfoPlaceholderRetryButton;
@property (retain) IBOutlet UIView   * dateContainer;
@property (retain) IBOutlet UILabel  * monthLabel;
@property (retain) IBOutlet UILabel  * dayNumberLabel;
@property (retain) IBOutlet UILabel  * dayNameLabel;
@property (retain) IBOutlet UIView   * timeContainer;
@property (retain) IBOutlet UILabel  * timeLabel;
@property (retain) IBOutlet UIView   * priceContainer;
@property (retain) IBOutlet UILabel  * priceLabel;
@property (retain) IBOutlet UIView   * locationContainer;
@property (retain) IBOutlet UILabel  * venueLabel;
@property (retain) IBOutlet UILabel  * addressLabel;
@property (retain) IBOutlet UILabel  * cityStateZipLabel;
@property (retain) IBOutlet UIButton * phoneNumberButton;
@property (retain) IBOutlet UIButton * mapButton;
@property (retain) IBOutlet UIView   * descriptionContainer;
@property (retain) IBOutlet UIView   * descriptionBackgroundColorView;
@property (retain) IBOutlet UILabel  * descriptionLabel;
@property (retain) UIView * shadowDescriptionContainer;

- (IBAction) backButtonTouched;
- (IBAction) logoButtonTouched;
- (IBAction) letsGoButtonTouched;
- (IBAction) shareButtonTouched;
- (IBAction) deleteButtonTouched;
- (IBAction) phoneButtonTouched;
- (IBAction) mapButtonTouched;
- (IBAction) occurrenceInfoRetryButtonTouched;

@property (nonatomic, retain) WebActivityView * webActivityView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnUserActionRequestAlertView;
//@property (retain) UIImage * imageFull;
@property (retain) NSURLConnection * loadImageURLConnection;
@property (retain) NSMutableData * loadImageData;
- (void) displayImage:(UIImage *)image;

@property (retain) UIActionSheet  * letsGoChoiceActionSheet;
@property (retain) NSMutableArray * letsGoChoiceActionSheetSelectors;
@property (retain) UIActionSheet  * shareChoiceActionSheet;
@property (retain) NSMutableArray * shareChoiceActionSheetSelectors;
- (void) pushedToAddToCalendar;
- (void) pushedToCreateFacebookEvent;
- (void) pushedToShareViaEmail;
- (void) pushedToShareViaFacebook;
- (void) setOccurrenceInfoContainerIsVisible:(BOOL)isVisible animated:(BOOL)animated;

//- (void) loadImage;

- (void) facebookEventCreateSuccess:(NSNotification *)notification;
- (void) facebookEventCreateFailure:(NSNotification *)notification;
- (void) facebookEventInviteSuccess:(NSNotification *)notification;
- (void) facebookEventInviteFailure:(NSNotification *)notification;
- (void) facebookAuthFailure:(NSNotification *)notification;

@end

@implementation EventViewController

@synthesize backgroundColorView, navigationBar, backButton, logoButton, actionBar, letsGoButton, shareButton, deleteButton, scrollView, titleBar, imageView, breadcrumbsBar, breadcrumbsLabel, occurrenceInfoContainer, occurrenceInfoContainerRegularHeight, occurrenceInfoContainerCollapsedHeight, occurrenceInfoPlaceholderView, occurrenceInfoPlaceholderRetryButton, dateContainer, monthLabel, dayNumberLabel, dayNameLabel, timeContainer, timeLabel, priceContainer, priceLabel, locationContainer, venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton, descriptionContainer, descriptionBackgroundColorView, descriptionLabel, shadowDescriptionContainer;

@synthesize event;
@synthesize webActivityView;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;
@synthesize facebookManager;
//@synthesize imageFull;
@synthesize loadImageURLConnection, loadImageData;
@synthesize letsGoChoiceActionSheet, letsGoChoiceActionSheetSelectors, shareChoiceActionSheet, shareChoiceActionSheetSelectors;

- (void)dealloc {
    [backgroundColorView release];
    [navigationBar release];
    [backButton release];
    [logoButton release];
    [actionBar release];
    [letsGoButton release];
    [shareButton release];
    [deleteButton release];
    [scrollView release];
    [titleBar release];
    [imageView release];
    [breadcrumbsBar release];
    [breadcrumbsLabel release];
    [occurrenceInfoContainer release];
    [occurrenceInfoPlaceholderView release];
    [occurrenceInfoPlaceholderRetryButton release];
    [dateContainer release];
    [monthLabel release];
    [dayNumberLabel release];
    [dayNameLabel release];
    [timeContainer release];
    [timeLabel release];
    [priceContainer release];
    [priceLabel release];
    [locationContainer release];
    [venueLabel release];
    [addressLabel release];
    [cityStateZipLabel release];
    [phoneNumberButton release];
    [mapButton release];
    [descriptionContainer release];
    [descriptionBackgroundColorView release];
    [descriptionLabel release];
    [shadowDescriptionContainer release];
    
    [event release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release]; // ---?
    [webDataTranslator release];
    [facebookManager release];
//    [imageFull release];
    [loadImageURLConnection release];
    [loadImageData release];
    [letsGoChoiceActionSheet release];
    [letsGoChoiceActionSheetSelectors release];
    [shareChoiceActionSheet release];
    [shareChoiceActionSheetSelectors release];

    [super dealloc];
	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cardbg.png"]];
    
    // Navigation bar
    self.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    
    // Action bar
    self.actionBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"actbar.png"]];
    // Action bar shadow
    UIView * shadowActionBar = [[UIView alloc] initWithFrame:
                                CGRectMake(self.actionBar.frame.origin.x, 
                                           self.actionBar.frame.origin.y, 
                                           self.actionBar.frame.size.width, 
                                           self.actionBar.frame.size.height-1)];
    shadowActionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    shadowActionBar.backgroundColor = [UIColor blackColor];
    shadowActionBar.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowActionBar.layer.shadowOffset = CGSizeMake(0, 0);
    shadowActionBar.layer.shadowOpacity = .55;
    shadowActionBar.layer.shouldRasterize = YES;
    [self.view insertSubview:shadowActionBar aboveSubview:self.backgroundColorView];
    [shadowActionBar release];
    
    // Title bar shadow
    UIView * shadowTitleBar = [[UIView alloc] initWithFrame:
                               CGRectMake(self.titleBar.frame.origin.x, 
                                          self.titleBar.frame.origin.y+1, 
                                          self.titleBar.frame.size.width, 
                                          self.titleBar.frame.size.height-1)];
    shadowTitleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    shadowTitleBar.backgroundColor = [UIColor blackColor];
    shadowTitleBar.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowTitleBar.layer.shadowOffset = CGSizeMake(0, 0);
    shadowTitleBar.layer.shadowOpacity = 0.55;
    shadowTitleBar.layer.shouldRasterize = YES;
    [self.scrollView addSubview:shadowTitleBar];
    [self.scrollView sendSubviewToBack:shadowTitleBar];
    [shadowTitleBar release];
    
    // Title bar bottom border
    // - Currently disabled... I think we need to revisit this (very minor) design element.
//    UIView * titleBarOverlayView = [[UIView alloc] initWithFrame:self.titleBar.bounds];
//    titleBarOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    titleBarOverlayView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HR.png"]];
//    titleBarOverlayView.opaque = NO;
//    titleBarOverlayView.userInteractionEnabled = NO;
//    self.titleBar.overlayView = titleBarOverlayView;
//    [titleBarOverlayView release];
    
    // Image view gesture recognizer
    UISwipeGestureRecognizer * swipeToGoBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack:)];
    [self.imageView addGestureRecognizer:swipeToGoBack];
    [swipeToGoBack release];
    
    // Occurrence info container
    self.occurrenceInfoContainerRegularHeight = self.occurrenceInfoContainer.frame.size.height;
    self.occurrenceInfoContainerCollapsedHeight = self.dateContainer.frame.size.height;
    [self.occurrenceInfoContainer addSubview:self.occurrenceInfoPlaceholderView];
    self.occurrenceInfoPlaceholderView.alpha = 0.0;
    self.occurrenceInfoPlaceholderView.userInteractionEnabled = NO;
    self.occurrenceInfoPlaceholderRetryButton.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.occurrenceInfoPlaceholderRetryButton.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.occurrenceInfoPlaceholderRetryButton setTitle:EVC_OCCURRENCE_INFO_LOADING_STRING forState:UIControlStateNormal];
    
    // Date views
    self.monthLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.dayNumberLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:33];
    self.dayNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];

    // Time views
    self.timeLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    // Price views
    self.priceLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                
    // Location views
    self.venueLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:22];
    self.addressLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.cityStateZipLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    // Phone number button
    self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:12];
    
    // Event description views
    self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:18];
    shadowDescriptionContainer = [[UIView alloc] initWithFrame:
                                  CGRectMake(self.descriptionContainer.frame.origin.x, 
                                             self.descriptionContainer.frame.origin.y, 
                                             self.descriptionContainer.frame.size.width, 
                                             self.descriptionContainer.frame.size.height-1)];
    self.shadowDescriptionContainer.backgroundColor = [UIColor blackColor];
    self.shadowDescriptionContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowDescriptionContainer.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowDescriptionContainer.layer.shadowOpacity = .55;
    self.shadowDescriptionContainer.layer.shouldRasterize = YES;
    [self.scrollView insertSubview:self.shadowDescriptionContainer atIndex:0];
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.frame];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    if (self.event) {
        [self updateViewsFromDataAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventCreateSuccess:) name:FBM_CREATE_EVENT_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventCreateFailure:) name:FBM_CREATE_EVENT_FAILURE_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventInviteSuccess:) name:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventInviteFailure:) name:FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAuthFailure:) name:FBM_AUTH_ERROR_KEY object:nil];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.titleBar scrollTextToOriginAnimated:animated];
}

-(void) showWebLoadingViews  {
//    NSLog(@"showWebLoadingViews");
//    if (self.view.window) {
//        NSLog(@"self.view.window");
        // ACTIVITY VIEWS
        [self.view bringSubviewToFront:self.webActivityView];
        [self.webActivityView showAnimated:YES];
        // USER INTERACTION
        self.view.userInteractionEnabled = NO;
//    }
}

-(void)hideWebLoadingViews  {
    
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.view.userInteractionEnabled = YES;
    
}

- (void)setEvent:(Event *)theEvent {
    if (event != theEvent) {
        [event release];
        event = [theEvent retain];
    }
    [self updateViewsFromDataAnimated:NO];
    [self.webConnector getAllOccurrencesForEventWithURI:event.uri]; // TURNING THIS OFF FOR TESTING
    [self.occurrenceInfoPlaceholderRetryButton setTitle:EVC_OCCURRENCE_INFO_LOADING_STRING forState:UIControlStateNormal]; // TURNING THIS OFF FOR TESTING
//    [self showWebLoadingViews]; // This is unnecessary.
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {

    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * responseDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    [self.coreDataModel updateEvent:self.event withExhaustiveOccurrencesArray:[responseDictionary valueForKey:@"objects"]];
    [self updateViewsFromDataAnimated:YES];
    [self hideWebLoadingViews];
    
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
    NSLog(@"getAllOccurrencesFailure - need to deal with this!");
    [self.occurrenceInfoPlaceholderRetryButton setTitle:EVC_OCCURRENCE_INFO_LOAD_FAILED_STRING forState:UIControlStateNormal];
    [self hideWebLoadingViews];
    
}

-(void) updateViewsFromDataAnimated:(BOOL)animated {
    
    NSString * EVENT_TIME_NOT_AVAILABLE = @"Time not available";
    NSString * EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
    NSString * EVENT_ADDRESS_NOT_AVAILABLE = @"Address not available";
    NSString * EVENT_PHONE_NOT_AVAILABLE = @"Phone number not available";
    
    // Concrete parent category color
    UIColor * concreteParentCategoryColor = self.event.concreteParentCategory.colorHex ? [WebUtil colorFromHexString:self.event.concreteParentCategory.colorHex] : [UIColor blackColor];
    
    // Background
//    self.view.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
    self.backgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.05];
//    self.detailsBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.10];
    self.descriptionBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
//    self.detailsLabel.backgroundColor = concreteParentCategoryColor;
//    self.detailsLabel.textColor = [UIColor whiteColor];
    
    // Title
    self.titleBar.text = self.event.title;
    self.titleBar.color = concreteParentCategoryColor;
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    NSArray * occurrencesChronological = [self.event occurrencesChronological];
    Occurrence * firstOccurrence = nil;
    if (occurrencesChronological && occurrencesChronological.count > 0) {
        firstOccurrence = [self.event.occurrencesChronological objectAtIndex:0];
    }
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    
    if (firstOccurrence) {
        
        // Date & Time
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        // Month
        [dateFormatter setDateFormat:@"MMM"];
        NSString * month = [dateFormatter stringFromDate:firstOccurrence.startDate];
        self.monthLabel.text = [month uppercaseString];
        // Day number
        [dateFormatter setDateFormat:@"d"];
        NSString * dayNumber = [dateFormatter stringFromDate:firstOccurrence.startDate];
        self.dayNumberLabel.text = dayNumber;
        self.dayNumberLabel.textColor = concreteParentCategoryColor;
        // Day name
        [dateFormatter setDateFormat:@"EEE"];
        NSString * dayName = [dateFormatter stringFromDate:firstOccurrence.startDate];
        [dateFormatter release];
        self.dayNameLabel.text = [dayName uppercaseString];
        // Time
        NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:firstOccurrence.startTime endDatetime:firstOccurrence.endTime dataUnavailableString:EVENT_TIME_NOT_AVAILABLE];
        self.timeLabel.text = time;
        
        NSArray * prices = firstOccurrence.pricesLowToHigh;
        Price * minPrice = nil;
        Price * maxPrice = nil;
        if (prices && prices.count > 0) {
            minPrice = (Price *)[prices objectAtIndex:0];
            maxPrice = (Price *)[prices lastObject];
        }
        NSString * price = [self.webDataTranslator priceRangeStringFromMinPrice:minPrice.value maxPrice:maxPrice.value dataUnavailableString:nil];
        self.priceLabel.text = [NSString stringWithFormat:@"Price: %@", price];
        
        // Location & Address
        NSString * addressFirstLine = firstOccurrence.place.address;
        NSString * addressSecondLine = [self.webDataTranslator addressSecondLineStringFromCity:firstOccurrence.place.city state:firstOccurrence.place.state zip:firstOccurrence.place.zip];
        BOOL someLocationInfo = addressFirstLine || addressSecondLine;
        if (!addressFirstLine) { addressFirstLine = EVENT_ADDRESS_NOT_AVAILABLE; }
        self.addressLabel.text = addressFirstLine;
        self.cityStateZipLabel.text = addressSecondLine;
        
        // Venue
        NSString * venue = firstOccurrence.place.title;
        if (!venue) { 
            if (someLocationInfo) {
                venue = @"Location:";
            } else {
                venue = @"Location not available";
            }
        }
        self.venueLabel.text = venue;
        
        // Map button
        self.mapButton.alpha = 1.0;
        self.mapButton.enabled = firstOccurrence.place.latitude && firstOccurrence.place.longitude;
        
        // Phone
        BOOL havePhoneNumber = firstOccurrence.place.phone != nil && [firstOccurrence.place.phone length] > 0;
        NSString * phone = havePhoneNumber ? firstOccurrence.place.phone : EVENT_PHONE_NOT_AVAILABLE;
        [self.phoneNumberButton setTitle:phone forState:UIControlStateNormal];
        self.phoneNumberButton.enabled = havePhoneNumber;
        
    } else {
        
        self.monthLabel.text = @"";
        self.dayNumberLabel.text = @"";
        self.dayNameLabel.text = @"";
        self.timeLabel.text = @"";
        self.priceLabel.text = @"";
        self.venueLabel.text = @"";
        self.addressLabel.text = @"";
        self.cityStateZipLabel.text = @"";
        [self.phoneNumberButton setTitle:@"" forState:UIControlStateNormal];
        self.phoneNumberButton.enabled = NO;
        self.mapButton.enabled = NO;
        self.mapButton.alpha = 0.0;
        
    }
    
    // Description
    NSString * descriptionString = self.event.eventDescription ? self.event.eventDescription : EVENT_DESCRIPTION_NOT_AVAILABLE;
    self.descriptionLabel.text = descriptionString;
    //set contentSize for scroll view
    CGSize detailsLabelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.bounds.size.width, 10000)];
    CGRect detailsLabelFrame = self.descriptionLabel.frame;
    detailsLabelFrame.size.height = detailsLabelSize.height;
    self.descriptionLabel.frame = detailsLabelFrame;
//    NSLog(@"%@", NSStringFromCGRect(self.detailsLabel.frame));
    CGRect detailsContainerFrame = self.descriptionContainer.frame;
    detailsContainerFrame.size.height = CGRectGetMaxY(self.descriptionLabel.frame) + self.descriptionLabel.frame.origin.y - 6; // TEMPORARY HACK, INFERRING THAT THE ORIGIN Y OF THE DETAILS LABEL IS EQUAL TO THE VERTICAL PADDING WE SHOULD GIVE UNDER THAT LABEL. // EVEN WORSE TEMPORARY HACK, HARDCODING AN OFFSET BECAUSE PUTTING EQUAL PADDING AFTER AS BEFORE DOES NOT LOOK EVEN.
    self.descriptionContainer.frame = detailsContainerFrame;
    self.shadowDescriptionContainer.frame = CGRectMake(self.descriptionContainer.frame.origin.x, self.descriptionContainer.frame.origin.y, self.descriptionContainer.frame.size.width, self.descriptionContainer.frame.size.height-1);
    
    [self setOccurrenceInfoContainerIsVisible:(firstOccurrence != nil) animated:animated];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.descriptionContainer.frame))];
    
    // Breadcrumbs
    NSMutableString * breadcrumbsString = [self.event.concreteParentCategory.title mutableCopy];
    NSArray * orderedConcreteCategoryBreadcrumbs = [self.event.concreteCategoryBreadcrumbs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]]];
    for (CategoryBreadcrumb * breadcrumb in orderedConcreteCategoryBreadcrumbs) {
        [breadcrumbsString appendFormat:@", %@", breadcrumb.category.title];
    }
    self.breadcrumbsLabel.text = breadcrumbsString;
    
    [self.imageView setImageWithURL:[URLBuilder imageURLForImageLocation:self.event.imageLocation] placeholderImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
    
}

- (void) setOccurrenceInfoContainerIsVisible:(BOOL)isVisible animated:(BOOL)animated {

    void (^occurrenceInfoContainerChangesBlock)(void) = ^{
        
        // Calculating frame values
        CGFloat newOccurrenceInfoContainerHeight = 0.0;
        if (isVisible) {
            newOccurrenceInfoContainerHeight = self.occurrenceInfoContainerRegularHeight;
        } else {
            CGFloat minOccurrenceInfoContainerHeight = self.scrollView.frame.size.height - self.descriptionContainer.frame.size.height - self.occurrenceInfoContainer.frame.origin.y;
            newOccurrenceInfoContainerHeight = MAX(self.occurrenceInfoContainerCollapsedHeight, minOccurrenceInfoContainerHeight);
        }
        
        // Setting frame values
        CGRect occurrenceInfoContainerFrame = self.occurrenceInfoContainer.frame;
        occurrenceInfoContainerFrame.size.height = newOccurrenceInfoContainerHeight;
        self.occurrenceInfoContainer.frame = occurrenceInfoContainerFrame;
        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
        descriptionContainerFrame.origin.y = CGRectGetMaxY(self.occurrenceInfoContainer.frame);
        self.descriptionContainer.frame = descriptionContainerFrame;
        CGRect shadowDescriptionContainerFrame = self.shadowDescriptionContainer.frame;
        shadowDescriptionContainerFrame.origin.y = self.descriptionContainer.frame.origin.y;
        self.shadowDescriptionContainer.frame = shadowDescriptionContainerFrame;
        
        // Showing / hiding views
        self.occurrenceInfoPlaceholderView.alpha = isVisible ? 0.0 : 1.0;
        
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:occurrenceInfoContainerChangesBlock];
    } else {
        occurrenceInfoContainerChangesBlock();
    }
    
    self.occurrenceInfoPlaceholderView.userInteractionEnabled = !isVisible;
    
}

- (void) set {
    
}

//- (void)loadImage {
//    
//    NSString * imageLocation = self.event.imageLocation;
//    
//    if (imageLocation != nil) {
////        // First, check to see if the image has been saved locally
////        BOOL imageExistsLocally = [LocalImagesManager eventImageExistsFromSourceLocation:imageLocation];
////        if (imageExistsLocally) {
////            self.imageFull = [LocalImagesManager loadEventImageDataFromSourceLocation:imageLocation];
////            NSLog(@"EventViewController about to displayImage from loadImage when image is saved locally");
////            [self displayImage:self.imageFull];
////        } else {
//        NSLog(@"current disk usage = %d", [[NSURLCache sharedURLCache] currentMemoryUsage]);
//            NSURL * imageURL = [URLBuilder imageURLForImageLocation:self.event.imageLocation];
//            NSURLRequest * request = [NSURLRequest requestWithURL:imageURL];
//            self.loadImageURLConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
//            if (self.loadImageURLConnection) {
//                self.loadImageData = [NSMutableData data];
//                // Wait for response...
//            } else {
//                // Error
//                self.imageFull = [UIImage imageNamed:@"event_img_placeholder.png"];
//                NSLog(@"EventViewController about to displayImage from loadImage when there was an error making NSURLConnection");
//                [self displayImage:self.imageFull];
//            }
////        }
//    } else {
//        self.imageFull = [UIImage imageNamed:@"event_img_placeholder.png"];
//        NSLog(@"EventViewController about to displayImage from loadImage when imageLocation is nil");
//        [self displayImage:self.imageFull];
//    }
//
//}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    if (connection == self.loadImageURLConnection) {
//        NSLog(@"EventViewController connection...didReceiveResponse");
//        // This method is called when the server has determined that it has enough information to create the NSURLResponse.
//        // It can be called multiple times, for example in the case of a redirect, so each time we reset the data.
//        [self.loadImageData setLength:0];
//    }
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
//    NSLog(@"EventViewController connection...willCacheResponse");
//    if (connection == self.loadImageURLConnection) {
//        NSLog(@"EventViewController connection...willCacheResponse (and it's the NSURLConnection we care about)");
//    }
//    return cachedResponse;
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    if (connection == self.loadImageURLConnection) {
//        [self.loadImageData appendData:data];
//    }
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"EventViewController connectionDidFinishLoading:%@", connection);
//    self.imageFull = [UIImage imageWithData:self.loadImageData];
////    [LocalImagesManager saveEventImageData:self.loadImageData sourceLocation:self.event.imageLocation];
//    NSLog(@"EventViewController about to displayImage from connectionDidFinishLoading");
//    [self displayImage:self.imageFull];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    if (connection == self.loadImageURLConnection) {
//        self.imageFull = [UIImage imageNamed:@"event_img_placeholder.png"];
//        NSLog(@"EventViewController about to displayImage from connection...didFailWithError, using placeholder image");
//        [self displayImage:self.imageFull];
//    }
//}

- (void)displayImage:(UIImage *)image {
    //NSLog(@"image is %f by %f", image.size.width, image.size.height);
    NSLog(@"EventViewController displayImage:%@ (%fx%f)", image, image.size.width, image.size.height);
	[self.imageView setImage:image];
    [self.scrollView bringSubviewToFront:self.titleBar];
}

- (WebConnector *) webConnector {
    if (webConnector == nil) {
        webConnector = [[WebConnector alloc] init];
        webConnector.delegate = self;
    }
    return webConnector;
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

- (void) swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture {
//    NSLog(@"foo");
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self viewControllerIsFinished];
    }
}

//delete event from core data and revert back to table
-(void)deleteButtonTouched {
    
    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"X"];
    [self showWebLoadingViews];
    // Wait for response from server
    
}

- (FacebookManager *)facebookManager {
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
        [facebookManager pullAuthenticationInfoFromDefaults];
    }
    return facebookManager;
}

-(void)shareButtonTouched {
    
    // Lets go choices
    self.shareChoiceActionSheet = [[[UIActionSheet alloc] initWithTitle:@"How would you like to share this event?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    self.shareChoiceActionSheetSelectors = [NSMutableArray array];
    BOOL moreSocialChoicesToBeHad = NO;
    // Add to calendar
    [self.shareChoiceActionSheet addButtonWithTitle:@"Send an Email"];
    [shareChoiceActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToShareViaEmail)]];
    // Create Facebook event
//    [self.facebookManager pullAuthenticationInfoFromDefaults];
//    if ([self.facebookManager.fb isSessionValid]) {
        [self.shareChoiceActionSheet addButtonWithTitle:@"Post to Facebook"];
        [shareChoiceActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToShareViaFacebook)]];
//    } else {
//        moreSocialChoicesToBeHad = YES;
//    }
    // Cancel button
    [self.shareChoiceActionSheet addButtonWithTitle:@"Cancel"];
    self.shareChoiceActionSheet.cancelButtonIndex = self.shareChoiceActionSheet.numberOfButtons - 1;
    // Title modification
    if (moreSocialChoicesToBeHad) {
        self.shareChoiceActionSheet.title = [self.shareChoiceActionSheet.title stringByAppendingString:@" Connect your social networks in the 'Settings' tab for even more options."];
    }
    // Show action sheet
    [self.shareChoiceActionSheet showFromRect:self.shareButton.frame inView:self.shareButton animated:YES];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)letsGoButtonTouched {
    
    // Send learned data to the web
    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"G"];
    
    // Lets go choices
    self.letsGoChoiceActionSheet = [[[UIActionSheet alloc] initWithTitle:@"What would you like to do with this event?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    self.letsGoChoiceActionSheetSelectors = [NSMutableArray array];
    BOOL moreSocialChoicesToBeHad = NO;
    // Add to calendar
    [self.letsGoChoiceActionSheet addButtonWithTitle:@"Add to Calendar"];
    [letsGoChoiceActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToAddToCalendar)]];
    // Create Facebook event
//    [self.facebookManager pullAuthenticationInfoFromDefaults];
//    if ([self.facebookManager.fb isSessionValid]) {
        [self.letsGoChoiceActionSheet addButtonWithTitle:@"Create Facebook Event"];
        [letsGoChoiceActionSheetSelectors addObject:[NSValue valueWithPointer:@selector(pushedToCreateFacebookEvent)]];
//    } else {
//        moreSocialChoicesToBeHad = YES;
//    }
    // Cancel button
    [self.letsGoChoiceActionSheet addButtonWithTitle:@"Cancel"];
    self.letsGoChoiceActionSheet.cancelButtonIndex = self.letsGoChoiceActionSheet.numberOfButtons - 1;
    // Title modification
    if (moreSocialChoicesToBeHad) {
        self.letsGoChoiceActionSheet.title = [self.letsGoChoiceActionSheet.title stringByAppendingString:@" Connect your social networks in the 'Settings' tab for even more options."];
    }
    // Show action sheet
    [self.letsGoChoiceActionSheet showFromRect:self.letsGoButton.frame inView:self.letsGoButton animated:YES];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.shareChoiceActionSheet ||
        actionSheet == self.letsGoChoiceActionSheet) {
        
        NSArray * actionSheetSelectors = (actionSheet == self.shareChoiceActionSheet) ? self.shareChoiceActionSheetSelectors : self.letsGoChoiceActionSheetSelectors;
        
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // Cancel button pushed...
        } else if (buttonIndex >= 0 &&
            actionSheetSelectors && 
            [actionSheetSelectors count] > buttonIndex) {
            SEL actionSheetSelector = [[actionSheetSelectors objectAtIndex:buttonIndex] pointerValue];
            [self performSelector:actionSheetSelector];
        } else {
            NSLog(@"ERROR in EventViewController - actionSheet buttonIndex does not have an associated selector");
        }
        
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized actionSheet");
    }
    
}

- (void) pushedToShareViaEmail {
    /////////////////////
    // Localytics below
    [Analytics localyticsSendShareViaEmailWithEvent:self.event];
    // Localytics above
    /////////////////////
    MFMailComposeViewController * emailViewController = [ActionsManagement makeEmailViewControllerForEvent:self.event withMailComposeDelegate:self usingWebDataTranslator:self.webDataTranslator];
    [self presentModalViewController:emailViewController animated:YES];
}

- (void) pushedToShareViaFacebook {
    NSLog(@"Pushed to share via Facebook");
    [self.facebookManager pullAuthenticationInfoFromDefaults];
    if ([self.facebookManager.fb isSessionValid]) {
        /////////////////////
        // Localytics below
        [Analytics localyticsSendShareViaFacebookWithEvent:self.event];
        // Localytics above
        /////////////////////
        [self.facebookManager postToFacebookWallWithEvent:self.event];
    } else {
        UIAlertView * facebookNotConnectedAlertView = [[UIAlertView alloc] initWithTitle:@"Facebook Not Connected" message:@"Please go to the 'Settings' tab and connect Facebook to your Kwiqet account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [facebookNotConnectedAlertView show];
        [facebookNotConnectedAlertView release];
    }
}

- (void) pushedToAddToCalendar {
    /////////////////////
    // Localytics below
    [Analytics localyticsSendLetsGoAddToCalendarWithEvent:self.event];
    // Localytics above
    /////////////////////
    // Add to calendar
    [ActionsManagement addEventToCalendar:self.event usingWebDataTranslator:self.webDataTranslator];
    // Show confirmation alert
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];

}

- (void) pushedToCreateFacebookEvent {
    NSLog(@"Pushed to create Facebook event");
    [self.facebookManager pullAuthenticationInfoFromDefaults];
    if ([self.facebookManager.fb isSessionValid]) {
        /////////////////////
        // Localytics below
        [Analytics localyticsSendLetsGoCreateFacebookEventWithEvent:self.event];
        // Localytics above
        /////////////////////
        ContactsSelectViewController * contactsSelectViewController = [[ContactsSelectViewController alloc] initWithNibName:@"ContactsSelectViewController" bundle:[NSBundle mainBundle]];
        //            contactsSelectViewController.contactsAll = [self.coreDataModel getAllFacebookContacts];
        contactsSelectViewController.delegate = self;
        contactsSelectViewController.coreDataModel = self.coreDataModel;
        [self presentModalViewController:contactsSelectViewController animated:YES];
        [contactsSelectViewController release];
    } else {
        UIAlertView * facebookNotConnectedAlertView = [[UIAlertView alloc] initWithTitle:@"Facebook Not Connected" message:@"Please go to the 'Settings' tab and connect Facebook to your Kwiqet account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [facebookNotConnectedAlertView show];
        [facebookNotConnectedAlertView release];
    }
}

- (void)contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts {
    if (!didCancel) {
        NSMutableDictionary * parameters = [ActionsManagement makeFacebookEventParametersFromEvent:self.event eventImage:self.imageView.image];
        [self.facebookManager createFacebookEventWithParameters:parameters inviteContacts:selectedContacts];
        [self showWebLoadingViews];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void) facebookEventCreateSuccess:(NSNotification *)notification {
    if (self.view.window) {
        // Wait until after facebook invites...
    }
}
- (void) facebookEventCreateFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"Something went wrong while trying to create an event on Facebook. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebLoadingViews];
    }
}
- (void) facebookEventInviteSuccess:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Event Created" message:@"We successfully created your Facebook event, and invited your selected friends. Have fun at the event!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebLoadingViews];
    }
}
- (void) facebookEventInviteFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"We created your Facebook event no problem, but an error occurred while inviting your friends. You should probably check things over on Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
        [self hideWebLoadingViews];
    }
}

- (void)facebookAuthFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"Something appears to have gone wrong with your Facebook connection. Please go to settings and try reconnecting - that should fix the problem." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebLoadingViews];
    }
}


- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
            
    if ([userAction isEqualToString:@"G"]) {
        
        // Currently, we delete the event if the user "went". THIS IS CONFUSING. We are changing this functionality.
        //deletedEventDueToGoingToEvent = YES;
        //[self.coreDataModel deleteRegularEventForURI:[self.eventDictionary objectForKey:@"resource_uri"]]; // This makes me uneasy deleting it here... But, we're not dealing with this right now.
        
    } else if ([userAction isEqualToString:@"X"]) {
        
        // We're done here, let our delegate know that we are finished, and that we ended by requesting to delete the event. Leave the actual event object deletion up to the delegate though.
        [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:YES eventURI:self.event.uri];
        
    }
    
    [self hideWebLoadingViews];
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"G"]) {
        //[self.connectionErrorOnUserActionRequestAlertView show]; // I'm taking this alert view out for now. We should definitely be saving this lost learning in some sort of cache and sending it up to the server at another time, but even though we are not doing that yet, there is still no reason to display an annoying popup to the user.
    } else if ([userAction isEqualToString:@"X"]) {
        [self.connectionErrorOnUserActionRequestAlertView show];
    }
    
    [self hideWebLoadingViews];
    
}

// make Phone number clickable..
-(void)phoneButtonTouched {
	NSLog(@"phone call");
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [self.event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", firstOccurrence.place.phone]]];
}

-(void)mapButtonTouched {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [self.event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    self.mapViewController.locationLatitude = firstOccurrence.place.latitude;
    self.mapViewController.locationLongitude = firstOccurrence.place.longitude;
    self.mapViewController.locationName = firstOccurrence.place.title;
    self.mapViewController.locationAddress = firstOccurrence.place.address;
    [self presentModalViewController:self.mapViewController animated:YES];
}

- (void)mapViewControllerDidPushBackButton:(MapViewController *)mapViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.mapViewController = nil;
}

- (void) backButtonTouched  {
    [self viewControllerIsFinished];
}

- (void) logoButtonTouched {
    [self viewControllerIsFinished];
}

- (void) viewControllerIsFinished {
    [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:deletedEventDueToGoingToEvent eventURI:self.event.uri];
}

- (void) occurrenceInfoRetryButtonTouched {
    [self.webConnector getAllOccurrencesForEventWithURI:self.event.uri];
    [self.occurrenceInfoPlaceholderRetryButton setTitle:EVC_OCCURRENCE_INFO_LOADING_STRING forState:UIControlStateNormal];
}

- (UIAlertView *)connectionErrorOnUserActionRequestAlertView {
    if (connectionErrorOnUserActionRequestAlertView == nil) {
        connectionErrorOnUserActionRequestAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry, due to a connection error, we could not complete your request. Please check your settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorOnUserActionRequestAlertView;
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {

    if (theScrollView == self.scrollView) {
        CGRect titleBarFrame = self.titleBar.frame;
        titleBarFrame.origin.y = MAX(0, self.scrollView.contentOffset.y);
        self.titleBar.frame = titleBarFrame;
    }
    
}

#pragma mark memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end