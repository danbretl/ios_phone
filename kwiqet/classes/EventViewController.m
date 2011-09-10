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
#import "OccurrenceVenueCell.h"
#import "OccurrenceTimeCell.h"
#import "OccurrenceSummaryDate.h"
#import "OccurrenceSummaryVenue.h"
#import "UIFont+Kwiqet.h"

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
@property (retain) UIView * shadowOccurrenceInfoContainer;
@property (retain) OccurrenceInfoOverlayView * occurrenceInfoOverlayView;
@property (retain) IBOutlet UIView   * dateContainer;
@property (retain) IBOutlet UIButton * dateOccurrenceInfoButton;
@property (retain) IBOutlet UILabel  * monthLabel;
@property (retain) IBOutlet UILabel  * dayNumberLabel;
@property (retain) IBOutlet UILabel  * dayNameLabel;
@property (retain) IBOutlet UIView   * timeContainer;
@property (retain) IBOutlet UILabel  * timeStartLabel;
@property (retain) IBOutlet UILabel  * timeEndLabel;
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
@property (retain) IBOutlet UIImageView * occurrencesControlsHandleImageView;
@property (retain) IBOutlet UIView * occurrencesControlsNavBar;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewContainer;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewOverlay;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewsContainer;
@property (retain) IBOutlet UITableView * occurrencesControlsDatesTableView;
@property (retain) IBOutlet UITableView * occurrencesControlsVenuesTableView;
@property (retain) IBOutlet UIView * occurrencesControlsDatesVenuesSeparatorView;
@property (retain) IBOutlet UIView * occurrencesControlsVenuesTimesSeparatorView;
@property (retain) IBOutlet UITableView * occurrencesControlsTimesTableView;

@property (retain) NSMutableArray * eventOccurrencesSummaryArray;
@property (retain) Occurrence * eventOccurrenceCurrent;
@property int eventOccurrenceCurrentDateIndex;
@property int eventOccurrenceCurrentVenueIndex;
@property int eventOccurrenceCurrentTimeIndex;

@property (nonatomic, retain) WebActivityView * webActivityView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) NSDateFormatter * occurrenceTimeFormatter;
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
- (void) occurrenceInfoRetryButtonTouched;
- (IBAction) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton;
- (void) setOccurrencesControlsToShowTableView:(UITableView *)tableView animated:(BOOL)animated;
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
- (void) processOccurrencesFromEvent:(Event *)theEvent;
- (void) reloadOccurrencesTableViews;
- (void) updateOccurrenceInfoViewsFromDataAnimated:(BOOL)animated;
- (NSString *) debugOccurrencesTableViewNameForTableViewTag:(int)tag;
- (void) setTimeLabelTextToTimeString:(NSString *)timeLabelString containsTwoTimes:(BOOL)doesContainTwoTimes usingSeparatorString:(NSString *)separatorString;
- (void) setOccurrenceInfoContainerIsVisible:(BOOL)isVisible animated:(BOOL)animated;
@property (nonatomic, readonly) OccurrenceSummaryDate * eventOccurrenceCurrentDateSummaryObject;
@property (nonatomic, readonly) OccurrenceSummaryVenue * eventOccurrenceCurrentVenueSummaryObject;
- (NSUInteger) indexOfDate:(NSDate *)date inSummaryDates:(NSArray *)arrayOfSummaryDates; // Returns the index of summary date matching the given date. If a match does not exist, returns NSNotFound.
- (NSUInteger) indexOfPlace:(Place *)place inSummaryVenues:(NSArray *)arrayOfSummaryVenues; // Returns the index of summary venue matching the given place. If a match does not exist, returns NSNotFound.
- (NSUInteger) indexOfTime:(NSDate *)time inOccurrences:(NSArray *)arrayOfOccurrences settleForClosestFit:(BOOL)shouldSettleForClosestFit; // Returns the index of occurrence with startTime matching the given time. If there is no occurrence that matches the given time, then this method will (depending on given BOOL parameter) either return NSNotFound or the index of the best fit occurrence.
- (void) facebookEventCreateSuccess:(NSNotification *)notification;
- (void) facebookEventCreateFailure:(NSNotification *)notification;
- (void) facebookEventInviteSuccess:(NSNotification *)notification;
- (void) facebookEventInviteFailure:(NSNotification *)notification;
- (void) facebookAuthFailure:(NSNotification *)notification;

@end

@implementation EventViewController

@synthesize backgroundColorView, navigationBar, backButton, logoButton, actionBar, letsGoButton, shareButton, deleteButton, scrollView, titleBar, shadowTitleBar, imageView, breadcrumbsBar, breadcrumbsLabel, occurrenceInfoContainer, shadowOccurrenceInfoContainer, occurrenceInfoOverlayView, dateContainer, dateOccurrenceInfoButton, monthLabel, dayNumberLabel, dayNameLabel, timeContainer, timeOccurrenceInfoButton, timeStartLabel, timeEndLabel, priceContainer, priceOccurrenceInfoButton, priceLabel, locationContainer, locationOccurrenceInfoButton, venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton, descriptionContainer, descriptionBackgroundColorView, descriptionLabel, shadowDescriptionContainer;
@synthesize darkOverlayViewForMainView, darkOverlayViewForScrollView;
@synthesize swipeToPullInOccurrencesControls, swipeToPushOutOccurrencesControls, tapToPullInOccurrencesControls;
@synthesize occurrencesControlsVisible;
@synthesize occurrencesControlsContainer, occurrencesControlsHandleImageView, occurrencesControlsNavBar, occurrencesControlsTableViewContainer, occurrencesControlsTableViewOverlay, occurrencesControlsTableViewsContainer, occurrencesControlsDatesTableView, occurrencesControlsVenuesTableView, occurrencesControlsDatesVenuesSeparatorView, occurrencesControlsVenuesTimesSeparatorView, occurrencesControlsTimesTableView;

@synthesize event;
@synthesize eventOccurrenceCurrent;
@synthesize eventOccurrenceCurrentDateIndex, eventOccurrenceCurrentVenueIndex, eventOccurrenceCurrentTimeIndex;
@synthesize eventOccurrencesSummaryArray;
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
    [shadowOccurrenceInfoContainer release];
    [occurrenceInfoOverlayView release];
    [dateContainer release];
    [dateOccurrenceInfoButton release];
    [monthLabel release];
    [dayNumberLabel release];
    [dayNameLabel release];
    [timeContainer release];
    [timeOccurrenceInfoButton release];
    [timeStartLabel release];
    [timeEndLabel release];
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
    [occurrencesControlsHandleImageView release];
    [occurrencesControlsNavBar release];
    [occurrencesControlsTableViewContainer release]; 
    [occurrencesControlsTableViewOverlay release];
    [occurrencesControlsTableViewsContainer release];
    [occurrencesControlsDatesTableView release];
    [occurrencesControlsVenuesTableView release];
    [occurrencesControlsDatesVenuesSeparatorView release];
    [occurrencesControlsVenuesTimesSeparatorView release];
    [occurrencesControlsTimesTableView release];
    [swipeToPullInOccurrencesControls release];
    [swipeToPushOutOccurrencesControls release];
    [tapToPullInOccurrencesControls release];
    [event release];
    [eventOccurrenceCurrent release];
    [eventOccurrencesSummaryArray release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release];
    [webDataTranslator release];
    [occurrenceTimeFormatter release];
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
        self.deleteAllowed = YES;
        self.eventOccurrencesSummaryArray = [NSMutableArray array];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cardbg.png"]];
    
    // Navigation bar
    self.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
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
    
    // Breadcrumbs bar
    self.breadcrumbsLabel.font = [UIFont kwiqetFontOfType:RegularNormal size:12];
    
    // Occurrence info container
    occurrenceInfoOverlayView = [[OccurrenceInfoOverlayView alloc] initWithFrame:CGRectMake(5, 5, self.occurrenceInfoContainer.bounds.size.width - 5 * 2, self.dateContainer.bounds.size.height - 5 * 2)];
    self.occurrenceInfoOverlayView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.occurrenceInfoContainer addSubview:self.occurrenceInfoOverlayView];
    [self.occurrenceInfoOverlayView.button addTarget:self action:@selector(occurrenceInfoRetryButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self setOccurrenceInfoContainerIsVisible:YES animated:NO];
    
    // Occurrence info container shadow
    shadowOccurrenceInfoContainer = [[UIView alloc] initWithFrame:
                                     CGRectMake(0, 1, self.occurrenceInfoContainer.bounds.size.width, self.occurrenceInfoContainer.bounds.size.height - 1 - 1)];
    self.shadowOccurrenceInfoContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.shadowOccurrenceInfoContainer.backgroundColor = [UIColor blackColor];
    self.shadowOccurrenceInfoContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowOccurrenceInfoContainer.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowOccurrenceInfoContainer.layer.shadowOpacity = 0.55;
    self.shadowOccurrenceInfoContainer.layer.shouldRasterize = YES;
    [self.occurrenceInfoContainer insertSubview:self.shadowOccurrenceInfoContainer atIndex:0];
    
    // Date views
    self.monthLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:10];
    self.dayNumberLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:30];
    self.dayNameLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:10];

    // Time views
    self.timeStartLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:24];
    self.timeEndLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:10];
    
    // Price views
    self.priceOccurrenceInfoButton.enabled = NO;
    self.priceLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:24];
                
    // Location views
    self.venueLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:21];
    self.addressLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    
    // Phone number button
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    // Occurrences controls
    [self.scrollView insertSubview:self.occurrencesControlsContainer belowSubview:self.titleBar];
    self.occurrencesControlsContainer.frame = CGRectMake(self.scrollView.bounds.size.width - self.occurrencesControlsHandleImageView.bounds.size.width, CGRectGetMaxY(self.occurrenceInfoContainer.frame) - self.occurrencesControlsContainer.frame.size.height, self.occurrencesControlsContainer.frame.size.width, self.occurrencesControlsContainer.frame.size.height);
    self.occurrencesControlsNavBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    self.occurrencesControlsTableViewOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"occurrence_faceplate.png"]];
    self.occurrencesControlsTableViewOverlay.opaque = NO;
    self.occurrencesControlsTableViewOverlay.layer.opaque = NO;
    [self.occurrencesControlsTableViewContainer insertSubview:self.occurrencesControlsTableViewsContainer belowSubview:self.occurrencesControlsTableViewOverlay];
    CGRect occurrencesControlsTableViewsContainerFrame = self.occurrencesControlsTableViewsContainer.frame;
    occurrencesControlsTableViewsContainerFrame.size.height = self.occurrencesControlsTableViewContainer.bounds.size.height;
    self.occurrencesControlsTableViewsContainer.frame = occurrencesControlsTableViewsContainerFrame;
    [self setOccurrencesControlsToShowTableView:self.occurrencesControlsDatesTableView animated:NO];
    self.occurrencesControlsVenuesTableView.backgroundColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.occurrencesControlsTimesTableView.backgroundColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    
    self.occurrencesControlsDatesVenuesSeparatorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"occurrence_tables_separator_shadow.png"]];
    self.occurrencesControlsDatesVenuesSeparatorView.opaque = NO;
    self.occurrencesControlsDatesVenuesSeparatorView.layer.opaque = NO;
    self.occurrencesControlsVenuesTimesSeparatorView.backgroundColor = self.occurrencesControlsDatesVenuesSeparatorView.backgroundColor;
    self.occurrencesControlsVenuesTimesSeparatorView.opaque = NO;
    self.occurrencesControlsVenuesTimesSeparatorView.layer.opaque = NO;
    
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
    self.descriptionLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14];
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
    [self.scrollView insertSubview:self.shadowDescriptionContainer belowSubview:self.descriptionContainer];
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.frame];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    if (self.event) {
        if (self.event.occurrencesByDateVenueTime && 
            self.event.occurrencesByDateVenueTime.count > 0) {
            [self processOccurrencesFromEvent:self.event];
            [self reloadOccurrencesTableViews];
        }
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
        if (self.event.occurrencesByDateVenueTime && 
            self.event.occurrencesByDateVenueTime.count > 0) {
            [self processOccurrencesFromEvent:self.event];
            [self reloadOccurrencesTableViews];
        }
        [self updateViewsFromDataAnimated:NO];
        [self.webConnector getAllOccurrencesForEventWithURI:event.uri]; // TURNING THIS OFF FOR TESTING
        [self.occurrenceInfoOverlayView setMessagesForMode:LoadingEventDetails]; // TURNING THIS OFF FOR TESTING
    }
}

- (void)setDeleteAllowed:(BOOL)deleteAllowed {
    deleteAllowed_ = deleteAllowed;
    self.deleteButton.enabled = self.deleteAllowed;
}

- (void)processOccurrencesFromEvent:(Event *)theEvent {
    NSArray * occurrencesByDateVenueTime = theEvent.occurrencesByDateVenueTime;
    // Sort through occurrences...
    // Get rid of any existing occurrence summary objects
    [self.eventOccurrencesSummaryArray removeAllObjects];
    // Set up variables
    OccurrenceSummaryDate * currentOccurrenceSummaryDate = nil;
    OccurrenceSummaryVenue * currentOccurrenceSummaryVenue = nil;
    NSMutableArray * currentDevelopingVenuesArray = nil;
    NSMutableArray * currentDevelopingOccurrencesArray = nil;
    // Loop through all occurrences (which are sorted by date, venue, time)
    for (Occurrence * occurrence in occurrencesByDateVenueTime) {
        // Check if we need to start a new OccurrenceSummaryDate object
        if (![occurrence.startDate isEqualToDate:currentOccurrenceSummaryDate.date]) {
            if (currentOccurrenceSummaryDate) {
                currentOccurrenceSummaryDate.venues = currentDevelopingVenuesArray;
            }
            currentOccurrenceSummaryDate = [[[OccurrenceSummaryDate alloc] init] autorelease]; 
            [self.eventOccurrencesSummaryArray addObject:currentOccurrenceSummaryDate];
            currentOccurrenceSummaryDate.date = occurrence.startDate;
            currentDevelopingVenuesArray = [NSMutableArray array];
        }
        // Check if we need to start a new OccurrenceSummaryVenue object
        if (occurrence.place != currentOccurrenceSummaryVenue.place) {
            if (currentOccurrenceSummaryVenue) {
                [currentOccurrenceSummaryVenue setOccurrences:currentDevelopingOccurrencesArray makeTimesSummaryUsingTimeFormatter:self.occurrenceTimeFormatter];
            }
            currentOccurrenceSummaryVenue = [[[OccurrenceSummaryVenue alloc] init] autorelease];
            [currentDevelopingVenuesArray addObject:currentOccurrenceSummaryVenue];
            currentOccurrenceSummaryVenue.place = occurrence.place;
            currentDevelopingOccurrencesArray = [NSMutableArray array];
        }
        // Add this occurrence to the current OccurrenceSummaryVenueObject
        [currentDevelopingOccurrencesArray addObject:occurrence];
    }
    // Final cleanup
    currentOccurrenceSummaryDate.venues = currentDevelopingVenuesArray;
    [currentOccurrenceSummaryVenue setOccurrences:currentDevelopingOccurrencesArray makeTimesSummaryUsingTimeFormatter:self.occurrenceTimeFormatter];
    
    self.eventOccurrenceCurrent = [occurrencesByDateVenueTime objectAtIndex:0]; // THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS.
    self.eventOccurrenceCurrentDateIndex = [self indexOfDate:self.eventOccurrenceCurrent.startDate inSummaryDates:self.eventOccurrencesSummaryArray];
    self.eventOccurrenceCurrentVenueIndex = [self indexOfPlace:self.eventOccurrenceCurrent.place inSummaryVenues:self.eventOccurrenceCurrentDateSummaryObject.venues];
    self.eventOccurrenceCurrentTimeIndex = [self indexOfTime:self.eventOccurrenceCurrent.startTime inOccurrences:self.eventOccurrenceCurrentVenueSummaryObject.occurrences settleForClosestFit:NO];
    
    // Debugging...
    NSLog(@"Summarize all that processing work we just did...");
    for (OccurrenceSummaryDate * osd in self.eventOccurrencesSummaryArray) {
        NSLog(@"OccurrenceSummaryDate %@", osd.date);
        for (OccurrenceSummaryVenue * osv in osd.venues) {
            NSLog(@"OccurrenceSummaryVenue %@", osv.place.title);
            for (Occurrence * o in osv.occurrences) {
                NSLog(@"Occurrence at %@", [self.occurrenceTimeFormatter stringFromDate:o.startTime]);
            }
        }
    }
    NSLog(@"eventOccurrenceCurrentDateIndex=%d", self.eventOccurrenceCurrentDateIndex);
    NSLog(@"eventOccurrenceCurrentVenueIndex=%d", self.eventOccurrenceCurrentVenueIndex);
    NSLog(@"eventOccurrenceCurrentTimeIndex=%d", self.eventOccurrenceCurrentTimeIndex);
    
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {

    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * responseDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    [self.coreDataModel updateEvent:self.event withExhaustiveOccurrencesArray:[responseDictionary valueForKey:@"objects"]];
    [self.coreDataModel coreDataSave];
    
    if (self.event.occurrencesByDateVenueTime && 
        self.event.occurrencesByDateVenueTime.count > 0) {
        [self processOccurrencesFromEvent:self.event];
        [self reloadOccurrencesTableViews];
    }
    
    [self updateViewsFromDataAnimated:YES];
    if ([[[responseDictionary objectForKey:@"meta"] valueForKey:@"total_count"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [self.occurrenceInfoOverlayView setMessagesForMode:NoOccurrencesExist];
    }
    [self hideWebLoadingViews];
    
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
    NSLog(@"getAllOccurrencesFailure - need to deal with this!");
    [self.occurrenceInfoOverlayView setMessagesForMode:FailedToLoadEventDetails];
    [self hideWebLoadingViews];
    
}

- (void) reloadOccurrencesTableViews {
    // Seed the occurrences table views...
    [self.occurrencesControlsDatesTableView reloadData];
    [self.occurrencesControlsVenuesTableView reloadData];
    [self.occurrencesControlsTimesTableView reloadData];
//    NSLog(@"Trying to select index path %@ in table %@ with %d rows, with data coming from an array with %d objects", [NSIndexPath indexPathForRow:self.eventOccurrenceCurrentDateIndex inSection:0], [self debugOccurrencesTableViewNameForTableViewTag:self.occurrencesControlsDatesTableView.tag], [self tableView:self.occurrencesControlsDatesTableView numberOfRowsInSection:0], self.eventOccurrencesSummaryArray.count);
    [self.occurrencesControlsDatesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentDateIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentVenueIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.occurrencesControlsTimesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentTimeIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

- (void) updateOccurrenceInfoViewsFromDataAnimated:(BOOL)animated {
    
    NSString * EVENT_TIME_NOT_AVAILABLE = @"--";
    NSString * EVENT_ADDRESS_NOT_AVAILABLE = @"Address not available";
    NSString * EVENT_PHONE_NOT_AVAILABLE = @"Phone number not available";
    
    UIColor * categoryColor = [WebUtil colorFromHexString:self.event.concreteParentCategory.colorHex];
    
    if (self.eventOccurrenceCurrent) {
        
        // Date & Time
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        // Month
        [dateFormatter setDateFormat:@"MMM"];
        NSString * month = [dateFormatter stringFromDate:self.eventOccurrenceCurrent.startDate];
        self.monthLabel.text = [month uppercaseString];
        // Day number
        [dateFormatter setDateFormat:@"d"];
        NSString * dayNumber = [dateFormatter stringFromDate:self.eventOccurrenceCurrent.startDate];
        self.dayNumberLabel.text = dayNumber;
        self.dayNumberLabel.textColor = categoryColor;
        // Day name
        [dateFormatter setDateFormat:@"EEE"];
        NSString * dayName = [dateFormatter stringFromDate:self.eventOccurrenceCurrent.startDate];
        [dateFormatter release];
        self.dayNameLabel.text = [dayName uppercaseString];
        // Time
        NSString * timesSeparatorString = @"ARBITRARYSEPARATORNOTTODISPLAY";
        /* TESTING / DEBUGGING BELOW */
//        NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:self.eventOccurrenceCurrent.startTime endDatetime:[NSDate dateWithTimeInterval:3600 sinceDate:self.eventOccurrenceCurrent.startTime] separatorString:timesSeparatorString dataUnavailableString:EVENT_TIME_NOT_AVAILABLE]; // Debugging
//        [self setTimeLabelTextToTimeString:time containsTwoTimes:YES usingSeparatorString:timesSeparatorString]; // Debugging
        /* TESTING / DEBUGGING ABOVE */
        NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:self.eventOccurrenceCurrent.startTime endDatetime:self.eventOccurrenceCurrent.endTime separatorString:timesSeparatorString dataUnavailableString:EVENT_TIME_NOT_AVAILABLE];
        [self setTimeLabelTextToTimeString:time containsTwoTimes:(self.eventOccurrenceCurrent.startTime && self.eventOccurrenceCurrent.endTime) usingSeparatorString:timesSeparatorString];
        
        NSArray * prices = self.eventOccurrenceCurrent.pricesLowToHigh;
        Price * minPrice = nil;
        Price * maxPrice = nil;
        if (prices && prices.count > 0) {
            minPrice = (Price *)[prices objectAtIndex:0];
            maxPrice = (Price *)[prices lastObject];
        }
        NSString * price = [self.webDataTranslator priceRangeStringFromMinPrice:minPrice.value maxPrice:maxPrice.value separatorString:nil dataUnavailableString:@"--"];
        self.priceLabel.text = price;
        
        // Location & Address
        NSString * addressFirstLine = self.eventOccurrenceCurrent.place.address;
        NSString * addressSecondLine = [self.webDataTranslator addressSecondLineStringFromCity:self.eventOccurrenceCurrent.place.city state:self.eventOccurrenceCurrent.place.state zip:self.eventOccurrenceCurrent.place.zip];
        BOOL someLocationInfo = addressFirstLine || addressSecondLine;
        if (!addressFirstLine) { addressFirstLine = EVENT_ADDRESS_NOT_AVAILABLE; }
        self.addressLabel.text = addressFirstLine;
        self.cityStateZipLabel.text = addressSecondLine;
        
        // Venue
        NSString * venue = self.eventOccurrenceCurrent.place.title;
        if (!venue) { 
            if (someLocationInfo) {
                venue = @"Location:";
            } else {
                venue = @"Location not available";
            }
        }
        self.venueLabel.text = venue;
        self.venueLabel.textColor = categoryColor;
        
        // Map button
        self.mapButton.alpha = 1.0;
        self.mapButton.enabled = self.eventOccurrenceCurrent.place.latitude && self.eventOccurrenceCurrent.place.longitude;
        
        // Phone
        BOOL havePhoneNumber = self.eventOccurrenceCurrent.place.phone != nil && [self.eventOccurrenceCurrent.place.phone length] > 0;
        NSString * phone = havePhoneNumber ? self.eventOccurrenceCurrent.place.phone : EVENT_PHONE_NOT_AVAILABLE;
        [self.phoneNumberButton setTitle:phone forState:UIControlStateNormal];
        self.phoneNumberButton.enabled = havePhoneNumber;
        
        NSArray * occurrencesByDateVenueTime = self.event.occurrencesByDateVenueTime;
        
        self.occurrencesControlsContainer.hidden = occurrencesByDateVenueTime.count <= 1;
        CGRect priceLabelFrame = self.priceLabel.frame;
        priceLabelFrame.size.width = self.occurrencesControlsContainer.hidden ? self.priceContainer.bounds.size.width - 2 * priceLabelFrame.origin.x : self.priceContainer.bounds.size.width - 2 * priceLabelFrame.origin.x - 20; // HARD CODED VALUES
        self.priceLabel.frame = priceLabelFrame;

        NSLog(@"before the crash");
        self.swipeToPullInOccurrencesControls.enabled = !self.occurrencesControlsContainer.hidden;
        self.swipeToPushOutOccurrencesControls.enabled = self.swipeToPullInOccurrencesControls.enabled;
        self.tapToPullInOccurrencesControls.enabled = self.swipeToPullInOccurrencesControls.enabled && !self.occurrencesControlsVisible;            
        self.dateOccurrenceInfoButton.enabled = [self.event occurrencesNotOnDate:self.eventOccurrenceCurrent.startDate].count > 0;
        self.locationOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:self.eventOccurrenceCurrent.startDate notAtPlace:self.eventOccurrenceCurrent.place].count > 0;
        self.timeOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:self.eventOccurrenceCurrent.startDate atPlace:self.eventOccurrenceCurrent.place notAtTime:self.eventOccurrenceCurrent.startTime].count > 0;
        NSLog(@"after the crash");
        
    } else {
        
        self.monthLabel.text = @"";
        self.dayNumberLabel.text = @"";
        self.dayNameLabel.text = @"";
        [self setTimeLabelTextToTimeString:@"" containsTwoTimes:NO usingSeparatorString:nil];
        self.priceLabel.text = @"";
        self.venueLabel.text = @"";
        self.addressLabel.text = @"";
        self.cityStateZipLabel.text = @"";
        self.priceLabel.text = @"";
        self.phoneNumberButton.enabled = NO;
        self.mapButton.enabled = NO;
        self.mapButton.alpha = 0.0;
        
        self.occurrencesControlsContainer.hidden = YES;
        self.dateOccurrenceInfoButton.enabled = NO;
        self.locationOccurrenceInfoButton.enabled = NO;
        self.timeOccurrenceInfoButton.enabled = NO;
        self.swipeToPullInOccurrencesControls.enabled = NO;
        self.swipeToPushOutOccurrencesControls.enabled = NO;
        self.tapToPullInOccurrencesControls.enabled = NO;
        
        
    }
    
    // Adjust the scroll view scroll indicator insets for the occurrences controls
    UIEdgeInsets scrollViewScrollIndicatorInsets = self.scrollView.scrollIndicatorInsets;
    scrollViewScrollIndicatorInsets.bottom = self.occurrencesControlsContainer.hidden ? 0 : 163; // HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE.
    self.scrollView.scrollIndicatorInsets = scrollViewScrollIndicatorInsets;
    
}

- (void) setTimeLabelTextToTimeString:(NSString *)timeLabelString containsTwoTimes:(BOOL)doesContainTwoTimes usingSeparatorString:(NSString *)separatorString {
    // Hide end time label if appropriate
    self.timeEndLabel.hidden = !doesContainTwoTimes;
    // Gather some values for simplicity
    CGSize superviewSize = self.timeStartLabel.superview.bounds.size;
    CGFloat horizontalPadding = 5;
    if (!doesContainTwoTimes) {
        self.timeStartLabel.text = timeLabelString;
        self.timeStartLabel.frame = CGRectMake(horizontalPadding, 0, superviewSize.width - 2*horizontalPadding, self.timeStartLabel.superview.bounds.size.height);
    } else {
        NSArray * stringParts = [timeLabelString componentsSeparatedByString:separatorString];
        self.timeStartLabel.text = [stringParts objectAtIndex:0];
        self.timeEndLabel.text = [NSString stringWithFormat:@"until %@", [stringParts lastObject]];
        // Size the frames to fit the new text
        [self.timeStartLabel sizeToFit];
        [self.timeEndLabel sizeToFit];
        // Grab the frames, and make sure that the time start frame is not too wide
        CGRect timeStartLabelFrame = self.timeStartLabel.frame;
        timeStartLabelFrame.size = CGSizeMake(MIN(superviewSize.width - horizontalPadding*2, timeStartLabelFrame.size.width), superviewSize.height);
        CGRect timeEndLabelFrame = self.timeEndLabel.frame;
        // Adjust the new frames' x origin
        timeStartLabelFrame.origin.x = (superviewSize.width - timeStartLabelFrame.size.width) / 2.0;
        timeEndLabelFrame.origin.x = timeStartLabelFrame.origin.x;
        self.timeStartLabel.frame = timeStartLabelFrame;
        self.timeEndLabel.frame = timeEndLabelFrame;
    }
    // Debugging...
//    self.timeStartLabel.backgroundColor = [UIColor yellowColor];
//    self.timeEndLabel.backgroundColor = [UIColor redColor];
    [self.timeEndLabel.superview bringSubviewToFront:self.timeEndLabel];
    NSLog(@"EventViewController setTimeLabelToTimeString to %@", timeLabelString);
}

- (void) updateViewsFromDataAnimated:(BOOL)animated {
    
    NSString * EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
        
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
    
    [self updateOccurrenceInfoViewsFromDataAnimated:animated]; // see setOccurrenceInfoContainerIsVisible note below
    
    // Description
    NSString * descriptionString = self.event.eventDescription ? self.event.eventDescription : EVENT_DESCRIPTION_NOT_AVAILABLE;
    self.descriptionLabel.text = descriptionString;
    //set contentSize for scroll view
    CGSize detailsLabelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.bounds.size.width, 10000)];
    CGRect detailsLabelFrame = self.descriptionLabel.frame;
    detailsLabelFrame.size.height = detailsLabelSize.height;
    detailsLabelFrame.size.width = self.occurrencesControlsContainer.hidden ? self.scrollView.bounds.size.width - 2 * detailsLabelFrame.origin.x : CGRectGetMinX(self.occurrencesControlsContainer.frame) - 2 * detailsLabelFrame.origin.x;
    self.descriptionLabel.frame = detailsLabelFrame;
//    NSLog(@"%@", NSStringFromCGRect(self.detailsLabel.frame));
    CGRect detailsContainerFrame = self.descriptionContainer.frame;
    detailsContainerFrame.size.height = CGRectGetMaxY(self.descriptionLabel.frame) + self.descriptionLabel.frame.origin.y;// - 6; // TEMPORARY HACK, INFERRING THAT THE ORIGIN Y OF THE DETAILS LABEL IS EQUAL TO THE VERTICAL PADDING WE SHOULD GIVE UNDER THAT LABEL. // EVEN WORSE TEMPORARY HACK, HARDCODING AN OFFSET BECAUSE PUTTING EQUAL PADDING AFTER AS BEFORE DOES NOT LOOK EVEN.
    self.descriptionContainer.frame = detailsContainerFrame;
    self.shadowDescriptionContainer.frame = CGRectMake(self.descriptionContainer.frame.origin.x, self.descriptionContainer.frame.origin.y, self.descriptionContainer.frame.size.width, self.descriptionContainer.frame.size.height-1);
    
    [self setOccurrenceInfoContainerIsVisible:(self.eventOccurrenceCurrent != nil) animated:animated]; // THIS WILL CHANGE / PROBABLY DISAPPEAR ONCE YOU IMPLEMENT ALLEN'S NEW FIXED-HEIGHT DESIGN OF THE OCCURRENCE INFO PLACEHOLDER. THIS WILL CHANGE / PROBABLY DISAPPEAR ONCE YOU IMPLEMENT ALLEN'S NEW FIXED-HEIGHT DESIGN OF THE OCCURRENCE INFO PLACEHOLDER. THIS WILL CHANGE / PROBABLY DISAPPEAR ONCE YOU IMPLEMENT ALLEN'S NEW FIXED-HEIGHT DESIGN OF THE OCCURRENCE INFO PLACEHOLDER.

    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.descriptionContainer.frame));
    
    // Breadcrumbs
    NSMutableString * breadcrumbsString = [[self.event.concreteParentCategory.title mutableCopy] autorelease];
    NSArray * orderedConcreteCategoryBreadcrumbs = [self.event.concreteCategoryBreadcrumbs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]]];
    for (CategoryBreadcrumb * breadcrumb in orderedConcreteCategoryBreadcrumbs) {
        [breadcrumbsString appendFormat:@", %@", breadcrumb.category.title];
    }
    self.breadcrumbsLabel.text = breadcrumbsString;
    self.breadcrumbsBar.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.6];
    
    [self.imageView setImageWithURL:[URLBuilder imageURLForImageLocation:self.event.imageLocation] placeholderImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
    
}

- (void) setOccurrenceInfoContainerIsVisible:(BOOL)isVisible animated:(BOOL)animated {

    void (^occurrenceInfoContainerChangesBlock)(void) = ^{
        
        // Showing / hiding views
        self.occurrenceInfoOverlayView.alpha = isVisible ? 0.0 : 1.0;

//        // Moving occurrence location info frame
//        CGFloat locationContainerFrameOriginY = CGRectGetMaxY(self.dateContainer.frame);
//        if (!isVisible) {
//            locationContainerFrameOriginY -= self.locationContainer.frame.size.height;
//        }
//        CGRect locationContainerFrame = self.locationContainer.frame;
//        locationContainerFrame.origin.y = locationContainerFrameOriginY;
//        self.locationContainer.frame = locationContainerFrame;
//        // Adjusting occurrence info container frame
//        CGRect occurrenceInfoContainerFrame = self.occurrenceInfoContainer.frame;
//        occurrenceInfoContainerFrame.size.height = CGRectGetMaxY(self.locationContainer.frame);
//        self.occurrenceInfoContainer.frame = occurrenceInfoContainerFrame;
//        // Moving description frame
//        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
//        descriptionContainerFrame.origin.y = CGRectGetMaxY(self.locationContainer.frame);
//        self.descriptionContainer.frame = descriptionContainerFrame;
//        CGRect shadowDescriptionContainerFrame = self.shadowDescriptionContainer.frame;
//        shadowDescriptionContainerFrame.origin.y = self.descriptionContainer.frame.origin.y;
//        self.shadowDescriptionContainer.frame = shadowDescriptionContainerFrame;
        
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:occurrenceInfoContainerChangesBlock];
    } else {
        occurrenceInfoContainerChangesBlock();
    }
    
    // Interaction
    self.occurrenceInfoOverlayView.userInteractionEnabled = !isVisible;
    
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

- (NSDateFormatter *) occurrenceTimeFormatter {
    if (occurrenceTimeFormatter == nil) {
        occurrenceTimeFormatter = [[NSDateFormatter alloc] init];
        [occurrenceTimeFormatter setDateFormat:@"h:mm a"];
    }
    return occurrenceTimeFormatter;
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
        [self setOccurrencesControlsToShowTableView:self.occurrencesControlsVenuesTableView animated:NO];
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
            occurrencesControlsContainerFrame.origin.x = -self.occurrencesControlsHandleImageView.bounds.size.width;
            self.darkOverlayViewForMainView.alpha = 1.0;
            self.darkOverlayViewForScrollView.alpha = 1.0;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        } else {
            occurrencesControlsContainerFrame.origin.x = self.scrollView.bounds.size.width - self.occurrencesControlsHandleImageView.bounds.size.width;
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.eventOccurrenceCurrent.place.phone]]];
}

-(void)mapButtonTouched {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    self.mapViewController.locationLatitude = self.eventOccurrenceCurrent.place.latitude;
    self.mapViewController.locationLongitude = self.eventOccurrenceCurrent.place.longitude;
    self.mapViewController.locationName = self.eventOccurrenceCurrent.place.title;
    self.mapViewController.locationAddress = self.eventOccurrenceCurrent.place.address;
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
    [self.occurrenceInfoOverlayView setMessagesForMode:LoadingEventDetails];
}

- (void) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton {
    if (occurrenceInfoButton == self.dateOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowTableView:self.occurrencesControlsDatesTableView animated:NO];
    } else if (occurrenceInfoButton == self.locationOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowTableView:self.occurrencesControlsVenuesTableView animated:NO];
    } else if (occurrenceInfoButton == self.timeOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowTableView:self.occurrencesControlsTimesTableView animated:NO];
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized occurrenceInfoButton");
    }
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
        // Adjust occurrence info container frame
        CGRect occurrenceInfoContainerFrame = self.occurrenceInfoContainer.frame;
        occurrenceInfoContainerFrame.origin.y = MAX(CGRectGetMaxY(self.titleBar.frame), CGRectGetMaxY(self.breadcrumbsBar.frame));
        self.occurrenceInfoContainer.frame = occurrenceInfoContainerFrame;
//        // Adjust shadow occurrence info container frame
//        CGRect shadowOccurrenceInfoContainerFrame = self.shadowOccurrenceInfoContainer.frame;
//        shadowOccurrenceInfoContainerFrame.origin.y = self.occurrenceInfoContainer.frame.origin.y + 10;
//        self.shadowOccurrenceInfoContainer.frame = shadowOccurrenceInfoContainerFrame;
        // Adjust occurrences controls frame
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        occurrencesControlsContainerFrame.origin.y = CGRectGetMinY(self.descriptionContainer.frame) - self.occurrencesControlsContainer.frame.size.height + self.scrollView.contentOffset.y;
        self.occurrencesControlsContainer.frame = occurrencesControlsContainerFrame;
    }
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)theScrollView {
    if (theScrollView == self.occurrencesControlsDatesTableView) {
        [self.occurrencesControlsVenuesTableView scrollToRowAtIndexPath:self.occurrencesControlsVenuesTableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    } else if (theScrollView == self.occurrencesControlsVenuesTableView) {
        [self.occurrencesControlsDatesTableView scrollToRowAtIndexPath:self.occurrencesControlsDatesTableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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

- (NSString *) debugOccurrencesTableViewNameForTableViewTag:(int)tag {
    NSString * tableViewName = @"UnknownOccurrencesTableView";
    switch (tag) {
        case 1: tableViewName = @"DatesOccurrencesTableView"; break;
        case 2: tableViewName = @"VenuesOccurrencesTableView"; break;
        case 3: tableViewName = @"TimesOccurrencesTableView"; break;
        default: break;
    }
    return tableViewName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%@ numberOfRowsInSection %d", [self debugOccurrencesTableViewNameForTableViewTag:tableView.tag], section);
    NSInteger rowCount = 0;        
    if (tableView == self.occurrencesControlsDatesTableView) {
        
        rowCount = self.eventOccurrencesSummaryArray.count;
        
    } else {
        
        if (tableView == self.occurrencesControlsVenuesTableView) {
            
            rowCount = self.eventOccurrenceCurrentDateSummaryObject.venues.count;
            
        } else if (tableView == self.occurrencesControlsTimesTableView) {
            
            rowCount = self.eventOccurrenceCurrentVenueSummaryObject.occurrences.count;
            
        } else {
            NSLog(@"ERROR in EventViewController - unrecognized table view");
        }

    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"%@ cellForRowAtIndexPath %d-%d", [self debugOccurrencesTableViewNameForTableViewTag:tableView.tag], indexPath.section, indexPath.row);
    
    UITableViewCell * tableViewCell = nil;
    NSString * CellIdentifier = @"OccurrenceInfoGenericCell";
    Class TableViewCellClass = [UITableViewCell class];
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        CellIdentifier = @"OccurrenceDateCell";
        TableViewCellClass = [OccurrenceDateCell class];
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        CellIdentifier = @"OccurrenceVenueCell";
        TableViewCellClass = [OccurrenceVenueCell class];
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        CellIdentifier = @"OccurrenceTimeCell";
        TableViewCellClass = [OccurrenceTimeCell class];
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    tableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[[TableViewCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int occurrenceSummaryDateIndex = (tableView == self.occurrencesControlsDatesTableView) ? indexPath.row : self.eventOccurrenceCurrentDateIndex;
    OccurrenceSummaryDate * occurrenceSummaryDate = [self.eventOccurrencesSummaryArray objectAtIndex:occurrenceSummaryDateIndex];
    UIColor * categoryColor = [WebUtil colorFromHexString:self.event.concreteParentCategory.colorHex];
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        
        OccurrenceDateCell * tableViewCellCast = (OccurrenceDateCell *)tableViewCell;
        tableViewCellCast.date = occurrenceSummaryDate.date;
        tableViewCellCast.dayNumberLabelColor = categoryColor;
        
    } else {
        
        int occurrenceSummaryVenueIndex = (tableView == self.occurrencesControlsVenuesTableView) ? indexPath.row : self.eventOccurrenceCurrentVenueIndex;
        OccurrenceSummaryVenue * occurrenceSummaryVenue = [occurrenceSummaryDate.venues objectAtIndex:occurrenceSummaryVenueIndex];
        
        if (tableView == self.occurrencesControlsVenuesTableView) {
            
            OccurrenceVenueCell * tableViewCellCast = (OccurrenceVenueCell *)tableViewCell;
            tableViewCellCast.venueLabel.text = occurrenceSummaryVenue.place.title;
            tableViewCellCast.venueLabelColor = categoryColor;
            tableViewCellCast.addressLabel.text = occurrenceSummaryVenue.place.address;
            tableViewCellCast.timesString = occurrenceSummaryVenue.timesString;
            
        } else if (tableView == self.occurrencesControlsTimesTableView) {
            
            Occurrence * occurrence = [occurrenceSummaryVenue.occurrences objectAtIndex:indexPath.row];
            OccurrenceTimeCell * tableViewCellCast = (OccurrenceTimeCell *)tableViewCell;
            tableViewCellCast.timeLabel.text = [self.occurrenceTimeFormatter stringFromDate:occurrence.startTime];
            NSArray * pricesLowToHigh = occurrence.pricesLowToHigh;
            NSNumber * minPrice = nil;
            NSNumber * maxPrice = nil;
            if (pricesLowToHigh && pricesLowToHigh.count > 0) {
                minPrice = ((Price *)[pricesLowToHigh objectAtIndex:0]).value;
                maxPrice = ((Price *)pricesLowToHigh.lastObject).value;
            }
            tableViewCellCast.priceAndInfoLabel.text = [self.webDataTranslator priceRangeStringFromMinPrice:minPrice maxPrice:maxPrice separatorString:nil dataUnavailableString:@"No price or info available"];
            
        } else {
            NSLog(@"ERROR in EventViewController - unrecognized table view");
        }
        
    }
    
    return tableViewCell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 44;
    
//    NSLog(@"%@ heightForRowAtIndexPath %d-%d", [self debugOccurrencesTableViewNameForTableViewTag:tableView.tag], indexPath.section, indexPath.row);
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        
        rowHeight = self.occurrencesControlsDatesTableView.rowHeight;
        
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        
        OccurrenceSummaryVenue * occurrenceSummaryVenue = [self.eventOccurrenceCurrentDateSummaryObject.venues objectAtIndex:indexPath.row];
        rowHeight = [OccurrenceVenueCell cellHeightForTimesString:occurrenceSummaryVenue.timesString cellWidth:self.occurrencesControlsVenuesTableView.bounds.size.width];
        
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        
        rowHeight = self.occurrencesControlsTimesTableView.rowHeight;
        
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    return rowHeight;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSIndexPath * returnIndexPath = indexPath;
//    if ([indexPath isEqual:tableView.indexPathForSelectedRow]) {
//        returnIndexPath = nil;
//    }
//    return returnIndexPath;
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL updateSelectedVenue = NO;
    BOOL updateSelectedTime = NO;
    
    if (tableView == self.occurrencesControlsDatesTableView) {
        
        self.eventOccurrenceCurrentDateIndex = indexPath.row;
        [self.occurrencesControlsDatesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        updateSelectedVenue = YES;
        updateSelectedTime = YES;
        
    } else if (tableView == self.occurrencesControlsVenuesTableView) {
        
        self.eventOccurrenceCurrentVenueIndex = indexPath.row;
        [self.occurrencesControlsVenuesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        updateSelectedTime = YES;
        
        [self setOccurrencesControlsToShowTableView:self.occurrencesControlsTimesTableView animated:YES];
        
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        
        self.eventOccurrenceCurrentTimeIndex = indexPath.row;
        [self.occurrencesControlsTimesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        [self toggleOccurrencesControls];
        
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    if (updateSelectedVenue) {
        updateSelectedTime = YES;
//        self.eventOccurrenceCurrentVenueIndex = 0; // Temporary safety value...
        NSUInteger indexOfVenueToSelect = [self indexOfPlace:self.eventOccurrenceCurrent.place inSummaryVenues:self.eventOccurrenceCurrentDateSummaryObject.venues];
        if (indexOfVenueToSelect == NSNotFound) { indexOfVenueToSelect = 0; } // THIS FALLBACK PROBABLY NEEDS TO BE UPDATED ONCE WE ARE SORTING THE LIST BY PROXIMITY TO USER, ETC...
        self.eventOccurrenceCurrentVenueIndex = indexOfVenueToSelect;
        NSIndexPath * indexPathOfVenueToSelect = [NSIndexPath indexPathForRow:self.eventOccurrenceCurrentVenueIndex inSection:0];
        [self.occurrencesControlsVenuesTableView reloadData];
        [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:indexPathOfVenueToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.occurrencesControlsVenuesTableView scrollToRowAtIndexPath:indexPathOfVenueToSelect atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    if (updateSelectedTime) {
//        self.eventOccurrenceCurrentTimeIndex = 0; // Temporary safety value...
        NSUInteger indexOfTimeToSelect = [self indexOfTime:self.eventOccurrenceCurrent.startTime inOccurrences:self.eventOccurrenceCurrentVenueSummaryObject.occurrences settleForClosestFit:YES];
        self.eventOccurrenceCurrentTimeIndex = indexOfTimeToSelect;
        NSIndexPath * indexPathOfTimeToSelect = [NSIndexPath indexPathForRow:self.eventOccurrenceCurrentTimeIndex inSection:0];
        [self.occurrencesControlsTimesTableView reloadData];
        [self.occurrencesControlsTimesTableView selectRowAtIndexPath:indexPathOfTimeToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.occurrencesControlsTimesTableView scrollToRowAtIndexPath:indexPathOfTimeToSelect atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    self.eventOccurrenceCurrent = [self.eventOccurrenceCurrentVenueSummaryObject.occurrences objectAtIndex:self.eventOccurrenceCurrentTimeIndex];
    [self updateOccurrenceInfoViewsFromDataAnimated:YES];
    
}

- (OccurrenceSummaryDate *) eventOccurrenceCurrentDateSummaryObject {
//    NSLog(@"Getting current event occurrence date at index %d from array of dates with count of %d", self.eventOccurrenceCurrentDateIndex, self.eventOccurrencesSummaryArray.count);
    OccurrenceSummaryDate * occurrenceSummaryDate = nil;
    if (self.eventOccurrencesSummaryArray && 
        self.eventOccurrencesSummaryArray.count > self.eventOccurrenceCurrentDateIndex) {
        occurrenceSummaryDate = [self.eventOccurrencesSummaryArray objectAtIndex:self.eventOccurrenceCurrentDateIndex];
    }
    return occurrenceSummaryDate;
}

- (OccurrenceSummaryVenue *) eventOccurrenceCurrentVenueSummaryObject {
//    NSLog(@"Getting current event occurrence venue at index %d from array of venues with count of %d", self.eventOccurrenceCurrentVenueIndex, self.eventOccurrenceCurrentDateSummaryObject.venues.count);
    OccurrenceSummaryVenue * occurrenceSummaryVenue = nil;
    if (self.eventOccurrenceCurrentDateSummaryObject.venues &&
        self.eventOccurrenceCurrentDateSummaryObject.venues.count > self.eventOccurrenceCurrentVenueIndex) {
        occurrenceSummaryVenue = [self.eventOccurrenceCurrentDateSummaryObject.venues objectAtIndex:self.eventOccurrenceCurrentVenueIndex];
    }
    return occurrenceSummaryVenue;
}

// Returns the index of summary date matching the given date. If a match does not exist, returns NSNotFound.
- (NSUInteger) indexOfDate:(NSDate *)date inSummaryDates:(NSArray *)arrayOfSummaryDates {
    BOOL(^passTestBlock)(id, NSUInteger, BOOL *) = ^(id elementInArray, NSUInteger indexOfElement, BOOL *stopFurtherProcessing){
        OccurrenceSummaryDate * occurrenceSummaryDate = (OccurrenceSummaryDate*)elementInArray;
        return [occurrenceSummaryDate.date isEqual:date];
    };
    return [arrayOfSummaryDates indexOfObjectPassingTest:passTestBlock];
}

// Returns the index of summary venue matching the given place. If a match does not exist, returns NSNotFound.
- (NSUInteger) indexOfPlace:(Place *)place inSummaryVenues:(NSArray *)arrayOfSummaryVenues {
    BOOL(^passTestBlock)(id, NSUInteger, BOOL *) = ^(id elementInArray, NSUInteger indexOfElement, BOOL *stopFurtherProcessing){
        OccurrenceSummaryVenue * occurrenceSummaryVenue = (OccurrenceSummaryVenue*)elementInArray;
        return [occurrenceSummaryVenue.place isEqual:place];
    };
    return [arrayOfSummaryVenues indexOfObjectPassingTest:passTestBlock];
}

// Returns the index of occurrence with startTime matching the given time. If there is no occurrence that matches the given time, then this method will (depending on given BOOL parameter) either return NSNotFound or the index of the best fit occurrence.
- (NSUInteger) indexOfTime:(NSDate *)time inOccurrences:(NSArray *)arrayOfOccurrences settleForClosestFit:(BOOL)shouldSettleForClosestFit {
    BOOL(^passTestBlock)(id, NSUInteger, BOOL *) = ^(id elementInArray, NSUInteger indexOfElement, BOOL *stopFurtherProcessing){
        Occurrence * occurrence = (Occurrence *)elementInArray;
        NSComparisonResult comparisonResult = [occurrence.startTime compare:time];
        BOOL occurrenceMatched = (comparisonResult == NSOrderedSame ||
                                  (shouldSettleForClosestFit &&
                                   comparisonResult == NSOrderedDescending));
        return occurrenceMatched;
    };
    NSUInteger indexMatched = [arrayOfOccurrences indexOfObjectPassingTest:passTestBlock];
    if (indexMatched == NSNotFound && shouldSettleForClosestFit) {
        indexMatched = arrayOfOccurrences.count - 1;
    }
    return indexMatched;
}

- (void) setOccurrencesControlsToShowTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    void(^changesBlock)(void) = ^{
        CGRect tableViewsContainerFrame = self.occurrencesControlsTableViewsContainer.frame;
        CGFloat tableViewsContainerOriginX = 0;
//        CGFloat occurrencesControlsVenuesTimesSeparatorViewAlpha = 0.0;
        
        if (tableView == self.occurrencesControlsDatesTableView ||
            tableView == self.occurrencesControlsVenuesTableView) {
            
            tableViewsContainerOriginX = 0;
//            occurrencesControlsVenuesTimesSeparatorViewAlpha = 1.0;
            
        } else if (tableView == self.occurrencesControlsTimesTableView) {
            
            tableViewsContainerOriginX = -self.occurrencesControlsTimesTableView.frame.origin.x + 5;
//            occurrencesControlsVenuesTimesSeparatorViewAlpha = 0.0;
            
        } else {
            NSLog(@"ERROR in EventViewController - unrecognized table view");
        }
        
        tableViewsContainerFrame.origin.x = tableViewsContainerOriginX;
        self.occurrencesControlsTableViewsContainer.frame = tableViewsContainerFrame;
//        self.occurrencesControlsVenuesTimesSeparatorView.alpha = occurrencesControlsVenuesTimesSeparatorViewAlpha;
    };
    
    if (animated) {
        [UIView animateWithDuration:.25 animations:changesBlock];
    } else {
        changesBlock();
    }
    
}

@end