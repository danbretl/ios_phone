//
//  EventViewController.m
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
@property BOOL occurrenceInfoContainerIsCollapsed;
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
@property (retain) IBOutlet UIButton  * venueButton;
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
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapToSetLocationGestureRecognizer;
@property (retain) UITapGestureRecognizer * tapVenueGestureRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeToPullInOccurrencesControls;
@property (retain) UISwipeGestureRecognizer * swipeToPushOutOccurrencesControls;
@property (retain) UITapGestureRecognizer * tapToPullInOccurrencesControls;
@property BOOL occurrencesControlsPulledOut;
@property (retain) IBOutlet UIView * occurrencesControlsContainer;
@property (retain) IBOutlet UIImageView * occurrencesControlsHandleImageView;
@property (nonatomic, readonly) BOOL occurrencesControlsHandleIsAvailable;
@property (retain) IBOutlet UIView * occurrencesControlsNavBar;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewContainer;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewOverlay;
@property (retain) IBOutlet UIView * occurrencesControlsTableViewsContainer;
@property (retain) IBOutlet UITableView * occurrencesControlsDatesTableView;
@property (retain) IBOutlet UITableView * occurrencesControlsVenuesTableView;
@property (retain) IBOutlet UIView * occurrencesControlsDatesVenuesSeparatorView;
@property (retain) IBOutlet UIView * occurrencesControlsVenuesTimesSeparatorView;
@property (retain) IBOutlet UITableView * occurrencesControlsTimesTableView;
@property (retain) IBOutlet UIView * occurrencesControlsNavBarsContainer;
@property (retain) IBOutlet UIView * occurrencesControlsDatesVenuesNavBar;
@property (retain) IBOutlet UIView * occurrencesControlsTimesNavBar;
@property (retain) IBOutlet UILabel * occurrencesControlsVenuesNearHeaderLabel;
@property (retain) IBOutlet UILabel * occurrencesControlsVenuesNearLocationLabel;
@property (retain) IBOutlet UILabel * occurrencesControlsTimesOnDateLabel;
@property (retain) IBOutlet UILabel * occurrencesControlsTimesAtVenueLabel;
@property (retain) IBOutlet UIButton * occurrencesControlsCancelButton;
@property (retain) IBOutlet UIButton * occurrencesControlsBackButton;

@property (retain) NSMutableArray * eventOccurrencesSummaryArray;
@property (retain) NSMutableDictionary * eventOccurrencesPlaceDistancesDictionary;
@property (retain) Occurrence * eventOccurrenceCurrent;
@property (retain) Occurrence * eventOccurrenceCurrentTemp;
@property int eventOccurrenceCurrentDateIndex;
@property int eventOccurrenceCurrentVenueIndex;
@property int eventOccurrenceCurrentTimeIndex;

@property (nonatomic, retain) WebActivityView * webActivityView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) NSDateFormatter * occurrenceTimeFormatter;
@property (nonatomic, readonly) NSDateFormatter * occurrencesControlsNavBarDateFormatter;
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
- (IBAction) occurrencesControlsCancelButtonTouched:(id)sender;
- (IBAction) occurrencesControlsBackButtonTouched:(id)sender;
- (void) occurrenceInfoRetryButtonTouched;
- (IBAction) occurrencesControlsDatesVenuesNavBarTouched:(UITapGestureRecognizer *)tapRecognizer;
- (IBAction) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton;
- (void) setOccurrencesControlsToShowGroup:(OccurrencesControlsGroup)ocGroup animated:(BOOL)animated;
- (IBAction) tappedVenueName:(UIButton *)button;
- (void) swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipedToPullInOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture;
- (void) tappedToPullInOccurrencesControls:(UITapGestureRecognizer *)tapGesture;
- (void) userActionOccurredToPullInOccurrencesControls:(UIGestureRecognizer *)gesture horizontalForgiveness:(CGFloat)horizontalForgiveness;
- (void) swipedToPushOutOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture;
- (void) toggleOccurrencesControlsAndResetTableViewsWhenClosing:(BOOL)shouldResetTableViewsWhenClosing;
- (void) displayImage:(UIImage *)image;
- (void) pushedToAddToCalendar;
- (void) pushedToCreateFacebookEvent;
- (void) pushedToShareViaEmail;
- (void) pushedToShareViaFacebook;
- (void) processEventOccurrences:(NSArray *)arrayOfEventOccurrences;
- (void) resortEventOccurrencesVenuesAccordingToCurrentUserLocation;
- (void) reloadOccurrencesTableViews;
- (void) updateOccurrenceInfoViewsFromDataAnimated:(BOOL)animated;
- (void) updateOccurrencesControlsInternalViewsFromData;
- (NSString *) debugOccurrencesTableViewNameForTableViewTag:(int)tag;
- (void) setTimeLabelTextToTimeString:(NSString *)timeLabelString containsTwoTimes:(BOOL)doesContainTwoTimes usingSeparatorString:(NSString *)separatorString;
- (void) setOccurrenceInfoContainerIsCollapsed:(BOOL)isCollapsed animated:(BOOL)animated;
- (void) setOccurrencesControlsHandleIsAvailable:(BOOL)isAvailable animated:(BOOL)animated;
- (void) resetOccurrencesControlsTableViewsToCurrentEventOccurrence;
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

//@property (retain) CLLocation * userLocation;
//@property (retain) NSString * userLocationString;

@property (nonatomic, retain) SetLocationViewController * setLocationViewController;

@end

@implementation EventViewController
@synthesize tapToSetLocationGestureRecognizer;

@synthesize backgroundColorView, navigationBar, backButton, logoButton, actionBar, letsGoButton, shareButton, deleteButton, scrollView, titleBar, shadowTitleBar, imageView, breadcrumbsBar, breadcrumbsLabel, occurrenceInfoContainer, occurrenceInfoContainerIsCollapsed, shadowOccurrenceInfoContainer, occurrenceInfoOverlayView, dateContainer, dateOccurrenceInfoButton, monthLabel, dayNumberLabel, dayNameLabel, timeContainer, timeOccurrenceInfoButton, timeStartLabel, timeEndLabel, priceContainer, priceOccurrenceInfoButton, priceLabel, locationContainer, locationOccurrenceInfoButton, venueButton, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton, descriptionContainer, descriptionBackgroundColorView, descriptionLabel, shadowDescriptionContainer;
@synthesize darkOverlayViewForMainView, darkOverlayViewForScrollView;
@synthesize tapVenueGestureRecognizer, swipeToPullInOccurrencesControls, swipeToPushOutOccurrencesControls, tapToPullInOccurrencesControls;
@synthesize occurrencesControlsPulledOut;
@synthesize occurrencesControlsContainer, occurrencesControlsHandleImageView, occurrencesControlsNavBar, occurrencesControlsTableViewContainer, occurrencesControlsTableViewOverlay, occurrencesControlsTableViewsContainer, occurrencesControlsDatesTableView, occurrencesControlsVenuesTableView, occurrencesControlsDatesVenuesSeparatorView, occurrencesControlsVenuesTimesSeparatorView, occurrencesControlsTimesTableView, occurrencesControlsNavBarsContainer, occurrencesControlsDatesVenuesNavBar, occurrencesControlsTimesNavBar, occurrencesControlsVenuesNearHeaderLabel, occurrencesControlsVenuesNearLocationLabel, occurrencesControlsTimesOnDateLabel, occurrencesControlsTimesAtVenueLabel, occurrencesControlsCancelButton, occurrencesControlsBackButton;

@synthesize userLocation=userLocation_;//, userLocationString=userLocationString_;
@synthesize event;
@synthesize eventOccurrenceCurrent;
@synthesize eventOccurrenceCurrentTemp;
@synthesize eventOccurrenceCurrentDateIndex, eventOccurrenceCurrentVenueIndex, eventOccurrenceCurrentTimeIndex;
@synthesize eventOccurrencesSummaryArray;
@synthesize eventOccurrencesPlaceDistancesDictionary;
@synthesize webActivityView;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;
@synthesize facebookManager;
@synthesize letsGoChoiceActionSheet, letsGoChoiceActionSheetSelectors, shareChoiceActionSheet, shareChoiceActionSheetSelectors;
@synthesize setLocationViewController=setLocationViewController_;

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
    [venueButton release];
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
    [occurrencesControlsNavBarsContainer release];
    [occurrencesControlsDatesVenuesNavBar release];
    [occurrencesControlsTimesNavBar release];
    [occurrencesControlsVenuesNearHeaderLabel release];
    [occurrencesControlsVenuesNearLocationLabel release];
    [occurrencesControlsTimesOnDateLabel release];
    [occurrencesControlsTimesAtVenueLabel release];
    [occurrencesControlsCancelButton release];
    [occurrencesControlsBackButton release];
    [tapVenueGestureRecognizer release];
    [swipeToPullInOccurrencesControls release];
    [swipeToPushOutOccurrencesControls release];
    [tapToPullInOccurrencesControls release];
    [userLocation_ release];
//    [userLocationString_ release];
    [event release];
    [eventOccurrenceCurrent release];
    [eventOccurrenceCurrentTemp release];
    [eventOccurrencesSummaryArray release];
    [eventOccurrencesPlaceDistancesDictionary release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release];
    [webDataTranslator release];
    [occurrencesControlsNavBarDateFormatter release];
    [occurrenceTimeFormatter release];
    [facebookManager release];
    [letsGoChoiceActionSheet release];
    [letsGoChoiceActionSheetSelectors release];
    [shareChoiceActionSheet release];
    [shareChoiceActionSheetSelectors release];
    [setLocationViewController_ release];
    [tapToSetLocationGestureRecognizer release];
    [super dealloc];
	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.eventOccurrencesSummaryArray = [NSMutableArray array];
        self.eventOccurrencesPlaceDistancesDictionary = [NSMutableDictionary dictionary];
        debuggingOccurrencesPicker = NO;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cardbg.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dark_gray.jpg"]];
    
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
//    self.deleteAllowed = NO; asldfjkasdlf;j
    
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
    self.occurrenceInfoContainerIsCollapsed = NO;
    occurrenceInfoOverlayView = [[OccurrenceInfoOverlayView alloc] initWithFrame:CGRectMake(5, 5, self.occurrenceInfoContainer.bounds.size.width - 5 * 2, self.dateContainer.bounds.size.height - 5 * 2)];
    self.occurrenceInfoOverlayView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.occurrenceInfoContainer addSubview:self.occurrenceInfoOverlayView];
    [self.occurrenceInfoOverlayView.button addTarget:self action:@selector(occurrenceInfoRetryButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.venueButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:21];
    self.addressLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    
    // Phone number button
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    // Occurrences controls
    [self.scrollView insertSubview:self.occurrencesControlsContainer belowSubview:self.titleBar];
    self.occurrencesControlsContainer.frame = CGRectMake(self.scrollView.bounds.size.width - self.occurrencesControlsHandleImageView.bounds.size.width, CGRectGetMaxY(self.occurrenceInfoContainer.frame) - self.occurrencesControlsContainer.frame.size.height, self.occurrencesControlsContainer.frame.size.width, self.occurrencesControlsContainer.frame.size.height);
    // Set up occurrences controls nav bars
    [self.occurrencesControlsNavBar addSubview:self.occurrencesControlsNavBarsContainer];
    // Occurrences controls nav bar labels
    self.occurrencesControlsVenuesNearHeaderLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:11.0];
    self.occurrencesControlsVenuesNearLocationLabel.font = [UIFont kwiqetFontOfType:RegularNormal size:17.0];
    self.occurrencesControlsTimesOnDateLabel.font = self.occurrencesControlsVenuesNearHeaderLabel.font;
    self.occurrencesControlsTimesAtVenueLabel.font = self.occurrencesControlsVenuesNearLocationLabel.font;
    // Adjust occurrences controls nav bar to have rounded top corners
    CGRect ocnbFrame = self.occurrencesControlsNavBar.frame;
    ocnbFrame.size.height += 10;
    self.occurrencesControlsNavBar.frame = ocnbFrame;
    self.occurrencesControlsNavBar.layer.cornerRadius = 10.0;
    // Set occurrences controls nav bar to have proper background color/image
    self.occurrencesControlsNavBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    self.occurrencesControlsDatesVenuesNavBar.backgroundColor = self.occurrencesControlsNavBar.backgroundColor;
    self.occurrencesControlsTimesNavBar.backgroundColor = self.occurrencesControlsNavBar.backgroundColor;
    // Set up occurrences controls table view overlay
    self.occurrencesControlsTableViewOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"occurrence_faceplate.png"]];
    self.occurrencesControlsTableViewOverlay.opaque = NO;
    self.occurrencesControlsTableViewOverlay.layer.opaque = NO;
    [self.occurrencesControlsTableViewContainer insertSubview:self.occurrencesControlsTableViewsContainer belowSubview:self.occurrencesControlsTableViewOverlay];
    // Set up occurrences controls table views
    CGRect occurrencesControlsTableViewsContainerFrame = self.occurrencesControlsTableViewsContainer.frame;
    occurrencesControlsTableViewsContainerFrame.size.height = self.occurrencesControlsTableViewContainer.bounds.size.height;
    self.occurrencesControlsTableViewsContainer.frame = occurrencesControlsTableViewsContainerFrame;
    [self setOccurrencesControlsToShowGroup:OCGroupDatesVenues animated:NO];
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
    self.swipeToPushOutOccurrencesControls.enabled = NO; // DISABLING THIS GESTURE FOR NOW, BECAUSE IT SEEMS UNCLEAR TO THE USER THAT SWIPING THE OCCURRENCES CONTROLS AWAY WOULD RESULT IN A CANCEL, ESPECIALLY SINCE THEY COULD SWIPE AWAY AFTER HAVING SELECTED A VENUE (BUT NOT YET A TIME).
    // Tap to pull in
    tapToPullInOccurrencesControls = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToPullInOccurrencesControls:)];
    self.tapToPullInOccurrencesControls.delegate = self;
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
    self.descriptionLabel.font = [UIFont kwiqetFontOfType:LightNormal size:16];
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
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    [self.occurrenceInfoOverlayView setMessagesForMode:LoadingEventDetails];
    if (self.event) {
        NSArray * arrayOfEventOccurrences = [self.event occurrencesByDateVenueTimeNearUserLocation:self.userLocation];
        if (arrayOfEventOccurrences && 
            arrayOfEventOccurrences.count > 0) {
//            NSLog(@"About to process occurrences from viewDidLoad");
            [self processEventOccurrences:arrayOfEventOccurrences];
            [self reloadOccurrencesTableViews];
            [self setOccurrenceInfoContainerIsCollapsed:YES animated:NO];
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
    [self.titleBar invalidateTimerAndScrollTextToOriginAnimated:NO];
}

-(void) showWebLoadingViews  {
    // ACTIVITY VIEWS
    [self.view bringSubviewToFront:self.webActivityView];
    [self.webActivityView showAnimated:YES];
    // USER INTERACTION
    self.letsGoButton.userInteractionEnabled = NO;
    self.shareButton.userInteractionEnabled = NO;
    self.deleteButton.userInteractionEnabled = NO;
    self.phoneNumberButton.userInteractionEnabled = NO;
    self.mapButton.userInteractionEnabled = NO;
    self.dateContainer.userInteractionEnabled = NO;
    self.timeContainer.userInteractionEnabled = NO;
    self.priceContainer.userInteractionEnabled = NO;
    self.locationContainer.userInteractionEnabled = NO;
}

-(void)hideWebLoadingViews  {
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.letsGoButton.userInteractionEnabled = YES;
    self.shareButton.userInteractionEnabled = YES;
    self.deleteButton.userInteractionEnabled = YES;
    self.phoneNumberButton.userInteractionEnabled = YES;
    self.mapButton.userInteractionEnabled = YES;
    self.dateContainer.userInteractionEnabled = YES;
    self.timeContainer.userInteractionEnabled = YES;
    self.priceContainer.userInteractionEnabled = YES;
    self.locationContainer.userInteractionEnabled = YES;
}

- (void)setEvent:(Event *)theEvent {
    if (event != theEvent) {
        [event release];
        event = [theEvent retain];
        NSArray * arrayOfEventOccurrences = [self.event occurrencesByDateVenueTimeNearUserLocation:self.userLocation];
        if (arrayOfEventOccurrences && 
            arrayOfEventOccurrences.count > 0) {
            [self processEventOccurrences:arrayOfEventOccurrences];
            [self reloadOccurrencesTableViews];
        }
        if (self.view.window) {
            [self updateViewsFromDataAnimated:NO];
            [self.occurrenceInfoOverlayView setMessagesForMode:LoadingEventDetails];
        }
        [self.webConnector getAllOccurrencesForEventWithURI:event.uri];
    }
}

//- (void)setUserLocation:(CLLocation *)userLocation withUserLocationString:(NSString *)userLocationString {
//    self.userLocation = userLocation;
//    self.userLocationString = userLocationString;
//}

- (void) processEventOccurrences:(NSArray *)arrayOfEventOccurrences {
    // Sort through occurrences...
    // Get rid of any existing occurrence summary objects
    [self.eventOccurrencesSummaryArray removeAllObjects];
    [self.eventOccurrencesPlaceDistancesDictionary removeAllObjects];
    // Set up variables
    OccurrenceSummaryDate * currentOccurrenceSummaryDate = nil;
    OccurrenceSummaryVenue * currentOccurrenceSummaryVenue = nil;
    NSMutableArray * currentDevelopingVenuesArray = nil;
    NSMutableArray * currentDevelopingOccurrencesArray = nil;
    CLLocation * userLocationCL = [[[CLLocation alloc] initWithLatitude:self.userLocation.latitude.doubleValue longitude:self.userLocation.longitude.doubleValue] autorelease];
    // Loop through all occurrences (which are sorted by date, venue, time)
    for (Occurrence * occurrence in arrayOfEventOccurrences) {
        if ([self.eventOccurrencesPlaceDistancesDictionary objectForKey:occurrence.place.uri] == nil) {
            CLLocation * occurrencePlaceLocation = [[CLLocation alloc] initWithLatitude:occurrence.place.latitude.doubleValue longitude:occurrence.place.longitude.doubleValue];
            NSNumber * distanceNumber = [NSNumber numberWithDouble:[userLocationCL distanceFromLocation:occurrencePlaceLocation]];
            [occurrencePlaceLocation release];
            [self.eventOccurrencesPlaceDistancesDictionary setObject:distanceNumber forKey:occurrence.place.uri];
        }
        // Fix small bug...
        BOOL madeNewVenuesArray = NO;
        // Check if we need to start a new OccurrenceSummaryDate object
        if (![occurrence.startDate isEqualToDate:currentOccurrenceSummaryDate.date]) {
            if (currentOccurrenceSummaryDate != nil) {
                currentOccurrenceSummaryDate.venues = currentDevelopingVenuesArray;
            }
            currentOccurrenceSummaryDate = [[[OccurrenceSummaryDate alloc] init] autorelease]; 
            [self.eventOccurrencesSummaryArray addObject:currentOccurrenceSummaryDate];
            currentOccurrenceSummaryDate.date = occurrence.startDate;
            currentDevelopingVenuesArray = [NSMutableArray array];
            madeNewVenuesArray = YES;
        }
        // Check if we need to start a new OccurrenceSummaryVenue object
        if (madeNewVenuesArray || occurrence.place != currentOccurrenceSummaryVenue.place) {
            if (currentOccurrenceSummaryVenue != nil) {
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
    
    self.eventOccurrenceCurrent = [arrayOfEventOccurrences objectAtIndex:0]; // THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS. THIS NEEDS TO CHANGE, ACCORDING TO WHAT THE USER'S FILTERS WERE IN EventsViewController, THEIR LOCATION, AND PROBABLY OTHER THINGS.
    self.eventOccurrenceCurrentTemp = self.eventOccurrenceCurrent;
    self.eventOccurrenceCurrentDateIndex = [self indexOfDate:self.eventOccurrenceCurrent.startDate inSummaryDates:self.eventOccurrencesSummaryArray];
    self.eventOccurrenceCurrentVenueIndex = [self indexOfPlace:self.eventOccurrenceCurrent.place inSummaryVenues:self.eventOccurrenceCurrentDateSummaryObject.venues];
    self.eventOccurrenceCurrentTimeIndex = [self indexOfTime:self.eventOccurrenceCurrent.startTime inOccurrences:self.eventOccurrenceCurrentVenueSummaryObject.occurrences settleForClosestFit:NO];
    
}

- (void) resortEventOccurrencesVenuesAccordingToCurrentUserLocation {
    [self.eventOccurrencesPlaceDistancesDictionary removeAllObjects];
    CLLocation * userLocationCL = [[[CLLocation alloc] initWithLatitude:self.userLocation.latitude.doubleValue longitude:self.userLocation.longitude.doubleValue] autorelease];
    for (OccurrenceSummaryDate * osd in self.eventOccurrencesSummaryArray) {
        [osd resortVenuesByProximityToCoordinate:CLLocationCoordinate2DMake(self.userLocation.latitude.doubleValue, self.userLocation.longitude.doubleValue)];
        for (OccurrenceSummaryVenue * osv in osd.venues) {
            if ([self.eventOccurrencesPlaceDistancesDictionary objectForKey:osv.place.uri] == nil) {
                CLLocation * occurrencePlaceLocation = [[CLLocation alloc] initWithLatitude:osv.place.latitude.doubleValue longitude:osv.place.longitude.doubleValue];
                NSNumber * distanceNumber = [NSNumber numberWithDouble:[userLocationCL distanceFromLocation:occurrencePlaceLocation]];
                [occurrencePlaceLocation release];
                [self.eventOccurrencesPlaceDistancesDictionary setObject:distanceNumber forKey:osv.place.uri];
            }
        }
    }
    [self.occurrencesControlsVenuesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:self.view.window ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
    self.eventOccurrenceCurrentVenueIndex = 0;
    [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentVenueIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {

    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * responseDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    [self.coreDataModel updateEvent:self.event withExhaustiveOccurrencesArray:[responseDictionary valueForKey:@"objects"]];
    [self.coreDataModel coreDataSave];
    
    NSArray * arrayOfEventOccurrences = [self.event occurrencesByDateVenueTimeNearUserLocation:self.userLocation];
    if (arrayOfEventOccurrences && 
        arrayOfEventOccurrences.count > 0) {
//        NSLog(@"About to process occurrences from getAllOccurrencesSuccess");
        [self processEventOccurrences:arrayOfEventOccurrences];
        [self reloadOccurrencesTableViews];
    }
    
    [self updateViewsFromDataAnimated:YES];
    if ([[[responseDictionary objectForKey:@"meta"] valueForKey:@"total_count"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [self.occurrenceInfoOverlayView setMessagesForMode:NoOccurrencesExist];
        self.occurrenceInfoOverlayView.userInteractionEnabled = NO;
    }
    [self hideWebLoadingViews];
    
}

- (void) webConnector:(WebConnector *)webConnector getAllOccurrencesFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
//    NSLog(@"getAllOccurrencesFailure - need to deal with this!");
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
        if (self.eventOccurrenceCurrent.isAllDay.boolValue) {
            self.timeStartLabel.text = @"All Day";
            self.timeEndLabel.text = @"";
        } else {
            NSString * timesSeparatorString = @"ARBITRARYSEPARATORNOTTODISPLAY";
            NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:self.eventOccurrenceCurrent.startTime endDatetime:self.eventOccurrenceCurrent.endTime separatorString:timesSeparatorString dataUnavailableString:EVENT_TIME_NOT_AVAILABLE];
            [self setTimeLabelTextToTimeString:time containsTwoTimes:(self.eventOccurrenceCurrent.startTime && self.eventOccurrenceCurrent.endTime) usingSeparatorString:timesSeparatorString];
        }
        // Price
        NSArray * prices = self.eventOccurrenceCurrent.pricesLowToHigh;
        Price * minPrice = nil;
        Price * maxPrice = nil;
        if (prices && prices.count > 0) {
            minPrice = (Price *)[prices objectAtIndex:0];
            maxPrice = (Price *)[prices lastObject];
        }
        NSString * priceUnavailableString = @"--";
        NSString * price = [self.webDataTranslator priceRangeStringFromMinPrice:minPrice.value maxPrice:maxPrice.value separatorString:nil dataUnavailableString:priceUnavailableString];
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
        [self.venueButton setTitle:venue forState:UIControlStateNormal];
        [self.venueButton setTitle:venue forState:UIControlStateHighlighted];
        [self.venueButton setTitleColor:categoryColor forState:UIControlStateNormal];
        [self.venueButton setTitleColor:categoryColor forState:UIControlStateHighlighted];
        self.venueButton.userInteractionEnabled = YES;
        
        // Map button
        self.mapButton.alpha = 1.0;
        self.mapButton.enabled = self.eventOccurrenceCurrent.place.latitude && self.eventOccurrenceCurrent.place.longitude;
        
        // Phone
        BOOL havePhoneNumber = self.eventOccurrenceCurrent.place.phone != nil && [self.eventOccurrenceCurrent.place.phone length] > 0;
        NSString * phone = havePhoneNumber ? self.eventOccurrenceCurrent.place.phone : EVENT_PHONE_NOT_AVAILABLE;
        [self.phoneNumberButton setTitle:phone forState:UIControlStateNormal];
        [self.phoneNumberButton setTitle:phone forState:UIControlStateHighlighted];
        self.phoneNumberButton.enabled = havePhoneNumber;
        
        NSArray * occurrencesByDateVenueTime = self.event.occurrencesByDateVenueTime;
        
        // Show or hide occurrences controls handle
        if (!self.occurrencesControlsPulledOut) {
            [self setOccurrencesControlsHandleIsAvailable:debuggingOccurrencesPicker || (occurrencesByDateVenueTime.count > 1) animated:animated];
        }

        // Adjust labels (price & venue) according to whether occurrences controls handle is showing
        CGFloat hardCodedHackValueLabelWidthAdjustment = 13; // HARD CODED VALUE! SHOULD BE MORE FLEXIBLE THAN THIS, BASED ON THE WIDTH OF THE HANDLE, OR SOMETHING LIKE THAT.
        CGRect priceLabelFrame = self.priceLabel.frame;
        CGRect venueButtonFrame = self.venueButton.frame;
        priceLabelFrame.size.width = self.priceContainer.bounds.size.width - 2 * priceLabelFrame.origin.x;
        venueButtonFrame.size.width = self.locationContainer.bounds.size.width;
        if (self.occurrencesControlsHandleIsAvailable) {
            priceLabelFrame.size.width -= hardCodedHackValueLabelWidthAdjustment;
            venueButtonFrame.size.width -= hardCodedHackValueLabelWidthAdjustment;
        }
        self.priceLabel.frame = priceLabelFrame;
        self.venueButton.frame = venueButtonFrame;
        
        [self updateOccurrencesControlsInternalViewsFromData];

//        NSLog(@"before the crash");
        self.swipeToPullInOccurrencesControls.enabled = self.occurrencesControlsHandleIsAvailable;
        self.swipeToPushOutOccurrencesControls.enabled = NO; // DISABLING THIS GESTURE FOR NOW, BECAUSE IT SEEMS UNCLEAR TO THE USER THAT SWIPING THE OCCURRENCES CONTROLS AWAY WOULD RESULT IN A CANCEL, ESPECIALLY SINCE THEY COULD SWIPE AWAY AFTER HAVING SELECTED A VENUE (BUT NOT YET A TIME).
        self.tapToPullInOccurrencesControls.enabled = self.swipeToPullInOccurrencesControls.enabled && !self.occurrencesControlsPulledOut;
        self.dateOccurrenceInfoButton.enabled = [self.event occurrencesNotOnDate:self.eventOccurrenceCurrent.startDate].count > 0;
        self.locationOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:self.eventOccurrenceCurrent.startDate notAtPlace:self.eventOccurrenceCurrent.place].count > 0;
        self.timeOccurrenceInfoButton.enabled = [self.event occurrencesOnDate:self.eventOccurrenceCurrent.startDate atPlace:self.eventOccurrenceCurrent.place notAtTime:self.eventOccurrenceCurrent.startTime].count > 0;
//        NSLog(@"after the crash");
        
    } else {
        
        self.monthLabel.text = @"";
        self.dayNumberLabel.text = @"";
        self.dayNameLabel.text = @"";
        [self setTimeLabelTextToTimeString:@"" containsTwoTimes:NO usingSeparatorString:nil];
        self.priceLabel.text = @"";
        [self.venueButton setTitle:@"" forState:UIControlStateNormal];
        [self.venueButton setTitle:@"" forState:UIControlStateHighlighted];
        self.venueButton.userInteractionEnabled = NO;
        self.addressLabel.text = @"";
        self.cityStateZipLabel.text = @"";
        self.phoneNumberButton.enabled = NO;
        self.mapButton.enabled = NO;
        self.mapButton.alpha = 0.0;
        
        [self setOccurrencesControlsHandleIsAvailable:NO animated:animated];
        self.dateOccurrenceInfoButton.enabled = NO;
        self.locationOccurrenceInfoButton.enabled = NO;
        self.timeOccurrenceInfoButton.enabled = NO;
        self.swipeToPullInOccurrencesControls.enabled = NO;
        self.swipeToPushOutOccurrencesControls.enabled = NO; // DISABLING THIS GESTURE FOR NOW, BECAUSE IT SEEMS UNCLEAR TO THE USER THAT SWIPING THE OCCURRENCES CONTROLS AWAY WOULD RESULT IN A CANCEL, ESPECIALLY SINCE THEY COULD SWIPE AWAY AFTER HAVING SELECTED A VENUE (BUT NOT YET A TIME).
        self.tapToPullInOccurrencesControls.enabled = NO;
        
    }
    
    // Shrink the venue button width down to as small as possible
    CGFloat venueButtonHorizontalInsets = self.venueButton.contentEdgeInsets.left + self.venueButton.contentEdgeInsets.right;
    CGSize venueButtonTextSize = [self.venueButton.titleLabel.text sizeWithFont:self.venueButton.titleLabel.font constrainedToSize:CGSizeMake(self.venueButton.frame.size.width - venueButtonHorizontalInsets, self.venueButton.frame.size.height)];
    CGFloat minWidth = MIN(venueButtonTextSize.width + venueButtonHorizontalInsets, self.venueButton.frame.size.width);
    CGRect venueButtonFrame = self.venueButton.frame;
    venueButtonFrame.size.width = minWidth;
    self.venueButton.frame = venueButtonFrame;
    
    [self setOccurrenceInfoContainerIsCollapsed:self.eventOccurrenceCurrent == nil animated:animated];        
    
    // Adjust the scroll view scroll indicator insets for the occurrences controls
    UIEdgeInsets scrollViewScrollIndicatorInsets = self.scrollView.scrollIndicatorInsets;
    scrollViewScrollIndicatorInsets.bottom = self.occurrencesControlsHandleIsAvailable ? 163 /* HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE. HARD CODED VALUE */ : 0;
    self.scrollView.scrollIndicatorInsets = scrollViewScrollIndicatorInsets;
    
}

- (void) updateOccurrencesControlsInternalViewsFromData {
    
    void (^updateLabelBlock)(UILabel *, NSString *, UIButton *, UIView *) = ^(UILabel * label, NSString * labelText, UIButton * leftButton, UIView * containerView){
        
        label.text = labelText;
        
        CGFloat containerViewPadding = leftButton.frame.origin.x;
        CGFloat containerViewWidth = containerView.bounds.size.width;
        CGFloat labelOriginX = label.frame.origin.x;
        CGFloat maximumLabelWidth = containerViewWidth - labelOriginX - containerViewPadding;
        CGSize labelTextSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(maximumLabelWidth, label.bounds.size.height)];
        CGFloat normalCenteredLabelWidth = containerViewWidth - 2 * labelOriginX;
        
        CGRect labelFrame = label.frame;
        if (labelTextSize.width > normalCenteredLabelWidth) {
            labelFrame.size.width = maximumLabelWidth;
            label.textAlignment = UITextAlignmentLeft;
        } else {
            labelFrame.size.width = normalCenteredLabelWidth;
            label.textAlignment = UITextAlignmentCenter;
        }
        label.frame = labelFrame;
        
    };
    
    // Venues near... (User location)
    updateLabelBlock(self.occurrencesControlsVenuesNearLocationLabel, self.userLocation.addressFormatted /* THIS IS NONFUNCTIONAL CURRENTLY. WE ARE CURRENTLY TAKING THE LOCATION FROM THE EVENTS LIST AND USING IT HERE. SOON, WE OBVIOUSLY NEED TO LET THE USER CHANGE (OR DEVICE UPDATE) THEIR LOCATION WITHIN THE EVENT CARD. *** UPDATE (DEC 12, 2011) THIS IS NOW BEING FIXED. */, self.occurrencesControlsCancelButton, self.occurrencesControlsNavBar);
    // Times on... (Selected date)
    self.occurrencesControlsTimesOnDateLabel.text = [NSString stringWithFormat:@"Times on %@ at", [self.occurrencesControlsNavBarDateFormatter stringFromDate:self.eventOccurrenceCurrentDateSummaryObject.date]];
    // Times on date at... (Venue name)
    updateLabelBlock(self.occurrencesControlsTimesAtVenueLabel, self.eventOccurrenceCurrentVenueSummaryObject.place.title, self.occurrencesControlsBackButton, self.occurrencesControlsNavBar);
    
}

- (void) setTimeLabelTextToTimeString:(NSString *)timeLabelString containsTwoTimes:(BOOL)doesContainTwoTimes usingSeparatorString:(NSString *)separatorString {
    // Hide end time label if appropriate
    self.timeEndLabel.hidden = !doesContainTwoTimes;
    // Gather some values for simplicity
    CGSize superviewSize = self.timeStartLabel.superview.bounds.size;
    CGFloat horizontalPadding = 5;
    if (!doesContainTwoTimes) {
        self.timeStartLabel.text = timeLabelString;
        self.timeStartLabel.frame = CGRectMake(horizontalPadding, 0, superviewSize.width - 2 * horizontalPadding, self.timeStartLabel.superview.bounds.size.height);
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
//    NSLog(@"EventViewController setTimeLabelToTimeString to %@", timeLabelString);
}

- (void) updateViewsFromDataAnimated:(BOOL)animated {
    
    NSString * EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
        
    // Concrete parent category color
    UIColor * concreteParentCategoryColor = self.event.concreteParentCategory.colorHex ? [WebUtil colorFromHexString:self.event.concreteParentCategory.colorHex] : [UIColor blackColor];
    
    // Background
//    self.view.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
//    self.backgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.05];
//    self.detailsBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.10];
    self.descriptionBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
//    self.detailsLabel.backgroundColor = concreteParentCategoryColor;
//    self.detailsLabel.textColor = [UIColor whiteColor];
    
    // Title
    self.titleBar.text = self.event.title;
    self.titleBar.color = concreteParentCategoryColor;
    
    // Action buttons
    BOOL actionButtonsEnabled = self.eventOccurrenceCurrent != nil;
    self.letsGoButton.enabled = actionButtonsEnabled;
    self.shareButton.enabled = actionButtonsEnabled;
    self.deleteButton.enabled = actionButtonsEnabled;
    
    // Occurrence Info
    [self updateOccurrenceInfoViewsFromDataAnimated:animated]; // This should come before setting the description string and sizes, because those things are dependent on whether or not the occurrence controls pull tab is visible.
    
    // Description
    NSString * descriptionString = self.event.eventDescription ? self.event.eventDescription : EVENT_DESCRIPTION_NOT_AVAILABLE;
    self.descriptionLabel.text = descriptionString;
    //set contentSize for scroll view
    CGFloat detailsLabelWidth = self.occurrencesControlsHandleIsAvailable ? CGRectGetMinX(self.occurrencesControlsContainer.frame) - 2 * self.descriptionLabel.frame.origin.x : self.scrollView.bounds.size.width - 2 * self.descriptionLabel.frame.origin.x; // This should come after updating the occurrence info views, because those things influence the width of the details label.
    CGSize detailsLabelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(detailsLabelWidth, 10000)];
    CGRect detailsLabelFrame = self.descriptionLabel.frame;
    detailsLabelFrame.size.height = detailsLabelSize.height;
    detailsLabelFrame.size.width = detailsLabelWidth;
    self.descriptionLabel.frame = detailsLabelFrame;
    CGRect detailsContainerFrame = self.descriptionContainer.frame;
    detailsContainerFrame.size.height = /*MAX(*/CGRectGetMaxY(self.descriptionLabel.frame) + self.descriptionLabel.frame.origin.y/*, self.scrollView.bounds.size.height - detailsContainerFrame.origin.y)*/;
    self.descriptionContainer.frame = detailsContainerFrame;
    self.shadowDescriptionContainer.frame = CGRectMake(self.descriptionContainer.frame.origin.x, self.descriptionContainer.frame.origin.y, self.descriptionContainer.frame.size.width, self.descriptionContainer.frame.size.height-1);

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

- (void) setOccurrenceInfoContainerIsCollapsed:(BOOL)isCollapsed animated:(BOOL)animated {

    void (^occurrenceInfoContainerChangesBlock)(void) = ^{
        
        // Show / hide views
        self.occurrenceInfoOverlayView.alpha = isCollapsed ? 1.0 : 0.0;

        // Move occurrence location info frame
        CGFloat locationContainerFrameOriginY = CGRectGetMaxY(self.dateContainer.frame);
        if (isCollapsed) {
            locationContainerFrameOriginY -= self.locationContainer.frame.size.height;
        }
        CGRect locationContainerFrame = self.locationContainer.frame;
        locationContainerFrame.origin.y = locationContainerFrameOriginY;
        self.locationContainer.frame = locationContainerFrame;
        
        // Adjust occurrence info container frame
        CGRect occurrenceInfoContainerFrame = self.occurrenceInfoContainer.frame;
        occurrenceInfoContainerFrame.size.height = CGRectGetMaxY(self.locationContainer.frame);
        self.occurrenceInfoContainer.frame = occurrenceInfoContainerFrame;
        
        // Move description frame
        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
        descriptionContainerFrame.origin.y = CGRectGetMaxY(self.occurrenceInfoContainer.frame);
        self.descriptionContainer.frame = descriptionContainerFrame;
        CGRect shadowDescriptionContainerFrame = self.shadowDescriptionContainer.frame;
        shadowDescriptionContainerFrame.origin.y = self.descriptionContainer.frame.origin.y;
        self.shadowDescriptionContainer.frame = shadowDescriptionContainerFrame;
//        NSLog(@"self.descriptionContainer.frame = %@", NSStringFromCGRect(self.descriptionContainer.frame));

        // Adjust scroll view content size
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.descriptionContainer.frame));
//        NSLog(@"self.scrollView.contentSize = %@", NSStringFromCGSize(self.scrollView.contentSize));
        
    };
    
    if (isCollapsed != self.occurrenceInfoContainerIsCollapsed) {
        
//        NSLog(@"Is this what is going on??? 1");
        
        if (animated) {
            [UIView animateWithDuration:0.25 animations:occurrenceInfoContainerChangesBlock];
        } else {
            occurrenceInfoContainerChangesBlock();
        }
        
        // Interaction
        self.occurrenceInfoOverlayView.userInteractionEnabled = isCollapsed;        
        
        self.occurrenceInfoContainerIsCollapsed = isCollapsed;
        
//        NSLog(@"Is this what is going on??? 2");
        
    }
    
}

- (void) setOccurrencesControlsHandleIsAvailable:(BOOL)isAvailable animated:(BOOL)animated {

    void (^occurrencesControlsHandleChangeBlock)(void) = ^{
        
        // Show / hide views
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        occurrencesControlsContainerFrame.origin.x = self.scrollView.bounds.size.width;
        if (isAvailable) {
            occurrencesControlsContainerFrame.origin.x -= self.occurrencesControlsHandleImageView.bounds.size.width;
        }
        self.occurrencesControlsContainer.frame = occurrencesControlsContainerFrame;
        
    };
    
    if (animated) {
        if (isAvailable) {
            self.occurrencesControlsContainer.hidden = NO;
        }
        [UIView animateWithDuration:0.25 animations:occurrencesControlsHandleChangeBlock completion:^(BOOL finished){
            if (!isAvailable) {
                self.occurrencesControlsContainer.hidden = YES;
            }
        }];
    } else {
        occurrencesControlsHandleChangeBlock();
        self.occurrencesControlsContainer.hidden = !isAvailable;
    }
    
}

- (BOOL)occurrencesControlsHandleIsAvailable {
    return !self.occurrencesControlsContainer.hidden;
}

- (void) toggleOccurrencesControlsAndResetTableViewsWhenClosing:(BOOL)shouldResetTableViewsWhenClosing {
//    NSLog(@"toggleOccurrencesControls from %d to %d", self.occurrencesControlsPulledOut, !self.occurrencesControlsPulledOut);
    self.occurrencesControlsPulledOut = !self.occurrencesControlsPulledOut;
    self.scrollView.scrollEnabled = !self.occurrencesControlsPulledOut;
    self.tapToPullInOccurrencesControls.enabled = !self.occurrencesControlsPulledOut;
    self.darkOverlayViewForScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.titleBar.frame), self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    self.eventOccurrenceCurrentTemp = self.eventOccurrenceCurrent;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        if (self.occurrencesControlsPulledOut) {
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
    } completion:^(BOOL finished){
        if (shouldResetTableViewsWhenClosing) {
            [self resetOccurrencesControlsTableViewsToCurrentEventOccurrence];
        }
    }];
}

- (void) swipedToPullInOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture {
//    NSLog(@"swipedToPullInOccurrencesControls");
    [self userActionOccurredToPullInOccurrencesControls:swipeGesture horizontalForgiveness:30];
}

- (void) tappedToPullInOccurrencesControls:(UITapGestureRecognizer *)tapGesture {
//    NSLog(@"tappedToPullInOccurrencesControls");
    CGRect mapButtonFrameInScrollView = [self.scrollView convertRect:self.mapButton.frame fromView:self.mapButton.superview]; // THIS ASSUMES THAT THE MAP BUTTON IS THE RIGHTMOST BUTTON IN OUR VIEW.
//    NSLog(@"%@, %f", NSStringFromCGRect(mapButtonFrameInScrollView), CGRectGetMinX(self.occurrencesControlsContainer.frame) - CGRectGetMaxX(mapButtonFrameInScrollView));
    [self userActionOccurredToPullInOccurrencesControls:tapGesture horizontalForgiveness:CGRectGetMinX(self.occurrencesControlsContainer.frame) - CGRectGetMaxX(mapButtonFrameInScrollView)];
}

- (void) userActionOccurredToPullInOccurrencesControls:(UIGestureRecognizer *)gesture horizontalForgiveness:(CGFloat)horizontalForgiveness {
    CGPoint location = [gesture locationInView:self.scrollView];
    CGRect acceptableOriginRegion = CGRectMake(CGRectGetMinX(self.occurrencesControlsContainer.frame) - horizontalForgiveness, self.occurrencesControlsContainer.frame.origin.y + 40, horizontalForgiveness + (self.occurrencesControlsContainer.superview.bounds.size.width - CGRectGetMinX(self.occurrencesControlsContainer.frame)), self.occurrencesControlsContainer.frame.size.height - 40 - 5);
    if (CGRectContainsPoint(acceptableOriginRegion, location) && 
        !self.occurrencesControlsPulledOut) {
        [self setOccurrencesControlsToShowGroup:OCGroupDatesVenues animated:NO];
        [self toggleOccurrencesControlsAndResetTableViewsWhenClosing:NO];
    }
}

- (void) swipedToPushOutOccurrencesControls:(UISwipeGestureRecognizer *)swipeGesture {
//    NSLog(@"swipedToPushOutOccurrencesControls");
    if (self.occurrencesControlsPulledOut) {
        [self toggleOccurrencesControlsAndResetTableViewsWhenClosing:YES];
    }
}

- (void)tappedVenueName:(UITapGestureRecognizer *)tapGesture {
//    NSLog(@"tappedVenueName");
    VenueViewController * venueViewController = [[VenueViewController alloc] initWithNibName:@"VenueViewController" bundle:[NSBundle mainBundle]];
    venueViewController.delegate = self;
    venueViewController.venue = self.eventOccurrenceCurrent.place;
    [self.navigationController pushViewController:venueViewController animated:YES];
    [venueViewController release];
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

- (void)displayImage:(UIImage *)image {
    //NSLog(@"image is %f by %f", image.size.width, image.size.height);
//    NSLog(@"EventViewController displayImage:%@ (%fx%f)", image, image.size.width, image.size.height);
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

- (NSDateFormatter *) occurrencesControlsNavBarDateFormatter {
    if (occurrencesControlsNavBarDateFormatter == nil) {
        occurrencesControlsNavBarDateFormatter = [[NSDateFormatter alloc] init];
        [occurrencesControlsNavBarDateFormatter setDateFormat:@"MMM d"];
    }
    return occurrencesControlsNavBarDateFormatter;
}

- (void) swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
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
        NSLog(@"Email sent, originally from EventViewController");
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
//    NSLog(@"Pushed to share via Facebook");
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
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];

}

- (void) pushedToCreateFacebookEvent {
//    NSLog(@"Pushed to create Facebook event");
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
        
        // Do nothing.
        
    } else if ([userAction isEqualToString:@"X"]) {
        
        // We're done here, let our delegate know that we are finished, and that we ended by requesting to delete the event. Leave the actual event object deletion up to the delegate though.
        [self.delegate eventViewController:self didFinishByRequestingEventDeletionForEventURI:self.event.uri];
        
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
//	NSLog(@"phone call");
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
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
}

- (void) logoButtonTouched {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:YES];
}

- (void) occurrenceInfoRetryButtonTouched {
    [self.webConnector getAllOccurrencesForEventWithURI:self.event.uri];
    [self.occurrenceInfoOverlayView setMessagesForMode:LoadingEventDetails];
}

- (void) occurrenceInfoButtonTouched:(UIButton *)occurrenceInfoButton {
    if (occurrenceInfoButton == self.dateOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowGroup:OCGroupDatesVenues animated:NO];
    } else if (occurrenceInfoButton == self.locationOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowGroup:OCGroupDatesVenues animated:NO];
    } else if (occurrenceInfoButton == self.timeOccurrenceInfoButton) {
        [self setOccurrencesControlsToShowGroup:OCGroupTimes animated:NO];
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized occurrenceInfoButton");
    }
    [self toggleOccurrencesControlsAndResetTableViewsWhenClosing:NO];
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
        // Adjust occurrence info container frame
        CGRect occurrenceInfoContainerFrame = self.occurrenceInfoContainer.frame;
        occurrenceInfoContainerFrame.origin.y = MAX(CGRectGetMaxY(self.titleBar.frame), CGRectGetMaxY(self.breadcrumbsBar.frame));
        self.occurrenceInfoContainer.frame = occurrenceInfoContainerFrame;
        // Adjust occurrences controls frame
        CGRect occurrencesControlsContainerFrame = self.occurrencesControlsContainer.frame;
        occurrencesControlsContainerFrame.origin.y = 132 + self.scrollView.contentOffset.y; // HARD CODED VALUE, but honestly it probably should be. Everything else is moving all over the place, and this object is its own entity anyway.
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
    [self setTapToSetLocationGestureRecognizer:nil];
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
//            tableViewCellCast.addressLabel.text = [NSString stringWithFormat:@"%f %@", [[self.eventOccurrencesPlaceDistancesDictionary objectForKey:occurrenceSummaryVenue.place.uri] doubleValue], occurrenceSummaryVenue.place.address]; // Debugging before we had a place for distance information in the venue cell
            [tableViewCellCast setDistanceInMeters:[[self.eventOccurrencesPlaceDistancesDictionary objectForKey:occurrenceSummaryVenue.place.uri] doubleValue]];
            tableViewCellCast.addressLabel.text = occurrenceSummaryVenue.place.address;
            
            tableViewCellCast.timesString = occurrenceSummaryVenue.timesString;
            
        } else if (tableView == self.occurrencesControlsTimesTableView) {
            
            Occurrence * occurrence = [occurrenceSummaryVenue.occurrences objectAtIndex:indexPath.row];
            OccurrenceTimeCell * tableViewCellCast = (OccurrenceTimeCell *)tableViewCell;
            if (occurrence.isAllDay.boolValue) {
                tableViewCellCast.timeLabel.text = @"All Day";
            } else {
                tableViewCellCast.timeLabel.text = [self.occurrenceTimeFormatter stringFromDate:occurrence.startTime];
            }
            if (tableViewCellCast.timeLabel.text.length == 0) {
                tableViewCellCast.timeLabel.text = @"--";
            }
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
        
        [self setOccurrencesControlsToShowGroup:OCGroupTimes animated:YES];
        
    } else if (tableView == self.occurrencesControlsTimesTableView) {
        
        self.eventOccurrenceCurrentTimeIndex = indexPath.row;
        [self.occurrencesControlsTimesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
        // Wait until later in method... Not even sure if this is necessary, but it's more clear.
        
    } else {
        NSLog(@"ERROR in EventViewController - unrecognized table view");
    }
    
    if (updateSelectedVenue) {
        updateSelectedTime = YES;
//        self.eventOccurrenceCurrentVenueIndex = 0; // Temporary safety value...
        NSUInteger indexOfVenueToSelect = [self indexOfPlace:self.eventOccurrenceCurrentTemp.place inSummaryVenues:self.eventOccurrenceCurrentDateSummaryObject.venues];
        if (indexOfVenueToSelect == NSNotFound) { indexOfVenueToSelect = 0; } // THIS FALLBACK PROBABLY NEEDS TO BE UPDATED ONCE WE ARE SORTING THE LIST BY PROXIMITY TO USER, ETC...
        self.eventOccurrenceCurrentVenueIndex = indexOfVenueToSelect;
        NSIndexPath * indexPathOfVenueToSelect = [NSIndexPath indexPathForRow:self.eventOccurrenceCurrentVenueIndex inSection:0];
        [self.occurrencesControlsVenuesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        [self.occurrencesControlsVenuesTableView reloadData];
        [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:indexPathOfVenueToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.occurrencesControlsVenuesTableView scrollToRowAtIndexPath:indexPathOfVenueToSelect atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    if (updateSelectedTime) {
//        self.eventOccurrenceCurrentTimeIndex = 0; // Temporary safety value...
        NSUInteger indexOfTimeToSelect = [self indexOfTime:self.eventOccurrenceCurrentTemp.startTime inOccurrences:self.eventOccurrenceCurrentVenueSummaryObject.occurrences settleForClosestFit:YES];
        self.eventOccurrenceCurrentTimeIndex = indexOfTimeToSelect;
        NSIndexPath * indexPathOfTimeToSelect = [NSIndexPath indexPathForRow:self.eventOccurrenceCurrentTimeIndex inSection:0];
        [self.occurrencesControlsTimesTableView reloadData];
        [self.occurrencesControlsTimesTableView selectRowAtIndexPath:indexPathOfTimeToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.occurrencesControlsTimesTableView scrollToRowAtIndexPath:indexPathOfTimeToSelect atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
    self.eventOccurrenceCurrentTemp = [self.eventOccurrenceCurrentVenueSummaryObject.occurrences objectAtIndex:self.eventOccurrenceCurrentTimeIndex];
    if (tableView == self.occurrencesControlsTimesTableView) {
        self.eventOccurrenceCurrent = self.eventOccurrenceCurrentTemp;
        [self updateOccurrenceInfoViewsFromDataAnimated:YES];
        [self toggleOccurrencesControlsAndResetTableViewsWhenClosing:NO];
    } else {
        [self updateOccurrencesControlsInternalViewsFromData];
    }
        
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

- (void) setOccurrencesControlsToShowGroup:(OccurrencesControlsGroup)ocGroup animated:(BOOL)animated {
    
    void(^tableViewsChangesBlock)(void) = ^{
        CGRect tableViewsContainerFrame = self.occurrencesControlsTableViewsContainer.frame;
        CGFloat tableViewsContainerOriginX = 0;
        //        CGFloat occurrencesControlsVenuesTimesSeparatorViewAlpha = 0.0;
        
        if (ocGroup == OCGroupDatesVenues) {
            
            tableViewsContainerOriginX = 0;
            //            occurrencesControlsVenuesTimesSeparatorViewAlpha = 1.0;
            
        } else if (ocGroup == OCGroupTimes) {
            
            tableViewsContainerOriginX = -self.occurrencesControlsTimesTableView.frame.origin.x + 5;
            //            occurrencesControlsVenuesTimesSeparatorViewAlpha = 0.0;
            
        } else {
            NSLog(@"ERROR in EventViewController - unrecognized occurrences controls group value");
        }
        
        tableViewsContainerFrame.origin.x = tableViewsContainerOriginX;
        self.occurrencesControlsTableViewsContainer.frame = tableViewsContainerFrame;
        //        self.occurrencesControlsVenuesTimesSeparatorView.alpha = occurrencesControlsVenuesTimesSeparatorViewAlpha;
    };
    
    void(^navBarChangesBlock)(void) = ^{
        CGRect navBarsContainerFrame = self.occurrencesControlsNavBarsContainer.frame;
        navBarsContainerFrame.origin.x = (ocGroup == OCGroupTimes) ? -CGRectGetMinX(self.occurrencesControlsTimesNavBar.frame) : 0;
        self.occurrencesControlsNavBarsContainer.frame = navBarsContainerFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            tableViewsChangesBlock();
            navBarChangesBlock();
        }];
    } else {
        tableViewsChangesBlock();
        navBarChangesBlock();
    }
    
}

- (void) resetOccurrencesControlsTableViewsToCurrentEventOccurrence {
    
    self.eventOccurrenceCurrentDateIndex = [self indexOfDate:self.eventOccurrenceCurrent.startDate inSummaryDates:self.eventOccurrencesSummaryArray];
    self.eventOccurrenceCurrentVenueIndex = [self indexOfPlace:self.eventOccurrenceCurrent.place inSummaryVenues:self.eventOccurrenceCurrentDateSummaryObject.venues];
    self.eventOccurrenceCurrentTimeIndex = [self indexOfTime:self.eventOccurrenceCurrent.startTime inOccurrences:self.eventOccurrenceCurrentVenueSummaryObject.occurrences settleForClosestFit:NO];
    
    [self.occurrencesControlsDatesTableView reloadData];
    [self.occurrencesControlsDatesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentDateIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [self.occurrencesControlsVenuesTableView reloadData];
    [self.occurrencesControlsVenuesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentVenueIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [self.occurrencesControlsTimesTableView reloadData];
    [self.occurrencesControlsTimesTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventOccurrenceCurrentTimeIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    [self updateOccurrencesControlsInternalViewsFromData];
    
}

- (void)occurrencesControlsCancelButtonTouched:(id)sender {
    [self toggleOccurrencesControlsAndResetTableViewsWhenClosing:YES];
}

- (void)occurrencesControlsBackButtonTouched:(id)sender {
    [self setOccurrencesControlsToShowGroup:OCGroupDatesVenues animated:YES];
}

- (void)occurrencesControlsDatesVenuesNavBarTouched:(UITapGestureRecognizer *)tapRecognizer {
    if (self.setLocationViewController == nil) {
        setLocationViewController_ = [[SetLocationViewController alloc] initWithNibName:@"SetLocationViewController" bundle:[NSBundle mainBundle]];
    }
    self.setLocationViewController.coreDataModel = self.coreDataModel;
    self.setLocationViewController.delegate = self;
    [self presentModalViewController:self.setLocationViewController animated:YES];
}

- (void) setLocationViewControllerDidCancel:(SetLocationViewController *)setLocationViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.setLocationViewController = nil;
}

- (void)setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectUserLocation:(UserLocation *)location {
    [self dismissModalViewControllerAnimated:YES];
    
//    LocationMode locationModeForSelectedLocation = location.isManual.boolValue ? LocationModeManual : LocationModeAuto;
//    if (self.isSearchOn) {
//        self.locationModeSearch = locationModeForSelectedLocation;
//    } else {
//        self.locationModeBrowse = locationModeForSelectedLocation;
//    }
    self.userLocation = location;
//    [self setUserLocation:location forSource:self.listMode updateViews:YES animated:NO];
    [self updateOccurrencesControlsInternalViewsFromData];
    [self resortEventOccurrencesVenuesAccordingToCurrentUserLocation];
    [self dismissModalViewControllerAnimated:YES];
    self.setLocationViewController = nil;
    // NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity NEED TO UPDATE the order of the venues list according to the new location, so that the venues are still listed in order of proximity 
//    [self setShouldReloadOnDrawerClose:YES updateDrawerReloadIndicatorView:YES shouldUpdateEventsSummaryStringForCurrentSource:YES animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    if (gestureRecognizer == self.tapToSetLocationGestureRecognizer) {
        if ([touch.view isDescendantOfView:self.occurrencesControlsCancelButton]) {
            shouldReceive = NO;
        } else {
            CGPoint touchPoint = [touch locationInView:self.occurrencesControlsDatesVenuesNavBar];
            if (touchPoint.x < self.occurrencesControlsVenuesNearLocationLabel.frame.origin.x ||
                touchPoint.x > CGRectGetMaxX(self.occurrencesControlsVenuesNearLocationLabel.frame)) {
                shouldReceive = NO;
            }
        }
    }
    return shouldReceive;
}

@end