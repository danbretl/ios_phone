//
//  EventsViewController.m
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "EventsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "URLBuilder.h"
#import "ASIHTTPRequest.h"
#import <YAJL/YAJL.h>
#import "DefaultsModel.h"
#import "WebUtil.h"
#import "Analytics.h"
#import "EventResult.h"
#import "UIFont+Kwiqet.h"

static NSString * const EVENTS_OLDFILTER_RECOMMENDED = @"recommended";
static NSString * const EVENTS_CATEGORY_BUTTON_TOUCH_POSTFIX = @"_touch";
static NSString * const EVENTS_NO_RESULTS_REASON_NO_RESULTS = @"EVENTS_NO_RESULTS_REASON_NO_RESULTS";
static NSString * const EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR = @"EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR";
static NSString * const EVENTS_SOURCE_BROWSE = @"EVENTS_SOURCE_BROWSE";
static NSString * const EVENTS_SOURCE_SEARCH = @"EVENTS_SOURCE_SEARCH";

float const EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT = 247.0/255.0;

@interface EventsViewController()

//////////////////////
// Models properties

@property (retain) EventsWebQuery * eventsWebQuery;
@property (retain) EventsWebQuery * eventsWebQueryFromSearch;
@property (nonatomic, readonly) EventsWebQuery * eventsWebQueryForCurrentSource;
@property (nonatomic, retain) NSMutableArray * events;
@property (nonatomic, retain) NSMutableArray * eventsFromSearch;
@property (nonatomic, readonly) NSMutableArray * eventsForCurrentSource;
@property (nonatomic, readonly) NSArray * concreteParentCategoriesArray;
@property (nonatomic, readonly) NSDictionary * concreteParentCategoriesDictionary;

/////////////////////////////
// "View models" properties

@property (nonatomic, readonly) NSArray * filtersForCurrentSource;
@property (retain) NSArray * filters;
@property (retain) EventsFilter * activeFilterInUI;
@property (retain) EventsFilterOption * selectedPriceFilterOption;
@property (retain) EventsFilterOption * selectedDateFilterOption;
@property (retain) EventsFilterOption * selectedTimeFilterOption;
@property (retain) EventsFilterOption * selectedLocationFilterOption;
@property (retain) EventsFilterOption * selectedCategoryFilterOption;
@property (retain) NSArray * filtersSearch;
@property (retain) EventsFilter * activeSearchFilterInUI;
@property (retain) NSMutableArray * adjustedSearchFiltersOrdered;
@property (nonatomic, readonly) EventsFilter * mostRecentlyAdjustedSearchFilter; // Currently, in search mode, after a prior search, if search text field becomes active, if prior search had filters applied, then the drawer automatically opens and displays the UI for the most recently adjusted search filter. This should maybe be changed to just the most recently viewed search filter. Not sure.
@property (retain) EventsFilterOption * selectedDateSearchFilterOption;
@property (retain) EventsFilterOption * selectedTimeSearchFilterOption;
@property (retain) EventsFilterOption * selectedLocationSearchFilterOption;
@property BOOL isDrawerOpen;
@property BOOL shouldReloadOnDrawerClose;
@property BOOL isSearchOn;
@property EventsFeedbackMessageType feedbackMessageTypeBrowseRemembered;
@property EventsFeedbackMessageType feedbackMessageTypeSearchRemembered;
@property (copy) NSString * oldFilterString;
@property (copy) NSString * categoryURI;
@property (retain) NSIndexPath * indexPathOfRowAttemptingToDelete;
@property (retain) NSIndexPath * indexPathOfSelectedRow;
@property (nonatomic) BOOL feedbackViewIsVisible;
@property (retain) NSString * eventsSummaryStringBrowse;
@property (retain) NSString * eventsSummaryStringSearch;
@property (nonatomic, readonly) NSString * eventsSummaryStringForCurrentSource;
@property BOOL deletedFromEventCard;
@property CGPoint tableViewContentOffsetPreserved;
@property BOOL userRequestedToShowLocationSetter;

/////////////////////
// Views properties

@property (retain) IBOutlet UITableView * tableView;
@property (retain) UIView * tableViewCoverViewContainer;
@property (retain) UIImageView * tableViewCoverView;
@property (retain) IBOutlet UIImageView * tableViewBackgroundView;
@property (retain) IBOutlet UIView   * searchContainerView;
@property (retain) IBOutlet UIView   * searchContainerViewShadowCheatView;
@property (retain) IBOutlet UIView * searchContainerTopEdgeView;
@property (retain) IBOutlet UIButton * searchButton;
@property (retain) IBOutlet UIButton * searchCancelButton;
@property (retain) IBOutlet UIButton * searchGoButton;
@property (retain) IBOutlet UITextField * searchTextField;
@property (retain) IBOutlet UIView   * tableReloadContainerView;
@property (retain) IBOutlet UIView   * tableReloadContainerShadowCheatView;
@property (retain) IBOutlet UIView   * pushableContainerView;
@property (retain) IBOutlet UIView   * pushableContainerShadowCheatView;
//
@property (retain) IBOutlet EventsFeedbackView * feedbackView;
//
@property (retain) IBOutlet UIView   * filtersContainerView;
@property (retain) IBOutlet UIView   * filtersContainerShadowCheatView;
@property (retain) IBOutlet UIView   * filtersContainerShadowCheatWayBelowView;
@property (retain) IBOutlet SegmentedHighlighterView * activeFilterHighlightsContainerView;
@property (retain) IBOutlet UIScrollView * drawerScrollView;
//
@property (retain) IBOutlet UIView   * filtersBarBrowse;
@property (retain) IBOutlet UIButton * filterButtonCategories;
@property (retain) IBOutlet UIButton * filterButtonPrice;
@property (retain) IBOutlet UIButton * filterButtonDate;
@property (retain) IBOutlet UIButton * filterButtonLocation;
@property (retain) IBOutlet UIButton * filterButtonTime;
//
@property (retain) IBOutlet UIView   * filtersBarSearch;
@property (retain) IBOutlet UIButton * filterSearchButtonDate;
@property (retain) IBOutlet UIButton * filterSearchButtonLocation;
@property (retain) IBOutlet UIButton * filterSearchButtonTime;
//
@property (retain) IBOutlet UIView * drawerViewsBrowseContainer;
@property (retain) IBOutlet UIView * drawerViewsSearchContainer;
// Drawer view price
@property (retain) IBOutlet UIView * drawerViewPrice;
@property (retain) IBOutlet UIButtonWithOverlayView * dvPriceButtonFree;
@property (retain) IBOutlet UIButtonWithOverlayView * dvPriceButtonUnder20;
@property (retain) IBOutlet UIButtonWithOverlayView * dvPriceButtonUnder50;
@property (retain) IBOutlet UIButtonWithOverlayView * dvPriceButtonAny;
// Drawer view date
@property (retain) IBOutlet UIView * drawerViewDate;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateButtonToday;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateButtonThisWeekend;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateButtonThisWeek;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateButtonThisMonth;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateButtonAny;
// Drawer view date search
@property (retain) IBOutlet UIView * drawerViewDateSearch;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateSearchButtonToday;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisWeekend;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisWeek;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisMonth;
@property (retain) IBOutlet UIButtonWithOverlayView * dvDateSearchButtonAny;
// Drawer view categories
@property (retain) IBOutlet UIView * drawerViewCategories;
// Drawer view time
@property (retain) IBOutlet UIView * drawerViewTime;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonMorning;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonAfternoon;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonEvening;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonNight;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonAny;
// Drawer view time search
@property (retain) IBOutlet UIView * drawerViewTimeSearch;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonMorning;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonAfternoon;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonEvening;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonNight;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonAny;
// Drawer view location
@property (retain) IBOutlet UIView * drawerViewLocation;
@property (retain) IBOutlet UIButton * dvLocationSetLocationButton;
@property (retain) IBOutlet UIButton * dvLocationCurrentLocationButton;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonWalking;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonNeighborhood;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonBorough;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonCity;
// Drawer view location search
@property (retain) IBOutlet UIView * drawerViewLocationSearch;
@property (retain) IBOutlet UIButton * dvLocationSearchSetLocationButton;
@property (retain) IBOutlet UIButton * dvLocationSearchCurrentLocationButton;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonWalking;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonNeighborhood;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonBorough;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonCity;
// Assorted views
@property (nonatomic, retain) WebActivityView * webActivityView;
@property (nonatomic, readonly) UIAlertView * connectionErrorStandardAlertView;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnDeleteAlertView;
@property (nonatomic, readonly) UIAlertView * resetAllFiltersAlertView;
// Gesture recognizers
@property (retain) UITapGestureRecognizer * tapToHideDrawerGR;
// Debugging
@property (retain) UITextView * debugTextView;

/////////////////////
// View Controllers

@property (nonatomic, retain) EventViewController * cardPageViewController;
@property (nonatomic, retain) SetLocationViewController * setLocationViewController;

///////////////////
// Web properties

@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;

/////////////////////
// Assorted methods

- (IBAction) filterButtonTouched:(id)sender;
- (IBAction) priceFilterOptionButtonTouched:(id)sender;
- (IBAction) dateFilterOptionButtonTouched:(id)sender;
- (IBAction) timeFilterOptionButtonTouched:(id)sender;
- (IBAction) locationFilterOptionButtonTouched:(id)sender;
- (void) categoryFilterOptionButtonTouched:(id)sender;
- (void) filterOptionButtonTouched:(UIButton *)filterOptionButton forFilterCode:(NSString *)filterCode selectedOptionGetter:(SEL)selectedFilterOptionGetter selectedOptionSetter:(SEL)selectedFilterOptionSetter;
- (IBAction) searchButtonTouched:(id)sender;
- (IBAction) searchCancelButtonTouched:(id)sender;
- (IBAction) searchGoButtonTouched:(id)sender;
- (void) feedbackViewRetryButtonTouched:(UIButton *)button;
- (IBAction) currentLocationButtonTouched:(UIButton *)currentLocationButton;
- (IBAction) setLocationButtonTouched:(UIButton *)setLocationButton;
- (IBAction) reloadEventsListButtonTouched:(id)sender;

- (void) adjustSearchViewsToShowButtons:(BOOL)showButtons;
- (void) behaviorWasReset:(NSNotification *)notification;
//- (void) categoryButtonPressed:(UIButton *)categoryButton;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (EventsFilter *) filterForFilterButton:(UIButton *)filterButton inFiltersArray:(NSArray *)arrayOfEventsFilters;
- (EventsFilter *) filterForFilterCode:(NSString *)filterCode inFiltersArray:(NSArray *)arrayOfEventsFilters;
- (EventsFilter *) filterForPositionX:(CGFloat)x withinViewWidth:(CGFloat)viewWidth fromFiltersArray:(NSArray *)arrayOfEventsFilters;
- (EventsFilter *) filterForDrawerScrollViewContentOffset:(CGPoint)contentOffset fromFilters:(NSArray *)arrayOfEventsFilters;
- (EventsFilterOption *) filterOptionForFilterOptionButton:(UIButton *)filterOptionButton inFilterOptionsArray:(NSArray *)filterOptions;
- (NSString *) makeEventsSummaryStringForSource:(NSString *)sourceString;
- (void) hideWebLoadingViews;
- (BOOL) isTableViewFilledOut;
- (BOOL) isTableViewScrolledToBottom;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) loginActivity:(NSNotification *)notification;
- (void) matchTableViewCoverViewToTableView;
- (void) releaseReconstructableViews;
- (void) releaseReconstructableViewModels;
- (void) resetSearchFilters;
- (void) searchExecutionRequestedByUser;
- (void) setDrawerScrollViewToDisplayViewsForSource:(NSString *)sourceString;
- (void) setDrawerToShowFilter:(EventsFilter *)filter animated:(BOOL)animated;
- (void) setFiltersBarToDisplayViewsForSource:(NSString *)sourceString;
- (void) setFiltersBarViewsOriginY:(CGFloat)originY adjustDrawerViewsAccordingly:(BOOL)shouldAdjustDrawerViews;
- (void) setImagesForCategoryButton:(UIButton *)button forCategory:(Category *)category;
- (void) setLocationSetterViewIsVisible:(BOOL)isVisible animated:(BOOL)animated animationBasedInKeyboardNotificationUserInfo:(NSDictionary *)keyboardNotificationUserInfo;
- (void) setLogoButtonImageForCategoryURI:(NSString *)theCategoryURI;
- (void) setLogoButtonImageWithImageNamed:(NSString *)imageName;
- (void) setPushableContainerViewsOriginY:(CGFloat)originY adjustHeightToFillMainView:(BOOL)shouldAdjustHeight;
- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable;
- (void) setUpFiltersUI:(NSArray *)arrayOfEventsFilters withOptionButtonSelectors:(NSDictionary *)dictionaryOfEventFilterOptionSelectors compressedOptionButtons:(BOOL)compressed;
- (void) showWebLoadingViews;
- (void) swipeAcrossFiltersStrip:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipeDownToShowDrawer:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipeUpToHideDrawer:(UISwipeGestureRecognizer *)swipeGesture;
- (void) tapToHideDrawer:(UITapGestureRecognizer *)tapGesture;
- (void) toggleDrawerAnimated:(BOOL)animated;
- (void) toggleSearchModeAnimated:(BOOL)animated shouldMakeSearchTextFieldActiveWhenTogglingOn:(BOOL)shouldMakeSearchTextFieldActive shouldFlushQueryAndFilters:(BOOL)shouldFlushQueryAndFilters; // What an ugly method! Should be split up into two, one for on, one for off.
- (void) updateActiveFilterHighlights;
- (void) updateFilter:(EventsFilter *)filter buttonImageForFilterOption:(EventsFilterOption *)filterOption;
- (void) updateFilterOptionButtonStatesOldSelected:(EventsFilterOption *)oldSelectedOption newSelected:(EventsFilterOption *)newSelectedOption;
- (void) updateTimeFilterOptions:(NSArray *)timeFilterOptions forSearch:(BOOL)forSearch givenSelectedDateFilterOption:(EventsFilterOption *)givenSelectedDateFilterOption userTime:(NSDate *)givenUserTime /*shouldBumpUnavailableTimes:(BOOL)shouldBumpUnavailableTimes*/;
- (void) setFeedbackViewIsVisible:(BOOL)feedbackViewIsVisible animated:(BOOL)animated;
- (void) setFeedbackViewMessageType:(EventsFeedbackMessageType)messageType eventsSummaryString:(NSString *)eventsSummaryString searchString:(NSString *)searchString animated:(BOOL)animated;
//- (void) updateFiltersSummaryLabelWithString:(NSString *)summaryString;
- (void) updateAdjustedSearchFiltersOrderedWithAdjustedFilter:(EventsFilter *)adjustedFilter selectedFilterOption:(EventsFilterOption *)selectedFilterOption;
- (void) updateViewsFromCurrentSourceDataWhichShouldBePopulated:(BOOL)dataShouldBePopulated reasonIfNot:(NSString *)reasonIfNotPopulated animated:(BOOL)animated;
- (void) webConnectGetEventsListWithCurrentOldFilterAndCategory;
- (void) webConnectGetEventsListWithOldFilter:(NSString *)theProposedOldFilterString categoryURI:(NSString *)theProposedCategoryURI;

@end

@implementation EventsViewController
@synthesize activeFilterInUI;
@synthesize selectedPriceFilterOption, selectedDateFilterOption, selectedTimeFilterOption, selectedLocationFilterOption, selectedCategoryFilterOption;
@synthesize filters, filtersSearch;
@synthesize activeSearchFilterInUI, adjustedSearchFiltersOrdered;
@synthesize selectedDateSearchFilterOption, selectedTimeSearchFilterOption, selectedLocationSearchFilterOption;
@synthesize filtersContainerView, filtersContainerShadowCheatView, filtersContainerShadowCheatWayBelowView;
@synthesize filtersBarBrowse, filtersBarSearch;
@synthesize filterButtonCategories, filterButtonPrice, filterButtonDate, filterButtonLocation, filterButtonTime;
@synthesize filterSearchButtonDate, filterSearchButtonLocation, filterSearchButtonTime;
@synthesize pushableContainerView, pushableContainerShadowCheatView, feedbackView, feedbackViewIsVisible=feedbackViewIsVisible_, eventsSummaryStringBrowse, eventsSummaryStringSearch;
@synthesize deletedFromEventCard, tableViewContentOffsetPreserved;
@synthesize userRequestedToShowLocationSetter=userRequestedToShowLocationSetter_;
@synthesize drawerScrollView, activeFilterHighlightsContainerView;
@synthesize drawerViewsBrowseContainer;
@synthesize drawerViewsSearchContainer;
@synthesize drawerViewPrice, dvPriceButtonAny, dvPriceButtonFree, dvPriceButtonUnder20, dvPriceButtonUnder50;
@synthesize drawerViewDate, dvDateButtonAny, dvDateButtonToday, dvDateButtonThisWeekend, dvDateButtonThisWeek, dvDateButtonThisMonth;
@synthesize drawerViewDateSearch, dvDateSearchButtonToday, dvDateSearchButtonThisWeekend, dvDateSearchButtonThisWeek, dvDateSearchButtonThisMonth, dvDateSearchButtonAny;
@synthesize drawerViewCategories;
@synthesize drawerViewTime, dvTimeButtonAny, dvTimeButtonMorning, dvTimeButtonAfternoon, dvTimeButtonEvening, dvTimeButtonNight;
@synthesize drawerViewTimeSearch, dvTimeSearchButtonMorning, dvTimeSearchButtonAfternoon, dvTimeSearchButtonEvening, dvTimeSearchButtonNight, dvTimeSearchButtonAny;
@synthesize drawerViewLocation, dvLocationSetLocationButton, dvLocationCurrentLocationButton, dvLocationButtonWalking, dvLocationButtonNeighborhood, dvLocationButtonBorough, dvLocationButtonCity;
@synthesize drawerViewLocationSearch, dvLocationSearchSetLocationButton, dvLocationSearchCurrentLocationButton, dvLocationSearchButtonWalking, dvLocationSearchButtonNeighborhood, dvLocationSearchButtonBorough, dvLocationSearchButtonCity;
@synthesize tableView=tableView_;
@synthesize tableViewCoverViewContainer, tableViewCoverView, tableViewBackgroundView;
@synthesize searchContainerView, searchContainerTopEdgeView, searchButton, searchCancelButton, searchGoButton, searchTextField, searchContainerViewShadowCheatView;
@synthesize tableReloadContainerView, tableReloadContainerShadowCheatView;
@synthesize tapToHideDrawerGR;
@synthesize debugTextView;
@synthesize eventsWebQuery, eventsWebQueryFromSearch, events, eventsFromSearch;
@synthesize locationManager;
@synthesize coreDataModel, webActivityView, concreteParentCategoriesDictionary;
@synthesize concreteParentCategoriesArray;
@synthesize oldFilterString, categoryURI;
@synthesize isSearchOn;
@synthesize cardPageViewController, setLocationViewController=setLocationViewController_;
@synthesize indexPathOfRowAttemptingToDelete, indexPathOfSelectedRow;
@synthesize isDrawerOpen, shouldReloadOnDrawerClose;
@synthesize feedbackMessageTypeBrowseRemembered, feedbackMessageTypeSearchRemembered;

- (void)dealloc {
    NSLog(@"--- --- --- --- --- EventsViewController dealloc --- --- --- --- ---");
    [cardPageViewController release];
    [setLocationViewController_ release];
    [concreteParentCategoriesArray release];
    [concreteParentCategoriesDictionary release];
    [coreDataModel release];
	[events release];
	[eventsFromSearch release];
    [eventsWebQuery release];
    [eventsWebQueryFromSearch release];
    [eventsSummaryStringBrowse release];
    [eventsSummaryStringSearch release];
    [indexPathOfRowAttemptingToDelete release];
    [indexPathOfSelectedRow release];
    [webConnector release];
    [webDataTranslator release];
    [locationManager release];
    [self releaseReconstructableViews];
    [self releaseReconstructableViewModels];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.deletedFromEventCard = NO;
//        locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"\n\n\n\n\n\n\n\n");
    NSLog(@"testing");
    NSLog(@"self.view.frame=%@", NSStringFromCGRect(self.view.frame));
    CGRect windowFrame = [self.view convertRect:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, 320, 480) toView:self.tableView];
    NSLog(@"windowFrame (re:searchContainerView) = %@", NSStringFromCGRect(windowFrame));
    NSLog(@"\n\n\n\n\n\n\n\n");
    
    // Views settings - Drawer scroll view
    self.drawerScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerScrollView.layer.masksToBounds = YES;
    self.drawerScrollView.hidden = YES;
    self.drawerViewsBrowseContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerViewsSearchContainer.backgroundColor = self.drawerViewsBrowseContainer.backgroundColor;
//    CGRect drawerScrollViewFrame = self.drawerScrollView.frame;
//    drawerScrollViewFrame.size.height = 0;
//    self.drawerScrollView.frame = drawerScrollViewFrame;
    
    // Views settings - Shadows
    // Search container
    self.searchContainerViewShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchContainerViewShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.searchContainerViewShadowCheatView.layer.shadowOpacity = 0.5;
    self.searchContainerViewShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.searchContainerViewShadowCheatView.bounds].CGPath;
    self.searchContainerViewShadowCheatView.layer.shouldRasterize = YES;
    self.searchContainerViewShadowCheatView.hidden = YES;
    // Reload container
    self.tableReloadContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tableReloadContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.tableReloadContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.tableReloadContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.tableReloadContainerShadowCheatView.bounds].CGPath;
    self.tableReloadContainerShadowCheatView.layer.shouldRasterize = YES;    
    // Filters container
    self.filtersContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filtersContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.filtersContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.filtersContainerShadowCheatView.bounds].CGPath;
    // Filters container
    self.filtersContainerShadowCheatWayBelowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOpacity = 0.5;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.filtersContainerShadowCheatWayBelowView.bounds].CGPath;
    self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
    self.filtersContainerShadowCheatWayBelowView.hidden = YES;
    // Pushable container
    self.pushableContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pushableContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.pushableContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.pushableContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.pushableContainerShadowCheatView.bounds].CGPath;
    self.pushableContainerShadowCheatView.layer.shouldRasterize = YES;
    self.pushableContainerShadowCheatView.hidden = YES;
    
    // Views settings - Table view
//    self.tableView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    // Alternate - transparent table view, brushed metal pushable container
    self.tableView.backgroundColor = [UIColor clearColor];
    self.pushableContainerView.backgroundColor = [UIColor clearColor];
    self.pushableContainerShadowCheatView.backgroundColor = [UIColor clearColor];
    UIImage * tableViewBackgroundImage = [UIImage imageNamed:@"bg_dark_gray.jpg"];
    self.tableViewBackgroundView.image = tableViewBackgroundImage;
    self.tableViewBackgroundView.contentMode = UIViewContentModeTopLeft;
    
    // Views settings - Table header & footer
    self.tableView.tableHeaderView = self.searchContainerView;
    self.tableView.tableFooterView = self.tableReloadContainerView;
    self.tableView.tableFooterView.alpha = 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = NO;
//    self.tableView.tableFooterView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    
    // Views settings - Table header
    self.searchContainerTopEdgeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stretchable_table_top.png"]];
    
    // Views allocation and settings - Table view cover view
    // Container
    tableViewCoverViewContainer = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableViewCoverViewContainer.autoresizingMask = UIViewAutoresizingNone;// self.tableView.autoresizingMask;
    self.tableViewCoverViewContainer.alpha = 0.0;//1.0;
    self.tableViewCoverViewContainer.clipsToBounds = YES;
    [self.pushableContainerView insertSubview:self.tableViewCoverViewContainer aboveSubview:self.tableView];
    // Cover view itself
    CGRect tableViewFrameAccordingToMainView = [self.view convertRect:self.tableView.bounds fromView:self.tableView];
    tableViewCoverView = [[UIImageView alloc] initWithImage:tableViewBackgroundImage];//[UIImage imageNamed:@"bg_purple.jpg"]];
    self.tableViewCoverView.frame = CGRectMake(0, -tableViewFrameAccordingToMainView.origin.y, tableViewBackgroundImage.size.width, tableViewBackgroundImage.size.height);
    self.tableViewCoverView.autoresizingMask = UIViewAutoresizingNone;
    self.tableViewCoverView.contentMode = UIViewContentModeTopLeft;
    [self.tableViewCoverViewContainer addSubview:self.tableViewCoverView];
    [self matchTableViewCoverViewToTableView];

    // Views settings - Feedback view
    [self.feedbackView.button addTarget:self action:@selector(feedbackViewRetryButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    // Views allocation and settings - Web activity view
    CGFloat webActivityViewSize = 60.0;
    self.webActivityView = [[[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds] autorelease];
    [self.view addSubview:self.webActivityView];
    
    // Views allocation and settings - Gesture recognizers
    // Swipe down to open drawer
    UISwipeGestureRecognizer * swipeDownFiltersGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToShowDrawer:)];
    swipeDownFiltersGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.filtersContainerView addGestureRecognizer:swipeDownFiltersGR];
    [swipeDownFiltersGR release];
    // Swipe up to close drawer
    UISwipeGestureRecognizer * swipeUpToHideDrawerGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpToHideDrawer:)];
    swipeUpToHideDrawerGR.direction = UISwipeGestureRecognizerDirectionUp;
    [self.pushableContainerView addGestureRecognizer:swipeUpToHideDrawerGR];
    [swipeUpToHideDrawerGR release];
    // Swipe up to close drawer (from within drawer)
    UISwipeGestureRecognizer * swipeUpToHideDrawerFromWithinDrawerGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpToHideDrawer:)];
    swipeUpToHideDrawerFromWithinDrawerGR.direction = UISwipeGestureRecognizerDirectionUp;
    [self.drawerScrollView addGestureRecognizer:swipeUpToHideDrawerFromWithinDrawerGR];
    [swipeUpToHideDrawerFromWithinDrawerGR release];
    // Tap to close drawer
    tapToHideDrawerGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideDrawer:)];
    [self.pushableContainerView addGestureRecognizer:self.tapToHideDrawerGR];
    self.tapToHideDrawerGR.enabled = NO;
    // 
    UISwipeGestureRecognizer * swipeAcrossFiltersStringGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAcrossFiltersStrip:)];
    swipeAcrossFiltersStringGR.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.filtersContainerView addGestureRecognizer:swipeAcrossFiltersStringGR];
    [swipeAcrossFiltersStringGR release];
    
    // Views settings - active filter highlighter
    self.activeFilterHighlightsContainerView.showColor = NO;
    self.activeFilterHighlightsContainerView.showImage = YES;
    self.activeFilterHighlightsContainerView.highlightImage = [UIImage imageNamed:@"filter_select_glow.png"];
    self.activeFilterHighlightsContainerView.hidden = YES;
    
    // Views settings - location drawers
    self.dvLocationSetLocationButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:15.0];
    self.dvLocationSearchSetLocationButton.titleLabel.font = self.dvLocationSetLocationButton.titleLabel.font;
    
    // Views allocation and settings - categories drawer view & its subviews
    int categoryOptionsCount = 9;
    NSMutableArray * categoryFilterOptions = [NSMutableArray arrayWithCapacity:categoryOptionsCount];
    // Category buttons
    CGSize categoryButtonImageSize = CGSizeMake(51, 51);
    CGSize categoryButtonContainerSize = CGSizeMake(99, 81);
    CGFloat categoryButtonsContainerLeftEdge = 11;
    CGFloat categoryButtonsContainerTopEdge = 0;
    CGFloat categoryTitleLabelTopSpacing = 3;
    UIView * categoryButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(categoryButtonsContainerLeftEdge, categoryButtonsContainerTopEdge, categoryButtonContainerSize.width * 3, categoryButtonContainerSize.height * 3)];
    [self.drawerViewCategories addSubview:categoryButtonsContainer];
    int x = 0; int y = 0;
    for (int i=0; i<categoryOptionsCount; i++) {
        x = i % 3; y = i / 3;
        // Container
        UIView * categoryButtonContainer = [[[UIView alloc] initWithFrame:CGRectMake(x * categoryButtonContainerSize.width, y * categoryButtonContainerSize.height, categoryButtonContainerSize.width, categoryButtonContainerSize.height)] autorelease];
        // Button
        UIButtonWithOverlayView * categoryButton = [[[UIButtonWithOverlayView alloc] initWithFrame:CGRectMake((categoryButtonContainerSize.width - categoryButtonImageSize.width) / 2.0, (categoryButtonContainerSize.height - categoryButtonImageSize.height) / 2.0, categoryButtonImageSize.width, categoryButtonImageSize.height)] autorelease];
        categoryButton.cornerRadius = 10.0;
        categoryButton.isShadowVisibleWhenButtonHighlighted = YES;
        // Label
        UILabel * categoryTitleLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(categoryButton.frame) + categoryTitleLabelTopSpacing, categoryButtonContainer.bounds.size.width, 25)] autorelease];
        categoryTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
        categoryTitleLabel.textAlignment = UITextAlignmentCenter;
        categoryTitleLabel.backgroundColor = [UIColor clearColor];
        // Values from category object
        Category * category = nil;
        if (y == 0 && x == 0) {
            categoryButton.button.tag = -1;
            categoryTitleLabel.text = @"All Categories";
        } else {
            //set icon image here
            category = (Category *)[self.concreteParentCategoriesArray objectAtIndex:i-1];
            categoryTitleLabel.text = category.title;
            categoryButton.button.tag = i-1;
        }
        [self setImagesForCategoryButton:categoryButton.button forCategory:category];
//        [categoryButton.button addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [categoryButtonContainer addSubview:categoryButton];
        [categoryButtonContainer addSubview:categoryTitleLabel];
        [categoryButtonsContainer addSubview:categoryButtonContainer];
        // EventsFilterOption object
        NSString * efoCategoryURI = (y == 0 && x == 0) ? nil : category.uri;
        [categoryFilterOptions addObject:[EventsFilterOption eventsFilterOptionWithCode:[EventsFilterOption eventsFilterOptionCategoryCodeForCategoryURI:efoCategoryURI] readableString:nil buttonText:nil buttonView:categoryButton]];
    }

    NSArray * priceOptions = [NSArray arrayWithObjects:
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: EFO_CODE_PRICE_FREE
                               readableString: @"Free" 
                               buttonText: @"Free"
                               buttonView: self.dvPriceButtonFree],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: EFO_CODE_PRICE_UNDER20 
                               readableString: @"Under $20" 
                               buttonText: @"Under $20"
                               buttonView: self.dvPriceButtonUnder20],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: EFO_CODE_PRICE_UNDER50 
                               readableString: @"Under $50" 
                               buttonText: @"Under $50"
                               buttonView: self.dvPriceButtonUnder50],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: EFO_CODE_PRICE_ANY 
                               readableString: nil 
                               buttonText: @"All Prices"
                               buttonView: self.dvPriceButtonAny],
                              nil];
    NSArray * dateOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_DATE_TODAY 
                              readableString: @"Today" 
                              buttonText: @"Today"
                              buttonView: self.dvDateButtonToday],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_DATE_WEEKEND 
                              readableString: @"This Weekend" 
                              buttonText: @"This Weekend"
                              buttonView: self.dvDateButtonThisWeekend],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_DATE_NEXT7DAYS 
                              readableString: @"In the next 7 Days" 
                              buttonText: @"Next 7 Days"
                              buttonView: self.dvDateButtonThisWeek],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_DATE_NEXT30DAYS 
                              readableString: @"In the next 30 Days" 
                              buttonText: @"Next 30 Days"
                              buttonView: self.dvDateButtonThisMonth],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_DATE_ANY 
                              readableString: nil 
                              buttonText: @"All Dates" 
                              buttonView: self.dvDateButtonAny],
                             nil];
    NSArray * timeOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_TIME_MORNING 
                              readableString: @"In the Morning" 
                              buttonText: @"Morning" 
                              buttonView: self.dvTimeButtonMorning],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_TIME_AFTERNOON 
                              readableString: @"In the Afternoon" 
                              buttonText: @"Afternoon" 
                              buttonView: self.dvTimeButtonAfternoon],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_TIME_EVENING 
                              readableString: @"In the Evening" 
                              buttonText: @"Evening" 
                              buttonView: self.dvTimeButtonEvening],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_TIME_NIGHT 
                              readableString: @"At Night" 
                              buttonText: @"Late Night" 
                              buttonView: self.dvTimeButtonNight],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: EFO_CODE_TIME_ANY 
                              readableString: nil 
                              buttonText: @"Any Time of Day" 
                              buttonView: self.dvTimeButtonAny],
                             nil];
    NSArray * locationOptions = [NSArray arrayWithObjects:
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: EFO_CODE_LOCATION_WALKING 
                                  readableString: @"Within Walking Distance of" 
                                  buttonText: @"Within Walking Distance"
                                  buttonView: self.dvLocationButtonWalking],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: EFO_CODE_LOCATION_NEIGHBORHOOD 
                                  readableString: @"In the Same Neighborhood as" 
                                  buttonText: @"In the Neighborhood"
                                  buttonView: self.dvLocationButtonNeighborhood],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: EFO_CODE_LOCATION_BOROUGH 
                                  readableString: @"In the Same Borough as" 
                                  buttonText: @"In the Borough"
                                  buttonView: self.dvLocationButtonBorough],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: EFO_CODE_LOCATION_CITY 
                                  readableString: nil
                                  buttonText: @"In the City"
                                  buttonView: self.dvLocationButtonCity],
                                 nil];
    
        // New filter "view models"
    self.filters = [NSMutableArray arrayWithObjects:
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_PRICE 
                     buttonText:@"Price"
                     button:self.filterButtonPrice 
                     drawerView:self.drawerViewPrice 
                     options:priceOptions
                     mostGeneralOption:priceOptions.lastObject],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_DATE 
                     buttonText:@"Date"
                     button:self.filterButtonDate 
                     drawerView:self.drawerViewDate 
                     options:dateOptions
                     mostGeneralOption:dateOptions.lastObject],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_CATEGORIES 
                     buttonText:nil
                     button:self.filterButtonCategories 
                     drawerView:self.drawerViewCategories 
                     options:categoryFilterOptions
                     mostGeneralOption:[categoryFilterOptions objectAtIndex:0]],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_TIME 
                     buttonText:@"Time"
                     button:self.filterButtonTime 
                     drawerView:self.drawerViewTime 
                     options:timeOptions
                     mostGeneralOption:timeOptions.lastObject],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_LOCATION 
                     buttonText:@"Location"
                     button:self.filterButtonLocation 
                     drawerView:self.drawerViewLocation 
                     options:locationOptions
                     mostGeneralOption:locationOptions.lastObject],
                    nil];
    
    NSArray * dateSearchOptions = [NSArray arrayWithObjects:
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_DATE_TODAY 
                                    readableString: @"Today" 
                                    buttonText: @"Today"
                                    buttonView: self.dvDateSearchButtonToday],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_DATE_WEEKEND 
                                    readableString: @"This Weekend" 
                                    buttonText: @"Weekend"
                                    buttonView: self.dvDateSearchButtonThisWeekend],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_DATE_NEXT7DAYS
                                    readableString: @"In the next 7 Days" 
                                    buttonText: @"7 Days"
                                    buttonView: self.dvDateSearchButtonThisWeek],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_DATE_NEXT30DAYS 
                                    readableString: @"In the next 30 Days" 
                                    buttonText: @"30 Days"
                                    buttonView: self.dvDateSearchButtonThisMonth],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_DATE_ANY 
                                    readableString: nil 
                                    buttonText: @"All Dates" 
                                    buttonView: self.dvDateSearchButtonAny],
                                   nil];
    NSArray * timeSearchOptions = [NSArray arrayWithObjects:
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_TIME_MORNING 
                                    readableString: @"In the Morning" 
                                    buttonText: @"Morning" 
                                    buttonView: self.dvTimeSearchButtonMorning],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_TIME_AFTERNOON 
                                    readableString: @"In the Afternoon" 
                                    buttonText: @"Afternoon" 
                                    buttonView: self.dvTimeSearchButtonAfternoon],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_TIME_EVENING 
                                    readableString: @"In the Evening" 
                                    buttonText: @"Evening" 
                                    buttonView: self.dvTimeSearchButtonEvening],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_TIME_NIGHT 
                                    readableString: @"At Night" 
                                    buttonText: @"Late Night" 
                                    buttonView: self.dvTimeSearchButtonNight],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: EFO_CODE_TIME_ANY 
                                    readableString: nil 
                                    buttonText: @"Any Time of Day" 
                                    buttonView: self.dvTimeSearchButtonAny],
                                   nil];
    NSArray * locationSearchOptions = [NSArray arrayWithObjects:
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: EFO_CODE_LOCATION_WALKING 
                                        readableString: @"Within Walking Distance of" 
                                        buttonText: @"Walking"
                                        buttonView: self.dvLocationSearchButtonWalking],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: EFO_CODE_LOCATION_NEIGHBORHOOD 
                                        readableString: @"In the Same Neighborhood as" 
                                        buttonText: @"Neighborhood"
                                        buttonView: self.dvLocationSearchButtonNeighborhood],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: EFO_CODE_LOCATION_BOROUGH 
                                        readableString: @"In the Same Borough as" 
                                        buttonText: @"Borough"
                                        buttonView: self.dvLocationSearchButtonBorough],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: EFO_CODE_LOCATION_CITY 
                                        readableString: nil
                                        buttonText: @"City"
                                        buttonView: self.dvLocationSearchButtonCity],
                                       nil];
    
    // Search filter view models
    self.filtersSearch = [NSMutableArray arrayWithObjects:
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_DATE 
                           buttonText:@"Date"
                           button:self.filterSearchButtonDate 
                           drawerView:self.drawerViewDateSearch 
                           options:dateSearchOptions
                           mostGeneralOption:dateSearchOptions.lastObject],
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_LOCATION 
                           buttonText:@"Location"
                           button:self.filterSearchButtonLocation 
                           drawerView:self.drawerViewLocationSearch 
                           options:locationSearchOptions
                           mostGeneralOption:locationSearchOptions.lastObject],
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_TIME 
                           buttonText:@"Time"
                           button:self.filterSearchButtonTime 
                           drawerView:self.drawerViewTimeSearch 
                           options:timeSearchOptions
                           mostGeneralOption:timeSearchOptions.lastObject],
                          nil];
    
    NSDictionary * filterOptionButtonSelectors = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSValue valueWithPointer:@selector(priceFilterOptionButtonTouched:)],
                                                  EVENTS_FILTER_PRICE,
                                                  [NSValue valueWithPointer:@selector(dateFilterOptionButtonTouched:)],
                                                  EVENTS_FILTER_DATE,
                                                  [NSValue valueWithPointer:@selector(timeFilterOptionButtonTouched:)],
                                                  EVENTS_FILTER_TIME,
                                                  [NSValue valueWithPointer:@selector(locationFilterOptionButtonTouched:)],
                                                  EVENTS_FILTER_LOCATION,
                                                  [NSValue valueWithPointer:@selector(categoryFilterOptionButtonTouched:)],
                                                  EVENTS_FILTER_CATEGORIES,
                                                  nil];
    
    [self setUpFiltersUI:self.filters withOptionButtonSelectors:filterOptionButtonSelectors compressedOptionButtons:NO];
    [self setUpFiltersUI:self.filtersSearch withOptionButtonSelectors:filterOptionButtonSelectors compressedOptionButtons:YES];
    
    ///////////////////////////////////////////////
    // THE REST OF viewDidLoad DEPENDS ON DATA...
    
    // To create/recreate EventsViewController, we need to figure out / do...
    // - Are there prior EventsWebQuery objects? If so, get the most recent ones for browse and for search.
    
    // Get the most recent events web queries, if they exist
    self.eventsWebQuery = [self.coreDataModel getMostRecentEventsWebQueryWithoutSearchTerm];
    self.events = [self.eventsWebQuery.eventResultsEventsInOrder.mutableCopy autorelease];
    self.eventsWebQueryFromSearch = [self.coreDataModel getMostRecentEventsWebQueryWithSearchTerm];
    self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
    NSLog(@"eventsWebQueryFromSearch was just updated in viewDidLoad and is now %@", self.eventsWebQueryFromSearch);
    NSLog(@"eventsWebQueryFromSearch was actually just pulled in for the first time and it is %@ which is notable right now *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***", self.eventsWebQueryFromSearch);
    
    // Make some decisions about showing browse mode vs. search mode
    EventsListMode mostRecentEventsListMode = [DefaultsModel loadEventsListMostRecentMode];
    if (mostRecentEventsListMode == ModeNotSet) {
        [DefaultsModel saveEventsListMostRecentMode:ModeBrowse];
    }
    BOOL mostRecentEventsListModeWasSearch = (mostRecentEventsListMode == ModeSearch);
    BOOL shouldDisplaySearchMode = mostRecentEventsListModeWasSearch && self.eventsFromSearch.count > 0;/* && self.eventsFromSearch.count > 0;*/ // THIS COULD CAUSE PROBLEMS IF WE START LETTING PEOPLE DELETE EVENTS FROM THE EVENT CARD WHEN THEY GOT TO THAT EVENT CARD FROM SEARCH MODE. CURRENTLY, WE DO NOT DELETES IN THAT CASE. It could cause a problem because if this view gets unloaded while the event card view controller is showing, and then the event gets deleted from the event card, and if that event was the only result that had come up from a search, then when this view gets reloaded, instead of reconstructing it in search mode, the condition above (self.eventsFromSearch.count > 0) would fail, and the view would be reconstructed in browse mode instead. This could either just be annoying for the user, or it could cause some real technical glitches. // UPDATE: This condition is just confusing things. For now, we'll let users go straight back to search, no matter how many results you had previously.
        
    // Block with which to find the index of a given filter option in a filter's options array, given ann array of filters and the desired filter code
    NSUInteger(^indexOfEventsFilterOptionBlock)(NSString *, NSArray *, NSString *)=^(NSString * filterCode, NSArray * filtersArray, NSString * filterOptionCode){
        NSLog(@"indexOfEventsFilterOptionBlock with filterCode=%@, filtersArray=%@, filterOptionCode=%@", filterCode, filtersArray, filterOptionCode);
        EventsFilter * filter = [self filterForFilterCode:filterCode inFiltersArray:filtersArray];
        NSArray * filterOptionsFound = [filter.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.code == %@", filterOptionCode]];
        EventsFilterOption * foundFO = nil;
        NSUInteger foundIndex = 0;
        if (filterOptionsFound && filterOptionsFound.count > 0) {
            foundFO = [filterOptionsFound objectAtIndex:0];
            foundIndex = [filter.options indexOfObject:foundFO];
        }
        return foundIndex;
    };
    
    // Do some initial setup for browse mode
    int indexOfActiveBrowseFilter = 0;
    NSString * categoryFilterURI = nil;
    int indexOfSelectedCategoryFilterOption = 0;
    int indexOfSelectedPriceFilterOption = priceOptions.count - 1;
    int indexOfSelectedDateFilterOption = dateOptions.count - 1;
    int indexOfSelectedTimeFilterOption = timeOptions.count - 1;
    int indexOfSelectedLocationFilterOption = locationOptions.count - 1;
    NSString * locationStringBrowse = nil;
    
    // Set a bunch of indexes from above
    if (self.eventsWebQuery != nil) {
        NSLog(@"Figuring out indexes for selected filter options for BROWSE");
        // indexOfActiveBrowseFilter... // Skipping for now. Not that important.
        categoryFilterURI = ((Category *)[self.eventsWebQuery.filterCategories anyObject]).uri; // THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES. THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES. THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES.
        indexOfSelectedCategoryFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_CATEGORIES, self.filters, [EventsFilterOption eventsFilterOptionCategoryCodeForCategoryURI:categoryFilterURI]);
        indexOfSelectedPriceFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_PRICE, self.filters, self.eventsWebQuery.filterPriceBucketString);
        indexOfSelectedDateFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_DATE, self.filters, self.eventsWebQuery.filterDateBucketString);
        NSLog(@"indexOfSelectedDateFilterOption=%d", indexOfSelectedDateFilterOption);
        indexOfSelectedTimeFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_TIME, self.filters, self.eventsWebQuery.filterTimeBucketString);
        indexOfSelectedLocationFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_LOCATION, self.filters, self.eventsWebQuery.filterDistanceBucketString);
        locationStringBrowse = self.eventsWebQuery.filterLocationString;
    }
    
    // Set the browse filter settings
    self.activeFilterInUI = [self.filters objectAtIndex:indexOfActiveBrowseFilter];
    self.selectedCategoryFilterOption = [categoryFilterOptions objectAtIndex:indexOfSelectedCategoryFilterOption];
    self.selectedPriceFilterOption = [priceOptions objectAtIndex:indexOfSelectedPriceFilterOption];
    self.selectedDateFilterOption = [dateOptions objectAtIndex:indexOfSelectedDateFilterOption];
    self.selectedTimeFilterOption = [timeOptions objectAtIndex:indexOfSelectedTimeFilterOption];
    self.selectedLocationFilterOption = [locationOptions objectAtIndex:indexOfSelectedLocationFilterOption];
    // More browse filter settings
    self.oldFilterString = EVENTS_OLDFILTER_RECOMMENDED; // This is deprecated, and constant.
    self.categoryURI = categoryFilterURI;
    // Events summary string
    self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];

    // Update views
    // Update filter option button states for browse
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedPriceFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationFilterOption];
    // Update filter button states for browse
    [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_PRICE inFiltersArray:self.filters]buttonImageForFilterOption:self.selectedPriceFilterOption];
    [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_DATE inFiltersArray:self.filters]buttonImageForFilterOption:self.selectedDateFilterOption];
    [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filters]buttonImageForFilterOption:self.selectedTimeFilterOption];
    [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_LOCATION inFiltersArray:self.filters]buttonImageForFilterOption:self.selectedLocationFilterOption];
    // Update category filter option button state
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
    
    // Start things off in browse mode, with browse filters.
    self.isSearchOn = NO;
    [self.filtersContainerView addSubview:self.filtersBarBrowse];
    [self.drawerScrollView addSubview:self.drawerViewsBrowseContainer];
    self.drawerScrollView.contentSize = self.drawerViewsBrowseContainer.bounds.size;
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filtersForCurrentSource.count;
    [self setDrawerToShowFilter:self.activeFilterInUI animated:NO];
    
    // Seed the feedback view as being visible
    self.feedbackViewIsVisible = YES; // THIS IS A TOTAL HACK, TO GET THE BALL ROLLING ON THE FEEDBACK VIEW BEING VISIBLE. REALLY, THIS VALUE SHOULD BE COMING FROM SOMEWHERE ELSE, PERHAPS A PREFERENCE, OR IT SHOULD JUST BE SET TO YES ALWAYS IN A MORE INTELLIGENT WAY.
    
    NSLog(@"About to updateViews for first time in viewDidLoad");
    [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:self.events.count > 0 reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS animated:NO];
    
    // Search setup
    int indexOfActiveSearchFilter = 0;
    int indexOfSelectedDateSearchFilterOption = dateSearchOptions.count - 1;
    int indexOfSelectedLocationSearchFilterOption = locationSearchOptions.count - 1;
    int indexOfSelectedTimeSearchFilterOption = timeSearchOptions.count - 1;
    NSString * locationStringSearch = nil;
    NSString * searchTerm = nil;
    
    // indexOfActiveSearchFilter... // Skipping for now. Not that important.
    if (self.eventsWebQueryFromSearch != nil) {
        [DefaultsModel saveEventsListMostRecentMode:ModeBrowse];
        NSLog(@"Figuring out indexes for selected filter options for SEARCH");
        NSLog(@"Using eventsWebQueryFromSearch=%@", self.eventsWebQueryFromSearch);
        indexOfSelectedDateSearchFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_DATE, self.filtersSearch, self.eventsWebQueryFromSearch.filterDateBucketString);
        indexOfSelectedTimeSearchFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_TIME, self.filtersSearch, self.eventsWebQueryFromSearch.filterTimeBucketString);
        indexOfSelectedLocationSearchFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_LOCATION, self.filtersSearch, self.eventsWebQueryFromSearch.filterDistanceBucketString);
        locationStringSearch = self.eventsWebQueryFromSearch.filterLocationString;
        searchTerm = self.eventsWebQueryFromSearch.searchTerm;
    }
    
    // Set the search filter settings
    self.activeSearchFilterInUI = [self.filtersSearch objectAtIndex:indexOfActiveSearchFilter];
    self.selectedDateSearchFilterOption = [dateSearchOptions objectAtIndex:indexOfSelectedDateSearchFilterOption];
    self.selectedLocationSearchFilterOption = [locationSearchOptions objectAtIndex:indexOfSelectedLocationSearchFilterOption];
    self.selectedTimeSearchFilterOption = [timeSearchOptions objectAtIndex:indexOfSelectedTimeSearchFilterOption];
    
    if (self.eventsWebQueryFromSearch == nil) {
        self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
        /* THE FOLLOWING CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
        self.eventsWebQueryFromSearch.searchTerm = searchTerm;
        self.eventsWebQueryFromSearch.filterDateBucketString = self.selectedDateSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterDistanceBucketString = self.selectedLocationSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchSetLocationButton.titleLabel.text; // LOCATION HACK
//        self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchTextField.text.length > 0 ? self.dvLocationSearchTextField.text : @"Current Location"; // LOCATION HACK
        self.eventsWebQueryFromSearch.filterTimeBucketString = self.selectedTimeSearchFilterOption.code;
        [self.coreDataModel coreDataSave];
        self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
        /* THE PREVIOUS CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
        NSLog(@"eventsWebQueryFromSearch was just updated in viewDidLoad and is now %@", self.eventsWebQueryFromSearch);
    }
    
    // Adjusted search filters... Sort of faking it for now. If any of the search filters were adjusted, we'll just pick one (that was adjusted) to be the most recently adjusted.
    self.adjustedSearchFiltersOrdered = [NSMutableArray arrayWithCapacity:self.filtersSearch.count];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_LOCATION inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedLocationSearchFilterOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedTimeFilterOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_DATE inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedDateFilterOption];
    
    // Set the feedback strings
    self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    
    if (shouldDisplaySearchMode) {
        
        [DefaultsModel saveEventsListMostRecentMode:ModeSearch];
                
        // Update filter option button states for search
        [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateSearchFilterOption];
        [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationSearchFilterOption];
        [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeSearchFilterOption];
        // Update filter button states for search
        [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_DATE inFiltersArray:self.filtersSearch]buttonImageForFilterOption:self.selectedDateSearchFilterOption];
        [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersSearch]buttonImageForFilterOption:self.selectedTimeSearchFilterOption];
        [self updateFilter:[self filterForFilterCode:EVENTS_FILTER_LOCATION inFiltersArray:self.filtersSearch]buttonImageForFilterOption:self.selectedLocationSearchFilterOption];
        
        // Switch to search mode.
        [self toggleSearchModeAnimated:NO shouldMakeSearchTextFieldActiveWhenTogglingOn:(self.eventsFromSearch.count == 0) shouldFlushQueryAndFilters:NO];
        
        // Set the search text field term
        self.searchTextField.text = searchTerm;

        NSLog(@"About to updateViews from within shouldDisplaySearchMode, when self.eventsFromSearch.count=%d", self.eventsFromSearch.count);
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:self.eventsFromSearch.count > 0 reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS animated:NO];
        
    }
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Register for login activity events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActivity:) name:@"loginActivity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(behaviorWasReset:) name:@"learningBehaviorWasReset" object:nil];
    
    ////////////////////
    // DEBUGGING BELOW
    
    BOOL debugging = NO;
    
    debugTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width / 2.0, 0, self.tableView.bounds.size.width / 2.0, self.tableView.bounds.size.height)];
    self.debugTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.debugTextView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.bounds.size.height, 0);
    self.debugTextView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    self.debugTextView.textColor = [UIColor whiteColor];
    self.debugTextView.font = [UIFont systemFontOfSize:12.0];
    [self.tableView addSubview:self.debugTextView];
    
    NSMutableString * debugText = [NSMutableString stringWithString:@"viewDidLoad finished:\n"];
    [debugText appendFormat:@"--- mostRecentViewMode was %d (%@)\n", mostRecentEventsListMode, mostRecentEventsListMode == 1 ? @"Browse" : mostRecentEventsListMode == 2 ? @"Search" : @"NotSet"];
    [debugText appendFormat:@"--- shouldDisplaySearchMode? %@\n", shouldDisplaySearchMode ? @"YES" : @"NO"];
    [debugText appendFormat:@"--- eventsWebQuery had %d associated events (which we are reading as %d events in our events array)\n", self.eventsWebQueryForCurrentSource.eventResults.count, self.eventsForCurrentSource.count];
    [debugText appendFormat:@"--- %@\n", self.eventsWebQueryForCurrentSource];
    self.debugTextView.text = debugText;
    NSLog(@"%@", debugText);
    
    self.debugTextView.hidden = !debugging;
    
    // DEBUGGING ABOVE
    ////////////////////
    
//    NSLog(@"OK FUCK IT I'M FIGURING THIS OUT - contentInset is %@ and feedbackView.height=%f AT END OF viewDidLoad", NSStringFromUIEdgeInsets(self.tableView.contentInset), self.feedbackView.bounds.size.height);
    
    
    
    
    NSLog(@"\n\n\n\n\n\n\n\n");
    NSLog(@"testing");
    windowFrame = [self.view convertRect:CGRectMake(0, 0, 320, 480) toView:self.tableView];
    NSLog(@"self.view.frame=%@", NSStringFromCGRect(self.view.frame));
    NSLog(@"windowFrame (re:searchContainerView) = %@", NSStringFromCGRect(windowFrame));
    NSLog(@"\n\n\n\n\n\n\n\n");

    
}

- (void) releaseReconstructableViews {
    self.tableView = nil;
    self.tableViewCoverViewContainer = nil;
    self.tableViewCoverView = nil;
    self.tableViewBackgroundView = nil;
    self.searchContainerView = nil;
    self.searchContainerViewShadowCheatView = nil;
    self.searchContainerTopEdgeView = nil;
    self.searchButton = nil;
    self.searchCancelButton = nil;
    self.searchGoButton = nil;
    self.searchTextField = nil;
    self.tableReloadContainerView = nil;
    self.tableReloadContainerShadowCheatView = nil;
    self.pushableContainerView = nil;
    self.pushableContainerShadowCheatView = nil;
    
    self.feedbackView = nil;
    
    self.filtersContainerView = nil;
    self.filtersContainerShadowCheatView = nil;
    self.filtersContainerShadowCheatWayBelowView = nil;
    self.activeFilterHighlightsContainerView = nil;
    self.drawerScrollView = nil;
    
    self.filtersBarBrowse = nil;
    self.filterButtonCategories = nil;
    self.filterButtonPrice = nil;
    self.filterButtonDate = nil;
    self.filterButtonLocation = nil;
    self.filterButtonTime = nil;
    
    self.filtersBarSearch = nil;
    self.filterSearchButtonDate = nil;
    self.filterSearchButtonLocation = nil;
    self.filterSearchButtonTime = nil;
    
    self.drawerViewsBrowseContainer = nil;
    self.drawerViewsSearchContainer = nil;
    
    self.drawerViewPrice = nil;
    self.dvPriceButtonFree = nil;
    self.dvPriceButtonUnder20 = nil;
    self.dvPriceButtonUnder50 = nil;
    self.dvPriceButtonAny = nil;
    
    self.drawerViewDate = nil;
    self.dvDateButtonToday = nil;
    self.dvDateButtonThisWeekend = nil;
    self.dvDateButtonThisWeek = nil;
    self.dvDateButtonThisMonth = nil;
    self.dvDateButtonAny = nil;
    
    self.drawerViewDateSearch = nil;
    self.dvDateSearchButtonToday = nil;
    self.dvDateSearchButtonThisWeekend = nil;
    self.dvDateSearchButtonThisWeek = nil;
    self.dvDateSearchButtonThisMonth = nil;
    self.dvDateSearchButtonAny = nil;
    
    self.drawerViewCategories = nil;
    
    self.drawerViewTime = nil;
    self.dvTimeButtonMorning = nil;
    self.dvTimeButtonAfternoon = nil;
    self.dvTimeButtonEvening = nil;
    self.dvTimeButtonNight = nil;
    self.dvTimeButtonAny = nil;
    
    self.drawerViewTimeSearch = nil;
    self.dvTimeSearchButtonMorning = nil;
    self.dvTimeSearchButtonAfternoon = nil;
    self.dvTimeSearchButtonEvening = nil;
    self.dvTimeSearchButtonNight = nil;
    self.dvTimeSearchButtonAny = nil;
    
    self.drawerViewLocation = nil;
    self.dvLocationSetLocationButton = nil;
    self.dvLocationCurrentLocationButton = nil;
    self.dvLocationButtonWalking = nil;
    self.dvLocationButtonNeighborhood = nil;
    self.dvLocationButtonBorough = nil;
    self.dvLocationButtonCity = nil;
    
    self.drawerViewLocationSearch = nil;
    self.dvLocationSearchSetLocationButton = nil;
    self.dvLocationSearchCurrentLocationButton = nil;
    self.dvLocationSearchButtonWalking = nil;
    self.dvLocationSearchButtonNeighborhood = nil;
    self.dvLocationSearchButtonBorough = nil;
    self.dvLocationSearchButtonCity = nil;
    
    self.webActivityView = nil;
    [connectionErrorStandardAlertView release];
    connectionErrorStandardAlertView = nil;
    [connectionErrorOnDeleteAlertView release];
    connectionErrorOnDeleteAlertView = nil;
    [resetAllFiltersAlertView release];
    resetAllFiltersAlertView = nil;
    self.tapToHideDrawerGR = nil;
    
    self.debugTextView = nil;
}

- (void) releaseReconstructableViewModels {
    self.filters = nil;
    self.filtersSearch = nil;
    self.activeFilterInUI = nil;
    self.activeSearchFilterInUI = nil;
    self.selectedCategoryFilterOption = nil;
    self.selectedDateFilterOption = nil;
    self.selectedDateSearchFilterOption = nil;
    self.selectedLocationFilterOption = nil;
    self.selectedLocationSearchFilterOption = nil;
    self.selectedPriceFilterOption = nil;
    self.selectedTimeFilterOption = nil;
    self.selectedTimeSearchFilterOption = nil;
    self.adjustedSearchFiltersOrdered = nil;
    self.oldFilterString = nil;
    self.categoryURI = nil;
}

- (void)didReceiveMemoryWarning {
    NSLog(@"--- --- --- --- --- EventsViewController didReceiveMemoryWarning --- --- --- --- ---");
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    NSLog(@"--- --- --- --- --- EventsViewController viewDidUnload --- --- --- --- ---");
    [super viewDidUnload];
    [self releaseReconstructableViews];
    [self releaseReconstructableViewModels];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.eventsForCurrentSource.count == 0) {
        if (self.isSearchOn) {
            // Not going to do anything on this path for now... Just leave the list blank?
        } else {
            //            NSLog(@"No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events.");
            [self setFeedbackViewMessageType:LoadingEventsTrue eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:NO];
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        }
    } else {
        if (self.indexPathOfSelectedRow != nil) {
            // - Make sure that the row that should be selected is selected.
            // - Make sure that the table view content offset is set to what it once was (only an issue if there had been a memory warning).
            [self.tableView selectRowAtIndexPath:self.indexPathOfSelectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        CGPoint preservedContentOffsetAdjusted = self.tableViewContentOffsetPreserved;
        // Order matters in the following two lines of code.
        preservedContentOffsetAdjusted.y = MIN(preservedContentOffsetAdjusted.y, self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom);
        preservedContentOffsetAdjusted.y = MAX(preservedContentOffsetAdjusted.y, 0); // This needs to come after the previous line of code. Otherwise, we get strange behavior when the table view content size is smaller (roughly) than the table view bounds height. We could handle this more intelligently, but I'm tired.
        // The following is trying to fix some weird very specific bug where if we were coming back from a reloaded view (after memory warning) in search mode and we had been scrolled all the way to the bottom of the list, that we would get popped up a bit. // HACK DIDN'T WORK.
        //        if (self.isSearchOn &&
        //            self.tableViewContentOffsetPreserved.y > self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom - self.tableView.rowHeight) { // THIS HACK RELIES ON TABLE VIEW ROW HEIGHTS BEING EQUAL
        //            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.eventsFromSearch.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //        } else {
        [self.tableView setContentOffset:preservedContentOffsetAdjusted animated:NO];
        //        }
        
        NSLog(@"FIGURING THIS OUT, setContentOffset=%@", NSStringFromCGPoint(preservedContentOffsetAdjusted));
        NSLog(@"FIGURING THIS OUT, self.tableView.contentOffset is %@", NSStringFromCGPoint(self.tableView.contentOffset));
    }
    
    //    NSLog(@"OK FUCK IT I'M FIGURING THIS OUT - contentInset is %@ and feedbackView.height=%f AT END OF viewWillAppear", NSStringFromUIEdgeInsets(self.tableView.contentInset), self.feedbackView.bounds.size.height);
    
    //    NSLog(@"\n\nINDEX PATH FOR SELECTED ROW ACCORDING TO TABLEVIEW IS %@\n\n", self.indexPathOfSelectedRow);
    //    [self.tableView selectRowAtIndexPath:self.indexPathOfSelectedRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    //    NSLog(@"\n\nINDEX PATH FOR SELECTED ROW ACCORDING TO TABLEVIEW IS %@\n\n", self.indexPathOfSelectedRow);
    
    [self updateTimeFilterOptions:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersForCurrentSource].options forSearch:self.isSearchOn givenSelectedDateFilterOption:self.isSearchOn ? self.selectedDateSearchFilterOption : self.selectedDateFilterOption userTime:[NSDate date]];
    
}

// On viewDidAppear, we should deselect the highlighted row (if there is one).
- (void)viewDidAppear:(BOOL)animated
{
    // Call super
	[super viewDidAppear:animated];
    [self suggestToRedrawEventsList];
    // Following if statement should never return true, but that's OK.
    if (![self.searchTextField isFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    NSLog(@"\n\nINDEX PATH FOR SELECTED ROW IS %@\n\n", self.indexPathOfSelectedRow);
    
    // I believe the following is old, and now unnecessary, and now causing bugs of its own.
    //    // Fixing some strange bug where if you are in search mode and not at the top of the events list, then push an event card, then come back to the events list, then the search text field (which we had been sticking at the top of the screen) would disappear until you scrolled the table view (at which point it would stick back at the top of the screen).
    //    if (self.isSearchOn) {
    //        CGRect scvf = self.searchContainerView.frame;
    //        scvf.origin.y = self.tableView.bounds.origin.y;
    //        self.searchContainerView.frame = scvf;
    //    }
    
    if (self.webConnector.connectionInProgress) {
        [self setFeedbackViewMessageType:LoadingEventsTrue eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:self.eventsWebQueryForCurrentSource.searchTerm animated:animated];
        [self showWebLoadingViews];
    }
    
    if (self.deletedFromEventCard) {
        Event * eventToDelete = [self.eventsForCurrentSource objectAtIndex:self.indexPathOfSelectedRow.row];
        
        [self.coreDataModel deleteRegularEventForURI:eventToDelete.uri];
        
        // Delete event from our table display array
        [self.eventsForCurrentSource removeObjectAtIndex:self.indexPathOfSelectedRow.row];
        
        // Animate event deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathOfSelectedRow] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    // Deselect selected row, if there is one
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated]; // There is something weird going on with the animation - it is going really slowly. Figure this out later. It doesn't look horrible right now though, so, I'm just going to leave it.
    
    //    NSLog(@"OK FUCK IT I'M FIGURING THIS OUT - contentInset is %@ and feedbackView.height=%f AT END OF viewDidAppear", NSStringFromUIEdgeInsets(self.tableView.contentInset), self.feedbackView.bounds.size.height);
    
    self.deletedFromEventCard = NO;
    self.indexPathOfSelectedRow = nil;
    
    NSLog(@"FIGURING THIS OUT, self.tableView.contentOffset is %@", NSStringFromCGPoint(self.tableView.contentOffset));
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableViewContentOffsetPreserved = self.tableView.contentOffset;
    NSLog(@"FIGURING THIS OUT, self.tableViewContentOffsetPreserved=%@", NSStringFromCGPoint(self.tableViewContentOffsetPreserved));
    //    if (self.isDrawerOpen) {
    //        [self toggleDrawerAnimated];
    //    } // I like this behavior less and less, especially when closing the drawer is what a user does to initiate an events reload (with newly adjusted filters).
    [self resignFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (self.isDrawerOpen) {
//        [self toggleDrawerAnimated:NO];
//    }
}

- (void) setUpFiltersUI:(NSArray *)arrayOfEventsFilters withOptionButtonSelectors:(NSDictionary *)dictionaryOfEventFilterOptionSelectors compressedOptionButtons:(BOOL)compressed {
    
    for (EventsFilter * filter in arrayOfEventsFilters) {
        filter.drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
        filter.drawerView.backgroundColor = [UIColor clearColor]; // TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT
        [filter.button setTitle:[filter.buttonText uppercaseString] forState:UIControlStateNormal];
        filter.button.titleLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:12.0];
        filter.button.adjustsImageWhenHighlighted = NO;
        if (![filter.code isEqualToString:EVENTS_FILTER_CATEGORIES]) {
            filter.button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
            UIEdgeInsets filterButtonTitleEdgeInsets = filter.button.titleEdgeInsets;
            UIEdgeInsets filterButtonImageEdgeInsets = filter.button.imageEdgeInsets;
            filterButtonTitleEdgeInsets.bottom = 16;
            filterButtonImageEdgeInsets.bottom = 16;
            filter.button.titleEdgeInsets = filterButtonTitleEdgeInsets;
            filter.button.imageEdgeInsets = filterButtonImageEdgeInsets;
        }
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        
        SEL filterOptionButtonSelector = [[dictionaryOfEventFilterOptionSelectors objectForKey:filter.code] pointerValue];
        for (EventsFilterOption * filterOption in filter.options) {
            
            // Set button option target
            [filterOption.buttonView.button addTarget:self action:filterOptionButtonSelector forControlEvents:UIControlEventTouchUpInside];
            
            // A lot of the following probably would work for the category filter option buttons, but I just don't have the time to go through and check right now. Category filter option buttons are being set up with legacy code in viewDidLoad.
            if (![filter.code isEqualToString:EVENTS_FILTER_CATEGORIES]) {
                
                // Prep to set button option images
                BOOL squareButton = compressed && !([filterOption.code isEqualToString:EFO_CODE_DATE_ANY] || [filterOption.code isEqualToString:EFO_CODE_TIME_ANY]);
                NSString * optionImagesNameBase = @"btn_filter_option";
                if (squareButton) { 
                    optionImagesNameBase = [optionImagesNameBase stringByAppendingString:@"_sq"];
                }
                NSString * optionImagesNameExtension = @".png";
                UIImage * (^optionImage) (NSString *) = ^(NSString * imageSpec) {
                    return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@%@", optionImagesNameBase, imageSpec, optionImagesNameExtension]];
                };
                
                // Set button option images
                [filterOption.buttonView.button setBackgroundImage:optionImage(@"_unselected") forState:UIControlStateNormal];
                [filterOption.buttonView.button setBackgroundImage:optionImage(@"_unselected_touch") forState:UIControlStateHighlighted];
                [filterOption.buttonView.button setBackgroundImage:optionImage(@"_selected") forState:UIControlStateSelected];
                [filterOption.buttonView.button setBackgroundImage:optionImage(@"_selected") forState:UIControlStateSelected | UIControlStateHighlighted];
                filterOption.buttonView.overlay.image = optionImage(@"_shine");
                filterOption.buttonView.buttonIconImage = [UIImage imageNamed:[EventsFilterOption eventsFilterOptionIconFilenameForCode:filterOption.code grayscale:NO larger:squareButton]];
                
                // Set button text
                if (!squareButton) {
                    filterOption.buttonView.buttonText = filterOption.buttonText;
                    UIColor * darkTextColor  = [UIColor colorWithWhite: 53.0/255.0 alpha:1.0];
                    UIColor * lightTextColor = [UIColor colorWithWhite:251.0/255.0 alpha:1.0];
                    [filterOption.buttonView.button setTitleColor:darkTextColor forState:UIControlStateNormal];
                    [filterOption.buttonView.button setTitleColor:darkTextColor forState:UIControlStateHighlighted];
                    [filterOption.buttonView.button setTitleColor:lightTextColor forState:UIControlStateSelected];
                    [filterOption.buttonView.button setTitleColor:lightTextColor forState:UIControlStateSelected | UIControlStateHighlighted];
                } else {
                    // Label
                    CGFloat categoryTitleLabelTopSpacing = 3;
                    CGFloat horizontalForgiveness = 10;
                    UILabel * buttonLabel = [[[UILabel alloc] initWithFrame:CGRectMake(filterOption.buttonView.frame.origin.x - horizontalForgiveness, CGRectGetMaxY(filterOption.buttonView.frame) + categoryTitleLabelTopSpacing, filterOption.buttonView.frame.size.width + horizontalForgiveness * 2, 25)] autorelease];
                    buttonLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
                    buttonLabel.textAlignment = UITextAlignmentCenter;
                    buttonLabel.backgroundColor = [UIColor clearColor];
                    buttonLabel.text = filterOption.buttonText;
                    [filter.drawerView addSubview:buttonLabel];
                }
                
                // Set other button attributes
                filterOption.buttonView.cornerRadius = squareButton ? 10.0 : 5.0;
                filterOption.buttonView.button.adjustsImageWhenHighlighted = NO;
                
            }

        }
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (NSMutableArray *)eventsForCurrentSource {
    return self.isSearchOn ? self.eventsFromSearch : self.events;
}

- (EventsWebQuery *)eventsWebQueryForCurrentSource {
    return self.isSearchOn ? self.eventsWebQueryFromSearch : self.eventsWebQuery;
}

- (NSArray *) filtersForCurrentSource {
    return self.isSearchOn ? self.filtersSearch : self.filters;
}

- (NSString *)eventsSummaryStringForCurrentSource {
    return self.isSearchOn ? self.eventsSummaryStringSearch : self.eventsSummaryStringBrowse;
}

- (NSDictionary *)concreteParentCategoriesDictionary {
    if (concreteParentCategoriesDictionary == nil) {
        concreteParentCategoriesDictionary = [[self.coreDataModel getAllCategoriesWithColorInDictionaryWithURIKeys] retain];
    }
    return concreteParentCategoriesDictionary;
}

- (NSArray *)concreteParentCategoriesArray {
    if (concreteParentCategoriesArray == nil) {
        concreteParentCategoriesArray = [[self.coreDataModel getAllCategoriesWithColor] retain];
    }
    return concreteParentCategoriesArray;
}

- (WebConnector *) webConnector {
    if (webConnector == nil) {
        webConnector = [[WebConnector alloc] init];
        webConnector.delegate = self;
//        webConnector.allowSimultaneousConnection = YES;
    }
    return webConnector;
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

- (UIAlertView *)connectionErrorStandardAlertView {
    if (connectionErrorStandardAlertView == nil) {
        connectionErrorStandardAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorStandardAlertView;
}

- (UIAlertView *)connectionErrorOnDeleteAlertView {
    if (connectionErrorOnDeleteAlertView == nil) {
        connectionErrorOnDeleteAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry, due to a connection error, we could not complete your request. Please check your settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorOnDeleteAlertView;
}

- (UIAlertView *)resetAllFiltersAlertView {
    if (resetAllFiltersAlertView == nil) {
        resetAllFiltersAlertView = [[UIAlertView alloc] initWithTitle:@"Reset all filters?" message:@"Are you sure you'd like to reset all filters, and get a new list of general recommended events?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
    }
    return resetAllFiltersAlertView;
}

- (void) webConnectGetEventsListWithCurrentOldFilterAndCategory {
//    NSLog(@"EventsViewController webConnectGetEventsListWithCurrentFilterAndCategory");
    [self webConnectGetEventsListWithOldFilter:self.oldFilterString categoryURI:self.categoryURI];
}

- (void) webConnectGetEventsListWithOldFilter:(NSString *)theProposedOldFilterString categoryURI:(NSString *)theProposedCategoryURI {
//    NSLog(@"EventsViewController webConnectGetEventsListWithFilter");

    // Storing and using EventWebQuery objects
    if (self.eventsWebQuery == nil || 
        self.eventsWebQuery.queryDatetime != nil) {
        self.eventsWebQuery = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
    }
    self.eventsWebQuery.filterDateBucketString = self.selectedDateFilterOption.code;
    self.eventsWebQuery.filterDistanceBucketString = self.selectedLocationFilterOption.code;
    self.eventsWebQuery.filterLocationString = self.dvLocationSetLocationButton.titleLabel.text; // LOCATION HACK
//    self.eventsWebQuery.filterLocationString = self.dvLocationTextField.text.length > 0 ? self.dvLocationTextField.text : @"Current Location"; // LOCATION HACK
    self.eventsWebQuery.filterPriceBucketString = self.selectedPriceFilterOption.code;
    self.eventsWebQuery.filterTimeBucketString = self.selectedTimeFilterOption.code;
    Category * filterCategory = [self.coreDataModel getCategoryWithURI:theProposedCategoryURI];
    if (filterCategory) { [self.eventsWebQuery addFilterCategoriesObject:filterCategory]; }
    [self.coreDataModel coreDataSave];
    
    self.oldFilterString = theProposedOldFilterString;
    self.categoryURI = theProposedCategoryURI;
    
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
//    [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource animated:YES]; // Moving this outside of this method, because we don't always want to do it when doing a web call. We could do it within this method conditionally using some sort of parameter, but I don't have the patience to make that kind of change right now. I also don't really think that would be appropriate, despite being easier.
    [self showWebLoadingViews];
    [self.webConnector getRecommendedEventsWithCategoryURI:self.categoryURI minPrice:self.eventsWebQuery.filterPriceMinimum maxPrice:self.eventsWebQuery.filterPriceMaximum startDateEarliest:self.eventsWebQuery.filterDateEarliest startDateLatest:self.eventsWebQuery.filterDateLatest startTimeEarliest:self.eventsWebQuery.filterTimeEarliest startTimeLatest:self.eventsWebQuery.filterTimeLatest];
//    [self.webConnector getEventsListWithFilter:self.oldFilterString categoryURI:self.categoryURI];
    
    /////////////////////
    // Localytics below
    NSString * localyticsFilterString = @"recommended";
    if (theProposedOldFilterString) { 
        localyticsFilterString = theProposedOldFilterString;
    }
    NSString * localyticsCategoryString = @"all";
    if (theProposedCategoryURI) {
        Category * category = [self.coreDataModel getCategoryWithURI:theProposedCategoryURI];
        localyticsCategoryString = category.title;
    }
    [Analytics localyticsSendGetEventsWithFilter:localyticsFilterString category:localyticsCategoryString];
    // Localytics above
    /////////////////////
    
}

// Process the new retrieved events (if there are indeed successfully retrieved events) and get them into Core Data
- (void) webConnector:(WebConnector *)webConnector getRecommendedEventsSuccess:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {

    NSString * responseString = [request responseString];
    //    NSLog(@"EventsViewController webConnector:getEventsListSuccess:withFilter:categoryURI: - response is %@", responseString);
    NSError * error = nil;
    NSDictionary * dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSArray * eventsDictionaries = [dictionaryFromJSON valueForKey:@"objects"];
    
    BOOL haveResults = eventsDictionaries && [eventsDictionaries count] > 0;
    
    if (haveResults) {
        
        int order = 0;
        // Loop through and process all event dictionaries
        for (NSDictionary * eventSummaryDictionary in eventsDictionaries) {
            
            Event * newEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            [self.coreDataModel updateEvent:newEvent usingEventSummaryDictionary:eventSummaryDictionary featuredOverride:nil fromSearchOverride:nil];
            
            EventResult * newEventResult = [NSEntityDescription insertNewObjectForEntityForName:@"EventResult" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            newEventResult.order = [NSNumber numberWithInt:order];
            order++;
            newEventResult.event = newEvent;
            newEventResult.query = self.eventsWebQuery;
            
        }
        
        // Save the current timestamp as the last time we retrieved events (regardless of filter/category)
        NSDate * now = [NSDate date];
        [DefaultsModel saveLastEventsListGetDate:now];
        self.eventsWebQuery.queryDatetime = now;
        // Update events array
        self.events = [self.eventsWebQuery.eventResultsEventsInOrder.mutableCopy autorelease];
                
    } else {
        self.eventsWebQuery.queryDatetime = [NSDate date];
        self.events = nil;
    }
    
    // Save our core data changes
    [self.coreDataModel coreDataSave];
    
    if (!self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:haveResults reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS animated:YES];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getRecommendedEventsFailure:(ASIHTTPRequest *)request withCategoryURI:(NSString *)categoryURI minPrice:(NSNumber *)minPriceInclusive maxPrice:(NSNumber *)maxPriceInclusive startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    
    NSString * statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError * error = [request error];
	NSLog(@"%@",error);
    
    self.eventsWebQuery.queryDatetime = [NSDate date];
    self.events = nil;
    
    // Save our core data changes
    [self.coreDataModel coreDataSave];
    
    if (!self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:NO reasonIfNot:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR animated:YES];
    }
    
}

- (void) searchExecutionRequestedByUser {
    
    NSString * searchTerm = self.searchTextField.text;
    
    if (searchTerm && searchTerm.length > 0) {
        
        [self.searchTextField resignFirstResponder];
        if (self.isDrawerOpen) {
            self.shouldReloadOnDrawerClose = NO; // Kind of a hack... Should sort out who calls who.
            [self toggleDrawerAnimated:YES];
        }
        
        // Storing and using EventWebQuery objects
        if (self.eventsWebQueryFromSearch == nil ||
            self.eventsWebQueryFromSearch.queryDatetime != nil) {
            self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];            
        }
        /* THE FOLLOWING CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
        self.eventsWebQueryFromSearch.searchTerm = searchTerm;
        self.eventsWebQueryFromSearch.filterDateBucketString = self.selectedDateSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterDistanceBucketString = self.selectedLocationSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSetLocationButton.titleLabel.text; // LOCATION HACK
//        self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchTextField.text.length > 0 ? self.dvLocationSearchTextField.text : @"Current Location"; // LOCATION HACK
        self.eventsWebQueryFromSearch.filterTimeBucketString = self.selectedTimeSearchFilterOption.code;
        [self.coreDataModel coreDataSave];
        self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
        /* THE PREVIOUS CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
        NSLog(@"eventsWebQueryFromSearch was just updated in searchExecutionRequestedByUser and is now %@", self.eventsWebQueryFromSearch);
        self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
        [self setFeedbackViewIsVisible:YES animated:YES];
        [self setFeedbackViewMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringSearch searchString:self.eventsWebQueryFromSearch.searchTerm animated:YES];
        [self showWebLoadingViews];
        [self.webConnector getEventsListForSearchString:searchTerm startDateEarliest:self.eventsWebQueryFromSearch.filterDateEarliest startDateLatest:self.eventsWebQueryFromSearch.filterDateLatest startTimeEarliest:self.eventsWebQueryFromSearch.filterTimeEarliest startTimeLatest:self.eventsWebQueryFromSearch.filterTimeLatest];
//        [self.webConnector getEventsListForSearchString:searchTerm];
        
    } else {
        
        UIAlertView * noSearchTermAlertView = [[UIAlertView alloc] initWithTitle:@"Missing Search Term" message:@"Please enter at least one search term in the text field above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noSearchTermAlertView show];
        [noSearchTermAlertView release];
        
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    
    NSString * responseString = [request responseString];
    //    NSLog(@"EventsViewController webConnector:getEventsListSuccess:withFilter:categoryURI: - response is %@", responseString);
    NSError * error = nil;
    NSDictionary * dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSArray * eventsDictionaries = [dictionaryFromJSON valueForKey:@"objects"];
    
    BOOL haveResults = eventsDictionaries && [eventsDictionaries count] > 0;
    
    if (haveResults) {
        
        int order = 0;
        // Loop through and process all event dictionaries
        for (NSDictionary * eventSummaryDictionary in eventsDictionaries) {
            
            Event * newEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            [self.coreDataModel updateEvent:newEvent usingEventSummaryDictionary:eventSummaryDictionary featuredOverride:nil fromSearchOverride:[NSNumber numberWithBool:YES]];
            
            EventResult * newEventResult = [NSEntityDescription insertNewObjectForEntityForName:@"EventResult" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            newEventResult.order = [NSNumber numberWithInt:order];
            order++;
            newEventResult.event = newEvent;
            newEventResult.query = self.eventsWebQueryFromSearch;
            
        }
        
        self.eventsWebQueryFromSearch.queryDatetime = [NSDate date];
        // Update events array
        self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
                        
    } else {
        self.eventsWebQueryFromSearch.queryDatetime = [NSDate date];
        self.eventsFromSearch = nil;
    }
    
    // Save our core data changes
    [self.coreDataModel coreDataSave];
        
    if (self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:haveResults reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS animated:YES];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString startDateEarliest:(NSDate *)startDateEarliestInclusive startDateLatest:(NSDate *)startDateLatestInclusive startTimeEarliest:(NSDate *)startTimeEarliestInclusive startTimeLatest:(NSDate *)startTimeLatestInclusive {
    
    NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    self.eventsWebQueryFromSearch.queryDatetime = [NSDate date];
    self.eventsFromSearch = nil;
    
    // Save our core data changes
    [self.coreDataModel coreDataSave];
    
    if (self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:NO reasonIfNot:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR animated:YES];
    }
    
}

- (void) updateViewsFromCurrentSourceDataWhichShouldBePopulated:(BOOL)dataShouldBePopulated reasonIfNot:(NSString *)reasonIfNotPopulated animated:(BOOL)animated {
    
    if (!self.isSearchOn) {
        self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
    } else {
        self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    }
    
    [self.tableView reloadData];
    BOOL haveEvents = self.eventsForCurrentSource.count > 0;
//    self.tableViewCoverView.alpha = haveEvents ? 0.0 : 1.0;
    if (!self.isSearchOn) {
        if (haveEvents) {
            CGFloat y = 0;
            if (self.tableView.contentSize.height - self.searchContainerView.bounds.size.height >= self.tableView.bounds.size.height) {
                y = self.searchContainerView.bounds.size.height;
            }
            [self.tableView setContentOffset:CGPointMake(0, y) animated:animated];
        }
    } else {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
    }
    
    NSLog(@"haveEvents in updateViews is %d", haveEvents);
    BOOL showTableFooterView = !self.isSearchOn && haveEvents;
    self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = showTableFooterView;
    NSLog(@"setTableViewScrollable from updateViews, could be sending NO");
    [self setTableViewScrollable:haveEvents selectable:haveEvents];
    if (haveEvents) {
        // Events were retrieved... They will be displayed.
        [self setFeedbackViewMessageType:LookingAtEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:self.eventsWebQueryForCurrentSource.searchTerm animated:animated];
    } else {
        // No events were retrieved. Respond accordingly, depending on the reason.
        if ([reasonIfNotPopulated isEqualToString:EVENTS_NO_RESULTS_REASON_NO_RESULTS]) {
            if (self.isSearchOn) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"No results" message:@"Sorry, we couldn't find any events matching your search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                [self.searchTextField becomeFirstResponder];
                [self setFeedbackViewIsVisible:NO animated:animated];
            } else {
                [self setFeedbackViewMessageType:NoEventsFound eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:animated];
            }
        } else if ([reasonIfNotPopulated isEqualToString:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR]) {
            [self setFeedbackViewMessageType:ConnectionError eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:self.eventsWebQueryForCurrentSource.searchTerm animated:animated];
            if (self.isSearchOn) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            } else {
                // ...
            }
        } else {
            NSLog(@"ERROR in EventsViewController - events array is empty for unknown reason.");
        }
    }
    
//    UIEdgeInsets tableViewInset = self.tableView.contentInset;
//    tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
//    self.tableView.contentInset = tableViewInset;
    
    [self hideWebLoadingViews];
    
}

- (void) setDrawerReloadIndicatorViewIsVisible:(BOOL)isVisible animated:(BOOL)animated { // This method actually can't animate currently, given our new reload indicator style. We could update this later, although I'm not even sure we want to. A hard transition is fine for now.

    void (^reloadIndicatorChangeBlock)(void) = ^{
        [self.activeFilterHighlightsContainerView setHighlightImage:
         (isVisible ? 
          [UIImage imageNamed:@"filter_select_glow_green.png"] :
          [UIImage imageNamed:@"filter_select_glow.png"])];
//        self.drawerReloadIndicatorView.alpha = isVisible ? 0.75 : 0.0;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.15 animations:reloadIndicatorChangeBlock];
    } else {
        reloadIndicatorChangeBlock();
    }
    
}

- (void) suggestToRedrawEventsList {

    NSDate * lastReloadDate = [DefaultsModel loadLastEventsListGetDate];
    NSDate * nowDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    BOOL lastReloadDateWasToday = [[dateFormatter stringFromDate:lastReloadDate] isEqualToString:[dateFormatter stringFromDate:nowDate]];
    [dateFormatter release];
    
    if (!lastReloadDateWasToday) {
        NSLog(@"Redrawing events list");
        [self.tableView reloadData];
        NSLog(@"EventsViewController tableView reloadData");
    }

}

- (void) forceToReloadEventsList {
    BOOL animated = self.view.window != nil;
    [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:self.eventsForCurrentSource.count > 0 reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS animated:animated];
//    [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
//    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

- (IBAction) filterButtonTouched:(id)sender {
    
    EventsFilter * oldActiveFilterInUI = nil;
    EventsFilter * newActiveFilterInUI = [self filterForFilterButton:sender inFiltersArray:self.filtersForCurrentSource];
    if (self.isSearchOn) {
        oldActiveFilterInUI = self.activeSearchFilterInUI;
        self.activeSearchFilterInUI = newActiveFilterInUI;
    } else {
        oldActiveFilterInUI = self.activeFilterInUI;
        self.activeFilterInUI = newActiveFilterInUI;
    }
    
    [self setDrawerToShowFilter:newActiveFilterInUI animated:self.isDrawerOpen];

    if (!self.isDrawerOpen ||
        oldActiveFilterInUI == newActiveFilterInUI) {
        [self toggleDrawerAnimated:YES];
    } // THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE 
    
}

- (IBAction) reloadEventsListButtonTouched:(id)sender {
    [self setFeedbackViewMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES]; // This button only gets used/touched in browse mode
    [self setFeedbackViewIsVisible:YES animated:YES]; // In case the feedback view was hidden due to the table view being scrolled to the very bottom. (I think we want the feedback view to pop up immediately, rather than wait for the web response.)
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable {
    NSLog(@"setTableViewScrollable:(BOOL)scrollable=%d selectable:(BOOL)selectable=%d", scrollable, selectable);
    self.tableView.scrollEnabled = scrollable;
    self.tableView.allowsSelection = selectable;
}

#pragma mark Search

- (void) adjustSearchViewsToShowButtons:(BOOL)showButtons {
    
    int reverser = showButtons ? 1 : -1;
    
    // Set search UI shifts up
    CGFloat searchCancelButtonShift = reverser * (7 + self.searchCancelButton.frame.size.width);
    CGFloat searchGoButtonShift = reverser * -(7 + self.searchGoButton.frame.size.width);
    CGFloat textFieldSpacing = showButtons ? 7 : 10;
    // Shift search cancel button
    CGRect scbf = self.searchCancelButton.frame;
    scbf.origin.x += searchCancelButtonShift;
    self.searchCancelButton.frame = scbf;
    // Shift search go button
    CGRect sgbf = self.searchGoButton.frame;
    sgbf.origin.x += searchGoButtonShift;
    self.searchGoButton.frame = sgbf;
    // Shift search text field
    CGRect stff = self.searchTextField.frame;
    stff.origin.x = CGRectGetMaxX(scbf) + textFieldSpacing;
    stff.size.width = CGRectGetMinX(sgbf) - textFieldSpacing - stff.origin.x;
    self.searchTextField.frame = stff;
    
}

- (void) setFiltersBarViewsOriginY:(CGFloat)originY adjustDrawerViewsAccordingly:(BOOL)shouldAdjustDrawerViews {

    // Move filters bar
    CGRect filtersBarFrame = self.filtersContainerView.frame;
    filtersBarFrame.origin.y = originY;
    self.filtersContainerView.frame = filtersBarFrame;
    // Move filters bar shadows
    self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
    self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
    
    // Move drawer views
    if (shouldAdjustDrawerViews) {
        CGFloat drawerViewsOriginY = CGRectGetMaxY(filtersBarFrame);
        CGRect drawerScrollViewFrame = self.drawerScrollView.frame;
        drawerScrollViewFrame.origin.y = drawerViewsOriginY;
        self.drawerScrollView.frame = drawerScrollViewFrame;
        CGRect activeFilterHighlightFrame = self.activeFilterHighlightsContainerView.frame;
        activeFilterHighlightFrame.origin.y = drawerViewsOriginY;
        self.activeFilterHighlightsContainerView.frame = activeFilterHighlightFrame;
    }
    
}

- (void) setPushableContainerViewsOriginY:(CGFloat)originY adjustHeightToFillMainView:(BOOL)shouldAdjustHeight {
    
    CGFloat tableViewBackgroundViewOriginalOriginY = self.tableViewBackgroundView.frame.origin.y;
    
    CGRect pcvf_o = self.pushableContainerView.frame;
    CGRect pcscv_o = self.pushableContainerShadowCheatView.frame;
    CGRect tvbvb_o = self.tableViewBackgroundView.bounds;
    CGRect tvbvf_o = self.tableViewBackgroundView.frame;
    CGRect tvcvf_o = self.tableViewCoverView.frame;
    CGRect tvcvb_o = self.tableViewCoverView.bounds;
    
    CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
    CGFloat originalOriginY = pushableContainerViewFrame.origin.y;
    pushableContainerViewFrame.origin.y = originY;
    CGFloat originYAdjustment = pushableContainerViewFrame.origin.y - originalOriginY;
    if (shouldAdjustHeight) {
        pushableContainerViewFrame.size.height = self.view.bounds.size.height - pushableContainerViewFrame.origin.y;        
    }
    self.pushableContainerView.frame = pushableContainerViewFrame;
    CGRect pushableContainerShadowFrame = self.pushableContainerShadowCheatView.frame;
    pushableContainerShadowFrame.origin.y = self.pushableContainerView.frame.origin.y;
    self.pushableContainerShadowCheatView.frame = pushableContainerShadowFrame;
    
//    NSLog(@"\n\n\n\n\n\n\n\n");
//    NSLog(@"testing");
//    CGRect testingFrame = [self.view convertRect:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, 320, 480) toView:self.tableViewBackgroundView.superview];
//    NSLog(@"testing ::: %@", NSStringFromCGRect(testingFrame));
//    NSLog(@"\n\n\n\n\n\n\n\n");
    
//    CGRect tableViewBackgroundViewFrame = self.tableViewBackgroundView.frame;
//    tableViewBackgroundViewFrame.origin.y = testingFrame.origin.y;
////    tableViewBackgroundViewFrame.origin.y = tableViewBackgroundViewOriginalOriginY - originYAdjustment;
//    self.tableViewBackgroundView.frame = tableViewBackgroundViewFrame;
    
    [self matchTableViewCoverViewToTableView];
    
    NSLog(@"\n*\n*\n*\nsetPushableContainerViewsOriginY");
    NSLog(@"pushableContainerView.frame ::: %@ to %@", NSStringFromCGRect(pcvf_o), NSStringFromCGRect(self.pushableContainerView.frame));
    NSLog(@"pushableContainerShadowCheatView.frame ::: %@ to %@", NSStringFromCGRect(pcscv_o), NSStringFromCGRect(self.pushableContainerShadowCheatView.frame));
    NSLog(@"tableViewBackgroundView.frame ::: %@ to %@", NSStringFromCGRect(tvbvf_o), NSStringFromCGRect(self.tableViewBackgroundView.frame));
    NSLog(@"tableViewBackgroundView.bounds (re:self.view) ::: %@ to %@", NSStringFromCGRect([self.view convertRect:tvbvb_o fromView:self.tableViewBackgroundView]), NSStringFromCGRect([self.view convertRect:self.tableViewBackgroundView.bounds fromView:self.tableViewBackgroundView]));
    NSLog(@"tableViewBackgroundView adjustment based on tableViewBackgroundViewOriginalOriginY=%f, originYAdjustment=%f", tableViewBackgroundViewOriginalOriginY, originYAdjustment);
    NSLog(@"tableViewCoverView.frame ::: %@ to %@", NSStringFromCGRect(tvcvf_o), NSStringFromCGRect(self.tableViewCoverView.frame));
    NSLog(@"tableViewCoverView.bounds (re:self.view) ::: %@ to %@", NSStringFromCGRect([self.view convertRect:tvcvb_o fromView:self.tableViewCoverView]), NSStringFromCGRect([self.view convertRect:self.tableViewCoverView.bounds fromView:self.tableViewCoverView]));
    
}

- (void) matchTableViewCoverViewToTableView {
    
    CGRect tvcvf_o = self.tableViewCoverView.frame;
    CGRect tvcvb_o = self.tableViewCoverView.bounds;
    
    CGFloat spaceForHeader = self.tableView.tableHeaderView != nil ? self.tableView.tableHeaderView.bounds.size.height : 0;
    
//    CGFloat originalCoverViewContainerOriginY = self.tableViewCoverViewContainer.frame.origin.y;
//    CGFloat originalCoverViewOriginY = self.tableViewCoverView.frame.origin.y;
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y += spaceForHeader;
    tableViewFrame.size.height -= spaceForHeader;
    self.tableViewCoverViewContainer.frame = tableViewFrame;
    
//    CGFloat coverViewContainerOriginYAdjustment = self.tableViewCoverViewContainer.frame.origin.y - originalCoverViewContainerOriginY;
//    CGRect tableViewCoverViewFrame = self.tableViewCoverView.frame;
//    tableViewCoverViewFrame.origin.y = originalCoverViewOriginY - coverViewContainerOriginYAdjustment;
//    self.tableViewCoverView.frame = tableViewCoverViewFrame;
    
    NSLog(@"\n\n\n\n\n\n\n\n");
    NSLog(@"testing");
    CGRect testingFrame = [self.view convertRect:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, 320, 480) toView:self.tableViewCoverView.superview];
    NSLog(@"testing ::: %@", NSStringFromCGRect(testingFrame));
    NSLog(@"\n\n\n\n\n\n\n\n");
    CGRect tableViewCoverViewFrame = self.tableViewCoverView.frame;
    tableViewCoverViewFrame.origin.y = testingFrame.origin.y;
    self.tableViewCoverView.frame = tableViewCoverViewFrame;
    
    NSLog(@"\n*\n*\n*\nmatchTableViewCoverViewToTableView");
    NSLog(@"tableViewCoverView.frame ::: %@ to %@", NSStringFromCGRect(tvcvf_o), NSStringFromCGRect(self.tableViewCoverView.frame));
    NSLog(@"tableViewCoverView.bounds (re:self.view) ::: %@ to %@", NSStringFromCGRect([self.view convertRect:tvcvb_o fromView:self.tableViewCoverView]), NSStringFromCGRect([self.view convertRect:self.tableViewCoverView.bounds fromView:self.tableViewCoverView]));
        
}

- (void) setFiltersBarToDisplayViewsForSource:(NSString *)sourceString {
    
    UIView * viewToRemoveFromSuperview = nil;
    UIView * viewToAddAsSubview = nil;
        
    if ([sourceString isEqualToString:EVENTS_SOURCE_BROWSE]) {
        viewToRemoveFromSuperview = self.filtersBarSearch;
        viewToAddAsSubview = self.filtersBarBrowse;
    } else if ([sourceString isEqualToString:EVENTS_SOURCE_SEARCH]) {
        viewToRemoveFromSuperview = self.filtersBarBrowse;
        viewToAddAsSubview = self.filtersBarSearch;
    } else {
        NSLog(@"ERROR in EventsViewController setFiltersBarToDisplayViewsForSource - unrecognized source string.");
    }
    [viewToRemoveFromSuperview removeFromSuperview];
    [self.filtersContainerView addSubview:viewToAddAsSubview];
    
}

- (void) setDrawerScrollViewToDisplayViewsForSource:(NSString *)sourceString {
    
    UIView * viewToRemoveFromSuperview = nil;
    UIView * viewToAddAsSubview = nil;
    EventsFilter * activeFilter = nil;
    
    if ([sourceString isEqualToString:EVENTS_SOURCE_BROWSE]) {
        viewToRemoveFromSuperview = self.drawerViewsSearchContainer;
        viewToAddAsSubview = self.drawerViewsBrowseContainer;
        activeFilter = self.activeFilterInUI;
    } else if ([sourceString isEqualToString:EVENTS_SOURCE_SEARCH]) {
        viewToRemoveFromSuperview = self.drawerViewsBrowseContainer;
        viewToAddAsSubview = self.drawerViewsSearchContainer;
        activeFilter = self.activeSearchFilterInUI;
    } else {
        NSLog(@"ERROR in EventsViewController setDrawerScrollViewToDisplayViewsForSource - unrecognized source string.");
    }
    [viewToRemoveFromSuperview removeFromSuperview];
    [self.drawerScrollView addSubview:viewToAddAsSubview];
    
    CGRect viewToAddAsSubviewBounds = viewToAddAsSubview != nil ? viewToAddAsSubview.bounds : CGRectZero;
    self.drawerScrollView.contentSize = viewToAddAsSubviewBounds.size;
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filtersForCurrentSource.count;
    [self setDrawerToShowFilter:activeFilter animated:NO];
    
}

-(void) toggleDrawerAnimated:(BOOL)animated {
    
    void(^allChangesBlock)(BOOL) = ^(BOOL wasDrawerOpen){
        self.isDrawerOpen = !wasDrawerOpen;
        self.tapToHideDrawerGR.enabled = self.isDrawerOpen;
        self.drawerScrollView.userInteractionEnabled = self.isDrawerOpen;
        if (self.isDrawerOpen == YES) {
//            CGRect drawerScrollViewFrame = self.drawerScrollView.frame;
//            drawerScrollViewFrame.size.height = self.isSearchOn ? self.drawerViewsSearchContainer.bounds.size.height : self.drawerViewsBrowseContainer.bounds.size.height;
//            self.drawerScrollView.frame = drawerScrollViewFrame;
            [self setPushableContainerViewsOriginY:(self.pushableContainerView.frame.origin.y + self.drawerScrollView.contentSize.height) adjustHeightToFillMainView:NO];
            NSLog(@"setTableViewScrollable from toggleSearch, sending NO");
            [self setTableViewScrollable:NO selectable:NO];
            self.filtersContainerShadowCheatView.alpha = 0.0;
            self.filtersContainerShadowCheatWayBelowView.alpha = 1.0;
            if (!self.isSearchOn && self.tableView.contentOffset.y < self.searchContainerView.bounds.size.height) {
                [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:NO];
            }
            BOOL hadResults = self.eventsForCurrentSource.count > 0;
            self.shouldReloadOnDrawerClose = !(self.isSearchOn || hadResults);
            [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:NO];
            if (!self.isSearchOn) {
                self.feedbackMessageTypeBrowseRemembered = self.feedbackView.messageType;
            } else {
                self.feedbackMessageTypeSearchRemembered = self.feedbackView.messageType;
            }
            [self setFeedbackViewMessageType:(self.shouldReloadOnDrawerClose ? CloseDrawerToLoadPrompt : SetFiltersPrompt) eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:animated];
            [self setFeedbackViewIsVisible:YES animated:animated];
            [self updateTimeFilterOptions:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersForCurrentSource].options forSearch:self.isSearchOn givenSelectedDateFilterOption:self.isSearchOn ? self.selectedDateSearchFilterOption : self.selectedDateFilterOption userTime:[NSDate date]];
        } else {
//            CGRect drawerScrollViewFrame = self.drawerScrollView.frame;
//            drawerScrollViewFrame.size.height = 0;
//            self.drawerScrollView.frame = drawerScrollViewFrame;
            [self setPushableContainerViewsOriginY:(self.pushableContainerView.frame.origin.y - self.drawerScrollView.contentSize.height) adjustHeightToFillMainView:NO];
            BOOL haveEvents = self.eventsForCurrentSource.count > 0;
            NSLog(@"setTableViewScrollable from toggleDrawer, could be sending NO");
            [self setTableViewScrollable:haveEvents selectable:haveEvents];
            self.filtersContainerShadowCheatView.alpha = 1.0;
            self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
//            [self.dvLocationTextField resignFirstResponder];
//            [self.dvLocationSearchTextField resignFirstResponder];
            if (self.shouldReloadOnDrawerClose) {
                if (!self.isSearchOn) {
                    // Browse mode, should reload...
                    [self setFeedbackViewMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:animated];
                    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
                } else {
                    // Search mode, should re-search...
                    NSLog(@"About to searchExecutionRequestedByUser from toggleDrawerAnimated");
                    [self searchExecutionRequestedByUser];
                }
            } else {
                EventsFeedbackMessageType rememberedMessageType = !self.isSearchOn ? self.feedbackMessageTypeBrowseRemembered : self.feedbackMessageTypeSearchRemembered;
                [self setFeedbackViewMessageType:rememberedMessageType eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:animated];
                [self setFeedbackViewIsVisible:![self isTableViewScrolledToBottom] animated:animated];
            }
            
            if (!self.isSearchOn && /*self.eventsForCurrentSource.count == 0*/
                self.tableView.contentSize.height - self.searchContainerView.bounds.size.height < self.tableView.bounds.size.height) {
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            // The following code moved here from filterOptionButtonTouched... This spot seems more appropriate, considering that the table view will not move while the drawer is open.
//            UIEdgeInsets tableViewInset = self.tableView.contentInset;
//            tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
//            self.tableView.contentInset = tableViewInset;
        }
    };
    
    if (animated) {
        CGFloat animationDurationSearch = /*2.8;//*/0.3;
        CGFloat animationDurationBrowse = /*3.0;//*/0.4;
        CGFloat animationDuration = self.isSearchOn ? animationDurationSearch : animationDurationBrowse;
        if (!self.isDrawerOpen) {
            self.activeFilterHighlightsContainerView.hidden = NO;
            self.filtersContainerShadowCheatWayBelowView.hidden = NO;
            self.drawerScrollView.hidden = NO;
//            self.tableViewBackgroundView.hidden = YES;
            self.pushableContainerShadowCheatView.hidden = NO;
            [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                allChangesBlock(self.isDrawerOpen);
            } completion:^(BOOL finished){}];
        } else {
            [UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                allChangesBlock(self.isDrawerOpen);
            } completion:^(BOOL finished){
                self.activeFilterHighlightsContainerView.hidden = YES;
                self.filtersContainerShadowCheatWayBelowView.hidden = YES;
                self.drawerScrollView.hidden = YES;
//                self.tableViewBackgroundView.hidden = NO;
                self.pushableContainerShadowCheatView.hidden = YES;
            }];
        }
        
    } else {
        allChangesBlock(self.isDrawerOpen);
        self.activeFilterHighlightsContainerView.hidden = !self.isDrawerOpen;
        self.filtersContainerShadowCheatWayBelowView.hidden = !self.isDrawerOpen;
        self.drawerScrollView.hidden = !self.isDrawerOpen;
        self.pushableContainerShadowCheatView.hidden = !self.isDrawerOpen;
//        self.tableViewBackgroundView.hidden = self.isDrawerOpen;
    }
    
}

- (void) toggleSearchModeAnimated:(BOOL)animated shouldMakeSearchTextFieldActiveWhenTogglingOn:(BOOL)shouldMakeSearchTextFieldActive shouldFlushQueryAndFilters:(BOOL)shouldFlushQueryAndFilters {
    
    float duration = animated ? 0.25 : 0.0;
    
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:animated];
    }
    self.isSearchOn = !self.isSearchOn;
    // Is new mode search on, or search off
    self.searchButton.enabled = !self.isSearchOn;
    self.searchTextField.text = @"";
    [DefaultsModel saveEventsListMostRecentMode:(self.isSearchOn ? ModeSearch : ModeBrowse)];
    
    if (self.isSearchOn) {
        if (shouldFlushQueryAndFilters) {
            [self resetSearchFilters];
            if (self.eventsWebQueryFromSearch == nil ||
                self.eventsWebQueryFromSearch.queryDatetime != nil) {
                self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
                NSLog(@"eventsWebQueryFromSearch was just made anew in toggleSearchMode");
            }
            NSString * searchTerm = self.searchTextField.text;
            /* THE FOLLOWING CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
            self.eventsWebQueryFromSearch.searchTerm = searchTerm;
            self.eventsWebQueryFromSearch.filterDateBucketString = self.selectedDateSearchFilterOption.code;
            self.eventsWebQueryFromSearch.filterDistanceBucketString = self.selectedLocationSearchFilterOption.code;
            self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchSetLocationButton.titleLabel.text; // LOCATION HACK
//            self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchTextField.text.length > 0 ? self.dvLocationSearchTextField.text : @"Current Location"; // LOCATION HACK
            self.eventsWebQueryFromSearch.filterTimeBucketString = self.selectedTimeSearchFilterOption.code;
            [self.coreDataModel coreDataSave];
            self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
            /* THE PREVIOUS CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
            NSLog(@"eventsWebQueryFromSearch was just updated in toggleSearchMode and is now %@", self.eventsWebQueryFromSearch);
        }
        [self matchTableViewCoverViewToTableView];
        // Set table view content offset to top
        self.tableView.contentOffset = CGPointMake(0, 0);
        [UIView animateWithDuration:duration 
                         animations:^{
                             // Move filters bar off screen
                             [self setFiltersBarViewsOriginY:-self.filtersContainerView.frame.size.height adjustDrawerViewsAccordingly:NO];
                             // Fade out the filters bar shadow
                             self.filtersContainerShadowCheatView.alpha = 0.0;
                             // Move pushable container view up to top of screen
                             [self setPushableContainerViewsOriginY:0 adjustHeightToFillMainView:YES];
                             [self matchTableViewCoverViewToTableView];
                             // Move summary string off screen
                             [self setFeedbackViewIsVisible:NO animated:animated];
                             // Fade table view out
                             self.tableViewCoverViewContainer.alpha = 1.0;
                             // Fade out table footer view
                             self.tableView.tableFooterView.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             // Reload table data
                             [self.tableView reloadData];
                             NSLog(@"EventsViewController tableView reloadData");
                             if (!shouldFlushQueryAndFilters && self.indexPathOfSelectedRow) {
                                 [self.tableView selectRowAtIndexPath:self.indexPathOfSelectedRow animated:animated scrollPosition:UITableViewScrollPositionNone];
                             }
                             // Pull the search bar out of the table view header
                             self.tableView.tableHeaderView = nil;
                             [self.view insertSubview:self.searchContainerView aboveSubview:self.filtersContainerView];
                             self.searchContainerView.frame = CGRectMake(0, 0, self.searchContainerView.frame.size.width, self.searchContainerView.frame.size.height);
                             [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) adjustHeightToFillMainView:YES];
                             [self matchTableViewCoverViewToTableView];
                             // Swap the browse & search filter bars
                             [self setFiltersBarToDisplayViewsForSource:EVENTS_SOURCE_SEARCH];
                             // Swap the browse & search filter drawer views
                             [self setDrawerScrollViewToDisplayViewsForSource:EVENTS_SOURCE_SEARCH];
                             // Prepare filters bar to come back on screen
                             [self setFiltersBarViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) - self.filtersContainerView.frame.size.height adjustDrawerViewsAccordingly:NO];
                             // Remove the table footer view
                             self.tableView.tableFooterView = nil;
                             // Remember the feedback message type that was showing
                             self.feedbackMessageTypeBrowseRemembered = self.feedbackView.messageType;
                             [UIView animateWithDuration:duration animations:^{
                                 // Make the search text field first responder, thus bringing the keyboard up
                                 if (shouldMakeSearchTextFieldActive) {
                                     [self resignFirstResponder];
                                     [self.searchTextField becomeFirstResponder];
                                 }
                                 [self adjustSearchViewsToShowButtons:YES];
                                 // Reveal filters bar on screen
                                 [self setFiltersBarViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) adjustDrawerViewsAccordingly:YES];
                                 // Fade in the filters bar shadow
                                 self.filtersContainerShadowCheatView.alpha = 1.0;
                                 // Move pushable container down
                                 [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.filtersContainerView.frame) adjustHeightToFillMainView:YES];
                                 [self matchTableViewCoverViewToTableView];
                                 // Move summary string on screen
                                 if (!shouldMakeSearchTextFieldActive && 
                                     self.eventsFromSearch.count > 0) {
                                     [self setFeedbackViewMessageType:LookingAtEvents eventsSummaryString:self.eventsSummaryStringSearch searchString:self.eventsWebQueryFromSearch.searchTerm animated:animated];
                                     [self setFeedbackViewIsVisible:YES animated:animated];
//                                     UIEdgeInsets tableViewInset = self.tableView.contentInset;
//                                     tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
//                                     self.tableView.contentInset = tableViewInset;
                                 }
                                 // Fade table view in
                                 self.tableViewCoverViewContainer.alpha = 0.0;
                             }];
                         }];
    } else {
        // New mode is search off
        [UIView animateWithDuration:duration 
                         animations:^{
                             // Force the search text field to resign first responder (thus hiding the keyboard if it was up), and make the view controller first responder again
                             [self.searchTextField resignFirstResponder];
                             [self becomeFirstResponder];
                             [self adjustSearchViewsToShowButtons:NO];
                             // Hide filters bar beneath search bar
                             [self setFiltersBarViewsOriginY:self.searchContainerView.frame.size.height - self.filtersContainerView.frame.size.height adjustDrawerViewsAccordingly:NO];
                             // Fade the filters bar shadow out
                             self.filtersContainerShadowCheatView.alpha = 0.0;  
                             // Move pushable container up
                             [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) adjustHeightToFillMainView:YES];
                             [self matchTableViewCoverViewToTableView];
                             // Move summary string off screen
                             [self setFeedbackViewIsVisible:NO animated:animated];
                             // Fade table view out
                             self.tableViewCoverViewContainer.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             // Reload table data
                             [self.tableView reloadData];
                             NSLog(@"EventsViewController tableView reloadData");
                             // Set table view content offset to the top (but use a scroll... method because this seems to effect the scrolling and thus acceleration of the table, whereas contentOffset methods do not).
                             if (self.events.count > 0) {
                                 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                             }
                             // Hide filters bar off screen, ready to come back on
                             [self setFiltersBarViewsOriginY:-self.filtersContainerView.frame.size.height adjustDrawerViewsAccordingly:NO];
                             // Move pushable container up
                             [self setPushableContainerViewsOriginY:self.searchContainerView.frame.origin.y adjustHeightToFillMainView:YES];
                             // Put the search bar back in the table view header
                             [self.searchContainerView removeFromSuperview];
                             self.tableView.tableHeaderView = self.searchContainerView;
                             // Adjust the table view cover view
                             [self matchTableViewCoverViewToTableView];
                             // Swap the browse & search filter bars
                             [self setFiltersBarToDisplayViewsForSource:EVENTS_SOURCE_BROWSE];
                             // Swap the browse & search filter drawer views
                             [self setDrawerScrollViewToDisplayViewsForSource:EVENTS_SOURCE_BROWSE];
                             // Add the table footer view back in
                             self.tableView.tableFooterView = self.tableReloadContainerView;
                             BOOL showTableFooterView = !self.isSearchOn && self.eventsForCurrentSource.count > 0;
                             self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
                             // Switch the filters summary label to browse
                             [UIView animateWithDuration:duration animations:^{
                                 // Move filters bar onto screen
                                 [self setFiltersBarViewsOriginY:0 adjustDrawerViewsAccordingly:YES];
                                 // Fade in the filters bar shadow
                                 self.filtersContainerShadowCheatView.alpha = 1.0;
                                 // Move pushable container down
                                 [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.filtersContainerView.frame) adjustHeightToFillMainView:YES];
                                 [self matchTableViewCoverViewToTableView];
                                 // Move summary string on screen
                                 [self setFeedbackViewMessageType:self.feedbackMessageTypeBrowseRemembered eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:animated];
                                 [self setFeedbackViewIsVisible:YES animated:animated];
//                                 UIEdgeInsets tableViewInset = self.tableView.contentInset;
//                                 tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
//                                 self.tableView.contentInset = tableViewInset;
                                 // Fade table view in
                                 self.tableViewCoverViewContainer.alpha = 0.0;
                                 BOOL haveResult = self.eventsForCurrentSource.count > 0;
                                 NSLog(@"setTableViewScrollable from toggleSearch, could be sending NO");
                                 [self setTableViewScrollable:haveResult selectable:haveResult];
                             }];
//                             // Search filters clean-up
//                             if (shouldFlushQueryAndFilters) {
//                                 [self resetSearchFilters];
//                                 if (self.eventsWebQueryFromSearch == nil ||
//                                     self.eventsWebQueryFromSearch.queryDatetime != nil) {
//                                     self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
//                                     NSLog(@"eventsWebQueryFromSearch was just made anew in toggleSearchMode");
//                                 }
//                                 NSString * searchTerm = self.searchTextField.text;
//                                 /* THE FOLLOWING CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
//                                 self.eventsWebQueryFromSearch.searchTerm = searchTerm;
//                                 self.eventsWebQueryFromSearch.filterDateBucketString = self.selectedDateSearchFilterOption.code;
//                                 self.eventsWebQueryFromSearch.filterDistanceBucketString = self.selectedLocationSearchFilterOption.code;
//                                self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchTextField.text.length > 0 ? self.dvLocationSearchTextField.text : @"Current Location"; // LOCATION HACK
//                                 self.eventsWebQueryFromSearch.filterTimeBucketString = self.selectedTimeSearchFilterOption.code;
//                                 [self.coreDataModel coreDataSave];
//                                 self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease];
//                                 /* THE PREVIOUS CODE IS DUPLICATED IN ...viewDidLoad..., ...toggleSearchMode..., and ...searchExecutionRequestedByUser... */
//                                 NSLog(@"eventsWebQueryFromSearch was just updated in toggleSearchMode and is now %@", self.eventsWebQueryFromSearch);
//                             }
                         }];
    }
}

- (void) resetSearchFilters {
    // Get the old selected filter options
    EventsFilterOption * oldDateSFO = self.selectedDateSearchFilterOption;
    EventsFilterOption * oldLocationSFO = self.selectedLocationSearchFilterOption;
    EventsFilterOption * oldTimeSFO = self.selectedTimeSearchFilterOption;
    // Get the filters
    EventsFilter * dateFilter = [self filterForFilterCode:EVENTS_FILTER_DATE inFiltersArray:self.filtersSearch];
    EventsFilter * locationFilter = [self filterForFilterCode:EVENTS_FILTER_LOCATION inFiltersArray:self.filtersSearch];
    EventsFilter * timeFilter = [self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersSearch];
    // Set the new selected filter options (all to most general option)
    self.selectedDateSearchFilterOption = dateFilter.mostGeneralOption;
    NSLog(@"resetSearchFilters set selectedDateSearchFilterOption to %@ (code %@)", self.selectedDateSearchFilterOption, self.selectedDateSearchFilterOption.code);
    self.selectedLocationSearchFilterOption = locationFilter.mostGeneralOption;
    NSLog(@"resetSearchFilters set selectedLocationSearchFilterOption to %@ (code %@)", self.selectedLocationSearchFilterOption, self.selectedLocationSearchFilterOption.code);
    self.selectedTimeSearchFilterOption = timeFilter.mostGeneralOption;
    NSLog(@"resetSearchFilters set selectedTimeSearchFilterOption to %@ (code %@)", self.selectedTimeSearchFilterOption, self.selectedTimeSearchFilterOption.code);
    // Update the filter option buttons UI
    [self updateFilterOptionButtonStatesOldSelected:oldDateSFO newSelected:self.selectedDateSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:oldLocationSFO newSelected:self.selectedLocationSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:oldTimeSFO newSelected:self.selectedTimeSearchFilterOption];
    // Update the filter buttons UI
    [self updateFilter:dateFilter buttonImageForFilterOption:self.selectedDateSearchFilterOption];
    [self updateFilter:locationFilter buttonImageForFilterOption:self.selectedLocationSearchFilterOption];
    [self updateFilter:timeFilter buttonImageForFilterOption:self.selectedTimeSearchFilterOption];
    // Update the search filters summary string
    self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    // Clear out the array of most recently adjusted search filters
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:dateFilter selectedFilterOption:dateFilter.mostGeneralOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:locationFilter selectedFilterOption:locationFilter.mostGeneralOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:timeFilter selectedFilterOption:timeFilter.mostGeneralOption];
}

- (IBAction) searchButtonTouched:(id)sender  {
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:YES];
    }
    [self toggleSearchModeAnimated:YES shouldMakeSearchTextFieldActiveWhenTogglingOn:YES shouldFlushQueryAndFilters:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn?");
    BOOL shouldReturn = YES;
    if (textField == self.searchTextField) {
        NSLog(@"About to searchExecutionRequestedByUser from textFieldShouldReturn");
        [self searchExecutionRequestedByUser];
        shouldReturn = NO;
    }
    return shouldReturn;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL should = YES;
    return should;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (textField == self.searchTextField) {
        
        if (self.eventsFromSearch.count > 0 &&
            self.adjustedSearchFiltersOrdered.count > 0 &&
            !self.isDrawerOpen) {
            self.activeSearchFilterInUI = self.mostRecentlyAdjustedSearchFilter;
            [self setDrawerToShowFilter:self.activeSearchFilterInUI animated:NO];
            [self toggleDrawerAnimated:YES];
        }
    }

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%d rows in section %d", self.eventsForCurrentSource.count, section);
    return self.eventsForCurrentSource.count;
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
//    NSLog(@"configureCell for %d-%d", indexPath.section, indexPath.row);
    
    Event * event = (Event *)[self.eventsForCurrentSource objectAtIndex:indexPath.row];
    
    NSString * title = event.summary.title;
    Category * concreteParentCategory = event.concreteParentCategory;
    NSString * location = event.summary.placeTitle;
    NSString * address = event.summary.placeAddressEtc;
    NSDate * startDateEarliest = event.summary.startDateEarliest;
    NSDate * startDateLatest = event.summary.startDateLatest;
    NSNumber * startDateCount = event.summary.startDateCount;
    NSDate * startTimeEarliest = event.summary.startTimeEarliest;
    NSDate * startTimeLatest = event.summary.startTimeLatest;
    NSNumber * startTimeCount = event.summary.startTimeCount;
    NSNumber * placeCount = event.summary.placeCount;
    NSNumber * priceMin = event.summary.priceMinimum;
    NSNumber * priceMax = event.summary.priceMaximum;
    
    if (!title) { title = @"Title not available"; }
    cell.titleLabel.text = title;
    
    NSString * colorHex = concreteParentCategory.colorHex;
    if (colorHex) {
        cell.categoryColorView.backgroundColor = [WebUtil colorFromHexString:colorHex];
    }
    NSString * iconThumb = concreteParentCategory.iconThumb;
    if (iconThumb) {
        cell.iconImageView.image = [UIImage imageNamed:iconThumb];
    }
    
    if (location || address) {
        if (location) {
            cell.locationLabel.text = location;
            if ([placeCount intValue] > 1) {
                int moreCount = placeCount.intValue - 1;
                NSString * locationWord = moreCount > 1 ? @"locations" : @"location";
                cell.locationLabel.text = [cell.locationLabel.text stringByAppendingFormat:@" & %d more %@", moreCount, locationWord];
            }
        } else {
            cell.locationLabel.text = address;
        }
    } else {
        cell.locationLabel.text = @"Location not available";
    }

    NSString * dateToDisplay = [self.webDataTranslator eventsListDateRangeStringFromEventDateEarliest:startDateEarliest eventDateLatest:startDateLatest eventDateCount:startDateCount relativeDates:YES dataUnavailableString:nil];
    NSString * timeToDisplay = [self.webDataTranslator eventsListTimeRangeStringFromEventTimeEarliest:startTimeEarliest eventTimeLatest:startTimeLatest eventTimeCount:startTimeCount dataUnavailableString:nil];
    
    NSString * divider = startDateEarliest && startTimeEarliest ? @" | " : @"";
    NSString * finalDatetimeString = [NSString stringWithFormat:@"%@%@%@", dateToDisplay, divider, timeToDisplay];
    cell.dateAndTimeLabel.text = finalDatetimeString;
    
    NSString * priceRange = [self.webDataTranslator priceRangeStringFromMinPrice:priceMin maxPrice:priceMax separatorString:nil dataUnavailableString:nil];
    cell.priceLabel.text = priceRange;
    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.indexPathOfSelectedRow = indexPath;
        
    Event * event = (Event *)[self.eventsForCurrentSource objectAtIndex:indexPath.row];
    
    self.cardPageViewController = [[[EventViewController alloc] initWithNibName:@"EventViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.cardPageViewController.coreDataModel = self.coreDataModel;
    self.cardPageViewController.delegate = self;
    self.cardPageViewController.hidesBottomBarWhenPushed = YES;
    self.cardPageViewController.deleteAllowed = !self.isSearchOn;
    NSLog(@"self.eventsWebQueryForCurrentSource.filterLocationString = %@", self.eventsWebQueryForCurrentSource.filterLocationString);
    [self.cardPageViewController setUserLocation:nil withUserLocationString:self.eventsWebQueryForCurrentSource.filterLocationString]; // THIS NEEDS TO BE UPDATED SO THAT WE ACTUALLY PASS ON THE USER'S LOCATION. THAT COULD JUST BE A STARTING POINT THOUGH - REALLY, THE EVENT VIEW CONTROLLER SHOULD CONTINUE DOING ITS OWN LOCATION UPDATING ETC.
    
    [self.webConnector sendLearnedDataAboutEvent:event.uri withUserAction:@"V"]; // Attempt to send the learning to our server.
    [self.webConnector getEventWithURI:event.uri]; // Attempt to get the full event info
    [self showWebLoadingViews];
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    if ([userAction isEqualToString:@"V"] && self.cardPageViewController) {
        
        NSLog(@"EventsViewController successfully sent 'view' learning to server for event with URI %@.", eventURI);
        
    } else if ([userAction isEqualToString:@"X"]) {
        
        // Delete event from core data
        [self.coreDataModel deleteRegularEventForURI:eventURI];
        // Get index path for event
        NSIndexPath * indexPath = self.indexPathOfRowAttemptingToDelete;
        self.indexPathOfRowAttemptingToDelete = nil;
        // Delete event from our table display array
        [self.eventsForCurrentSource removeObjectAtIndex:indexPath.row];
        // Animate event deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"V"] && self.cardPageViewController) {
        
        NSLog(@"EventsViewController failed to send 'view' learning to server for event with URI %@. We should be remembering this, and trying to send the learning again later! This is crucial!", eventURI);
        
    } else if ([userAction isEqualToString:@"X"]) {
        [self.connectionErrorOnDeleteAlertView show];
    }
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {

    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * eventDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    
    Event * event = [self.eventsForCurrentSource objectAtIndex:self.indexPathOfSelectedRow.row];
    
    [self.coreDataModel updateEvent:event usingEventDictionary:eventDictionary featuredOverride:nil fromSearchOverride:nil];
    
    self.cardPageViewController.event = event;
    [self.navigationController pushViewController:self.cardPageViewController animated:YES];
    self.deletedFromEventCard = NO;
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
    [self.connectionErrorStandardAlertView show];
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.connectionErrorStandardAlertView) {
        if ([self.tableView indexPathForSelectedRow]) {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO]; // This may not always be appropriate, and perhaps we should check to see if we really want to do this depending on why the connection error alert view was shown in the first place, BUT I can't really see how it will hurt things for now.
        }
    } else if (alertView == self.connectionErrorOnDeleteAlertView) {
        // Do something...
        
    } else if (alertView == self.resetAllFiltersAlertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSLog(@"Not currently supported...");
        }
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized alert view.");
    }
}

- (void)cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI {

    self.deletedFromEventCard = eventWasDeleted;
    [self.navigationController popViewControllerAnimated:YES];
    // The rest has been moved to / is taken care of in view(Will/Did)Appear.
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canEdit = YES;
    if (tableView == self.tableView) {
        canEdit = !(self.isSearchOn || self.isDrawerOpen);
    }
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Event * event = (Event *)[self.eventsForCurrentSource objectAtIndex:indexPath.row];
        
        // Send learned data to server
        self.indexPathOfRowAttemptingToDelete = indexPath;
        [self.webConnector sendLearnedDataAboutEvent:event.uri withUserAction:@"X"]; // If we don't connect with the server about deleting an event, we should cache the request and retry later, because we don't want to lose that learned behavior, but for now we're going to leave that out. DEFINITELY COME BACK TO THIS LATER. Issue submitted to GitHub. For now, we will wait to get a server response before doing anything else (such as deleting the item locally, etc). We should also probably lock up the UI while we're waiting.
        [self showWebLoadingViews];
        
	}
    
}

- (void) setLocationSetterViewIsVisible:(BOOL)isVisible animated:(BOOL)animated animationBasedInKeyboardNotificationUserInfo:(NSDictionary *)keyboardNotificationUserInfo {
    
//	CGSize keyboardSize = [[keyboardNotificationUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    double keyboardAnimationDuration = [[keyboardNotificationUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve keyboardAnimationCurve = [[keyboardNotificationUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
//    
//    CGFloat endingLocationSetterViewOriginX = 0.0;
//    if (isVisible) {
//        
//        [self.view bringSubviewToFront:self.locationSetterView];
//        CGRect locationSetterViewFrame = self.locationSetterView.frame;
//        locationSetterViewFrame.size.height = self.view.bounds.size.height + self.tabBarController.tabBar.bounds.size.height - keyboardSize.height;
//        self.locationSetterView.frame = locationSetterViewFrame;
//        endingLocationSetterViewOriginX = 0.0;
//        
//    } else {
//        
//        endingLocationSetterViewOriginX = self.view.bounds.size.width;
//        
//    }
//    
//    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
//        CGRect locationSetterViewFrame = self.locationSetterView.frame;
//        locationSetterViewFrame.origin.x = endingLocationSetterViewOriginX;
//        self.locationSetterView.frame = locationSetterViewFrame;
//    } completion:^(BOOL finished){ self.userRequestedToShowLocationSetter = isVisible; }];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if (self.userRequestedToShowLocationSetter) {
        [self setLocationSetterViewIsVisible:YES animated:YES animationBasedInKeyboardNotificationUserInfo:info];
    } else {
        [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.bottom = keyboardSize.height - self.tabBarController.tabBar.bounds.size.height;
            self.tableView.contentInset = insets;
            UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
            scrollInsets.bottom = keyboardSize.height - self.tabBarController.tabBar.bounds.size.height;
            self.tableView.scrollIndicatorInsets = scrollInsets;
        } completion:^(BOOL finished){}];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if (self.userRequestedToShowLocationSetter) {
        [self setLocationSetterViewIsVisible:NO animated:YES animationBasedInKeyboardNotificationUserInfo:info];
    } else {
        [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.bottom = /*self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : */0.0;
            self.tableView.contentInset = insets;
            UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
            scrollInsets.bottom = 0;
            self.tableView.scrollIndicatorInsets = scrollInsets;
        } completion:^(BOOL finished){ }];
    }
}

- (void)loginActivity:(NSNotification *)notification {
//    NSLog(@"EventsViewController loginActivity");
    //NSString * action = [[notification userInfo] valueForKey:@"action"]; // We don't really care whether the user just logged in or logged out - we should get new events list no matter what.
    BOOL animated = self.view.window != nil;
    if (self.isSearchOn) {
        [self toggleSearchModeAnimated:animated shouldMakeSearchTextFieldActiveWhenTogglingOn:YES shouldFlushQueryAndFilters:YES];
    }
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:animated];
    }
    [self setFeedbackViewMessageType:LoadingEventsTrue eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:animated];
    [self webConnectGetEventsListWithOldFilter:EVENTS_OLDFILTER_RECOMMENDED categoryURI:nil];
}

- (void) behaviorWasReset:(NSNotification *)notification {
    BOOL animated = self.view.window != nil;
    if (self.isSearchOn) {
        [self toggleSearchModeAnimated:animated shouldMakeSearchTextFieldActiveWhenTogglingOn:YES shouldFlushQueryAndFilters:YES];
    }
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:animated];
    }
    [self setFeedbackViewMessageType:LoadingEventsTrue eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:animated];
    [self webConnectGetEventsListWithOldFilter:EVENTS_OLDFILTER_RECOMMENDED categoryURI:nil];
}

#pragma mark color

- (void) showWebLoadingViews  {
    if (self.view.window) {
        
        // WE COULD MAKE THE FOLLOWING RECENTERING APPLY TO A LOT MORE SITUATIONS / BECOME A LOT MORE INTELLIGENT WITHOUT TOO MUCH EFFORT. COME BACK TO THIS SOMETIME WHEN YOU HAVE SOME FREE TIME. JUST FIGURE OUT WHAT UI ELEMENT IS FARTHEST DOWN (FROM THE TOP OF THE VIEW) THAT YOU'D LIKE TO AVOID, AND WHAT UI ELEMENT IS FARTHEST UP (FROM THE BOTTOM OF THE VIEW) THAT YOU'D LIKE TO AVOID, AND RECENTER THE WEB ACTIVITY VIEW USING THE RESULTING CALCULATED RECT, JUST LIKE WE'RE DOING BELOW.
//        NSLog(@"wlvOrigin = %@", NSStringFromCGPoint(self.webActivityView.frame.origin));
        CGRect webActivityViewSpaceFrame = self.view.bounds;
        if (self.feedbackViewIsVisible && 
            self.feedbackView.isCurrentMessageComplex) {
//            NSLog(@"Doing something tricky...");
            CGRect searchContainerViewFrameConvertedToMainView = [self.searchContainerView convertRect:self.searchContainerView.frame toView:self.view];
//            NSLog(@"searchContainerViewFrameConvertedToMainView=%@", NSStringFromCGRect(searchContainerViewFrameConvertedToMainView));
            CGRect feedbackViewFrameConvertedToMainView = [self.view convertRect:self.feedbackView.frame fromView:self.feedbackView.superview];
//            NSLog(@"feedbackViewFrameConvertedToMainView=%@", NSStringFromCGRect(feedbackViewFrameConvertedToMainView));
            webActivityViewSpaceFrame = CGRectMake(0, CGRectGetMaxY(searchContainerViewFrameConvertedToMainView), self.view.bounds.size.width, CGRectGetMinY(feedbackViewFrameConvertedToMainView) - CGRectGetMaxY(searchContainerViewFrameConvertedToMainView));
//            NSLog(@"webActivityViewSpaceFrame=%@", NSStringFromCGRect(webActivityViewSpaceFrame));
//            webActivityViewSpaceFrame.size.height -= self.feedbackView.bounds.size.height;
        }
        [self.webActivityView recenterInFrame:webActivityViewSpaceFrame];
//        NSLog(@"wlvOrigin = %@", NSStringFromCGPoint(self.webActivityView.frame.origin));
        
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        
        // USER INTERACTION
        tableView_.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
    }
}

-(void)hideWebLoadingViews  {

    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    
    // USER INTERACTION
    self.tableView.userInteractionEnabled = YES; // Enable user interaction
    self.view.userInteractionEnabled = YES;

}

- (void) setImagesForCategoryButton:(UIButton *)button forCategory:(Category *)category {
    NSString * baseImageFilename = nil;
    if (category == nil) {
        baseImageFilename = @"btn_cat_all.png";
    } else {
        baseImageFilename = category.buttonThumb;
    }
    [button setBackgroundImage:[UIImage imageNamed:baseImageFilename] forState: UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:[baseImageFilename stringByReplacingOccurrencesOfString:@".png" withString:[NSString stringWithFormat:@"%@.png", EVENTS_CATEGORY_BUTTON_TOUCH_POSTFIX]]] forState:UIControlStateHighlighted];
}

- (EventsFilter *) filterForPositionX:(CGFloat)x withinViewWidth:(CGFloat)viewWidth fromFiltersArray:(NSArray *)arrayOfEventsFilters {
    EventsFilter * matchingFilter = nil;
    x = MAX(0, MIN(x, viewWidth));
    for (EventsFilter * filter in arrayOfEventsFilters) {
        if (x <= CGRectGetMaxX(filter.button.frame) &&
            x >= CGRectGetMinX(filter.button.frame)) {
            matchingFilter = filter;
            break;
        }
    }
    if (matchingFilter == nil) {
        NSLog(@"ERROR in EventsViewController - can't find a matching filter button for a swipe");
    }
    return matchingFilter;
}

- (EventsFilter *) filterForFilterCode:(NSString *)filterCode inFiltersArray:(NSArray *)arrayOfEventsFilters {
    EventsFilter * filter = nil;
    NSArray * resultsArray = [arrayOfEventsFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", filterCode]];
    if (resultsArray && [resultsArray count] > 0) {
        filter = [resultsArray objectAtIndex:0];
    }
    if (filter == nil) {
        NSLog(@"ERROR in EventsViewController - can't match a filter code to a filter");
    }
    return filter;
}

- (EventsFilter *) filterForFilterButton:(UIButton *)filterButton inFiltersArray:(NSArray *)arrayOfEventsFilters {
    EventsFilter * filter = nil;
    NSArray * resultsArray = [arrayOfEventsFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"button == %@", filterButton]];
    if (resultsArray && [resultsArray count] > 0) {
        filter = [resultsArray objectAtIndex:0];
    }
    if (filter == nil) {
        NSLog(@"ERROR in EventsViewController - can't match a filter button to a filter");
    }
    return filter;
}

- (EventsFilterOption *) filterOptionForFilterOptionButton:(UIButton *)filterOptionButton 
                                      inFilterOptionsArray:(NSArray *)filterOptions {
//    NSLog(@"%@ %@", filterOptionButton, filterOptions);
//    for (EventsFilterOption * filterOption in filterOptions) {
//        NSLog(@"%@ %@", filterOption, filterOption.code);
//    }
    EventsFilterOption * filterOption = nil;
    NSArray * resultsArray = [filterOptions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"buttonView.button == %@", filterOptionButton]];
    if (resultsArray && [resultsArray count] > 0) {
        filterOption = [resultsArray objectAtIndex:0];
    }
    if (filterOption == nil) {
        NSLog(@"ERROR in EventsViewController - can't match a filter option button to a filter option");
    }
    return filterOption;
}

- (void)swipeDownToShowDrawer:(UISwipeGestureRecognizer *)swipeGesture {
    EventsFilter * swipedOverFilter = [self filterForPositionX:[swipeGesture locationInView:swipeGesture.view].x withinViewWidth:swipeGesture.view.bounds.size.width fromFiltersArray:self.filtersForCurrentSource];
    if (!self.isDrawerOpen) {
        if (self.isSearchOn) {
            self.activeSearchFilterInUI = swipedOverFilter;
        } else {
            self.activeFilterInUI = swipedOverFilter;
        }
        NSLog(@"swipeDownToShowDrawer for button with title %@%@", swipedOverFilter.button.titleLabel.text, self.isSearchOn ? @"(while search is on)" : @"");
        [self setDrawerToShowFilter:swipedOverFilter animated:self.isDrawerOpen];
        [self toggleDrawerAnimated:YES];
    }
}

- (void) swipeUpToHideDrawer:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipeUpToHideDrawer");
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:YES];
    }
}

- (void) tapToHideDrawer:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"tapToHideDrawer");
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated:YES];
    }
}

- (void) swipeAcrossFiltersStrip:(UISwipeGestureRecognizer *)swipeGesture {
//    [self.resetAllFiltersAlertView show]; // Disabling this gesture for now... Sort of weird.
}

- (void) setDrawerToShowFilter:(EventsFilter *)filter animated:(BOOL)animated {
    
    void (^shiftDrawerScrollViewContentOffsetBlock) (void) = ^{
        self.drawerScrollView.contentOffset = CGPointMake(filter.drawerView.frame.origin.x, self.drawerScrollView.contentOffset.y);
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:shiftDrawerScrollViewContentOffsetBlock];
    } else {
        shiftDrawerScrollViewContentOffsetBlock();
    }
        
    [self updateActiveFilterHighlights];
    
}

- (EventsFilter *) filterForDrawerScrollViewContentOffset:(CGPoint)contentOffset fromFilters:(NSArray *)arrayOfEventsFilters {
    EventsFilter * matchingFilter = nil;
    for (EventsFilter * filter in arrayOfEventsFilters) {
        if (contentOffset.x < CGRectGetMaxX(filter.drawerView.frame) &&
            contentOffset.x >= CGRectGetMinX(filter.drawerView.frame)) {
            matchingFilter = filter;
            break;
        }
    }
    if (matchingFilter == nil) {
        NSLog(@"ERROR in EventsViewController - can't find a matching filter button for a swipe");
    }
    return matchingFilter;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.drawerScrollView) {
        EventsFilter * filter = [self filterForDrawerScrollViewContentOffset:scrollView.contentOffset fromFilters:self.filtersForCurrentSource];
        if (self.isSearchOn) {
            self.activeSearchFilterInUI = filter;
        } else {
            self.activeFilterInUI = filter;
        }
        [self updateActiveFilterHighlights]; // Moved this here from scrollViewDidScroll for performance reasons.
    } else if (scrollView == self.tableView) {
        if (self.isDrawerOpen) {
            if (self.tableView.contentOffset.y < self.searchContainerView.bounds.size.height) {
                [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];
            }
        }
    }
}

- (void) updateAdjustedSearchFiltersOrderedWithAdjustedFilter:(EventsFilter *)adjustedFilter selectedFilterOption:(EventsFilterOption *)selectedFilterOption {
    
    if (self.mostRecentlyAdjustedSearchFilter != adjustedFilter ||
        selectedFilterOption.isMostGeneralOption) {
        [self.adjustedSearchFiltersOrdered removeObject:adjustedFilter];
        if (!selectedFilterOption.isMostGeneralOption) {
            [self.adjustedSearchFiltersOrdered insertObject:adjustedFilter atIndex:0];
        }
    }

//    // Debugging...
//    for (EventsFilter * filter in self.adjustedSearchFiltersOrdered) {
//        NSLog(@"%@", filter.code);
//    }

}
        
- (EventsFilter *)mostRecentlyAdjustedSearchFilter {
    EventsFilter * mostRecentlyAdjustedSearchFilter = nil;
    if (self.adjustedSearchFiltersOrdered &&
        self.adjustedSearchFiltersOrdered.count > 0) {
        mostRecentlyAdjustedSearchFilter = [self.adjustedSearchFiltersOrdered objectAtIndex:0];
    }
    return mostRecentlyAdjustedSearchFilter;
}

- (void) filterOptionButtonTouched:(UIButton *)filterOptionButton forFilterCode:(NSString *)filterCode selectedOptionGetter:(SEL)selectedFilterOptionGetter selectedOptionSetter:(SEL)selectedFilterOptionSetter {
    
    NSLog(@"filterOptionButtonTouched");
    
    EventsFilter * filter = [self filterForFilterCode:filterCode inFiltersArray:self.filtersForCurrentSource];
    EventsFilterOption * newSelectedOption = [self filterOptionForFilterOptionButton:filterOptionButton inFilterOptionsArray:filter.options];
    EventsFilterOption * oldSelectedOption = [self performSelector:selectedFilterOptionGetter];
    
    if (oldSelectedOption != newSelectedOption) {
        [self performSelector:selectedFilterOptionSetter withObject:newSelectedOption];
        if (![filter.code isEqualToString:EVENTS_FILTER_CATEGORIES]) {
            [self updateFilterOptionButtonStatesOldSelected:oldSelectedOption newSelected:newSelectedOption];
            [self updateFilter:filter buttonImageForFilterOption:newSelectedOption];            
        } else {
            self.categoryURI = [EventsFilterOption categoryURIForEventsFilterOptionCategoryCode:newSelectedOption.code];
            [self setLogoButtonImageForCategoryURI:self.categoryURI];
        }

        if (self.isSearchOn) {
            [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:filter selectedFilterOption:newSelectedOption];
        }
        
        /* WARNING: THE FOLLOWING CODE HAS BEEN COPIED TO SETLOCATIONVIEWCONTROLLER DELEGATE PROTOCOL METHODS */
        self.shouldReloadOnDrawerClose = YES;
        [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
        
        if (!self.isSearchOn) {
            self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
            [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
        } else {
            self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
            [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
        }
        /* WARNING: THE CODE ABOVE HAS BEEN COPIED TO SETLOCATIONVIEWCONTROLLER DELEGATE PROTOCOL METHODS */

    }
}

- (IBAction) priceFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter = NULL;
    SEL selectedOptionSetter = NULL;
    if (self.isSearchOn) { } else {
        selectedOptionGetter = @selector(selectedPriceFilterOption);
        selectedOptionSetter = @selector(setSelectedPriceFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_PRICE 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
}
- (IBAction) dateFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter, selectedOptionSetter;
    if (self.isSearchOn) {
        selectedOptionGetter = @selector(selectedDateSearchFilterOption);
        selectedOptionSetter = @selector(setSelectedDateSearchFilterOption:);
    } else {
        selectedOptionGetter = @selector(selectedDateFilterOption);
        selectedOptionSetter = @selector(setSelectedDateFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_DATE 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
    [self updateTimeFilterOptions:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersForCurrentSource].options forSearch:self.isSearchOn givenSelectedDateFilterOption:self.isSearchOn ? self.selectedDateSearchFilterOption : self.selectedDateFilterOption userTime:[NSDate date]];
}
- (IBAction) timeFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter, selectedOptionSetter;
    if (self.isSearchOn) {
        selectedOptionGetter = @selector(selectedTimeSearchFilterOption);
        selectedOptionSetter = @selector(setSelectedTimeSearchFilterOption:);
    } else {
        selectedOptionGetter = @selector(selectedTimeFilterOption);
        selectedOptionSetter = @selector(setSelectedTimeFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_TIME 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
}
- (IBAction) locationFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter, selectedOptionSetter;
    if (self.isSearchOn) {
        selectedOptionGetter = @selector(selectedLocationSearchFilterOption);
        selectedOptionSetter = @selector(setSelectedLocationSearchFilterOption:);
    } else {
        selectedOptionGetter = @selector(selectedLocationFilterOption);
        selectedOptionSetter = @selector(setSelectedLocationFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_LOCATION 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
}
- (void) categoryFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter = NULL;
    SEL selectedOptionSetter = NULL;
    if (self.isSearchOn) { } else {
        selectedOptionGetter = @selector(selectedCategoryFilterOption);
        selectedOptionSetter = @selector(setSelectedCategoryFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_CATEGORIES 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
}

- (NSString *) makeEventsSummaryStringForSource:(NSString *)sourceString {
    
    NSString * priceReadable    = nil;
    NSString * dateReadable     = nil;
    NSString * categoryReadable = nil;
    NSString * timeReadable     = nil;
    NSString * locationReadable = nil;
    NSString * locationItself   = nil;
        
    if ([sourceString isEqualToString:EVENTS_SOURCE_BROWSE]) {
        priceReadable    = self.selectedPriceFilterOption.readable;
        dateReadable     = self.selectedDateFilterOption.readable;
        categoryReadable = self.categoryURI ? [self.coreDataModel getCategoryWithURI:self.categoryURI].title : nil;
        timeReadable     = self.selectedTimeFilterOption.readable;
        locationReadable = self.selectedLocationFilterOption.readable;
        locationItself   = self.dvLocationSetLocationButton.titleLabel.text;
//        locationItself   = self.dvLocationTextField.text;
    } else if ([sourceString isEqualToString:EVENTS_SOURCE_SEARCH]) {
        dateReadable     = self.selectedDateSearchFilterOption.readable;
        locationReadable = self.selectedLocationSearchFilterOption.readable;
        locationItself   = self.dvLocationSearchSetLocationButton.titleLabel.text;
//        locationItself   = self.dvLocationSearchTextField.text;
        timeReadable     = self.selectedTimeSearchFilterOption.readable;
    } else {
        NSLog(@"ERROR in EventsViewController filtersSummaryStringForSource:andUpdateSummaryLabel: - unrecognized source string.");
    }
    
    // Location HACK
    if (!(locationItself.length > 0) || [locationItself.lowercaseString isEqualToString:@"current location"]) {
        locationItself = @"your current location";
    }
    
    NSMutableString * summaryString = [NSMutableString string];
//    NSString * DUMMY_START_STRING = @"---DUMMY_START_STRING---";
//    [summaryString appendString:DUMMY_START_STRING];
    NSString * eventsWord = @"events";
    if (categoryReadable) {
        eventsWord = [NSString stringWithFormat:@"%@ %@", categoryReadable, eventsWord.lowercaseString];
    }
    if (priceReadable) {
        if ([priceReadable isEqualToString:@"Free"]) {
            [summaryString appendFormat:@"%@ %@ ", priceReadable.lowercaseString, eventsWord];
        } else {
            [summaryString appendFormat:@"%@ that cost %@ ", eventsWord, priceReadable.lowercaseString];
        }
    } else {
        [summaryString appendFormat:@"%@ ", eventsWord];
    }
    if (timeReadable || dateReadable) {
        [summaryString appendString:@"happening "];
    }
    if (dateReadable) {
        [summaryString appendFormat:@"%@ ", dateReadable.lowercaseString];
    }
    if (timeReadable) {
        [summaryString appendFormat:@"%@ ", timeReadable.lowercaseString];
    }
    if (locationReadable) {
        [summaryString appendFormat:@"%@ %@ ", locationReadable.lowercaseString, locationItself];
    }
    [summaryString deleteCharactersInRange:NSMakeRange(summaryString.length-1, 1)];
    
    if ([sourceString isEqualToString:EVENTS_SOURCE_SEARCH]) {
        [summaryString replaceOccurrencesOfString:@"events" withString:[NSString stringWithFormat:@"events matching '%@'", self.searchTextField.text] options:0 range:NSMakeRange(0, summaryString.length)];
    } else {
        summaryString = [NSString stringWithFormat:@"recommended %@", summaryString];
    }
//    [summaryString appendFormat:@"."];
//    [summaryString replaceOccurrencesOfString:@"You are looking at events." withString:@"Looking for something specific? Use the filters above to narrow in on the type of events you're interested in." options:0 range:NSMakeRange(0, summaryString.length)];
    
    return summaryString;
    
}

- (BOOL) isTableViewFilledOut {
    return self.tableView.contentSize.height >= self.tableView.bounds.size.height;
}

- (BOOL) isTableViewScrolledToBottom {
    return [self isTableViewFilledOut] && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.bounds.size.height;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"co=%@, ch=%f, bh=%f, fbvh=%f, fh=%f", NSStringFromCGPoint(scrollView.contentOffset), scrollView.contentSize.height, scrollView.bounds.size.height, self.feedbackView.bounds.size.height, self.tableView.tableFooterView != nil ? self.tableView.tableFooterView.bounds.size.height : 0);
    //    if (scrollView == self.drawerScrollView) {
    //        [self updateActiveFilterHighlights]; // This is killing performance.
    //    }
    if (scrollView == self.tableView) {
        if (!self.isDrawerOpen && [self isTableViewFilledOut]) {
            BOOL scrolledPastEnd = [self isTableViewScrolledToBottom];
            BOOL feedbackViewWasVisible = self.feedbackViewIsVisible;
//            NSString * gtltSymbol = nil;
//            NSString * verb = @"do nothing";
//            gtltSymbol = scrolledPastEnd ? @">=" : @"<";
            if (feedbackViewWasVisible && scrolledPastEnd) {
                [self setFeedbackViewIsVisible:NO animated:YES];
//                verb = @"hide";
            } else if (!feedbackViewWasVisible && !scrolledPastEnd) {
                [self setFeedbackViewIsVisible:YES animated:YES];
//                verb = @"show";
            }
//            NSLog(@"%f %@ %f && isVis?%d : should %@", scrollView.contentOffset.y, gtltSymbol, scrollView.contentSize.height - scrollView.bounds.size.height, feedbackViewWasVisible, verb);
        }
    }
}

- (void) setFeedbackViewIsVisible:(BOOL)feedbackViewIsVisible {
    [self setFeedbackViewIsVisible:feedbackViewIsVisible animated:NO];
}

- (void) setFeedbackViewIsVisible:(BOOL)feedbackViewIsVisible animated:(BOOL)animated {
    
    feedbackViewIsVisible_ = feedbackViewIsVisible;
    
    void(^feedbackViewVisibilityBlock)(BOOL) = ^(BOOL makeVisible){
        CGFloat feedbackViewOriginY = self.view.frame.size.height;
        if (makeVisible) {
            feedbackViewOriginY -= self.feedbackView.frame.size.height;
        }
        CGRect feedbackViewFrame = self.feedbackView.frame;
        feedbackViewFrame.origin.y = feedbackViewOriginY;
        self.feedbackView.frame = feedbackViewFrame;
    };
    
    if (animated) {
        CGFloat durationTotal = 0.25;
        [UIView animateWithDuration:durationTotal delay:0 
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             feedbackViewVisibilityBlock(self.feedbackViewIsVisible);
                         } 
                         completion:^(BOOL finished){}];
    } else {
        feedbackViewVisibilityBlock(self.feedbackViewIsVisible);
    }
    
}

- (void) setFeedbackViewMessageType:(EventsFeedbackMessageType)messageType eventsSummaryString:(NSString *)eventsSummaryString searchString:(NSString *)searchString animated:(BOOL)animated {
    
    void(^setMessagesTextBlock)(void) = ^{
        [self.feedbackView setMessagesToShowMessageType:messageType withEventsString:eventsSummaryString searchString:searchString];
    };
    
    void(^frameAdjustmentBlock)(BOOL) = ^(BOOL maintainBottomY){
        CGSize feedbackViewAdjustedSize = [self.feedbackView sizeForMessagesWithMessageType:messageType withEventsString:eventsSummaryString searchString:searchString];
        CGRect feedbackViewFrame = self.feedbackView.frame;
        if (maintainBottomY) {
            feedbackViewFrame.origin.y -= (feedbackViewAdjustedSize.height - feedbackViewFrame.size.height);
        }
        feedbackViewFrame.size = feedbackViewAdjustedSize;
        self.feedbackView.frame = feedbackViewFrame;
    };
    
    if (!animated || !self.feedbackViewIsVisible) {
        
        setMessagesTextBlock();
        frameAdjustmentBlock(self.feedbackViewIsVisible);
        
    } else {
        
        CGFloat durationTotal = 0.25;
        
        BOOL currentMessageComplex = self.feedbackView.isCurrentMessageComplex;
        BOOL forthcomingMessageComplex = [EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType];
        if (currentMessageComplex != forthcomingMessageComplex) {
            [UIView animateWithDuration:durationTotal/2.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction 
                             animations:^{
                                 self.feedbackView.messagesContainer.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 setMessagesTextBlock();
                                 [UIView animateWithDuration:durationTotal/2.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
                                     self.feedbackView.messagesContainer.alpha = 1.0;
                                 } completion:^(BOOL finished){}];
                             }];
        } else {
            setMessagesTextBlock();
        }
        
        [UIView animateWithDuration:durationTotal delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{ frameAdjustmentBlock(self.feedbackViewIsVisible); } completion:^(BOOL finished){}];
        
    }
    
}

//- (void) updateFiltersSummaryLabelWithString:(NSString *)summaryString {
//    
//    self.filtersSummaryLabel.text = summaryString;
//    
//    CGFloat filtersSummaryLabelPadding = 5.0;
//    CGRect filtersSummaryLabelFrame = self.filtersSummaryLabel.frame;
//    
//    filtersSummaryLabelFrame.size = [self.filtersSummaryLabel.text sizeWithFont:self.filtersSummaryLabel.font constrainedToSize:CGSizeMake(self.feedbackView.bounds.size.width - 2 * filtersSummaryLabelPadding, 1000) lineBreakMode:UILineBreakModeWordWrap];
//    filtersSummaryLabelFrame.origin.x = roundf((self.feedbackView.bounds.size.width - filtersSummaryLabelFrame.size.width) / 2.0);
//    CGFloat filtersSummaryContainerViewHeight = filtersSummaryLabelFrame.size.height + 2 * filtersSummaryLabelPadding;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.filtersSummaryLabel.frame = filtersSummaryLabelFrame;
//        self.feedbackView.frame = CGRectMake(self.feedbackView.frame.origin.x, self.view.bounds.size.height - filtersSummaryContainerViewHeight, self.feedbackView.frame.size.width, filtersSummaryContainerViewHeight);
//
//    }];
//    CGPoint tableViewContentOffset = self.tableView.contentOffset;
//    UIEdgeInsets tableViewInset = self.tableView.contentInset;
//    tableViewInset.bottom = self.feedbackView.bounds.size.height;
//    self.tableView.contentInset = tableViewInset;
//    if (!(self.eventsForCurrentSource.count > 0)) {
//        self.tableView.contentOffset = tableViewContentOffset; // Fixing a very slight bug, which would result in the search bar being scrolled into view when there were no results in the table.
//    }
//
//}

- (void) updateFilter:(EventsFilter *)filter buttonImageForFilterOption:(EventsFilterOption *)filterOption {
    NSString * bwIconFilename = [EventsFilterOption eventsFilterOptionIconFilenameForCode:filterOption.code grayscale:YES larger:NO];
    UIImage * bwIconImage = [UIImage imageNamed:bwIconFilename];
    // TEMPORARY HACK CHANGE. THE WAY WE ARE DEALING WITH LOCATION'S MOST GENERAL OPTION - IN THE CITY - IS A BIT UNDEFINED AT THE MOMENT. THAT IS THE MOST GENERAL LOCATION OPTION, AND YET IT HAS AN ICON AND IS NOT LABELLED "ANYWHERE" OR SOMETHING LIKE THAT. FOR NOW, I'D LIKE TO NOT PUT THE CITY ICON UP IN THE FILTER BUTTON, AND INSTEAD SHOW THE TEXT "LOCATION" WHEN IN THE CITY IS THE SELECTED OPTION.
    if (filterOption.isMostGeneralOption) {
        bwIconImage = nil;
    }
    [filter.button setImage:bwIconImage forState:UIControlStateNormal];
    if (bwIconImage == nil) {
        [filter.button setTitle:[filter.buttonText uppercaseString] forState:UIControlStateNormal];
    } else {
        [filter.button setTitle:nil forState:UIControlStateNormal];
    }
}

- (void) updateFilterOptionButtonStatesOldSelected:(EventsFilterOption *)oldSelectedOption newSelected:(EventsFilterOption *)newSelectedOption {
    oldSelectedOption.buttonView.button.selected = NO;
    newSelectedOption.buttonView.button.selected = YES;
    oldSelectedOption.buttonView.enabled = oldSelectedOption.buttonView.enabled; // This is masking some weird bug where if a button view was selected (the button) and disabled (the view), and then was set to no longer be selected above, the button's image view alpha would be set to full, no matter the wishes of the button view's enabled/disabled state.
}


- (void) updateActiveFilterHighlights {
    CGFloat scrollMidX = CGRectGetMidX(self.drawerScrollView.bounds);
    for (int i=0; i<self.filtersForCurrentSource.count; i++) {
        EventsFilter * filter = (EventsFilter *)[self.filtersForCurrentSource objectAtIndex:i];
        CGFloat filterMidX = CGRectGetMidX(filter.drawerView.frame);
        float highlightAmount = 1 - (fabsf(filterMidX - scrollMidX)/self.drawerScrollView.bounds.size.width);
        [self.activeFilterHighlightsContainerView setHighlightAmount:highlightAmount forSegmentAtIndex:i];
    }
}

- (void)setLogoButtonImageWithImageNamed:(NSString *)imageName {
    [self.filterButtonCategories setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void) setLogoButtonImageForCategoryURI:(NSString *)theCategoryURI {
    NSString * logoCategoryThumbnail = @"logo_";
    if (theCategoryURI) {
        Category * matchedCategory = (Category *)[self.concreteParentCategoriesDictionary objectForKey:theCategoryURI];
        NSString * normalCategoryThumbnail = matchedCategory.buttonThumb;
        logoCategoryThumbnail = [logoCategoryThumbnail stringByAppendingString:normalCategoryThumbnail];
    } else {
        logoCategoryThumbnail = [logoCategoryThumbnail stringByAppendingString:@"btn_cat_all.png"];
    }
    [self setLogoButtonImageWithImageNamed:logoCategoryThumbnail];
}

- (void)searchCancelButtonTouched:(id)sender {
    if ([self.searchTextField isFirstResponder]) {
        if (self.eventsFromSearch.count > 0) {
            [self.searchTextField resignFirstResponder];
        } else {
            [self toggleSearchModeAnimated:YES shouldMakeSearchTextFieldActiveWhenTogglingOn:YES shouldFlushQueryAndFilters:YES];
        }
    } else {
        [self toggleSearchModeAnimated:YES shouldMakeSearchTextFieldActiveWhenTogglingOn:YES shouldFlushQueryAndFilters:YES];
    }
}

- (void)searchGoButtonTouched:(id)sender {
    NSLog(@"About to searchExecutionRequestedByUser from searchGoButtonTouched");
    [self searchExecutionRequestedByUser];
}

- (void) feedbackViewRetryButtonTouched:(UIButton *)button {
//    NSLog(@"EventsViewController feedbackViewRetryButtonTouched");
    if (button == self.feedbackView.button) {
//        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource animated:YES];
        if (!self.isSearchOn) {
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        } else {
            NSLog(@"About to searchExecutionRequestedByUser from feedbackViewRetryButtonTouched");
            [self searchExecutionRequestedByUser];
        }
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized button sending message feedbackViewRetryButtonTouched");
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        if (!self.isSearchOn) {
            if (self.isDrawerOpen) {
                if (self.shouldReloadOnDrawerClose) {
                    [self toggleDrawerAnimated:YES];
                }
            } else {
                NSLog(@"Shake to reload");
                if (!self.feedbackView.isCurrentMessageComplex) {
                    [self setFeedbackViewMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
                }
                [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
            }
        }
    }
}

// THE FOLLOWING METHOD STUPIDLY ASSUMES THAT THE USER IS IN THE SAME TIME ZONE AS THE EVENTS FOR WHICH THEY ARE QUERYING. REALLY, WE SHOULD BE FIGURING OUT WHAT TIME ZONE THE USER IS IN, AND MAKING AN ADJUSTMENT IN THE FOLLOWING METHOD'S CALCULATIONS. This issue has been filed on #github.
- (void) updateTimeFilterOptions:(NSArray *)timeFilterOptions forSearch:(BOOL)forSearch givenSelectedDateFilterOption:(EventsFilterOption *)givenSelectedDateFilterOption userTime:(NSDate *)givenUserTime /*shouldBumpUnavailableTimes:(BOOL)shouldBumpUnavailableTimes*/ {
    BOOL allEnabled = forSearch || ![givenSelectedDateFilterOption.code isEqualToString:EFO_CODE_DATE_TODAY];
    for (EventsFilterOption * timeFilterOption in timeFilterOptions) {
        NSDate * latestTimeForFilterOption = [EventsFilterOption timeLatestForCode:timeFilterOption.code withUserTime:givenUserTime];
        unsigned int timeComponents = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar * calender = [NSCalendar currentCalendar];
        NSDateComponents * latestTimeComponents = [calender components:timeComponents fromDate:latestTimeForFilterOption];
        NSDateComponents * givenUserTimeComponents = [calender components:timeComponents fromDate:givenUserTime];
        latestTimeForFilterOption = [calender dateFromComponents:latestTimeComponents];
        givenUserTime = [calender dateFromComponents:givenUserTimeComponents];
        NSComparisonResult timesComparisonResult = [latestTimeForFilterOption compare:givenUserTime];
        timeFilterOption.buttonView.enabled = allEnabled || timeFilterOption.isMostGeneralOption || (timesComparisonResult == NSOrderedDescending);
        NSLog(@"Compared bucket latest %@ with user's time %@, got %d (where descending is %d)", latestTimeForFilterOption, givenUserTime, timesComparisonResult, NSOrderedDescending);
    }
//    if (shouldBumpUnavailableTimes) {
//        // ...
//    }
}

- (void) setLocationViewControllerDidCancel:(SetLocationViewController *)setLocationViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.setLocationViewController = nil;
}

- (void) setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectLocation:(BSKmlResult *)location {
    [self.dvLocationSetLocationButton setTitle:location.address forState:UIControlStateNormal];
    [self.dvLocationSearchSetLocationButton setTitle:location.address forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
    self.setLocationViewController = nil;
    /* THE FOLLOWING CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
    self.shouldReloadOnDrawerClose = YES;
    [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
    
    if (!self.isSearchOn) {
        self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
    } else {
        self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
    }
    /* THE PREVIOUS CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
}

- (void) setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectCurrentLocation:(CLLocation *)location {
    [self.dvLocationSetLocationButton setTitle:@"Current Location" forState:UIControlStateNormal];
    [self.dvLocationSearchSetLocationButton setTitle:@"Current Location" forState:UIControlStateNormal];
    [self dismissModalViewControllerAnimated:YES];
    self.setLocationViewController = nil;
    /* THE FOLLOWING CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
    self.shouldReloadOnDrawerClose = YES;
    [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
    
    if (!self.isSearchOn) {
        self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
    } else {
        self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
    }
    /* THE PREVIOUS CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
}

- (IBAction) currentLocationButtonTouched:(UIButton *)currentLocationButton {
    if (currentLocationButton == self.dvLocationCurrentLocationButton) {
        [self.dvLocationSetLocationButton setTitle:@"Current Location" forState:UIControlStateNormal];
    } else if (currentLocationButton == self.dvLocationSearchCurrentLocationButton) {
        [self.dvLocationSearchSetLocationButton setTitle:@"Current Location" forState:UIControlStateNormal];
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized currentLocationButton %@", currentLocationButton);
    }
    /* THE FOLLOWING CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
    self.shouldReloadOnDrawerClose = YES;
    [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
    
    if (!self.isSearchOn) {
        self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
    } else {
        self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
        [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
    }
    /* THE PREVIOUS CODE IS DUPLICATED SEVERAL PLACES IN EVENTSVIEWCONTROLLER */
}

- (IBAction) setLocationButtonTouched:(UIButton *)setLocationButton {
    
    self.userRequestedToShowLocationSetter = YES;
    if (self.setLocationViewController == nil) {
        setLocationViewController_ = [[SetLocationViewController alloc] initWithNibName:@"SetLocationViewController" bundle:[NSBundle mainBundle]];
    }
    self.setLocationViewController.delegate = self;
    self.setLocationViewController.hidesBottomBarWhenPushed = YES;
    [self presentModalViewController:self.setLocationViewController animated:YES];
    
//    if (textField == self.dvLocationTextField ||
//        textField == self.dvLocationSearchTextField) {
//        [self.dvLocationTextField resignFirstResponder];
//        [self.dvLocationSearchTextField resignFirstResponder];
//        
//        /* WARNING: THE FOLLOWING CODE IS COPIED FROM THE METHOD ...filterOptionButtonTouched...*/
//        self.shouldReloadOnDrawerClose = YES;
//        [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
//        
//        if (!self.isSearchOn) {
//            self.eventsSummaryStringBrowse = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
//            [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
//        } else {
//            self.eventsSummaryStringSearch = [self makeEventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
//            [self setFeedbackViewMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
//        }
//        /* WARNING: THE CODE ABOVE IS COPIED FROM THE METHOD ...filterOptionButtonTouched...*/
//        
//        shouldReturn = NO;
//    }

}

@end
