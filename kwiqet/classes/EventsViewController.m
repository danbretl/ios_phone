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
@property (readonly) BOOL feedbackViewIsVisible;
@property (retain) NSString * eventsSummaryStringBrowse;
@property (retain) NSString * eventsSummaryStringSearch;
@property (nonatomic, readonly) NSString * eventsSummaryStringForCurrentSource;

/////////////////////
// Views properties

@property (retain) IBOutlet UITableView * tableView;
@property (retain) UIView * tableViewCoverView;
@property (retain) IBOutlet UIView   * searchContainerView;
@property (retain) IBOutlet UIButton * searchButton;
@property (retain) IBOutlet UIButton * searchCancelButton;
@property (retain) IBOutlet UIButton * searchGoButton;
@property (retain) IBOutlet UITextField * searchTextField;
@property (retain) IBOutlet UIView   * tableReloadContainerView;
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
@property (retain) IBOutlet UITextField * dvLocationTextField;
@property (retain) UIButton * dvLocationCurrentLocationButton;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonWalking;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonNeighborhood;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonBorough;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonCity;
// Drawer view location search
@property (retain) IBOutlet UIView * drawerViewLocationSearch;
@property (retain) IBOutlet UITextField * dvLocationSearchTextField;
@property (retain) UIButton * dvLocationSearchCurrentLocationButton;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonWalking;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonNeighborhood;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonBorough;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonCity;
// Assorted views
@property (nonatomic, retain) WebActivityView * webActivityView;
@property (nonatomic, readonly) UIAlertView * connectionErrorStandardAlertView;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnDeleteAlertView;
// Gesture recognizers
@property (retain) UITapGestureRecognizer * tapToHideDrawerGR;

/////////////////////
// View Controllers

@property (nonatomic, retain) EventViewController * cardPageViewController;

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
- (IBAction) locationFilterCurrentLocationButtonTouched;
- (IBAction) searchButtonTouched:(id)sender;
- (IBAction) searchCancelButtonTouched:(id)sender;
- (IBAction) searchGoButtonTouched:(id)sender;
- (void) feedbackViewRetryButtonTouched:(UIButton *)button;

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
- (NSString *) eventsSummaryStringForSource:(NSString *)sourceString;
- (void) hideWebLoadingViews;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) loginActivity:(NSNotification *)notification;
- (void) releaseReconstructableViews;
- (void) releaseReconstructableViewModels;
- (void) resetSearchFilters;
- (void) searchExecutionRequestedByUser;
- (void) setDrawerScrollViewToDisplayViewsForSource:(NSString *)sourceString;
- (void) setDrawerToShowFilter:(EventsFilter *)filter animated:(BOOL)animated;
- (void) setFiltersBarToDisplayViewsForSource:(NSString *)sourceString;
- (void) setFiltersBarViewsOriginY:(CGFloat)originY adjustDrawerViewsAccordingly:(BOOL)shouldAdjustDrawerViews;
- (void) setImagesForCategoryButton:(UIButton *)button forCategory:(Category *)category;
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
- (void) toggleDrawerAnimated;
- (void) toggleSearchMode;
- (void) updateActiveFilterHighlights;
- (void) updateFilter:(EventsFilter *)filter buttonImageForFilterOption:(EventsFilterOption *)filterOption;
- (void) updateFilterOptionButtonStatesOldSelected:(EventsFilterOption *)oldSelectedOption newSelected:(EventsFilterOption *)newSelectedOption;
- (void) setFeedbackViewIsVisible:(BOOL)makeVisible adjustMessages:(BOOL)shouldAdjustMessages withMessageType:(EventsFeedbackMessageType)messageType eventsSummaryString:(NSString *)eventsSummaryString searchString:(NSString *)searchString animated:(BOOL)animated;
//- (void) updateFiltersSummaryLabelWithString:(NSString *)summaryString;
- (void) updateAdjustedSearchFiltersOrderedWithAdjustedFilter:(EventsFilter *)adjustedFilter selectedFilterOption:(EventsFilterOption *)selectedFilterOption;
- (void) updateViewsFromCurrentSourceDataWhichShouldBePopulated:(BOOL)dataShouldBePopulated reasonIfNot:(NSString *)reasonIfNotPopulated;
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
@synthesize pushableContainerView, pushableContainerShadowCheatView, feedbackView, feedbackViewIsVisible, eventsSummaryStringBrowse, eventsSummaryStringSearch;
@synthesize drawerScrollView, activeFilterHighlightsContainerView;
@synthesize drawerViewsBrowseContainer;
@synthesize drawerViewsSearchContainer;
@synthesize drawerViewPrice, dvPriceButtonAny, dvPriceButtonFree, dvPriceButtonUnder20, dvPriceButtonUnder50;
@synthesize drawerViewDate, dvDateButtonAny, dvDateButtonToday, dvDateButtonThisWeekend, dvDateButtonThisWeek, dvDateButtonThisMonth;
@synthesize drawerViewDateSearch, dvDateSearchButtonToday, dvDateSearchButtonThisWeekend, dvDateSearchButtonThisWeek, dvDateSearchButtonThisMonth, dvDateSearchButtonAny;
@synthesize drawerViewCategories;
@synthesize drawerViewTime, dvTimeButtonAny, dvTimeButtonMorning, dvTimeButtonAfternoon, dvTimeButtonEvening, dvTimeButtonNight;
@synthesize drawerViewTimeSearch, dvTimeSearchButtonMorning, dvTimeSearchButtonAfternoon, dvTimeSearchButtonEvening, dvTimeSearchButtonNight, dvTimeSearchButtonAny;
@synthesize drawerViewLocation, dvLocationTextField, dvLocationCurrentLocationButton, dvLocationButtonWalking, dvLocationButtonNeighborhood, dvLocationButtonBorough, dvLocationButtonCity;
@synthesize drawerViewLocationSearch, dvLocationSearchTextField, dvLocationSearchCurrentLocationButton, dvLocationSearchButtonWalking, dvLocationSearchButtonNeighborhood, dvLocationSearchButtonBorough, dvLocationSearchButtonCity;
@synthesize tableView=tableView_;
@synthesize tableViewCoverView;
@synthesize searchContainerView, searchButton, searchCancelButton, searchGoButton, searchTextField;
@synthesize tableReloadContainerView;
@synthesize tapToHideDrawerGR;
@synthesize eventsWebQuery, eventsWebQueryFromSearch, events, eventsFromSearch;
@synthesize coreDataModel, webActivityView, concreteParentCategoriesDictionary;
@synthesize concreteParentCategoriesArray;
@synthesize oldFilterString, categoryURI;
@synthesize isSearchOn;
@synthesize cardPageViewController;
@synthesize indexPathOfRowAttemptingToDelete, indexPathOfSelectedRow;
@synthesize isDrawerOpen, shouldReloadOnDrawerClose;
@synthesize feedbackMessageTypeBrowseRemembered, feedbackMessageTypeSearchRemembered;

- (void)dealloc {
    NSLog(@"--- --- --- --- --- EventsViewController dealloc --- --- --- --- ---");
    [cardPageViewController release];
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
    [self releaseReconstructableViews];
    [self releaseReconstructableViewModels];
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
    
    // Views settings - Drawer scroll view
    self.drawerScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerScrollView.layer.masksToBounds = YES;
    self.drawerViewsBrowseContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerViewsSearchContainer.backgroundColor = self.drawerViewsBrowseContainer.backgroundColor;
    
    // Views settings - Shadows
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
    // Pushable container
    self.pushableContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pushableContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.pushableContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.pushableContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.pushableContainerShadowCheatView.bounds].CGPath;
    self.pushableContainerShadowCheatView.layer.shouldRasterize = YES;
        
    // Views settings - Table view
    self.tableView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    
    // Views settings - Table header & footer
    self.tableView.tableHeaderView = self.searchContainerView;
    self.tableView.tableFooterView = self.tableReloadContainerView;
    self.tableView.tableFooterView.alpha = 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = NO;
    self.tableView.tableFooterView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    
    // Views allocation and settings - Table view cover view
    tableViewCoverView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableViewCoverView.backgroundColor = [UIColor whiteColor];
    self.tableViewCoverView.autoresizingMask = self.tableView.autoresizingMask;
    self.tableViewCoverView.alpha = 0.0;
    [self.pushableContainerView insertSubview:self.tableViewCoverView aboveSubview:self.tableView];

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
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filtersForCurrentSource.count;
    
    // Views allocations and settings - Location drawer view & its subviews
    // Current location button
    self.dvLocationCurrentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dvLocationCurrentLocationButton.frame = CGRectMake(0, 0, 23, 15);
    self.dvLocationCurrentLocationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.dvLocationCurrentLocationButton setImage:[UIImage imageNamed:@"ico_locationsearch.png"] forState:UIControlStateNormal];
    [self.dvLocationCurrentLocationButton addTarget:self action:@selector(locationFilterCurrentLocationButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    // Location text field
    self.dvLocationTextField.leftView = self.dvLocationCurrentLocationButton;
    self.dvLocationTextField.leftViewMode = UITextFieldViewModeAlways;
    self.dvLocationSearchTextField.leftView = self.dvLocationCurrentLocationButton;
    self.dvLocationSearchTextField.leftViewMode = UITextFieldViewModeAlways;
    
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
    
    // To create/recreate EventsViewController, we need to figure out / do...
    // - Is there a prior EventsWebQuery object? If so, what is the most recent one? Is it a search query, or just regular? What are the specifics of that query?
    // - Set all our filters accordingly, and set our appropriate events array accordingly as well.
    // - Finally, set all our views to match that data that we just (possibly re)created.
    
    // Get the most recent events web queries, if they exist
    self.eventsWebQuery = [self.coreDataModel getMostRecentEventsWebQueryWithoutSearchTerm];
    self.eventsWebQueryFromSearch = [self.coreDataModel getMostRecentEventsWebQueryWithSearchTerm];
    
    // Do some initial setup
    int indexOfActiveBrowseFilter = 0;
    NSString * categoryFilterURI = nil;
    int indexOfSelectedCategoryFilterOption = 0;
    int indexOfSelectedPriceFilterOption = priceOptions.count - 1;
    int indexOfSelectedDateFilterOption = dateOptions.count - 1;
    int indexOfSelectedTimeFilterOption = timeOptions.count - 1;
    int indexOfSelectedLocationFilterOption = locationOptions.count - 1;
    int indexOfActiveSearchFilter = 0;
    int indexOfSelectedDateSearchFilterOption = dateSearchOptions.count - 1;
    int indexOfSelectedLocationSearchFilterOption = locationSearchOptions.count - 1;
    int indexOfSelectedTimeSearchFilterOption = timeSearchOptions.count - 1;
    NSString * locationStringBrowse = nil;
    NSString * locationStringSearch = nil;
    NSString * searchTerm = nil;
    // Figure out which events web query is the most recent (if either exists)
    BOOL priorEventsWebQueryExists = NO;
    BOOL mostRecentEventsWebQueryWasFromSearch = NO;
    EventsWebQuery * mostRecentEventsWebQuery = nil;
    if (self.eventsWebQuery != nil ||
        self.eventsWebQueryFromSearch != nil) {
        // Basic variables setup
        priorEventsWebQueryExists = YES;
        mostRecentEventsWebQueryWasFromSearch = [self.eventsWebQuery.queryDatetime compare:self.eventsWebQueryFromSearch.queryDatetime] == NSOrderedAscending;
        mostRecentEventsWebQuery = mostRecentEventsWebQueryWasFromSearch ? self.eventsWebQueryFromSearch : self.eventsWebQuery;
        // Set events arrays, both browse and search
        self.events = [self.eventsWebQuery.eventResultsEventsInOrder.mutableCopy autorelease]; // If the query is nil, the events array will be set to nil. Not a problem.
        self.eventsFromSearch = [self.eventsWebQueryFromSearch.eventResultsEventsInOrder.mutableCopy autorelease]; // If the query is nil, the events array will be set to nil. Not a problem.
        NSUInteger(^indexOfEventsFilterOptionBlock)(NSString *, NSArray *, NSString *)=^(NSString * filterCode, NSArray * filtersArray, NSString * filterOptionCode){
            EventsFilter * filter = [self filterForFilterCode:filterCode inFiltersArray:filtersArray];
            EventsFilterOption * foundFO = [[filter.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.code == %@", filterOptionCode]] objectAtIndex:0];
            return [filter.options indexOfObject:foundFO];
        };
        // Set a bunch of indexes from above
        if (self.eventsWebQuery != nil) {
            // indexOfActiveBrowseFilter... // Skipping for now. Not that important.
            categoryFilterURI = ((Category *)[self.eventsWebQuery.filterCategories anyObject]).uri; // THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES. THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES. THIS WILL NEED TO CHANGE WHEN WE START SUPPORTING MULTIPLE SELECTED CATEGORIES.
            indexOfSelectedCategoryFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_CATEGORIES, self.filters, [EventsFilterOption eventsFilterOptionCategoryCodeForCategoryURI:categoryFilterURI]);
            indexOfSelectedPriceFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_PRICE, self.filters, self.eventsWebQuery.filterPriceBucketString);
            indexOfSelectedDateFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_DATE, self.filters, self.eventsWebQuery.filterDateBucketString);
            indexOfSelectedTimeFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_TIME, self.filters, self.eventsWebQuery.filterTimeBucketString);
            indexOfSelectedLocationFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_LOCATION, self.filters, self.eventsWebQuery.filterDistanceBucketString);
            locationStringBrowse = self.eventsWebQuery.filterLocationString;
        }
        if (self.eventsWebQueryFromSearch != nil) {
            // indexOfActiveSearchFilter... // Skipping for now. Not that important.
            indexOfSelectedDateFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_DATE, self.filtersSearch, self.eventsWebQueryFromSearch.filterDateBucketString);
            indexOfSelectedTimeFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_TIME, self.filtersSearch, self.eventsWebQueryFromSearch.filterTimeBucketString);
            indexOfSelectedLocationFilterOption = indexOfEventsFilterOptionBlock(EVENTS_FILTER_LOCATION, self.filtersSearch, self.eventsWebQueryFromSearch.filterDistanceBucketString);
            locationStringSearch = self.eventsWebQueryFromSearch.filterLocationString;
            searchTerm = self.eventsWebQueryFromSearch.searchTerm;
        }
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
    
    // Set the search filter settings
    self.activeSearchFilterInUI = [self.filtersSearch objectAtIndex:indexOfActiveSearchFilter];
    self.selectedDateSearchFilterOption = [dateSearchOptions objectAtIndex:indexOfSelectedDateSearchFilterOption];
    self.selectedLocationSearchFilterOption = [locationSearchOptions objectAtIndex:indexOfSelectedLocationSearchFilterOption];
    self.selectedTimeSearchFilterOption = [timeSearchOptions objectAtIndex:indexOfSelectedTimeSearchFilterOption];
    // Adjusted search filters... Sort of faking it for now. If any of the search filters were adjusted, we'll just pick one (that was adjusted) to be the most recently adjusted.
    self.adjustedSearchFiltersOrdered = [NSMutableArray arrayWithCapacity:self.filtersSearch.count];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_LOCATION inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedLocationSearchFilterOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_TIME inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedTimeFilterOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:[self filterForFilterCode:EVENTS_FILTER_DATE inFiltersArray:self.filtersSearch] selectedFilterOption:self.selectedDateFilterOption];
    
    // Set the feedback strings
    self.eventsSummaryStringBrowse = [self eventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
    self.eventsSummaryStringSearch = [self eventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    
    // Update views
    // Update filter option button states - both browse and search
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedPriceFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeSearchFilterOption];
    // Update category filter option button state
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
    
    // Start things off in browse mode, with browse filters. Then, if we should be in search mode, just call our toggleSearchMode method. All the views start in browse mode positions anyway, so we kind of have to do this.
    self.isSearchOn = NO;
    [self.filtersContainerView addSubview:self.filtersBarBrowse];
    [self.drawerScrollView addSubview:self.drawerViewsBrowseContainer];
    self.drawerScrollView.contentSize = self.drawerViewsBrowseContainer.bounds.size;
    [self setDrawerToShowFilter:self.activeFilterInUI animated:NO];
    if (priorEventsWebQueryExists &&
        mostRecentEventsWebQueryWasFromSearch) {
        [self toggleSearchMode]; // COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED. COME BACK TO THIS. CURRENTLY THIS WILL BE A PROBLEM, BECAUSE IT WILL BE ANIMATED.
        self.searchTextField.text = searchTerm;
    }
    
    if (!priorEventsWebQueryExists ||
        (!mostRecentEventsWebQueryWasFromSearch &&
         mostRecentEventsWebQuery.eventResults.count == 0)) {
        // Connect to web and try to get a new set of results (IF we are in browse mode - if we're in search mode, just sit tight).
        [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:NO];
        [self webConnectGetEventsListWithCurrentOldFilterAndCategory]; // Don't need to reloadData until we get a response back from this web connection attempt.
    }
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Register for login activity events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActivity:) name:@"loginActivity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(behaviorWasReset:) name:@"learningBehaviorWasReset" object:nil];
    
}

- (void) releaseReconstructableViews {
    self.tableView = nil;
    self.tableViewCoverView = nil;
    self.searchContainerView = nil;
    self.searchButton = nil;
    self.searchCancelButton = nil;
    self.searchGoButton = nil;
    self.searchTextField = nil;
    self.tableReloadContainerView = nil;
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
    self.dvLocationTextField = nil;
    self.dvLocationCurrentLocationButton = nil;
    self.dvLocationButtonWalking = nil;
    self.dvLocationButtonNeighborhood = nil;
    self.dvLocationButtonBorough = nil;
    self.dvLocationButtonCity = nil;
    
    self.drawerViewLocationSearch = nil;
    self.dvLocationSearchTextField = nil;
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
    self.tapToHideDrawerGR = nil;
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

- (void) setUpFiltersUI:(NSArray *)arrayOfEventsFilters withOptionButtonSelectors:(NSDictionary *)dictionaryOfEventFilterOptionSelectors compressedOptionButtons:(BOOL)compressed {
    
    for (EventsFilter * filter in arrayOfEventsFilters) {
        filter.drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
        filter.drawerView.backgroundColor = [UIColor clearColor]; // TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT TESTING PERFORMANCE HIT
        [filter.button setTitle:[filter.buttonText uppercaseString] forState:UIControlStateNormal];
        filter.button.titleLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:12.0];
        filter.button.adjustsImageWhenHighlighted = NO;
        if (![filter.code isEqualToString:EVENTS_FILTER_CATEGORIES]) {
            filter.button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
            filter.button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 16, 0);
            filter.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 16, 0);
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
    
    // Fixing some strange bug where if you are in search mode and not at the top of the events list, then push an event card, then come back to the events list, then the search text field (which we had been sticking at the top of the screen) would disappear until you scrolled the table view (at which point it would stick back at the top of the screen).
    if (self.isSearchOn) {
        CGRect scvf = self.searchContainerView.frame;
        scvf.origin.y = self.tableView.bounds.origin.y;
        self.searchContainerView.frame = scvf;
    }
    
    // Deselect selected row, if there is one
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES]; // There is something weird going on with the animation - it is going really slowly. Figure this out later. It doesn't look horrible right now though, so, I'm just going to leave it.
    
    if (self.webConnector.connectionInProgress) {
        [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:animated];
        [self showWebLoadingViews];
    } else if (self.eventsWebQueryForCurrentSource.eventResults.count == 0) {
        if (self.isSearchOn) {
            // Not going to do anything on this path for now... Just leave the list blank?
        } else {
            NSLog(@"No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events.");
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        }
    } else {
        // Not worried about this path currently...
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    if (self.isDrawerOpen) {
//        [self toggleDrawerAnimated];
//    } // I like this behavior less and less, especially when closing the drawer is what a user does to initiate an events reload (with newly adjusted filters).
    [self resignFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        if (!self.isSearchOn) {
            NSLog(@"Shake to reload");
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
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

- (void) webConnectGetEventsListWithCurrentOldFilterAndCategory {
//    NSLog(@"EventsViewController webConnectGetEventsListWithCurrentFilterAndCategory");
    [self webConnectGetEventsListWithOldFilter:self.oldFilterString categoryURI:self.categoryURI];
}

- (void) webConnectGetEventsListWithOldFilter:(NSString *)theProposedOldFilterString categoryURI:(NSString *)theProposedCategoryURI {
//    NSLog(@"EventsViewController webConnectGetEventsListWithFilter");

    // Storing and using EventWebQuery objects
    if (self.eventsWebQuery.queryDatetime != nil) {
        self.eventsWebQuery = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];            
    }
    self.eventsWebQuery.filterDateBucketString = self.selectedDateFilterOption.code;
    self.eventsWebQuery.filterDistanceBucketString = self.selectedLocationFilterOption.code;
    self.eventsWebQuery.filterLocationString = self.dvLocationTextField.text;
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
    [self.webConnector getEventsListWithFilter:self.oldFilterString categoryURI:self.categoryURI];
    
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

// Process the new retrieved events (if there are indeed successfully retrieved events) and get htem into Core Data
- (void)webConnector:(WebConnector *)theWebConnector getEventsListSuccess:(ASIHTTPRequest *)request withFilter:(NSString *)theFilterString categoryURI:(NSString *)theCategoryURI {

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
        
        // Save our core data changes
        [self.coreDataModel coreDataSave];
        
    } else {
        self.eventsWebQuery.queryDatetime = [NSDate date];
        self.events = nil;
    }
    
    if (!self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:haveResults reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS];
    }

}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request withFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI {

    NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    self.eventsWebQuery.queryDatetime = [NSDate date];
    self.events = nil;
    
    if (!self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:NO reasonIfNot:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR];
    }
    
}

- (void) searchExecutionRequestedByUser {
    
    NSString * searchTerm = self.searchTextField.text;
    
    if (searchTerm && searchTerm.length > 0) {
        
        [self.searchTextField resignFirstResponder];
        if (self.isDrawerOpen) {
            [self toggleDrawerAnimated];
        }
        
        // Storing and using EventWebQuery objects
        if (self.eventsWebQueryFromSearch.queryDatetime != nil) {
            self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];            
        }
        self.eventsWebQueryFromSearch.searchTerm = searchTerm;
        self.eventsWebQueryFromSearch.filterDateBucketString = self.selectedDateSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterDistanceBucketString = self.selectedLocationSearchFilterOption.code;
        self.eventsWebQueryFromSearch.filterLocationString = self.dvLocationSearchTextField.text;
        self.eventsWebQueryFromSearch.filterTimeBucketString = self.selectedTimeSearchFilterOption.code;
        [self.coreDataModel coreDataSave];
        
        [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
        [self showWebLoadingViews];
        [self.webConnector getEventsListForSearchString:searchTerm];
        
    } else {
        
        UIAlertView * noSearchTermAlertView = [[UIAlertView alloc] initWithTitle:@"Missing Search Term" message:@"Please enter at least one search term in the text field above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noSearchTermAlertView show];
        [noSearchTermAlertView release];
        
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString {
    
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
        
        // Save our core data changes
        [self.coreDataModel coreDataSave];
                
    } else {
        self.eventsWebQueryFromSearch.queryDatetime = [NSDate date];
        self.eventsFromSearch = nil;
    }
        
    if (self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:haveResults reasonIfNot:EVENTS_NO_RESULTS_REASON_NO_RESULTS];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString {
    
    NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    self.eventsWebQueryFromSearch.queryDatetime = [NSDate date];
    self.eventsFromSearch = nil;
    
    if (self.isSearchOn) {
        [self updateViewsFromCurrentSourceDataWhichShouldBePopulated:NO reasonIfNot:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR];
    }
    
}

- (void) updateViewsFromCurrentSourceDataWhichShouldBePopulated:(BOOL)dataShouldBePopulated reasonIfNot:(NSString *)reasonIfNotPopulated {
    
    if (!self.isSearchOn) {
        self.eventsSummaryStringBrowse = [self eventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
    } else {
        self.eventsSummaryStringSearch = [self eventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    }
    
    [self.tableView reloadData];
    if (!self.isSearchOn) {
        if (self.eventsWebQueryForCurrentSource.eventResults.count > 0) {
            [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];
        }
    } else {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    BOOL eventsRetrieved = self.eventsWebQueryForCurrentSource.eventResults.count > 0;
    BOOL showTableFooterView = eventsRetrieved && !self.isSearchOn;
    self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = showTableFooterView;
    [self setTableViewScrollable:eventsRetrieved selectable:eventsRetrieved];
    if (eventsRetrieved) {
        // Events were retrieved... They will be displayed.
        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LookingAtEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    } else {
        // No events were retrieved. Respond accordingly, depending on the reason.
        if ([reasonIfNotPopulated isEqualToString:EVENTS_NO_RESULTS_REASON_NO_RESULTS]) {
            if (self.isSearchOn) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"No results" message:@"Sorry, we couldn't find any events matching your search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                [self.searchTextField becomeFirstResponder];
                [self setFeedbackViewIsVisible:NO adjustMessages:NO withMessageType:0 eventsSummaryString:nil searchString:nil animated:YES];
            } else {
                [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:NoEventsFound eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
            }
        } else if ([reasonIfNotPopulated isEqualToString:EVENTS_NO_RESULTS_REASON_CONNECTION_ERROR]) {
            [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:ConnectionError eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
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
    
    UIEdgeInsets tableViewInset = self.tableView.contentInset;
    tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
    self.tableView.contentInset = tableViewInset;
    
    [self hideWebLoadingViews];
    
}

//- (void) showProblemViewNoEventsForOldFilter:(NSString *)forOldFilterString categoryTitle:(NSString *)categoryTitle animated:(BOOL)animated {
//    
//    NSString * message = nil;
//    
//    if (forOldFilterString && categoryTitle) {
//        message = [NSString stringWithFormat:@"Sorry, we couldn't find any\n%@ events for you\nin %@.\nTry a different combination.", forOldFilterString/*[forFilterString capitalizedString]*/, categoryTitle];
//    } else if (forOldFilterString || categoryTitle) {
//        NSString * modifier = forOldFilterString ? forOldFilterString : categoryTitle;
//        message = [NSString stringWithFormat:@"Sorry, we couldn't find any\n%@ events for you.\nPlease try again.", modifier];        
//    } else {
//        message = @"Sorry, we couldn't find any events for you at this time. Please try again.";
//    }
//    
//    [self setProblemViewVisible:YES withMessage:message animated:animated];
//    
//}
//
//- (void) showProblemViewBadConnectionAnimated:(BOOL)animated {
//    NSString * message = WEB_CONNECTION_ERROR_MESSAGE_STANDARD;
//    [self setProblemViewVisible:YES withMessage:message animated:animated];
//}
//
//- (void) hideProblemViewAnimated:(BOOL)animated {
//    [self setProblemViewVisible:NO withMessage:nil animated:animated];
//}
//
//- (void) showProblemViewAnimated:(BOOL)animated {
//    [self setProblemViewVisible:YES withMessage:nil animated:animated];
//}
//
//- (void) setProblemViewVisible:(BOOL)showView withMessage:(NSString *)message animated:(BOOL)animated {
//
//    void (^replaceTextBlock)(void) = ^{
//        if (message) {
//            self.problemLabel.text = message;
//            CGRect tempFrame = self.problemLabel.frame;
//            tempFrame.size.width = self.problemView.frame.size.width;
//            self.problemLabel.frame = tempFrame;
//            [self.problemLabel sizeToFit];
//            tempFrame = self.problemLabel.frame;
//            tempFrame.origin.x = floorf((self.problemView.frame.size.width - tempFrame.size.width) / 2.0);
//            self.problemLabel.frame = tempFrame;
//        }
//    };
//    
//    void (^alphaChangeBlock)(void) = ^{
//        self.problemView.alpha = showView ? 1.0 : 0.0;
//    };
//    
//    if (animated) {
//        if (showView) {
//            replaceTextBlock();
//        }
//        [UIView animateWithDuration:0.25 animations:alphaChangeBlock completion:^(BOOL finished) {
//            if (!showView) { replaceTextBlock(); }
//        }];
//    } else {
//        // Order shouldn't matter when not animated...
//        replaceTextBlock();
//        alphaChangeBlock();
//    }
//    
//    self.problemView.userInteractionEnabled = showView;
////    [self setTableViewScrollable:!showView selectable:!showView];
//    
//}

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
    [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.drawerScrollView) {
//        [self updateActiveFilterHighlights]; // This is killing performance.
//    }
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
        [self toggleDrawerAnimated];
    } // THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE THIS IS WHERE YOU ARE 
    
}

- (IBAction) reloadEventsListButtonTouched:(id)sender {
    [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

-(void)toggleDrawerAnimated {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:self.isSearchOn ? 0.3 : 0.4];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    if (self.isDrawerOpen == NO) {
        self.isDrawerOpen = YES;
        self.tapToHideDrawerGR.enabled = YES;
        CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
        pushableContainerViewFrame.origin.y += self.drawerScrollView.contentSize.height;
        self.pushableContainerView.frame = pushableContainerViewFrame;
        self.pushableContainerShadowCheatView.frame = self.pushableContainerView.frame;
        [self setTableViewScrollable:NO selectable:NO];
        self.filtersContainerShadowCheatView.alpha = 0.0;
        self.filtersContainerShadowCheatWayBelowView.alpha = 1.0;
        if (!self.isSearchOn && self.tableView.contentOffset.y < self.searchContainerView.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];
        }
        BOOL hadResults = self.eventsWebQueryForCurrentSource.eventResults.count > 0;
        self.shouldReloadOnDrawerClose = !hadResults;
        [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:NO];
        if (!self.isSearchOn) {
            self.feedbackMessageTypeBrowseRemembered = self.feedbackView.messageType;
        } else {
            self.feedbackMessageTypeSearchRemembered = self.feedbackView.messageType;
        }
        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:(hadResults ? SetFiltersPrompt : CloseDrawerToLoadPrompt) eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    } else {
        self.isDrawerOpen = NO;
        self.tapToHideDrawerGR.enabled = NO;
        CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
        pushableContainerViewFrame.origin.y -= self.drawerScrollView.contentSize.height;
        self.pushableContainerView.frame = pushableContainerViewFrame;
        self.pushableContainerShadowCheatView.frame = self.pushableContainerView.frame;
        BOOL haveEvents = self.eventsWebQueryForCurrentSource.eventResults.count > 0;
        [self setTableViewScrollable:haveEvents selectable:haveEvents];
        self.filtersContainerShadowCheatView.alpha = 1.0;
        self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
        [self.dvLocationTextField resignFirstResponder];
        [self.dvLocationSearchTextField resignFirstResponder];
        if (self.shouldReloadOnDrawerClose) {
            if (!self.isSearchOn) {
                // Browse mode, should reload...
                [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
            } else {
                // Search mode, should re-search...
                [self searchExecutionRequestedByUser];
            }
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
        } else {
            EventsFeedbackMessageType rememberedMessageType = !self.isSearchOn ? self.feedbackMessageTypeBrowseRemembered : self.feedbackMessageTypeSearchRemembered;
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:rememberedMessageType eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
        }
        // The following code moved here from filterOptionButtonTouched... This spot seems more appropriate, considering that the table view will not move while the drawer is open.
        UIEdgeInsets tableViewInset = self.tableView.contentInset;
        tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
        self.tableView.contentInset = tableViewInset;
    }
    self.drawerScrollView.userInteractionEnabled = self.isDrawerOpen;
    
    [UIView commitAnimations];
}

- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable {
    self.tableView.scrollEnabled = scrollable;
    self.tableView.allowsSelection = selectable;
}

#pragma mark Search

- (void) adjustSearchViewsToShowButtons:(BOOL)showButtons {
    
    int reverser = showButtons ? 1 : -1;
    
    // Set search UI shifts up
    CGFloat searchCancelButtonShift = reverser * (10 + self.searchCancelButton.frame.size.width);
    CGFloat searchGoButtonShift = reverser * -(10 + self.searchGoButton.frame.size.width);
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
    stff.origin.x += searchCancelButtonShift;
    stff.size.width += -searchCancelButtonShift + searchGoButtonShift;
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
    
    CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
    pushableContainerViewFrame.origin.y = originY;
    if (shouldAdjustHeight) {
        pushableContainerViewFrame.size.height = self.view.bounds.size.height - pushableContainerViewFrame.origin.y;        
    }
    self.pushableContainerView.frame = pushableContainerViewFrame;
    self.pushableContainerShadowCheatView.frame = pushableContainerViewFrame;
    
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
    
    self.drawerScrollView.contentSize = viewToAddAsSubview.bounds.size;
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filtersForCurrentSource.count;
    [self setDrawerToShowFilter:activeFilter animated:NO];
    
}

- (void) toggleSearchMode {
    
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    self.isSearchOn = !self.isSearchOn;
    // Is new mode search on, or search off
    self.searchButton.enabled = !self.isSearchOn;
    self.searchTextField.text = @"";
    
    if (self.isSearchOn) {
        // New mode is search on
        // Clear all previous search results / terms etc
        self.eventsWebQueryFromSearch = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
        self.eventsFromSearch = nil;
        self.tableViewCoverView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + self.tableView.tableHeaderView.bounds.size.height, self.tableView.frame.size.width, self.pushableContainerView.frame.size.height - self.tableView.tableHeaderView.bounds.size.height);
        // Set table view content offset to top
        self.tableView.contentOffset = CGPointMake(0, 0);
        [UIView animateWithDuration:0.25 
                         animations:^{
                             // Move filters bar off screen
                             [self setFiltersBarViewsOriginY:-self.filtersContainerView.frame.size.height adjustDrawerViewsAccordingly:NO];
                             // Fade out the filters bar shadow
                             self.filtersContainerShadowCheatView.alpha = 0.0;
                             // Move pushable container view up to top of screen
                             [self setPushableContainerViewsOriginY:0 adjustHeightToFillMainView:YES];
                             // Move summary string off screen
                             [self setFeedbackViewIsVisible:NO adjustMessages:NO withMessageType:0 eventsSummaryString:nil searchString:nil animated:YES];
                             // Fade table view out
                             self.tableViewCoverView.alpha = 1.0;
                             // Fade out table footer view
                             self.tableView.tableFooterView.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             // Reload table data
                             [self.tableView reloadData];
                             NSLog(@"EventsViewController tableView reloadData");
                             // Pull the search bar out of the table view header
                             self.tableView.tableHeaderView = nil;
                             [self.view insertSubview:self.searchContainerView aboveSubview:self.filtersContainerView];
                             self.searchContainerView.frame = CGRectMake(0, 0, self.searchContainerView.frame.size.width, self.searchContainerView.frame.size.height);
                             [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) adjustHeightToFillMainView:YES];
                             self.tableViewCoverView.frame = self.tableView.frame;
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
                             [UIView animateWithDuration:0.25 animations:^{
                                 // Make the search text field first responder, thus bringing the keyboard up
                                 [self resignFirstResponder];
                                 [self.searchTextField becomeFirstResponder];
                                 [self adjustSearchViewsToShowButtons:YES];
                                 // Reveal filters bar on screen
                                 [self setFiltersBarViewsOriginY:CGRectGetMaxY(self.searchContainerView.frame) adjustDrawerViewsAccordingly:YES];
                                 // Fade in the filters bar shadow
                                 self.filtersContainerShadowCheatView.alpha = 1.0;
                                 // Move pushable container down
                                 [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.filtersContainerView.frame) adjustHeightToFillMainView:YES];
                                 // Move summary string on screen
//                                 [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringSearch animated:YES];
                                 // Fade table view in
                                 self.tableViewCoverView.alpha = 0.0;
                             }];
                         }];
    } else {
        // New mode is search off
        [UIView animateWithDuration:0.25 
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
                             // Move summary string off screen
                             [self setFeedbackViewIsVisible:NO adjustMessages:NO withMessageType:0 eventsSummaryString:nil searchString:nil animated:YES];
                             // Fade table view out
                             self.tableViewCoverView.alpha = 1.0;
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
                             self.tableViewCoverView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + self.searchContainerView.bounds.size.height, self.tableView.frame.size.width, self.pushableContainerView.frame.size.height - self.searchContainerView.bounds.size.height);
                             // Swap the browse & search filter bars
                             [self setFiltersBarToDisplayViewsForSource:EVENTS_SOURCE_BROWSE];
                             // Swap the browse & search filter drawer views
                             [self setDrawerScrollViewToDisplayViewsForSource:EVENTS_SOURCE_BROWSE];
                             // Add the table footer view back in
                             self.tableView.tableFooterView = self.tableReloadContainerView;
                             BOOL showTableFooterView = self.eventsWebQueryForCurrentSource.eventResults.count > 0;
                             self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
                             // Switch the filters summary label to browse
                             [UIView animateWithDuration:0.25 animations:^{
                                 // Move filters bar onto screen
                                 [self setFiltersBarViewsOriginY:0 adjustDrawerViewsAccordingly:YES];
                                 // Fade in the filters bar shadow
                                 self.filtersContainerShadowCheatView.alpha = 1.0;
                                 // Move pushable container down
                                 [self setPushableContainerViewsOriginY:CGRectGetMaxY(self.filtersContainerView.frame) adjustHeightToFillMainView:YES];
                                 // Move summary string on screen
                                 [self setFeedbackViewIsVisible:YES adjustMessages:YES withMessageType:self.feedbackMessageTypeBrowseRemembered eventsSummaryString:self.eventsSummaryStringBrowse searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
                                 // Fade table view in
                                 self.tableViewCoverView.alpha = 0.0;
                                 BOOL haveResult = self.eventsWebQueryForCurrentSource.eventResults.count > 0;
                                 [self setTableViewScrollable:haveResult selectable:haveResult];
                             }];
                             // Search filters clean-up
                             [self resetSearchFilters];
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
    self.selectedLocationSearchFilterOption = locationFilter.mostGeneralOption;
    self.selectedTimeSearchFilterOption = timeFilter.mostGeneralOption;
    // Update the filter option buttons UI
    [self updateFilterOptionButtonStatesOldSelected:oldDateSFO newSelected:self.selectedDateSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:oldLocationSFO newSelected:self.selectedLocationSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:oldTimeSFO newSelected:self.selectedTimeSearchFilterOption];
    // Update the filter buttons UI
    [self updateFilter:dateFilter buttonImageForFilterOption:self.selectedDateSearchFilterOption];
    [self updateFilter:locationFilter buttonImageForFilterOption:self.selectedLocationSearchFilterOption];
    [self updateFilter:timeFilter buttonImageForFilterOption:self.selectedTimeSearchFilterOption];
    // Update the search filters summary string
    self.eventsSummaryStringSearch = [self eventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
    // Clear out the array of most recently adjusted search filters
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:dateFilter selectedFilterOption:dateFilter.mostGeneralOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:locationFilter selectedFilterOption:locationFilter.mostGeneralOption];
    [self updateAdjustedSearchFiltersOrderedWithAdjustedFilter:timeFilter selectedFilterOption:timeFilter.mostGeneralOption];
}

- (IBAction) searchButtonTouched:(id)sender  {
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    [self toggleSearchMode];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.searchTextField) {
        [self searchExecutionRequestedByUser];
        shouldReturn = NO;
    } else if (textField == self.dvLocationTextField ||
               textField == self.dvLocationSearchTextField) {
        [self.dvLocationTextField resignFirstResponder];
        [self.dvLocationSearchTextField resignFirstResponder];
        
        /* WARNING: THE FOLLOWING CODE IS COPIED FROM THE METHOD ...filterOptionButtonTouched...*/
        self.shouldReloadOnDrawerClose = YES;
        [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
        
        if (!self.isSearchOn) {
            self.eventsSummaryStringBrowse = [self eventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
        } else {
            self.eventsSummaryStringSearch = [self eventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
        }
        /* WARNING: THE CODE ABOVE IS COPIED FROM THE METHOD ...filterOptionButtonTouched...*/
        
        shouldReturn = NO;
    }
    return shouldReturn;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    if (textField == self.searchTextField) {
        
        if (self.eventsWebQueryFromSearch.eventResults.count > 0 &&
            self.adjustedSearchFiltersOrdered.count > 0 &&
            !self.isDrawerOpen) {
            self.activeSearchFilterInUI = self.mostRecentlyAdjustedSearchFilter;
            [self setDrawerToShowFilter:self.activeSearchFilterInUI animated:NO];
            [self toggleDrawerAnimated];
        }
    }

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
        
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized alert view.");
    }
}

- (void)cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI {

    if (eventWasDeleted) {
        
        [self.coreDataModel deleteRegularEventForURI:eventURI];

        // Delete event from our table display array
        [self.eventsForCurrentSource removeObjectAtIndex:self.indexPathOfSelectedRow.row];
        
        // Animate event deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathOfSelectedRow] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = keyboardSize.height - self.tabBarController.tabBar.bounds.size.height;
        self.tableView.contentInset = insets;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        scrollInsets.bottom = keyboardSize.height - self.tabBarController.tabBar.bounds.size.height;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
//	CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    double keyboardAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
        self.tableView.contentInset = insets;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        scrollInsets.bottom = 0;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    }];
}

- (void)loginActivity:(NSNotification *)notification {
//    NSLog(@"EventsViewController loginActivity");
    //NSString * action = [[notification userInfo] valueForKey:@"action"]; // We don't really care whether the user just logged in or logged out - we should get new events list no matter what.
    if (self.isSearchOn) {
        [self toggleSearchMode];
    }
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    if (self.view.window) {
        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    }
    [self webConnectGetEventsListWithOldFilter:EVENTS_OLDFILTER_RECOMMENDED categoryURI:nil];
}

- (void) behaviorWasReset:(NSNotification *)notification {
    if (self.isSearchOn) {
        [self toggleSearchMode];
    }
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    if (self.view.window) {
        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource searchString:(self.isSearchOn ? self.searchTextField.text : nil) animated:YES];
    }
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
        NSLog(@"wlvOrigin = %@", NSStringFromCGPoint(self.webActivityView.frame.origin));
        
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
        [self toggleDrawerAnimated];
    }
}

- (void) swipeUpToHideDrawer:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipeUpToHideDrawer");
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
}

- (void) tapToHideDrawer:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"tapToHideDrawer");
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
}

- (void) swipeAcrossFiltersStrip:(UISwipeGestureRecognizer *)swipeGesture {
    UIAlertView * resetAllFiltersAlertView = [[UIAlertView alloc] initWithTitle:@"Reset all filters?" message:@"Are you sure you'd like to reset all filters?" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
    [resetAllFiltersAlertView show];
    [resetAllFiltersAlertView release];
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
    
    [self.dvLocationTextField resignFirstResponder];
    [self.dvLocationSearchTextField resignFirstResponder];
    
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
        
        
        /* WARNING: THE FOLLOWING CODE HAS BEEN COPIED TO THE METHOD ...textFieldShouldReturn... */
        self.shouldReloadOnDrawerClose = YES;
        [self setDrawerReloadIndicatorViewIsVisible:self.shouldReloadOnDrawerClose animated:self.isDrawerOpen];
        
        if (!self.isSearchOn) {
            self.eventsSummaryStringBrowse = [self eventsSummaryStringForSource:EVENTS_SOURCE_BROWSE];
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringBrowse searchString:nil animated:YES];
        } else {
            self.eventsSummaryStringSearch = [self eventsSummaryStringForSource:EVENTS_SOURCE_SEARCH];
            [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:CloseDrawerToLoadPrompt eventsSummaryString:self.eventsSummaryStringSearch searchString:self.searchTextField.text animated:YES];
        }
        /* WARNING: THE CODE ABOVE HAS BEEN COPIED TO THE METHOD ...textFieldShouldReturn... */

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
    SEL selectedOptionGetter, selectedOptionSetter;
    if (self.isSearchOn) { } else {
        selectedOptionGetter = @selector(selectedCategoryFilterOption);
        selectedOptionSetter = @selector(setSelectedCategoryFilterOption:);
    }
    [self filterOptionButtonTouched:sender 
                      forFilterCode:EVENTS_FILTER_CATEGORIES 
               selectedOptionGetter:selectedOptionGetter
               selectedOptionSetter:selectedOptionSetter];
}

- (NSString *) eventsSummaryStringForSource:(NSString *)sourceString {
    
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
        locationItself   = self.dvLocationTextField.text;
    } else if ([sourceString isEqualToString:EVENTS_SOURCE_SEARCH]) {
        dateReadable     = self.selectedDateSearchFilterOption.readable;
        locationReadable = self.selectedLocationSearchFilterOption.readable;
        locationItself   = self.dvLocationSearchTextField.text;
        timeReadable     = self.selectedTimeSearchFilterOption.readable;
    } else {
        NSLog(@"ERROR in EventsViewController filtersSummaryStringForSource:andUpdateSummaryLabel: - unrecognized source string.");
    }
    
    NSMutableString * summaryString = [NSMutableString string];
//    NSString * DUMMY_START_STRING = @"---DUMMY_START_STRING---";
//    [summaryString appendString:DUMMY_START_STRING];
    NSString * eventsWord = @"events";
    if (categoryReadable) {
        eventsWord = [NSString stringWithFormat:@"%@ %@", categoryReadable, eventsWord];
    }
    if (priceReadable) {
        if ([priceReadable isEqualToString:@"Free"]) {
            [summaryString appendFormat:@"%@ %@ ", [priceReadable lowercaseString], [eventsWord lowercaseString]];
        } else {
            [summaryString appendFormat:@"%@ that cost %@ ", [eventsWord lowercaseString], [priceReadable lowercaseString]];
        }
    } else {
        [summaryString appendFormat:@"%@ ", [eventsWord lowercaseString]];
    }
    if (timeReadable || dateReadable) {
        [summaryString appendString:@"happening "];
    }
    if (dateReadable) {
        [summaryString appendFormat:@"%@ ", [dateReadable lowercaseString]];
    }
    if (timeReadable) {
        [summaryString appendFormat:@"%@ ", [timeReadable lowercaseString]];
    }
    if (locationReadable) {
        [summaryString appendFormat:@"%@ %@ ", [locationReadable lowercaseString], locationItself];
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

- (void) setFeedbackViewIsVisible:(BOOL)makeVisible adjustMessages:(BOOL)shouldAdjustMessages withMessageType:(EventsFeedbackMessageType)messageType eventsSummaryString:(NSString *)eventsSummaryString searchString:(NSString *)searchString animated:(BOOL)animated {
    NSLog(@"EventsViewController setFeedbackViewIsVisible:(BOOL)%d adjustMessages:(BOOL)%d withMessageType:(EventsFeedbackMessageType)%d eventsSummaryString:(NSString *)%@ animated:(BOOL)%d", makeVisible, shouldAdjustMessages, messageType, eventsSummaryString, animated);

    void(^setMessagesTextBlock)(void) = ^{
        [self.feedbackView setMessagesToShowMessageType:messageType withEventsString:eventsSummaryString searchString:searchString];
    };
    void(^tableViewBlock)(void) = ^{
//        CGPoint tableViewContentOffset = self.tableView.contentOffset;
//        NSLog(@"tableViewContentOffset was %@", NSStringFromCGPoint(tableViewContentOffset));
//        UIEdgeInsets tableViewInset = self.tableView.contentInset;
//        tableViewInset.bottom = self.feedbackViewIsVisible ? self.feedbackView.bounds.size.height : 0.0;
//        self.tableView.contentInset = tableViewInset;
//        NSLog(@"self.tableView.contentOffset is %@", NSStringFromCGPoint(self.tableView.contentOffset));
//        if (!(self.eventsWebQueryForCurrentSource.eventResults.count > 0) && self.isDrawerOpen) {
//            self.tableView.contentOffset = tableViewContentOffset; // Fixing a very slight bug, which would result in the search bar being scrolled into view when there were no results in the table.
//            NSLog(@"self.tableView.contentOffset is %@ (special case adjustment)", NSStringFromCGPoint(self.tableView.contentOffset));
//        }
    };
    void(^frameAdjustmentBlock)(BOOL) = ^(BOOL maintainBottomY){
        CGSize feedbackViewAdjustedSize = [self.feedbackView sizeForMessagesWithMessageType:messageType withEventsString:eventsSummaryString searchString:searchString];
        CGRect feedbackViewFrame = self.feedbackView.frame;
        if (maintainBottomY) {
            feedbackViewFrame.origin.y -= (feedbackViewAdjustedSize.height - feedbackViewFrame.size.height);
        }
        feedbackViewFrame.size = feedbackViewAdjustedSize;
        self.feedbackView.frame = feedbackViewFrame;
        tableViewBlock();
    };
    void(^feedbackViewVisibilityBlock)(void) = ^{
        CGFloat feedbackViewOriginY = self.view.frame.size.height;
        if (makeVisible) {
            feedbackViewOriginY -= self.feedbackView.frame.size.height;
        }
        CGRect feedbackViewFrame = self.feedbackView.frame;
        feedbackViewFrame.origin.y = feedbackViewOriginY;
        self.feedbackView.frame = feedbackViewFrame;
        feedbackViewIsVisible = makeVisible;
        tableViewBlock();
    };
    
    if (animated) {
        CGFloat durationTotal = 0.25;
        if (!makeVisible) {
            [UIView animateWithDuration:durationTotal animations:feedbackViewVisibilityBlock completion:^(BOOL finished) {
                if (shouldAdjustMessages) {
                    setMessagesTextBlock();
                    frameAdjustmentBlock(NO);
                }
            }];
        } else {
            if (shouldAdjustMessages) {
                BOOL currentMessageComplex = self.feedbackView.isCurrentMessageComplex;
                BOOL forthcomingMessageComplex = [EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType];
                if (self.feedbackViewIsVisible &&
                    currentMessageComplex != forthcomingMessageComplex) {
                    [UIView animateWithDuration:durationTotal/2.0 
                                     animations:^{
                                         self.feedbackView.messagesContainer.alpha = 0.0;
                                     }
                                     completion:^(BOOL finished){
                                         setMessagesTextBlock();
                                         [UIView animateWithDuration:durationTotal/2.0 animations:^{
                                             self.feedbackView.messagesContainer.alpha = 1.0;
                                         }];
                                     }];
                } else {
                    setMessagesTextBlock();
                }
            }
            [UIView animateWithDuration:durationTotal animations:^{
                if (shouldAdjustMessages) {
                    frameAdjustmentBlock(self.feedbackViewIsVisible);
                }
                feedbackViewVisibilityBlock();
            }];
        }
    } else {
        if (shouldAdjustMessages) {
            setMessagesTextBlock();
            frameAdjustmentBlock(YES);
        }
        feedbackViewVisibilityBlock();
    }
    
    NSLog(@"feedbackView.frame = %@ (so that bottom edge of feedbackView is %f points away from the bottom edge of the main view itself)", NSStringFromCGRect(self.feedbackView.frame), self.view.bounds.size.height - CGRectGetMaxY(self.feedbackView.frame));
    
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
//    if (!(self.eventsWebQueryForCurrentSource.eventResults.count > 0)) {
//        self.tableView.contentOffset = tableViewContentOffset; // Fixing a very slight bug, which would result in the search bar being scrolled into view when there were no results in the table.
//    }
//
//}

- (void) updateFilter:(EventsFilter *)filter buttonImageForFilterOption:(EventsFilterOption *)filterOption {
    NSString * bwIconFilename = [EventsFilterOption eventsFilterOptionIconFilenameForCode:filterOption.code grayscale:YES larger:NO];
    UIImage * bwIconImage = [UIImage imageNamed:bwIconFilename];
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

- (void)locationFilterCurrentLocationButtonTouched {
    if (self.isSearchOn) {
        [self.dvLocationSearchTextField resignFirstResponder];        
        self.dvLocationSearchTextField.text = @"";
        self.dvLocationSearchTextField.placeholder = @"Current Location";        
    } else {
        [self.dvLocationTextField resignFirstResponder];        
        self.dvLocationTextField.text = @"";
        self.dvLocationTextField.placeholder = @"Current Location";
    }
}

- (void)searchCancelButtonTouched:(id)sender {
    if ([self.searchTextField isFirstResponder]) {
        if (self.eventsWebQueryFromSearch.eventResults.count > 0) {
            [self.searchTextField resignFirstResponder];
        } else {
            [self toggleSearchMode];
        }
    } else {
        [self toggleSearchMode];
    }
}

- (void)searchGoButtonTouched:(id)sender {
    [self searchExecutionRequestedByUser];
}

- (void) feedbackViewRetryButtonTouched:(UIButton *)button {
    NSLog(@"EventsViewController feedbackViewRetryButtonTouched");
    if (button == self.feedbackView.button) {
//        [self setFeedbackViewIsVisible:self.feedbackViewIsVisible adjustMessages:YES withMessageType:LoadingEvents eventsSummaryString:self.eventsSummaryStringForCurrentSource animated:YES];
        [self showWebLoadingViews];
        if (!self.isSearchOn) {
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        } else {
            [self searchExecutionRequestedByUser];
        }
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized button sending message feedbackViewRetryButtonTouched");
    }
}

@end
