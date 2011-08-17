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

static NSString * const EVENTS_OLDFILTER_RECOMMENDED = @"recommended";
static NSString * const EVENTS_CATEGORY_BUTTON_TOUCH_POSTFIX = @"_touch";

static NSString * const EVENTS_UPDATED_NOTIFICATION_KEY = @"eventsUpdated";
static NSString * const EVENTS_UPDATED_USER_INFO_KEY_RESULTS = @"results";
static NSString * const EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL = @"resultsDetail";
static NSString * const EVENTS_UPDATED_USER_INFO_KEY_SOURCE = @"source";
static NSString * const EVENTS_UPDATED_USER_INFO_RESULTS_POPULATED = @"populated";
static NSString * const EVENTS_UPDATED_USER_INFO_RESULTS_EMPTY = @"empty";
static NSString * const EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_NO_RESULTS = @"noResults";
static NSString * const EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_CONNECTION_ERROR = @"connectionError";
static NSString * const EVENTS_UPDATED_USER_INFO_SOURCE_GENERAL = @"general";
static NSString * const EVENTS_UPDATED_USER_INFO_SOURCE_FROM_SEARCH = @"fromSearch";

float const EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT = 247.0/255.0;

@interface EventsViewController()

//////////////////////
// Models properties

@property (nonatomic, retain) NSMutableArray * events;
@property (nonatomic, retain) NSMutableArray * eventsFromSearch;
@property (nonatomic, readonly) NSMutableArray * eventsForCurrentSource;
@property (nonatomic, readonly) NSArray * concreteParentCategoriesArray;
@property (nonatomic, readonly) NSDictionary * concreteParentCategoriesDictionary;

/////////////////////////////
// "View models" properties

@property (nonatomic, readonly) NSArray * filtersForCurrentSource;
@property (retain) NSMutableArray * filters;
@property (retain) EventsFilter * activeFilterInUI;
@property (retain) EventsFilterOption * selectedPriceFilterOption;
@property (retain) EventsFilterOption * selectedDateFilterOption;
@property (retain) EventsFilterOption * selectedTimeFilterOption;
@property (retain) EventsFilterOption * selectedLocationFilterOption;
@property (retain) NSMutableArray * filtersSearch;
@property (retain) EventsFilter * activeSearchFilterInUI;
@property (retain) EventsFilterOption * selectedDateSearchFilterOption;
@property (retain) EventsFilterOption * selectedTimeSearchFilterOption;
@property (retain) EventsFilterOption * selectedLocationSearchFilterOption;
@property BOOL isDrawerOpen;
@property BOOL isSearchOn;
@property BOOL problemViewWasShowing;
@property (readonly) BOOL problemViewIsShowing;
@property (copy) NSString * oldFilterString;
@property (copy) NSString * categoryURI;
@property (retain) NSIndexPath * indexPathOfRowAttemptingToDelete;
@property (retain) NSIndexPath * indexPathOfSelectedRow;

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
@property (retain) IBOutlet UIView   * filtersSummaryContainerView;
@property (retain) IBOutlet UILabel  * filtersSummaryLabel;
@property (retain) IBOutlet NSString * filtersSummaryStringBrowse;
@property (retain) IBOutlet NSString * filtersSummaryStringSearch;
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
@property (retain) UIView * problemView;
@property (retain) UILabel * problemLabel;
@property (nonatomic, retain) EventViewController * cardPageViewController;
@property (nonatomic, readonly) UIAlertView * connectionErrorStandardAlertView;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnDeleteAlertView;

///////////////////
// Web properties

@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;

/////////////////////
// Assorted methods

- (IBAction) filterButtonPressed:(id)sender;
- (IBAction) priceFilterOptionButtonTouched:(id)sender;
- (IBAction) dateFilterOptionButtonTouched:(id)sender;
- (IBAction) timeFilterOptionButtonTouched:(id)sender;
- (IBAction) locationFilterOptionButtonTouched:(id)sender;
- (void) filterOptionButtonTouched:(UIButton *)filterOptionButton forFilterCode:(NSString *)filterCode selectedOptionGetter:(SEL)selectedFilterOptionGetter selectedOptionSetter:(SEL)selectedFilterOptionSetter;
- (IBAction) locationFilterCurrentLocationButtonTouched;
- (IBAction) searchButtonTouched:(id)sender;
- (IBAction) searchCancelButtonTouched:(id)sender;
- (IBAction) searchGoButtonTouched:(id)sender;

- (IBAction) reloadEventsListButtonTouched:(id)sender;

- (void) behaviorWasReset:(NSNotification *)notification;
- (void) categoryButtonPressed:(UIButton *)categoryButton;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) dataSourceEventsUpdated:(NSNotification *)notification;
- (EventsFilter *) filterForDrawerScrollViewContentOffset:(CGPoint)contentOffset;
- (EventsFilter *) filterForFilterButton:(UIButton *)filterButton;
- (EventsFilter *) filterForFilterCode:(NSString *)filterCode inFiltersArray:(NSArray *)arrayOfEventsFilters;
- (EventsFilter *) filterForPositionX:(CGFloat)x withinViewWidth:(CGFloat)viewWidth fromFiltersArray:(NSArray *)arrayOfEventsFilters;
- (EventsFilterOption *) filterOptionForFilterOptionButton:(UIButton *)filterOptionButton inFilterOptionsArray:(NSArray *)filterOptions;
- (void) hideProblemViewAnimated:(BOOL)animated;
- (void) hideWebLoadingViews;
- (void) homeButtonPressed;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) loginActivity:(NSNotification *)notification;
- (void) setDrawerToShowFilter:(EventsFilter *)filter animated:(BOOL)animated;
- (void) setImagesForCategoryButton:(UIButton *)button forCategory:(Category *)category;
- (void) setLogoButtonImageForCategoryURI:(NSString *)theCategoryURI;
- (void) setLogoButtonImageWithImageNamed:(NSString *)imageName;
- (void) setProblemViewVisible:(BOOL)showView withMessage:(NSString *)message animated:(BOOL)animated;
- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable;
- (void) setUpFiltersUI:(NSArray *)arrayOfEventsFilters withOptionButtonSelectors:(NSDictionary *)dictionaryOfEventFilterOptionSelectors compressedOptionButtons:(BOOL)compressed;
- (void) showProblemViewAnimated:(BOOL)animated;
- (void) showProblemViewBadConnectionAnimated:(BOOL)animated;
- (void) showProblemViewNoEventsForOldFilter:(NSString *)forOldFilterString categoryTitle:(NSString *)categoryTitle animated:(BOOL)animated;
- (void) showWebLoadingViews;
- (void) swipeAcrossFiltersStrip:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipeDownToShowDrawer:(UISwipeGestureRecognizer *)swipeGesture;
- (void) swipeUpToHideDrawer:(UISwipeGestureRecognizer *)swipeGesture;
- (void) toggleDrawerAnimated;
- (void) toggleSearchMode;
- (void) updateActiveFilterHighlights;
- (void) updateFilter:(EventsFilter *)filter buttonImageForFilterOption:(EventsFilterOption *)filterOption;
- (void) updateFilterOptionButtonStatesOldSelected:(EventsFilterOption *)oldSelectedOption newSelected:(EventsFilterOption *)newSelectedOption;
- (void) updateFiltersSummaryLabelWithCurrentSelectedFilterOptions;
- (void) webConnectGetEventsListWithCurrentOldFilterAndCategory;
- (void) webConnectGetEventsListWithOldFilter:(NSString *)theProposedOldFilterString categoryURI:(NSString *)theProposedCategoryURI;

@end

@implementation EventsViewController
@synthesize filters;
@synthesize activeFilterInUI;
@synthesize selectedPriceFilterOption, selectedDateFilterOption, selectedTimeFilterOption, selectedLocationFilterOption;
@synthesize filtersSearch;
@synthesize activeSearchFilterInUI;
@synthesize selectedDateSearchFilterOption, selectedTimeSearchFilterOption, selectedLocationSearchFilterOption;
@synthesize filtersContainerView, filtersContainerShadowCheatView, filtersContainerShadowCheatWayBelowView;
@synthesize filtersBarBrowse, filtersBarSearch;
@synthesize filterButtonCategories, filterButtonPrice, filterButtonDate, filterButtonLocation, filterButtonTime;
@synthesize filterSearchButtonDate, filterSearchButtonLocation, filterSearchButtonTime;
@synthesize pushableContainerView, pushableContainerShadowCheatView, filtersSummaryContainerView, filtersSummaryLabel, filtersSummaryStringBrowse, filtersSummaryStringSearch;
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

@synthesize eventsFromSearch, events,coreDataModel,webActivityView,concreteParentCategoriesDictionary;
//@synthesize refreshHeaderView;
@synthesize concreteParentCategoriesArray;
@synthesize oldFilterString, categoryURI;
@synthesize isSearchOn;
@synthesize problemView, problemLabel;
@synthesize cardPageViewController;
@synthesize indexPathOfRowAttemptingToDelete, indexPathOfSelectedRow;
@synthesize isDrawerOpen;
@synthesize problemViewWasShowing;

- (void)dealloc {
    [filters release];
    [activeFilterInUI release];
    [activeFilterHighlightsContainerView release];
    [selectedDateFilterOption release];
    [selectedLocationFilterOption release];
    [selectedPriceFilterOption release];
    [selectedTimeFilterOption release];
    [filtersSearch release];
    [activeSearchFilterInUI release];
    [selectedDateSearchFilterOption release];
    [selectedTimeSearchFilterOption release];
    [selectedLocationSearchFilterOption release];
    [filtersContainerView release];
    [filtersContainerShadowCheatView release];
    [filtersContainerShadowCheatWayBelowView release];
    [filterButtonCategories release];
    [filterButtonPrice release];
    [filterButtonDate release];
    [filterButtonLocation release];
    [filterButtonTime release];
    [filterSearchButtonDate release];
    [filterSearchButtonLocation release];
    [filterSearchButtonTime release];
    [pushableContainerView release];
    [pushableContainerShadowCheatView release];
    [filtersSummaryContainerView release];
    [filtersSummaryLabel release];
    [filtersSummaryStringBrowse release];
    [filtersSummaryStringSearch release];
    [searchButton release];
    [searchCancelButton release];
    [searchGoButton release];
    [searchTextField release];
    [drawerScrollView release];
    [drawerViewsBrowseContainer release];
    [drawerViewsSearchContainer release];
    // Drawer view price
    [drawerViewPrice release];
    [dvPriceButtonFree release];
    [dvPriceButtonUnder20 release];
    [dvPriceButtonUnder50 release];
    [dvPriceButtonAny release];
    // Drawer view date
    [drawerViewDate release];
    [dvDateButtonToday release];
    [dvDateButtonThisWeekend release];
    [dvDateButtonThisWeek release];
    [dvDateButtonThisMonth release];
    [dvDateButtonAny release];
    // Drawer view date search
    [drawerViewDateSearch release];
    [dvDateSearchButtonToday release];
    [dvDateSearchButtonThisWeekend release];
    [dvDateSearchButtonThisWeek release];
    [dvDateSearchButtonThisMonth release];
    [dvDateSearchButtonAny release];
    // Drawer view categories
    [drawerViewCategories release];
    // Drawer view time
    [drawerViewTime release];
    [dvTimeButtonMorning release];
    [dvTimeButtonAfternoon release];
    [dvTimeButtonEvening release];
    [dvTimeButtonNight release];
    [dvTimeButtonAny release];
    // Drawer view time search
    [drawerViewTimeSearch release];
    [dvTimeSearchButtonMorning release];
    [dvTimeSearchButtonAfternoon release];
    [dvTimeSearchButtonEvening release];
    [dvTimeSearchButtonNight release];
    [dvTimeSearchButtonAny release];
    // Drawer view location
    [drawerViewLocation release];
    [dvLocationTextField release];
    [dvLocationCurrentLocationButton release];
    [dvLocationButtonWalking release];
    [dvLocationButtonNeighborhood release];
    [dvLocationButtonBorough release];
    [dvLocationButtonCity release];
    // Drawer view location search
    [drawerViewLocationSearch release];
    [dvLocationSearchTextField release];
    [dvLocationSearchCurrentLocationButton release];
    [dvLocationSearchButtonWalking release];
    [dvLocationSearchButtonNeighborhood release];
    [dvLocationSearchButtonBorough release];
    [dvLocationSearchButtonCity release];
    // Views
    [tableView_ release];
    [tableViewCoverView release];
    [searchContainerView release];
    [tableReloadContainerView release];

    [concreteParentCategoriesDictionary release];
    [concreteParentCategoriesArray release];
	[eventsFromSearch release];
	[events release];
    [coreDataModel release];
//	[refreshHeaderView release];
	[webActivityView release];
    [oldFilterString release];
    [categoryURI release];
    [problemView release];
    [problemLabel release];
    [cardPageViewController release];
    [webConnector release];
    [webDataTranslator release];
    [connectionErrorStandardAlertView release];
    [connectionErrorOnDeleteAlertView release];
    [indexPathOfRowAttemptingToDelete release];
    [indexPathOfSelectedRow release];
    [dvLocationButtonCity release];
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
    
    // Create categories background view under UITableView
//    self.categoriesBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 255)] autorelease];
    self.drawerScrollView.showsHorizontalScrollIndicator = NO;
    self.drawerScrollView.contentSize = self.drawerViewsBrowseContainer.bounds.size;
    self.drawerScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerScrollView.userInteractionEnabled = NO;
    self.drawerScrollView.layer.masksToBounds = YES;
    self.drawerScrollView.delegate = self;
    self.drawerViewsBrowseContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerViewsSearchContainer.backgroundColor = self.drawerViewsBrowseContainer.backgroundColor;
    
    // Shadows
    self.filtersContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filtersContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.filtersContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.filtersContainerShadowCheatView.bounds].CGPath;
    // More shadows
    self.filtersContainerShadowCheatWayBelowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOpacity = 0.5;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.filtersContainerShadowCheatWayBelowView.bounds].CGPath;
    self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
    // More shadows
    self.pushableContainerShadowCheatView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pushableContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.pushableContainerShadowCheatView.layer.shadowOpacity = 0.5;
    self.pushableContainerShadowCheatView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.pushableContainerShadowCheatView.bounds].CGPath;
    self.pushableContainerShadowCheatView.layer.shouldRasterize = YES;
    // More shadows
    self.filtersSummaryContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filtersSummaryContainerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersSummaryContainerView.layer.shadowOpacity = 0.5;
    self.filtersSummaryContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 10, self.filtersSummaryContainerView.bounds.size.width, self.filtersSummaryContainerView.bounds.size.height - 10)].CGPath;

    // Category buttons
    CGSize categoryButtonImageSize = CGSizeMake(51, 51);
    CGSize categoryButtonContainerSize = CGSizeMake(99, 81);
    CGFloat categoryButtonsContainerLeftEdge = 11;
    CGFloat categoryButtonsContainerTopEdge = 0;
    CGFloat categoryTitleLabelTopSpacing = 3;
    int index = 0;
    UIView * categoryButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(categoryButtonsContainerLeftEdge, categoryButtonsContainerTopEdge, categoryButtonContainerSize.width * 3, categoryButtonContainerSize.height * 3)];
    [self.drawerViewCategories addSubview:categoryButtonsContainer];
    for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
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
                category = (Category *)[self.concreteParentCategoriesArray objectAtIndex:index-1];
                categoryTitleLabel.text = category.title;
                categoryButton.button.tag = index-1;
            }
            [self setImagesForCategoryButton:categoryButton.button forCategory:category];
            [categoryButton.button addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [categoryButtonContainer addSubview:categoryButton];
            [categoryButtonContainer addSubview:categoryTitleLabel];
            [categoryButtonsContainer addSubview:categoryButtonContainer];
            // Increment
            index++;
        }
    }
        
	// Set up the tableView
    self.tableView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    
    // Set up the tableViewCoverView
    tableViewCoverView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableViewCoverView.backgroundColor = [UIColor whiteColor];
    self.tableViewCoverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableViewCoverView.alpha = 0.0;
    [self.pushableContainerView insertSubview:self.tableViewCoverView aboveSubview:self.tableView];
        
    // Table header & footer
    self.tableView.tableHeaderView = self.searchContainerView;
    self.tableView.tableFooterView = self.tableReloadContainerView;
    self.tableView.tableFooterView.alpha = 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = NO;
    
    UISwipeGestureRecognizer * swipeDownFiltersGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToShowDrawer:)];
    swipeDownFiltersGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.filtersContainerView addGestureRecognizer:swipeDownFiltersGR];
    [swipeDownFiltersGR release];
//    UISwipeGestureRecognizer * swipeDownFiltersGRSupplemental = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToShowDrawer:)];
//    swipeDownFiltersGRSupplemental.direction = UISwipeGestureRecognizerDirectionDown;
//    [self.filtersSummaryContainerView addGestureRecognizer:swipeDownFiltersGRSupplemental];
//    [swipeDownFiltersGRSupplemental release];
    
    UISwipeGestureRecognizer * swipeUpToHideDrawerGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpToHideDrawer:)];
    swipeUpToHideDrawerGR.direction = UISwipeGestureRecognizerDirectionUp;
    [self.pushableContainerView addGestureRecognizer:swipeUpToHideDrawerGR];
    [swipeUpToHideDrawerGR release];
    
    UISwipeGestureRecognizer * swipeUpToHideDrawerFromWithinDrawerGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpToHideDrawer:)];
    swipeUpToHideDrawerFromWithinDrawerGR.direction = UISwipeGestureRecognizerDirectionUp;
    [self.drawerScrollView addGestureRecognizer:swipeUpToHideDrawerFromWithinDrawerGR];
    [swipeUpToHideDrawerFromWithinDrawerGR release];
    
    UISwipeGestureRecognizer * swipeAcrossFiltersStringGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAcrossFiltersStrip:)];
    swipeAcrossFiltersStringGR.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.filtersContainerView addGestureRecognizer:swipeAcrossFiltersStringGR];
    [swipeAcrossFiltersStringGR release];
    
    // Create the "no results" view
    CGSize problemViewSize = CGSizeMake(self.tableView.bounds.size.width - 40.0, 100.0);
    problemView = [[UIView alloc] initWithFrame:
                   CGRectMake(20.0, (self.tableView.bounds.size.height - problemViewSize.height) / 2.0, problemViewSize.width, problemViewSize.height)];
//    self.problemView = [[UIView alloc] initWithFrame:CGRectMake(/*self.myTableView.frame.origin.x + */20.0, /*self.myTableView.frame.origin.y + */70.0, self.tableView.frame.size.width - 40.0, 100.0)];
    self.problemView.backgroundColor = [UIColor clearColor];//[UIColor whiteColor];
//    self.noResultsView.layer.cornerRadius = 20.0;
//    self.noResultsView.layer.masksToBounds = YES;
//    self.noResultsView.layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
//    self.noResultsView.layer.borderWidth = 1.0;
    [self.tableView addSubview:self.problemView];
    [self.tableView bringSubviewToFront:self.problemView];
    self.problemLabel = [[[UILabel alloc] initWithFrame:self.problemView.bounds] autorelease];
    self.problemLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.problemLabel.numberOfLines = 0;
    self.problemLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:20];//[UIFont fontWithName:@"HelveticaNeue" size:18.0];
    self.problemLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.problemLabel.backgroundColor = [UIColor clearColor];
//    noResultsLabel.backgroundColor = [UIColor yellowColor];
    [self.problemView addSubview:self.problemLabel];    
    [self setProblemViewVisible:NO withMessage:@"Loading..." animated:NO];
    
    CGFloat webActivityViewSize = 60.0;
    self.webActivityView = [[[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.frame] autorelease];
    [self.view addSubview:self.webActivityView];
    
    NSArray * priceOptions = [NSArray arrayWithObjects:
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: @"free" 
                               readableString: @"Free" 
                               buttonText: @"Free"
                               buttonView: self.dvPriceButtonFree],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: @"under20" 
                               readableString: @"Under $20" 
                               buttonText: @"Under $20"
                               buttonView: self.dvPriceButtonUnder20],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: @"under50" 
                               readableString: @"Under $50" 
                               buttonText: @"Under $50"
                               buttonView: self.dvPriceButtonUnder50],
                              [EventsFilterOption 
                               eventsFilterOptionWithCode: @"anyprice" 
                               readableString: nil 
                               buttonText: @"All Prices"
                               buttonView: self.dvPriceButtonAny],
                              nil];
    NSArray * dateOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"today"
                              readableString: @"Today" 
                              buttonText: @"Today"
                              buttonView: self.dvDateButtonToday],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"weekend" 
                              readableString: @"This Weekend" 
                              buttonText: @"This Weekend"
                              buttonView: self.dvDateButtonThisWeekend],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"next7days" 
                              readableString: @"In the next 7 Days" 
                              buttonText: @"Next 7 Days"
                              buttonView: self.dvDateButtonThisWeek],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"next30days" 
                              readableString: @"In the next 30 Days" 
                              buttonText: @"Next 30 Days"
                              buttonView: self.dvDateButtonThisMonth],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"anydate" 
                              readableString: nil 
                              buttonText: @"All Dates" 
                              buttonView: self.dvDateButtonAny],
                             nil];
    NSArray * dateSearchOptions = [NSArray arrayWithObjects:
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"today"
                                    readableString: @"Today" 
                                    buttonText: @"Today"
                                    buttonView: self.dvDateSearchButtonToday],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"weekend" 
                                    readableString: @"This Weekend" 
                                    buttonText: @"Weekend"
                                    buttonView: self.dvDateSearchButtonThisWeekend],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"next7days" 
                                    readableString: @"In the next 7 Days" 
                                    buttonText: @"7 Days"
                                    buttonView: self.dvDateSearchButtonThisWeek],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"next30days" 
                                    readableString: @"In the next 30 Days" 
                                    buttonText: @"30 Days"
                                    buttonView: self.dvDateSearchButtonThisMonth],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"anydate" 
                                    readableString: nil 
                                    buttonText: @"All Dates" 
                                    buttonView: self.dvDateSearchButtonAny],
                                   nil];
    NSArray * timeOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"morning" 
                              readableString: @"In the Morning" 
                              buttonText: @"Morning" 
                              buttonView: self.dvTimeButtonMorning],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"afternoon" 
                              readableString: @"In the Afternoon" 
                              buttonText: @"Afternoon" 
                              buttonView: self.dvTimeButtonAfternoon],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"evening" 
                              readableString: @"In the Evening" 
                              buttonText: @"Evening" 
                              buttonView: self.dvTimeButtonEvening],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"night" 
                              readableString: @"At Night" 
                              buttonText: @"Late Night" 
                              buttonView: self.dvTimeButtonNight],
                             [EventsFilterOption 
                              eventsFilterOptionWithCode: @"anytime" 
                              readableString: nil 
                              buttonText: @"Any Time of Day" 
                              buttonView: self.dvTimeButtonAny],
                             nil];
    NSArray * timeSearchOptions = [NSArray arrayWithObjects:
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"morning" 
                                    readableString: @"In the Morning" 
                                    buttonText: @"Morning" 
                                    buttonView: self.dvTimeSearchButtonMorning],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"afternoon" 
                                    readableString: @"In the Afternoon" 
                                    buttonText: @"Afternoon" 
                                    buttonView: self.dvTimeSearchButtonAfternoon],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"evening" 
                                    readableString: @"In the Evening" 
                                    buttonText: @"Evening" 
                                    buttonView: self.dvTimeSearchButtonEvening],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"night" 
                                    readableString: @"At Night" 
                                    buttonText: @"Late Night" 
                                    buttonView: self.dvTimeSearchButtonNight],
                                   [EventsFilterOption 
                                    eventsFilterOptionWithCode: @"anytime" 
                                    readableString: nil 
                                    buttonText: @"Any Time of Day" 
                                    buttonView: self.dvTimeSearchButtonAny],
                                   nil];
    NSArray * locationOptions = [NSArray arrayWithObjects:
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: @"walking" 
                                  readableString: @"Within Walking Distance of" 
                                  buttonText: @"Within Walking Distance"
                                  buttonView: self.dvLocationButtonWalking],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: @"neighborhood" 
                                  readableString: @"In the Same Neighborhood as" 
                                  buttonText: @"In the Neighborhood"
                                  buttonView: self.dvLocationButtonNeighborhood],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: @"borough" 
                                  readableString: @"In the Same Borough as" 
                                  buttonText: @"In the Borough"
                                  buttonView: self.dvLocationButtonBorough],
                                 [EventsFilterOption 
                                  eventsFilterOptionWithCode: @"city" 
                                  readableString: nil
                                  buttonText: @"In the City"
                                  buttonView: self.dvLocationButtonCity],
                                 nil];
    NSArray * locationSearchOptions = [NSArray arrayWithObjects:
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: @"walking" 
                                        readableString: @"Within Walking Distance of" 
                                        buttonText: @"Walking"
                                        buttonView: self.dvLocationSearchButtonWalking],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: @"neighborhood" 
                                        readableString: @"In the Same Neighborhood as" 
                                        buttonText: @"Neighborhood"
                                        buttonView: self.dvLocationSearchButtonNeighborhood],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: @"borough" 
                                        readableString: @"In the Same Borough as" 
                                        buttonText: @"Borough"
                                        buttonView: self.dvLocationSearchButtonBorough],
                                       [EventsFilterOption 
                                        eventsFilterOptionWithCode: @"city" 
                                        readableString: nil
                                        buttonText: @"City"
                                        buttonView: self.dvLocationSearchButtonCity],
                                       nil];
    
    // New filter "view models"
    self.filters = [NSMutableArray arrayWithObjects:
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_PRICE 
                     buttonText:@"Price"
                     button:self.filterButtonPrice 
                     drawerView:self.drawerViewPrice 
                     options:priceOptions],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_DATE 
                     buttonText:@"Date"
                     button:self.filterButtonDate 
                     drawerView:self.drawerViewDate 
                     options:dateOptions],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_CATEGORIES 
                     buttonText:nil
                     button:self.filterButtonCategories 
                     drawerView:self.drawerViewCategories 
                     options:nil],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_TIME 
                     buttonText:@"Time"
                     button:self.filterButtonTime 
                     drawerView:self.drawerViewTime 
                     options:timeOptions],
                    [EventsFilter 
                     eventsFilterWithCode:EVENTS_FILTER_LOCATION 
                     buttonText:@"Location"
                     button:self.filterButtonLocation 
                     drawerView:self.drawerViewLocation 
                     options:locationOptions],
                    nil];
    // Search filter view models
    self.filtersSearch = [NSMutableArray arrayWithObjects:
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_DATE 
                           buttonText:@"Date"
                           button:self.filterSearchButtonDate 
                           drawerView:self.drawerViewDateSearch 
                           options:dateSearchOptions],
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_LOCATION 
                           buttonText:@"Location"
                           button:self.filterSearchButtonLocation 
                           drawerView:self.drawerViewLocationSearch 
                           options:locationSearchOptions],
                          [EventsFilter 
                           eventsFilterWithCode:EVENTS_FILTER_TIME 
                           buttonText:@"Time"
                           button:self.filterSearchButtonTime 
                           drawerView:self.drawerViewTimeSearch 
                           options:timeSearchOptions],
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
                                                  nil];
    
    [self setUpFiltersUI:self.filters withOptionButtonSelectors:filterOptionButtonSelectors compressedOptionButtons:NO];
    [self setUpFiltersUI:self.filtersSearch withOptionButtonSelectors:filterOptionButtonSelectors compressedOptionButtons:YES];
     
    self.dvLocationCurrentLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dvLocationCurrentLocationButton.frame = CGRectMake(0, 0, 23, 15);
    self.dvLocationCurrentLocationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.dvLocationCurrentLocationButton setImage:[UIImage imageNamed:@"ico_locationsearch.png"] forState:UIControlStateNormal];
    [self.dvLocationCurrentLocationButton addTarget:self action:@selector(locationFilterCurrentLocationButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.dvLocationTextField.leftView = self.dvLocationCurrentLocationButton;
    self.dvLocationTextField.leftViewMode = UITextFieldViewModeAlways;
    self.dvLocationSearchTextField.leftView = self.dvLocationCurrentLocationButton;
    self.dvLocationSearchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.activeFilterHighlightsContainerView.highlightColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_select_glow.png"]];
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filters.count; // This needs to get changed when we switch back and forth between browse & search.
    // Default browse filter settings
    self.activeFilterInUI = [self.filters objectAtIndex:0];
    [self setDrawerToShowFilter:self.activeFilterInUI animated:NO];
    [self updateActiveFilterHighlights];
    self.selectedPriceFilterOption = priceOptions.lastObject;
    self.selectedDateFilterOption = dateOptions.lastObject;
    self.selectedTimeFilterOption = timeOptions.lastObject;
    self.selectedLocationFilterOption = locationOptions.lastObject;
    // Default search filter settings
    self.activeSearchFilterInUI = [self.filters objectAtIndex:0];
    self.selectedDateSearchFilterOption = dateSearchOptions.lastObject;
    self.selectedLocationSearchFilterOption = locationSearchOptions.lastObject;
    self.selectedTimeSearchFilterOption = timeSearchOptions.lastObject;
    
    // Update filter option button states
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedPriceFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedDateSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedLocationSearchFilterOption];
    [self updateFilterOptionButtonStatesOldSelected:nil newSelected:self.selectedTimeSearchFilterOption];
    self.oldFilterString = EVENTS_OLDFILTER_RECOMMENDED;
    self.categoryURI = nil;
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
    
    // Start things off with browse filters (as opposed to search ones)
    [self.filtersContainerView addSubview:self.filtersBarBrowse];
    [self.drawerScrollView addSubview:self.drawerViewsBrowseContainer];
    
    // Register for data updated events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSourceEventsUpdated:)
                                                 name:EVENTS_UPDATED_NOTIFICATION_KEY
                                               object:nil];
    
    // Register for keyboard events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Register for login activity events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginActivity:) name:@"loginActivity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(behaviorWasReset:) name:@"learningBehaviorWasReset" object:nil];
    
    // Connect to web
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory]; // Don't need to reloadData until we get a response back from this web connection attempt.
    
}

- (void) setUpFiltersUI:(NSArray *)arrayOfEventsFilters withOptionButtonSelectors:(NSDictionary *)dictionaryOfEventFilterOptionSelectors compressedOptionButtons:(BOOL)compressed {
    
    for (EventsFilter * filter in arrayOfEventsFilters) {
        filter.drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
        [filter.button setTitle:[filter.buttonText uppercaseString] forState:UIControlStateNormal];
        filter.button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:12.0];
        filter.button.adjustsImageWhenHighlighted = NO;
        if (![filter.code isEqualToString:EVENTS_FILTER_CATEGORIES]) {
            filter.button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
            filter.button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 12, 0);
            filter.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 16, 0);
        }
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        
        SEL filterOptionButtonSelector = [[dictionaryOfEventFilterOptionSelectors objectForKey:filter.code] pointerValue];
        for (EventsFilterOption * filterOption in filter.options) {
            
            // Set button option target
            [filterOption.buttonView.button addTarget:self action:filterOptionButtonSelector forControlEvents:UIControlEventTouchUpInside];
            
            // Prep to set button option images
            BOOL squareButton = compressed && !([filterOption.code isEqualToString:@"anydate"] || [filterOption.code isEqualToString:@"anytime"]);
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
            }
            
            // Set other button attributes
            filterOption.buttonView.cornerRadius = 5.0;
            filterOption.buttonView.button.adjustsImageWhenHighlighted = NO;

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
        [self showWebLoadingViews];
    } else if ([self.eventsForCurrentSource count] == 0) {
        if (self.isSearchOn) {
            // Not going to do anything on this path for now... Just leave the list blank?
        } else {
            NSLog(@"No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events. No events for current source, going to web-get events.");
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        }
    } else {
        // Not worried about this path currently...
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    [self resignFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        if (!self.isSearchOn) {
            NSLog(@"Shake to reload");
            [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        }
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (NSArray *) filtersForCurrentSource {
    return self.isSearchOn ? self.filtersSearch : self.filters;
}

- (NSMutableArray *)eventsForCurrentSource {
    NSMutableArray * eventsArray = self.isSearchOn ? self.eventsFromSearch : self.events;
    return eventsArray;
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
    self.oldFilterString = theProposedOldFilterString;
    self.categoryURI = theProposedCategoryURI;
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
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
    
    // First, delete all previous events in Core Data
    [self.coreDataModel deleteRegularEvents];
    
    BOOL haveResults = eventsDictionaries && [eventsDictionaries count] > 0;
    
    if (haveResults) {
        
        // Loop through and process all event dictionaries
        for (NSDictionary * eventSummaryDictionary in eventsDictionaries) {
            
            Event * newEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            [self.coreDataModel updateEvent:newEvent usingEventSummaryDictionary:eventSummaryDictionary featuredOverride:nil fromSearchOverride:nil];
            
        }
        
        // Save the current timestamp as the last time we retrieved events (regardless of filter/category)
        NSDate * now = [NSDate date];
        [DefaultsModel saveLastEventsListGetDate:now];
//        [self.refreshHeaderView setLastRefreshDate:now];
        
    }

    // Save our core data changes
    [self.coreDataModel coreDataSave];
    
    // Send out a notification that the events in Core Data have been flushed, and there is (maybe) a new set of retrieved events available.
    NSMutableDictionary * eventsUpdatedInfo = [NSMutableDictionary dictionary];
    NSString * results;
    if (haveResults) {
        results = EVENTS_UPDATED_USER_INFO_RESULTS_POPULATED;
    } else {
        results = EVENTS_UPDATED_USER_INFO_RESULTS_EMPTY;
        [eventsUpdatedInfo setObject:EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_NO_RESULTS forKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL];
    }
    [eventsUpdatedInfo setObject:results forKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS];
    [eventsUpdatedInfo setObject:EVENTS_UPDATED_USER_INFO_SOURCE_GENERAL forKey:EVENTS_UPDATED_USER_INFO_KEY_SOURCE];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED_NOTIFICATION_KEY object:nil userInfo:eventsUpdatedInfo];

}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request withFilter:(NSString *)filterString categoryURI:(NSString *)categoryURI {
    
	NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    [self.coreDataModel deleteRegularEvents];
        
    // Send out a notification that the events in Core Data have been flushed, and there is (maybe) a new set of retrieved events available.
    NSString * results = EVENTS_UPDATED_USER_INFO_RESULTS_EMPTY;
    NSString * resultsDetail = EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_CONNECTION_ERROR;
    NSDictionary * eventsUpdatedInfo = [NSDictionary dictionaryWithObjectsAndKeys:results, EVENTS_UPDATED_USER_INFO_KEY_RESULTS, resultsDetail, EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL, EVENTS_UPDATED_USER_INFO_SOURCE_GENERAL, EVENTS_UPDATED_USER_INFO_KEY_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED_NOTIFICATION_KEY object:nil userInfo:eventsUpdatedInfo];
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString {
    
    NSString * responseString = [request responseString];
    //    NSLog(@"EventsViewController webConnector:getEventsListSuccess:withFilter:categoryURI: - response is %@", responseString);
    NSError * error = nil;
    NSDictionary * dictionaryFromJSON = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSArray * eventsDictionaries = [dictionaryFromJSON valueForKey:@"objects"];
    
    // First, delete all previous events found from search in Core Data
    [self.coreDataModel deleteRegularEventsFromSearch];
    
    BOOL haveResults = eventsDictionaries && [eventsDictionaries count] > 0;
    
    if (haveResults) {
        
        // Loop through and process all event dictionaries
        for (NSDictionary * eventSummaryDictionary in eventsDictionaries) {
            
            Event * newEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            [self.coreDataModel updateEvent:newEvent usingEventSummaryDictionary:eventSummaryDictionary featuredOverride:nil fromSearchOverride:[NSNumber numberWithBool:YES]];
            
        }
        
    }
    
    // Save our core data changes
    [self.coreDataModel coreDataSave];
    
    // Send out a notification that the events in Core Data have been flushed, and there is (maybe) a new set of retrieved events available.
    NSMutableDictionary * eventsUpdatedInfo = [NSMutableDictionary dictionary];
    NSString * results;
    if (haveResults) {
        results = EVENTS_UPDATED_USER_INFO_RESULTS_POPULATED;
    } else {
        results = EVENTS_UPDATED_USER_INFO_RESULTS_EMPTY;
        [eventsUpdatedInfo setObject:EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_NO_RESULTS forKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL];
    }
    [eventsUpdatedInfo setObject:results forKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS];
    [eventsUpdatedInfo setObject:EVENTS_UPDATED_USER_INFO_SOURCE_FROM_SEARCH forKey:EVENTS_UPDATED_USER_INFO_KEY_SOURCE];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED_NOTIFICATION_KEY object:nil userInfo:eventsUpdatedInfo];
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forSearchString:(NSString *)searchString {
    
    NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
    
    [self.coreDataModel deleteRegularEventsFromSearch];
    
    // Send out a notification that the events in Core Data have been flushed, and there is (maybe) a new set of retrieved events available.
    NSString * results = EVENTS_UPDATED_USER_INFO_RESULTS_EMPTY;
    NSString * resultsDetail = EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_CONNECTION_ERROR;
    NSDictionary * eventsUpdatedInfo = [NSDictionary dictionaryWithObjectsAndKeys:results, EVENTS_UPDATED_USER_INFO_KEY_RESULTS, resultsDetail, EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL, EVENTS_UPDATED_USER_INFO_SOURCE_FROM_SEARCH, EVENTS_UPDATED_USER_INFO_KEY_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_UPDATED_NOTIFICATION_KEY object:nil userInfo:eventsUpdatedInfo];
    
}

- (void) dataSourceEventsUpdated:(NSNotification *)notification {
        
    NSDictionary * userInfo = [notification userInfo];
    
    //NSString * results = [userInfo objectForKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS]; // Don't need this for now - can just check the number of items in events array.
    NSString * resultsDetail = [userInfo objectForKey:EVENTS_UPDATED_USER_INFO_KEY_RESULTS_DETAIL];
    BOOL fromSearch = [[userInfo objectForKey:EVENTS_UPDATED_USER_INFO_KEY_SOURCE] isEqualToString:EVENTS_UPDATED_USER_INFO_SOURCE_FROM_SEARCH];
    
    if (!fromSearch) {
        self.events = [[[self.coreDataModel getRegularEvents] mutableCopy] autorelease];
    } else {
        self.eventsFromSearch = [[[self.coreDataModel getRegularEventsFromSearch] mutableCopy] autorelease];
    }
    
    
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    if (!self.isSearchOn) {
        [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];        
    }
    
    BOOL eventsRetrieved = self.eventsForCurrentSource && self.eventsForCurrentSource.count > 0;
    BOOL showTableFooterView = eventsRetrieved && !self.isSearchOn;
    self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
    self.tableView.tableFooterView.userInteractionEnabled = showTableFooterView;
    if (eventsRetrieved) {
        // Events were retrieved... They will be displayed.
        [self hideProblemViewAnimated:NO];
    } else {
        // No events were retrieved. Respond accordingly, depending on the reason.
        if ([resultsDetail isEqualToString:EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_NO_RESULTS]) {
            if (!fromSearch) {
                Category * category = (Category *)[self.concreteParentCategoriesDictionary objectForKey:self.categoryURI];
                [self showProblemViewNoEventsForOldFilter:self.oldFilterString categoryTitle:category.title animated:NO];
            } else {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"No results" message:@"Sorry, we couldn't find any events matching your search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                [self.searchTextField becomeFirstResponder];
            }
        } else if ([resultsDetail isEqualToString:EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_CONNECTION_ERROR]) {
            if (!fromSearch) {
                [self showProblemViewBadConnectionAnimated:NO];
            } else {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
        } else {
            NSLog(@"ERROR in EventsViewController - events array is empty for unknown reason.");
        }
    }
    
    [self hideWebLoadingViews];
    
}

- (void) showProblemViewNoEventsForOldFilter:(NSString *)forOldFilterString categoryTitle:(NSString *)categoryTitle animated:(BOOL)animated {
    
    NSString * message = nil;
    
    if (forOldFilterString && categoryTitle) {
        message = [NSString stringWithFormat:@"Sorry, we couldn't find any\n%@ events for you\nin %@.\nTry a different combination.", forOldFilterString/*[forFilterString capitalizedString]*/, categoryTitle];
    } else if (forOldFilterString || categoryTitle) {
        NSString * modifier = forOldFilterString ? forOldFilterString : categoryTitle;
        message = [NSString stringWithFormat:@"Sorry, we couldn't find any\n%@ events for you.\nPlease try again.", modifier];        
    } else {
        message = @"Sorry, we couldn't find any events for you at this time. Please try again.";
    }
    
    [self setProblemViewVisible:YES withMessage:message animated:animated];
    
}

- (void) showProblemViewBadConnectionAnimated:(BOOL)animated {
    NSString * message = WEB_CONNECTION_ERROR_MESSAGE_STANDARD;
    [self setProblemViewVisible:YES withMessage:message animated:animated];
}

- (void) hideProblemViewAnimated:(BOOL)animated {
    [self setProblemViewVisible:NO withMessage:nil animated:animated];
}

- (void) showProblemViewAnimated:(BOOL)animated {
    [self setProblemViewVisible:YES withMessage:nil animated:animated];
}

- (void) setProblemViewVisible:(BOOL)showView withMessage:(NSString *)message animated:(BOOL)animated {

    void (^replaceTextBlock)(void) = ^{
        if (message) {
            self.problemLabel.text = message;
            CGRect tempFrame = self.problemLabel.frame;
            tempFrame.size.width = self.problemView.frame.size.width;
            self.problemLabel.frame = tempFrame;
            [self.problemLabel sizeToFit];
            tempFrame = self.problemLabel.frame;
            tempFrame.origin.x = floorf((self.problemView.frame.size.width - tempFrame.size.width) / 2.0);
            self.problemLabel.frame = tempFrame;
        }
    };
    
    void (^alphaChangeBlock)(void) = ^{
        self.problemView.alpha = showView ? 1.0 : 0.0;
    };
    
    if (animated) {
        if (showView) {
            replaceTextBlock();
        }
        [UIView animateWithDuration:0.25 animations:alphaChangeBlock completion:^(BOOL finished) {
            if (!showView) { replaceTextBlock(); }
        }];
    } else {
        // Order shouldn't matter when not animated...
        replaceTextBlock();
        alphaChangeBlock();
    }
    
    self.problemView.userInteractionEnabled = showView;
//    [self setTableViewScrollable:!showView selectable:!showView];
    
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
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

//// Pulling the table down enough triggers a web reload.
//- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView
//                   willDecelerate:(BOOL)decelerate {
//    
//    NSLog(@"ffffffffffffff -- %f", self.refreshHeaderView.bounds.size.height);
//    
//    if (scrollView == self.tableView && 
//        !self.isSearchOn && 
//        scrollView.contentOffset.y <= -(self.refreshHeaderView.bounds.size.height + self.filtersSummaryAndSearchContainerView.frame.size.height)) {
//        
//        [self.refreshHeaderView setState:EGOOPullRefreshLoading];
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:0.2];
//        UIEdgeInsets tableViewContentInset = self.tableView.contentInset;
//        NSLog(@"inc");
//        tableViewContentInset.top += self.refreshHeaderView.bounds.size.height;
//        self.tableView.contentInset = tableViewContentInset;
//		[UIView commitAnimations];
//        
//        [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
//        
//	}
//    
//}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    if (scrollView == self.tableView) {
//        NSLog(@"\ntableViewOffset: %@ \ntableViewInset: %@ \ntableViewScrollInset: %@ \ntableViewBounds: %@ \ntableViewFrame: %@ \ntabBarBounds: %@",
//              NSStringFromCGPoint(self.tableView.contentOffset), 
//              NSStringFromUIEdgeInsets(self.tableView.contentInset), 
//              NSStringFromUIEdgeInsets(self.tableView.scrollIndicatorInsets),
//              NSStringFromCGRect(self.tableView.bounds),
//              NSStringFromCGRect(self.tableView.frame),
//              NSStringFromCGRect(self.tabBarController.tabBar.bounds));
//    }

    if (scrollView == self.tableView) {
        if (!self.isSearchOn) {
            //        //        NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
            //        if (scrollView.contentOffset.y <= -(self.refreshHeaderView.bounds.size.height + self.filtersSummaryAndSearchContainerView.frame.size.height)) {
            //            [self.refreshHeaderView setState:EGOOPullRefreshPulling];
            //        } else {
            //            [self.refreshHeaderView setState:EGOOPullRefreshNormal];
            //        }
            //        
        } else {
            
//            CGRect thvf = self.tableView.tableHeaderView.frame;
//            thvf.origin.y = self.tableView.bounds.origin.y;
//            self.tableView.tableHeaderView.frame = thvf;
            
        }
        
    } else if (scrollView == self.drawerScrollView) {
        
//        [self updateActiveFilterHighlights]; // This is killing performance.
        
    }
    
}

-(void)homeButtonPressed  {
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

- (IBAction) filterButtonPressed:(id)sender {
    EventsFilter * oldActiveFilterInUI = self.activeFilterInUI;
    EventsFilter * newActiveFilterInUI = [self filterForFilterButton:sender];
    self.activeFilterInUI = newActiveFilterInUI;
    [self setDrawerToShowFilter:self.activeFilterInUI animated:self.isDrawerOpen];
    [self updateActiveFilterHighlights];
    if (!self.isDrawerOpen ||
        oldActiveFilterInUI == newActiveFilterInUI) {
        [self toggleDrawerAnimated];
    }
}

- (IBAction) reloadEventsListButtonTouched:(id)sender {
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

-(void)toggleDrawerAnimated {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    if (self.isDrawerOpen == NO) {
        self.isDrawerOpen = YES;
        CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
        pushableContainerViewFrame.origin.y += self.drawerScrollView.frame.size.height;
        self.pushableContainerView.frame = pushableContainerViewFrame;
        self.pushableContainerShadowCheatView.frame = self.pushableContainerView.frame;
        [self setTableViewScrollable:NO selectable:NO];
        self.filtersContainerShadowCheatView.alpha = 0.0;
        self.filtersContainerShadowCheatWayBelowView.alpha = 1.0;
        if (self.tableView.contentOffset.y < self.searchContainerView.bounds.size.height) {
            [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];
        }
    }
    else {
        self.isDrawerOpen = NO;
        CGRect pushableContainerViewFrame = self.pushableContainerView.frame;
        pushableContainerViewFrame.origin.y -= self.drawerScrollView.frame.size.height;
        self.pushableContainerView.frame = pushableContainerViewFrame;
        self.pushableContainerShadowCheatView.frame = self.pushableContainerView.frame;
        [self setTableViewScrollable:YES selectable:YES];
        self.filtersContainerShadowCheatView.alpha = 1.0;
        self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
        [self.dvLocationTextField resignFirstResponder];
    }
    self.drawerScrollView.userInteractionEnabled = self.isDrawerOpen;
    
    [UIView commitAnimations];
}

- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable {
    self.tableView.scrollEnabled = scrollable;
    self.tableView.allowsSelection = selectable;
}

- (void) categoryButtonPressed:(UIButton *)categoryButton {

    if (self.isDrawerOpen) {
        // Get the category for the categoryButton pushed, and do a web load for that category (with whatever filter we're potentially using as well)
        [self toggleDrawerAnimated];
        int categoryButtonTag = categoryButton.tag;
        NSString * theSelectedCategoryURI = nil;
        if (categoryButtonTag != -1) {
            // Specific category
            int concreteParentCategoryIndex = categoryButtonTag;
            NSDictionary * categoryDictionary = [self.concreteParentCategoriesArray objectAtIndex:concreteParentCategoryIndex];
            theSelectedCategoryURI = [categoryDictionary valueForKey:@"uri"];
        }
        
        [self webConnectGetEventsListWithOldFilter:self.oldFilterString categoryURI:theSelectedCategoryURI];
        
    } else {
        // Ignore category button press when drawer is closed. This should never happen, and if it did, it is because of multitouching most likely, and shouldn't be respected.
    }
    
}

- (BOOL)problemViewIsShowing {
    return (self.problemView.alpha > 0.0 && !self.problemView.hidden);
}
#pragma mark Search	

- (void) toggleSearchMode { // KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS KEEP WORKING ON THIS
    
    self.isSearchOn = !self.isSearchOn;
    // Is new mode search on, or search off
    self.searchButton.enabled = !self.isSearchOn;
    self.searchTextField.text = @"";
    
    // Adjust scroll insets block
    void (^adjustScrollInsets) (void) = ^{
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        scrollInsets.top = self.isSearchOn ? self.searchContainerView.bounds.size.height + self.filtersContainerView.bounds.size.height : 0.0;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    };
    
    if (self.isSearchOn) {
        // New mode is search on
        // Clear all previous search results / terms etc
        [self.coreDataModel deleteRegularEventsFromSearch];
        [self.eventsFromSearch removeAllObjects];
        self.tableViewCoverView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + self.tableView.tableHeaderView.bounds.size.height, self.tableView.frame.size.width, self.pushableContainerView.frame.size.height - self.tableView.tableHeaderView.bounds.size.height);
        [UIView animateWithDuration:0.25 
                         animations:^{
                             // Move filters bar off screen
                             CGRect filtersBarFrame = self.filtersContainerView.frame;
                             filtersBarFrame.origin.y = -filtersBarFrame.size.height;
                             self.filtersContainerView.frame = filtersBarFrame;
                             // Move filters bar shadow along with filters bar
                             self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                             self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                             // Fade out the filters bar shadow
                             CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                             shadowAnimation.fromValue = [NSNumber numberWithFloat:self.filtersContainerShadowCheatView.layer.shadowOpacity];
                             shadowAnimation.toValue = [NSNumber numberWithFloat:0.0];
                             shadowAnimation.duration = 0.25;
                             [self.filtersContainerShadowCheatView.layer addAnimation:shadowAnimation forKey:@"shadowOpacity"];
                             self.filtersContainerShadowCheatView.layer.shadowOpacity = 0.0;
                             // Move pushable container view up to top of screen
                             CGRect pushableFrame = self.pushableContainerView.frame;
                             pushableFrame.origin.y -= filtersBarFrame.size.height;
                             pushableFrame.size.height += filtersBarFrame.size.height;
                             self.pushableContainerView.frame = pushableFrame;
                             // Move summary string off screen
                             CGRect fscvf = self.filtersSummaryContainerView.frame;
                             fscvf.origin.y += fscvf.size.height;
                             self.filtersSummaryContainerView.frame = fscvf;
                             // Fade table view out
                             self.tableViewCoverView.alpha = 1.0;
                             self.tableView.tableFooterView.alpha = 0.0;
                             self.tableView.tableFooterView.userInteractionEnabled = NO;
                         }
                         completion:^(BOOL finished){
                             // Pull the search bar out of the table view header
                             self.tableView.tableHeaderView = nil;
                             [self.view insertSubview:self.searchContainerView aboveSubview:self.filtersContainerView];
                             self.searchContainerView.frame = CGRectMake(0, 0, self.searchContainerView.frame.size.width, self.searchContainerView.frame.size.height);
                             // Swap the browse & search filter bars
                             [self.filtersBarBrowse removeFromSuperview];
                             [self.filtersContainerView addSubview:self.filtersBarSearch];
                             // Prepare filters bar to come back on screen
                             CGRect filtersBarFrame = self.filtersContainerView.frame;
                             filtersBarFrame.origin.y = CGRectGetMaxY(self.searchContainerView.frame) - filtersBarFrame.size.height;
                             self.filtersContainerView.frame = filtersBarFrame;
                             // Move filters bar shadow along with filters bar
                             self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                             self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                             [UIView animateWithDuration:0.25 animations:^{
                                 // Make the search text field first responder, thus bringing the keyboard up
                                 [self resignFirstResponder];
                                 [self.searchTextField becomeFirstResponder];
                                 // Set search UI shifts up
                                 CGFloat searchCancelButtonShift = 10 + self.searchCancelButton.frame.size.width;
                                 CGFloat searchGoButtonShift = -(10 + self.searchGoButton.frame.size.width);
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
                                 // Reveal filters bar on screen
                                 CGRect filtersBarFrame = self.filtersContainerView.frame;
                                 filtersBarFrame.origin.y = CGRectGetMaxY(self.searchContainerView.frame);
                                 self.filtersContainerView.frame = filtersBarFrame;
                                 // Move filters bar shadow along with filters bar
                                 self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                                 self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                                 // Fade in the filters bar shadow
                                 CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                                 shadowAnimation.fromValue = [NSNumber numberWithFloat:self.filtersContainerShadowCheatView.layer.shadowOpacity];
                                 shadowAnimation.toValue = [NSNumber numberWithFloat:0.5];
                                 shadowAnimation.duration = 0.25;
                                 [self.filtersContainerShadowCheatView.layer addAnimation:shadowAnimation forKey:@"shadowOpacity"];
                                 self.filtersContainerShadowCheatView.layer.shadowOpacity = 0.5;
                                 // Move summary string on screen
                                 CGRect fscvf = self.filtersSummaryContainerView.frame;
                                 fscvf.origin.y -= fscvf.size.height;
                                 self.filtersSummaryContainerView.frame = fscvf;
                                 // Adjust scroll insets
                                 adjustScrollInsets();
                                 // Fade table view in
                                 self.tableViewCoverView.alpha = 0.0;
                                 self.tableView.tableFooterView = nil;
                                 problemViewWasShowing = self.problemViewIsShowing;
                                 [self hideProblemViewAnimated:NO];
                                 [self.tableView reloadData];
                                 NSLog(@"EventsViewController tableView reloadData");
                             }];
                         }];
    } else {
        // New mode is search off
        [UIView animateWithDuration:0.25 
                         animations:^{
                             // Force the search text field to resign first responder (thus hiding the keyboard if it was up), and make the view controller first responder again
                             [self.searchTextField resignFirstResponder];
                             [self becomeFirstResponder];
                             // Set search UI shifts up
                             CGFloat searchCancelButtonShift = -(10 + self.searchCancelButton.frame.size.width);
                             CGFloat searchGoButtonShift = 10 + self.searchGoButton.frame.size.width;
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
                             // Hide filters bar beneath search bar
                             CGRect filtersBarFrame = self.filtersContainerView.frame;
                             filtersBarFrame.origin.y = CGRectGetMaxY(self.searchContainerView.frame) - filtersBarFrame.size.height;
                             self.filtersContainerView.frame = filtersBarFrame;
                             // Move filters bar shadow along with filters bar
                             self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                             self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                             // Move summary string off screen
                             CGRect fscvf = self.filtersSummaryContainerView.frame;
                             fscvf.origin.y += fscvf.size.height;
                             self.filtersSummaryContainerView.frame = fscvf;
                             // Fade table view out
                             self.tableViewCoverView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             [self.tableView reloadData];
                             self.tableView.contentOffset = CGPointMake(0, 0);
                             // Hide filters bar off screen, ready to come back on
                             CGRect filtersBarFrame = self.filtersContainerView.frame;
                             filtersBarFrame.origin.y = -filtersBarFrame.size.height;
                             self.filtersContainerView.frame = filtersBarFrame;
                             // Move filters bar shadow along with filters bar
                             self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                             self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                             // Put the search bar back in the table view header
                             [self.searchContainerView removeFromSuperview];
                             self.tableView.tableHeaderView = self.searchContainerView;
                             // Swap the browse & search filter bars
                             [self.filtersBarSearch removeFromSuperview];
                             [self.filtersContainerView addSubview:self.filtersBarBrowse];
                             [UIView animateWithDuration:0.25 animations:^{
                                 // Move filters bar onto screen
                                 CGRect filtersBarFrame = self.filtersContainerView.frame;
                                 filtersBarFrame.origin.y = 0;
                                 self.filtersContainerView.frame = filtersBarFrame;
                                 // Move filters bar shadow along with filters bar
                                 self.filtersContainerShadowCheatView.frame = self.filtersContainerView.frame;
                                 self.filtersContainerShadowCheatWayBelowView.frame = self.filtersContainerView.frame;
                                 // Fade in the filters bar shadow
                                 CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                                 shadowAnimation.fromValue = [NSNumber numberWithFloat:self.filtersContainerShadowCheatView.layer.shadowOpacity];
                                 shadowAnimation.toValue = [NSNumber numberWithFloat:0.5];
                                 shadowAnimation.duration = 0.25;
                                 [self.filtersContainerShadowCheatView.layer addAnimation:shadowAnimation forKey:@"shadowOpacity"];
                                 self.filtersContainerShadowCheatView.layer.shadowOpacity = 0.5;
                                 // Move pushable container view down
                                 CGRect pushableFrame = self.pushableContainerView.frame;
                                 pushableFrame.origin.y += filtersBarFrame.size.height;
                                 pushableFrame.size.height -= filtersBarFrame.size.height;
                                 self.pushableContainerView.frame = pushableFrame;
                                 // Move summary string on screen
                                 CGRect fscvf = self.filtersSummaryContainerView.frame;
                                 fscvf.origin.y -= fscvf.size.height;
                                 self.filtersSummaryContainerView.frame = fscvf;
                                 // Adjust scroll insets
                                 adjustScrollInsets();
                                 // Fade table view in
                                 self.tableViewCoverView.alpha = 0.0;
                                 if (problemViewWasShowing) { [self showProblemViewAnimated:NO]; }
                                 NSLog(@"EventsViewController tableView reloadData");
                                 BOOL showTableFooterView = self.eventsForCurrentSource && self.eventsForCurrentSource.count > 0;
                                 self.tableView.tableFooterView = self.tableReloadContainerView;
                                 self.tableView.tableFooterView.alpha = showTableFooterView ? 1.0 : 0.0;
                                 self.tableView.tableFooterView.userInteractionEnabled = showTableFooterView;
                             }];
                         }];
    }
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
        [self.webConnector getEventsListForSearchString:self.searchTextField.text];
        [self showWebLoadingViews];
        [self.searchTextField resignFirstResponder];
        shouldReturn = NO;
    } else if (textField == self.dvLocationTextField) {
        [self.dvLocationTextField resignFirstResponder];
        shouldReturn = NO;
    }
    return shouldReturn;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsForCurrentSource count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * CellIdentifier = @"EventCellGeneral";
    
    EventTableViewCell * cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } else {
//        NSLog(@"Got a dequeued");
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
    
    NSString * priceRange = [self.webDataTranslator priceRangeStringFromMinPrice:priceMin maxPrice:priceMax dataUnavailableString:nil];
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
        insets.bottom = self.filtersSummaryContainerView.bounds.size.height;
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
    [self webConnectGetEventsListWithOldFilter:EVENTS_OLDFILTER_RECOMMENDED categoryURI:nil];
}

- (void) behaviorWasReset:(NSNotification *)notification {
    if (self.isSearchOn) {
        [self toggleSearchMode];
    }
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    [self webConnectGetEventsListWithOldFilter:EVENTS_OLDFILTER_RECOMMENDED categoryURI:nil];
}

#pragma mark color

-(void) showWebLoadingViews  {
    if (self.view.window) {
        
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

//    // REFRESH HEADER VIEW
//    if (self.refreshHeaderView.state == EGOOPullRefreshLoading) {
//        [self.refreshHeaderView setState:EGOOPullRefreshNormal];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:.3];
//        UIEdgeInsets contentInset = self.tableView.contentInset;
//        contentInset.top -= self.refreshHeaderView.bounds.size.height;
//        self.tableView.contentInset = contentInset;
//        [UIView commitAnimations];
//    }
    
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
    NSArray * resultsArray = [self.filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code == %@", filterCode]];
    if (resultsArray && [resultsArray count] > 0) {
        filter = [resultsArray objectAtIndex:0];
    }
    if (filter == nil) {
        NSLog(@"ERROR in EventsViewController - can't match a filter code to a filter");
    }
    return filter;
}

- (EventsFilter *) filterForFilterButton:(UIButton *)filterButton {
    EventsFilter * filter = nil;
    NSArray * resultsArray = [self.filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"button == %@", filterButton]];
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
    EventsFilter * swipedOverFilter = [self filterForPositionX:[swipeGesture locationInView:swipeGesture.view].x withinViewWidth:swipeGesture.view.bounds.size.width fromFiltersArray:self.isSearchOn ? self.filters : self.filtersSearch];
    if (!self.isDrawerOpen) {
        if (self.isSearchOn) {
            self.activeSearchFilterInUI = swipedOverFilter;
        } else {
            self.activeFilterInUI = swipedOverFilter;
        }
        NSLog(@"swipeDownToShowDrawer for button with title %@%@", self.activeFilterInUI.button.titleLabel.text, self.isSearchOn ? @"(while search is on)" : @"");
        [self setDrawerToShowFilter:self.activeFilterInUI animated:self.isDrawerOpen];
        [self updateActiveFilterHighlights];
        [self toggleDrawerAnimated];
    }
}

- (void) swipeUpToHideDrawer:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipeUpToHideDrawer");
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
    
}

- (EventsFilter *) filterForDrawerScrollViewContentOffset:(CGPoint)contentOffset {
    EventsFilter * matchingFilter = nil;
    for (EventsFilter * filter in self.filters) {
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
        EventsFilter * filter = [self filterForDrawerScrollViewContentOffset:scrollView.contentOffset];
        self.activeFilterInUI = filter;
        [self updateActiveFilterHighlights]; // Moved this here from scrollViewDidScroll for performance reasons.
    } else if (scrollView == self.tableView) {
        if (self.isDrawerOpen) {
            if (self.tableView.contentOffset.y < self.searchContainerView.bounds.size.height) {
                [self.tableView setContentOffset:CGPointMake(0, self.searchContainerView.bounds.size.height) animated:YES];
            }
        }
    }
}

- (void) filterOptionButtonTouched:(UIButton *)filterOptionButton forFilterCode:(NSString *)filterCode selectedOptionGetter:(SEL)selectedFilterOptionGetter selectedOptionSetter:(SEL)selectedFilterOptionSetter {
    
    EventsFilter * filter = [self filterForFilterCode:filterCode inFiltersArray:self.filtersForCurrentSource];
    EventsFilterOption * newSelectedOption = [self filterOptionForFilterOptionButton:filterOptionButton inFilterOptionsArray:filter.options];
    EventsFilterOption * oldSelectedOption = [self performSelector:selectedFilterOptionGetter];
    [self performSelector:selectedFilterOptionSetter withObject:newSelectedOption];
    [self updateFilterOptionButtonStatesOldSelected:oldSelectedOption newSelected:newSelectedOption];
    [self updateFilter:filter buttonImageForFilterOption:newSelectedOption];
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];

}

- (IBAction) priceFilterOptionButtonTouched:(id)sender {
    SEL selectedOptionGetter, selectedOptionSetter;
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

- (void) updateFiltersSummaryLabelWithCurrentSelectedFilterOptions {
    
    NSString * priceReadable    = nil;
    NSString * dateReadable     = nil;
    NSString * categoryReadable = nil;
    NSString * timeReadable     = nil;
    NSString * locationReadable = nil;
    
    if (self.isSearchOn) {
        dateReadable     = self.selectedDateSearchFilterOption.readable;
        locationReadable = self.selectedLocationSearchFilterOption.readable;
        timeReadable     = self.selectedTimeSearchFilterOption.readable;
    } else {
        priceReadable    = self.selectedPriceFilterOption.readable;
        dateReadable     = self.selectedDateFilterOption.readable;
        categoryReadable = self.categoryURI ? [self.coreDataModel getCategoryWithURI:self.categoryURI].title : nil;
        timeReadable     = self.selectedTimeFilterOption.readable;
        locationReadable = self.selectedLocationFilterOption.readable;
    }
    
    NSMutableString * compositeString = [NSMutableString string];
    [compositeString appendString:@"You are looking at "];
    NSString * eventsWord = @"events";
    if (categoryReadable) {
        eventsWord = [NSString stringWithFormat:@"%@ %@", categoryReadable, eventsWord];
    }
    if (priceReadable) {
        if ([priceReadable isEqualToString:@"Free"]) {
            [compositeString appendFormat:@"%@ %@ ", [priceReadable lowercaseString], [eventsWord lowercaseString]];
        } else {
            [compositeString appendFormat:@"%@ that cost %@ ", [eventsWord lowercaseString], [priceReadable lowercaseString]];
        }
    } else {
        [compositeString appendFormat:@"%@ ", [eventsWord lowercaseString]];
    }
    if (timeReadable || dateReadable) {
        [compositeString appendString:@"happening "];
    }
    if (dateReadable) {
        [compositeString appendFormat:@"%@ ", [dateReadable lowercaseString]];
    }
    if (timeReadable) {
        [compositeString appendFormat:@"%@ ", [timeReadable lowercaseString]];
    }
    if (locationReadable) {
        [compositeString appendFormat:@"%@ %@ ", [locationReadable lowercaseString], self.dvLocationTextField.text];
    }
    [compositeString deleteCharactersInRange:NSMakeRange(compositeString.length-1, 1)];
    [compositeString appendFormat:@"."];
    [compositeString replaceOccurrencesOfString:@"You are looking at events." withString:@"Looking for something specific? Use the filters above to narrow in on the type of events you're interested in." options:0 range:NSMakeRange(0, compositeString.length)];
    
    if (self.isSearchOn) {
        self.filtersSummaryStringSearch = compositeString;
    } else {
        self.filtersSummaryStringBrowse = compositeString;
    }
    
    self.filtersSummaryLabel.text = compositeString;
    
    CGFloat filtersSummaryLabelPadding = 5.0;
    CGRect filtersSummaryLabelFrame = self.filtersSummaryLabel.frame;
    
    filtersSummaryLabelFrame.size = [self.filtersSummaryLabel.text sizeWithFont:self.filtersSummaryLabel.font constrainedToSize:CGSizeMake(self.filtersSummaryContainerView.bounds.size.width - 2 * filtersSummaryLabelPadding, 1000) lineBreakMode:UILineBreakModeWordWrap];
    filtersSummaryLabelFrame.origin.x = roundf((self.filtersSummaryContainerView.bounds.size.width - filtersSummaryLabelFrame.size.width) / 2.0);
    CGFloat filtersSummaryContainerViewHeight = filtersSummaryLabelFrame.size.height + 2 * filtersSummaryLabelPadding;
    [UIView animateWithDuration:0.25 animations:^{
        self.filtersSummaryLabel.frame = filtersSummaryLabelFrame;
        self.filtersSummaryContainerView.frame = CGRectMake(self.filtersSummaryContainerView.frame.origin.x, self.view.bounds.size.height - filtersSummaryContainerViewHeight, self.filtersSummaryContainerView.frame.size.width, filtersSummaryContainerViewHeight);
        UIEdgeInsets tableViewInset = self.tableView.contentInset;
        tableViewInset.bottom = self.filtersSummaryContainerView.bounds.size.height;
        self.tableView.contentInset = tableViewInset;
    }];

//    NSLog(@"label=%@ container=%@ (calculated=%@ for %@)", NSStringFromCGRect(self.filtersSummaryLabel.frame), NSStringFromCGRect(self.filtersSummaryContainerView.frame), NSStringFromCGSize(filtersSummaryLabelFrame.size), self.filtersSummaryLabel.text);
    
}

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
    for (int i=0; i<self.filters.count; i++) {
        EventsFilter * filter = (EventsFilter *)[self.filters objectAtIndex:i];
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
    [self.dvLocationTextField resignFirstResponder];
    self.dvLocationTextField.text = @"";
    self.dvLocationTextField.placeholder = @"Current Location";
}

- (void)searchCancelButtonTouched:(id)sender {
    if ([self.searchTextField isFirstResponder]) {
        if (!self.eventsFromSearch || 
            self.eventsFromSearch.count == 0) {
            [self toggleSearchMode];
        } else {
            [self.searchTextField resignFirstResponder];
        }
    } else {
        [self toggleSearchMode];        
    }
}

- (void)searchGoButtonTouched:(id)sender {
    [self.searchTextField resignFirstResponder];
    [self showWebLoadingViews];
    [self.webConnector getEventsListForSearchString:self.searchTextField.text];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [dvLocationButtonCity release];
    dvLocationButtonCity = nil;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
