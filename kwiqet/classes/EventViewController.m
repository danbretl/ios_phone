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
#import "OccurrenceDateCell.h"

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
@property (retain) UIView * shadowTitleBar;
@property (retain) IBOutlet UIImageView * imageView;
@property (retain) IBOutlet UIView * breadcrumbsBar;
@property (retain) IBOutlet UILabel * breadcrumbsLabel;
@property (retain) IBOutlet UIView   * occurrenceInfoContainer;
@property CGFloat occurrenceInfoContainerRegularHeight;
@property CGFloat occurrenceInfoContainerCollapsedHeight;
@property (retain) IBOutlet UIView   * occurrenceInfoPlaceholderView;
@property (retain) IBOutlet UIButton * occurrenceInfoPlaceholderRetryButton;
@property (retain) IBOutlet UIView   * dateContainer;
@property (retain) IBOutlet UIButton * dateOccurrenceInfoButton;
@property (retain) IBOutlet UILabel  * monthLabel;
@property (retain) IBOutlet UILabel  * dayNumberLabel;
@property (retain) IBOutlet UILabel  * dayNameLabel;
@property (retain) IBOutlet UIView   * timeContainer;
@property (retain) IBOutlet UILabel  * timeLabel;
@property (retain) IBOutlet UIButton * timeOccurrenceInfoButton;
@property (retain) IBOutlet UIView   * priceContainer;
@property (retain) IBOutlet UIButton * priceOccurrenceInfoButton;
@property (retain) IBOutlet UILabel  * priceLabel;
@property (retain) IBOutlet UIView   * locationContainer;
@property (retain) IBOutlet UIButton * locationOccurrenceInfoButton;
@property (retain) IBOutlet UILabel  * venueLabel;
@property (retain) IBOutlet UILabel  * addressLabel;
@property (retain) IBOutlet UILabel  * cityStateZipLabel;
@property (retain) IBOutlet UIButton * phoneNumberButton;
@property (retain) IBOutlet UIButton * mapButton;
@property (retain) IBOutlet UIView   * descriptionContainer;
@property (retain) IBOutlet UIView   * descriptionBackgroundColorView;
@property (retain) IBOutlet UILabel  * descriptionLabel;
@property (retain) UIView * shadowDescriptionContainer;
@property (retain) UIView * darkOverlayViewForMainView;
@property (retain) UIView * darkOverlayViewForScrollView;
@property (retain) UISwipeGestureRecognizer * swipeToPullInOccurrencesControls;
@property (retain) UISwipeGestureRecognizer * swipeToPushOutOccurrencesControls;
@property (retain) UITapGestureRecognizer * tapToPullInOccurrencesControls;
@property BOOL occurrencesControlsVisible;
@property (retain) IBOutlet UIView * occurrencesControlsContainer;
@property (retain) IBOutlet UIView * occurrencesControlsNavBar;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewContainer;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewOverlay;
@property (retain) IBOutlet UIView * occurrencesControlsDatesVenuesTableViewContainer;
@property (retain) IBOutlet UITableView * occurrencesControlsDatesTableView;
@property (retain) IBOutlet UITableView * occurrencesControlsVenuesTableView;
@property (retain) IBOutlet UIView * occurrencesControlsTimesTableViewContainer;
@property (retain) IBOutlet UITableView * occurrencesControlsTimesTableView;
@property (nonatomic, retain) WebActivityView * webActivityView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnUserActionRequestAlertView;
@property (retain) UIActionSheet  * letsGoChoiceActionSheet;
@property (retain) NSMutableArray * letsGoChoiceActionSheetSelectors;
@property (retain) UIActionSheet  * shareChoiceActionSheet;
@property (retain) NSMutableArray * shareChoiceActionSheetSelectors;

- (IBAction) backButtonTouched;
- (IBAction) logoButtonTouched;
- (IBAction) letsGoButtonTouched;
- (IBAction) shareButtonTouched;
- (IBAction) deleteButtonTouched;
- (IBAction) phoneButtonTouched;
- (IBAction) mapButtonTouched;
- (IBAction) occurrenceInfoRetryButtonTouched;
- (IBAction) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton;
- (void) swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipedToPullInOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture;
- (void) tappedToPullInOccurrencesControls:(UITapGestureRecognizer *)tapGesture;
- (void) userActionOccurredToPullInOccurrencesControls:(UIGestureRecognizer *)gesture horizontalForgiveness:(CGFloat)horizontalForgiveness;
- (void) swipedToPushOutOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture;
- (void) toggleOccurrencesControls;
- (void) displayImage:(UIImage *)image;
- (void) pushedToAddToCalendar;
- (void) pushedToCreateFacebookEvent;
- (void) pushedToShareViaEmail;
- (void) pushedToShareViaFacebook;
- (void) setOccurrenceInfoContainerIsVisible:(BOOL)isVisible animated:(BOOL)animated;
- (void) facebookEventCreateSuccess:(NSNotification *)notification;
- (void) facebookEventCreateFailure:(NSNotification *)notification;
- (void) facebookEventInviteSuccess:(NSNotification *)notification;
- (void) facebookEventInviteFailure:(NSNotification *)notification;
- (void) facebookAuthFailure:(NSNotification *)notification;

@end

@implementation EventViewController

@synthesize backgroundColorView, navigationBar, backButton, logoButton, actionBar, letsGoButton, shareButton, deleteButton, scrollView, titleBar, shadowTitleBar, imageView, breadcrumbsBar, breadcrumbsLabel, occurrenceInfoContainer, occurrenceInfoContainerRegularHeight, occurrenceInfoContainerCollapsedHeight, occurrenceInfoPlaceholderView, occurrenceInfoPlaceholderRetryButton, dateContainer, dateOccurrenceInfoButton, monthLabel, dayNumberLabel, dayNameLabel, timeContainer, timeOccurrenceInfoButton, timeLabel, priceContainer, priceOccurrenceInfoButton, priceLabel, locationContainer, locationOccurrenceInfoButton, venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton, descriptionContainer, descriptionBackgroundColorView, descriptionLabel, shadowDescriptionContainer;
@synthesize darkOverlayViewForMainView, darkOverlayViewForScrollView;
@synthesize swipeToPullInOccurrencesControls, swipeToPushOutOccurrencesControls, tapToPullInOccurrencesControls;
@synthesize occurrencesControlsVisible;
@synthesize occurrencesControlsContainer, occurrencesControlsNavBar, occurrencesControlsTableViewContainer, occurrencesControlsTableViewOverlay, occurrencesControlsDatesVenuesTableViewContainer, occurrencesControlsDatesTableView, occurrencesControlsVenuesTableView, occurrencesControlsTimesTableViewContainer, occurrencesControlsTimesTableView;

@synthesize event;
@synthesize webActivityView;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;
@synthesize facebookManager;
@synthesize letsGoChoiceActionSheet, letsGoChoiceActionSheetSelectors, shareChoiceActionSheet, shareChoiceActionSheetSelectors;
@synthesize deleteAllowed=deleteAllowed_;

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
    [shadowTitleBar release];
    [imageView release];
    [breadcrumbsBar release];
    [breadcrumbsLabel release];
    [occurrenceInfoContainer release];
    [occurrenceInfoPlaceholderView release];
    [occurrenceInfoPlaceholderRetryButton release];
    [dateContainer release];
    [dateOccurrenceInfoButton release];
    [monthLabel release];
    [dayNumberLabel release];
    [dayNameLabel release];
    [timeContainer release];
    [timeOccurrenceInfoButton release];
    [timeLabel release];
    [priceContainer release];
    [priceOccurrenceInfoButton release];
    [priceLabel release];
    [locationContainer release];
    [locationOccurrenceInfoButton release];
    [venueLabel release];
    [addressLabel release];
    [cityStateZipLabel release];
    [phoneNumberButton release];
    [mapButton release];
    [descriptionContainer release];
    [descriptionBackgroundColorView release];
    [descriptionLabel release];
    [shadowDescriptionContainer release];
    [darkOverlayViewForMainView release];
    [darkOverlayViewForScrollView release];
    [occurrencesControlsContainer release];
    [occurrencesControlsNavBar release];
    [occurrencesControlsTableViewContainer release]; 
    [occurrencesControlsTableViewOverlay release];
    [occurrencesControlsDatesVenuesTableViewContainer release];
    [occurrencesControlsDatesTableView release];
    [occurrencesControlsVenuesTableView release];
    [occurrencesControlsTimesTableViewContainer release];
    [occurrencesControlsTimesTableView release];
    [swipeToPullInOccurrencesControls release];
    [swipeToPushOutOccurrencesControls release];
    [tapToPullInOccurrencesControls release];
    [event release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release];
    [webDataTranslator release];
    [facebookManager release];
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
        self.deleteAllowed = YES;
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
    // Delete button
    self.deleteButton.enabled = self.deleteAllowed;
    
    // Title bar shadow
    shadowTitleBar = [[UIView alloc] initWithFrame:
                      CGRectMake(self.titleBar.frame.origin.x, 
                                 self.titleBar.frame.origin.y+1, 
                                 self.titleBar.frame.size.width, 
                                 self.titleBar.frame.size.height-2)];
    self.shadowTitleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.shadowTitleBar.backgroundColor = [UIColor blackColor];
    self.shadowTitleBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowTitleBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowTitleBar.layer.shadowOpacity = 0.55;
    self.shadowTitleBar.layer.shouldRasterize = YES;
    [self.scrollView insertSubview:self.shadowTitleBar belowSubview:self.titleBar];
    
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
    swipeToGoBack.direction = UISwipeGestureRecognizerDirectionRight;
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
    [self.occurrenceInfoPlaceholderRetryButton setTitle:EVC_OCCURRENCE_INFO_LOADING_STRING forState:UIControlStateNormal];
    
    // Date views
    self.monthLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.dayNumberLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:33];
    self.dayNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];

    // Time views
    self.timeLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    // Price views
    self.priceOccurrenceInfoButton.enabled = NO;
    self.priceLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                
    // Location views
    self.venueLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:22];
    self.addressLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.cityStateZipLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    // Phone number button
    self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:12];
    
    // Occurrences controls
    [self.scrollView insertSubview:self.occurrencesControlsContainer belowSubview:self.titleBar];
    self.occurrencesControlsContainer.frame = CGRectMake(self.scrollView.bounds.size.width - 16, CGRectGetMaxY(self.occurrenceInfoContainer.frame) - self.occurrencesControlsContainer.frame.size.height, self.occurrencesControlsContainer.frame.size.width, self.occurrencesControlsContainer.frame.size.height);
    self.occurrencesControlsContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"occurrences_mockup_shape.png"]];
    self.occurrencesControlsContainer.opaque = NO;
    self.occurrencesControlsContainer.layer.opaque = NO;
    self.occurrencesControlsTableViewOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"occurrences_controls_table_view_overlay.png"]];
    self.occurrencesControlsTableViewOverlay.opaque = NO;
    self.occurrencesControlsTableViewOverlay.layer.opaque = NO;
    [self.occurrencesControlsTableViewContainer insertSubview:self.occurrencesControlsDatesVenuesTableViewContainer belowSubview:self.occurrencesControlsTableViewOverlay];
    self.occurrencesControlsDatesVenuesTableViewContainer.frame = self.occurrencesControlsTableViewContainer.bounds;
    [self.occurrencesControlsDatesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    // Occurrences controls gesture recognizers
    // Swipe to pull in
    swipeToPullInOccurrencesControls = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToPullInOccurrencesControls:)];
    self.swipeToPullInOccurrencesControls.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.scrollView addGestureRecognizer:self.swipeToPullInOccurrencesControls];
    // Swipe to push out
    swipeToPushOutOccurrencesControls = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToPushOutOccurrencesControls:)];
    self.swipeToPushOutOccurrencesControls.direction = UISwipeGestureRecognizerDirectionRight;
    [self.occurrencesControlsContainer addGestureRecognizer:self.swipeToPushOutOccurrencesControls];
    // Tap to pull in
    tapToPullInOccurrencesControls = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToPullInOccurrencesControls:)];
    self.tapToPullInOccurrencesControls.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:self.tapToPullInOccurrencesControls];
    
    // Dark overlay views for when occurrence controls are showing
    // To be subview of main view (above everything else)
    darkOverlayViewForMainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetMaxY(self.actionBar.frame) + self.titleBar.bounds.size.height)];
    self.darkOverlayViewForMainView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    self.darkOverlayViewForMainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.darkOverlayViewForMainView.alpha = 0.0;
    [self.view insertSubview:self.darkOverlayViewForMainView aboveSubview:self.scrollView];
    // To be subview of scroll view (just below occurrencesControlsContainer)
    darkOverlayViewForScrollView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.darkOverlayViewForScrollView.backgroundColor = self.darkOverlayViewForMainView.backgroundColor;
    self.darkOverlayViewForScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.darkOverlayViewForScrollView.alpha = 0.0;
    [self.scrollView insertSubview:self.darkOverlayViewForScrollView belowSubview:self.occurrencesControlsContainer];
    
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

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touches");
//}

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

- (void)setDeleteAllowed:(BOOL)deleteAllowed {
    deleteAllowed_ = deleteAllowed;
    self.deleteButton.enabled = self.deleteAllowed;
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {

    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * responseDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    [self.coreDataModel updateEvent:self.event withExhaustiveOccurrencesArray:[responseDictionary valueForKey:@"objects"]];
    [self.coreDataModel coreDataSave];
    [self updateViewsFromDataAnimated:YES];
    if ([[[responseDictionary objectForKey:@"meta"] valueForKey:@"total_count"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [self.occurrenceInfoPlaceholderRetryButton setTitle:@"There are no occurrences for this event!" forState:UIControlStateNormal];
    }
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
        
        self.dateOccurrenceInfoButton.enabled = [self.event occurrencesNotOnDate:firstOccurrence.startDate].count > 0;
        self.locationOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:firstOccurrence.startDate notAtPlace:firstOccurrence.place].count > 0;
        self.timeOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:firstOccurrence.startDate atPlace:firstOccurrence.place notAtTime:firstOccurrence.startTime].count > 0;
        self.occurrencesControlsContainer.hidden = !(self.dateOccurrenceInfoButton.enabled || self.locationOccurrenceInfoButton.enabled || self.timeOccurrenceInfoButton.enabled);
        self.swipeToPullInOccurrencesControls.enabled = !self.occurrencesControlsContainer.hidden;
        self.swipeToPushOutOccurrencesControls.enabled = self.swipeToPullInOccurrencesControls.enabled;
        self.tapToPullInOccurrencesControls.enabled = self.swipeToPullInOccurrencesControls.enabled && !self.occurrencesControlsVisible;
        [self.occurrencesControlsDatesTableView reloadData];
        [self.occurrencesControlsVenuesTableView reloadData];
        [self.occurrencesControlsTimesTableView reloadData];
        
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
        
        self.dateOccurrenceInfoButton.enabled = NO;
        self.locationOccurrenceInfoButton.enabled = NO;
        self.timeOccurrenceInfoButton.enabled = NO;
        self.occurrencesControlsContainer.hidden = YES;
        
    }
    
    // Adjust the scroll view scroll indicator insets for the occurrences controls
    UIEdgeInsets scrollViewScrollIndicatorInsets = self.scrollView.scrollIndicatorInsets;
    scrollViewScrollIndicatorInsets.bottom = self.occurrencesControlsContainer.hidden ? 0 : self.occurrencesControlsContainer.frame.size.height + (self.scrollView.bounds.size.height - CGRectGetMaxY(self.occurrencesControlsContainer.frame)) - 40;// * 2;
    self.scrollView.scrollIndicatorInsets = scrollViewScrollIndicatorInsets;
    
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

    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.descriptionContainer.frame));
    
    // Breadcrumbs
    NSMutableString * breadcrumbsString = [[self.event.concreteParentCategory.title mutableCopy] autorelease];
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

- (void)displayImage:(UIImage *)image {
    //NSLog(@"image is %f by %f", image.size.width, image.size.height);
    NSLog(@"EventViewController displayImage:%@ (%fx%f)", image, image.size.width, image.size.height);
	[self.imageView setImage:image];
//    [self.scrollView bringSubviewToFront:self.titleBar];
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
    [self viewControllerIsFinished];
}

- (void) swipedToPullInOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipedToPullInOccurrencesControls");
    [self userActionOccurredToPullInOccurrencesControls:swipeGesture horizontalForgiveness:30];
}

- (void) tappedToPullInOccurrencesControls:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"tappedToPullInOccurrencesControls");
    CGRect mapButtonFrameInScrollView = [self.scrollView convertRect:self.mapButton.frame fromView:self.mapButton.superview]; // THIS ASSUMES THAT THE MAP BUTTON IS THE RIGHTMOST BUTTON IN OUR VIEW.
    NSLog(@"%@, %f", NSStringFromCGRect(mapButtonFrameInScrollView), CGRectGetMinX(self.occurrencesControlsContainer.frame) - CGRectGetMaxX(mapButtonFrameInScrollView));
    [self userActionOccurredToPullInOccurrencesControls:tapGesture horizontalForgiveness:CGRectGetMinX(self.occurrencesControlsContainer.frame) - CGRectGetMaxX(mapButtonFrameInScrollView)];
}

- (void) userActionOccurredToPullInOccurrencesControls:(UIGestureRecognizer *)gesture horizontalForgiveness:(CGFloat)horizontalForgiveness {
    CGPoint location = [gesture locationInView:self.scrollView];
    NSLog(@"userActionOccurredToPullInOccurrencesControls PROPOSED - %@ in %@", NSStringFromCGPoint(location), NSStringFromCGRect(CGRectMake(CGRectGetMinX(self.occurrencesControlsContainer.frame) - horizontalForgiveness, self.occurrencesControlsContainer.frame.origin.y + 40, horizontalForgiveness + (self.occurrencesControlsContainer.superview.bounds.size.width - CGRectGetMinX(self.occurrencesControlsContainer.frame)), self.occurrencesControlsContainer.frame.size.height - 40 - 5)));
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(self.occurrencesControlsContainer.frame) - horizontalForgiveness, 
                                       self.occurrencesControlsContainer.frame.origin.y + 40, 
                                       horizontalForgiveness + (self.occurrencesControlsContainer.superview.bounds.size.width - CGRectGetMinX(self.occurrencesControlsContainer.frame)), 
                                       self.occurrencesControlsContainer.frame.size.height - 40 - 5), location) &&
        !self.occurrencesControlsVisible) {
        NSLog(@"userActionOccurredToPullInOccurrencesControls ACCEPTED - %@ in %@", NSStringFromCGPoint(location), NSStringFromCGRect(CGRectMake(CGRectGetMinX(self.occurrencesControlsContainer.frame) - horizontalForgiveness, self.occurrencesControlsContainer.frame.origin.y + 40, horizontalForgiveness + (self.occurrencesControlsContainer.superview.bounds.size.width - CGRectGetMinX(self.occurrencesControlsContainer.frame)), self.occurrencesControlsContainer.frame.size.height - 40 - 5)));
        [self toggleOccurrencesControls];
    }
}


- (void) swipedToPushOutOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipedToPushOutOccurrencesControls");
    if (self.occurrencesControlsVisible) {
        [self toggleOccurrencesControls];
    }
}


- (void) toggleOccurrencesControls {
    NSLog(@"toggleOccurrencesControls - switch visible from %d to %d", self.occurrencesControlsVisible, !self.occurrencesControlsVisible);
    self.occurrencesControlsVisible = !self.occurrencesControlsVisible;
    self.scrollView.scrollEnabled = !self.occurrencesControlsVisible;
    self.tapToPullInOccurrencesControls.enabled = !self.occurrencesControlsVisible;
    self.darkOverlayViewForScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.titleBar.frame), self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        if (self.occurrencesControlsVisible) {
            occurrencesControlsContainerFrame.origin.x = -16;
            self.darkOverlayViewForMainView.alpha = 1.0;
            self.darkOverlayViewForScrollView.alpha = 1.0;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        } else {
            occurrencesControlsContainerFrame.origin.x = self.scrollView.bounds.size.width - 16;
            self.darkOverlayViewForMainView.alpha = 0.0;
            self.darkOverlayViewForScrollView.alpha = 0.0;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        }
        self.occurrencesControlsContainer.frame = occurrencesControlsContainerFrame;
    } completion:^(BOOL finished){}];
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

- (void) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton {
    [self toggleOccurrencesControls];
}

- (UIAlertView *)connectionErrorOnUserActionRequestAlertView {
    if (connectionErrorOnUserActionRequestAlertView == nil) {
        connectionErrorOnUserActionRequestAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry, due to a connection error, we could not complete your request. Please check your settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorOnUserActionRequestAlertView;
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {
    
    if (theScrollView == self.scrollView) {
        // Adjust title bar frame
        CGRect titleBarFrame = self.titleBar.frame;
        titleBarFrame.origin.y = MAX(0, self.scrollView.contentOffset.y);
        self.titleBar.frame = titleBarFrame;
        // Adjust shadow title bar frame
        CGRect shadowTitleBarFrame = self.shadowTitleBar.frame;
        shadowTitleBarFrame.origin.y = titleBarFrame.origin.y + 1;
        self.shadowTitleBar.frame = shadowTitleBarFrame;        
//        CGRect titleBarFrame = self.titleBar.frame;
//        titleBarFrame.origin.y = CGRectGetMaxY(self.actionBar.frame) - MIN(0, self.scrollView.contentOffset.y);
//        self.titleBar.frame = titleBarFrame;
//        CGRect shadowTitleBarFrame = self.shadowTitleBar.frame;
//        shadowTitleBarFrame.origin.y = titleBarFrame.origin.y + 1;
//        self.shadowTitleBar.frame = shadowTitleBarFrame;
        // Adjust occurrences controls frame
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        occurrencesControlsContainerFrame.origin.y = CGRectGetMaxY(self.occurrenceInfoContainer.frame) - self.occurrencesControlsContainer.frame.size.height + self.scrollView.contentOffset.y;
        self.occurrencesControlsContainer.frame = occurrencesControlsContainerFrame;
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

#pragma mark tableViews

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    if (tableView == self.occurrencesControlsDatesTableView) {
        NSLog(@"About to try");
        NSArray * dates = [self.coreDataModel getDistinctOccurrenceDatesForEvent:self.event];
        if (dates && dates.count > 0) {
            rowCount = dates.count;
        } else {
            rowCount = 1;
        }
        NSLog(@"Row count is %d", rowCount);
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        rowCount = 10;
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        rowCount = 10;
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * tableViewCell = nil;
    NSString * CellIdentifier = @"OccurrenceInfoGenericCell";
    Class TableViewCellClass = [UITableViewCell class];
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        CellIdentifier = @"OccurrenceDateCell";
        TableViewCellClass = [OccurrenceDateCell class];
        
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        // ...
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        // ...
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    tableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[[TableViewCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        NSArray * dates = [self.coreDataModel getDistinctOccurrenceDatesForEvent:self.event];
        if (dates && dates.count > 0) {
            Occurrence * occurrence = (Occurrence *)[dates objectAtIndex:indexPath.row];
            OccurrenceDateCell * tableViewCellCast = (OccurrenceDateCell *)tableViewCell;
            tableViewCellCast.date = occurrence.startDate;
        }
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        tableViewCell.textLabel.text = [NSString stringWithFormat:@"Loc%d%d", indexPath.section, indexPath.row];
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        tableViewCell.textLabel.text = [NSString stringWithFormat:@"Time%d%d", indexPath.section, indexPath.row];
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    return tableViewCell;
    
}

@end