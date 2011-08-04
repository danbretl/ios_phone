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

@property (retain) NSMutableArray * filters;
@property (retain) EventsFilter * activeFilterInUI;
@property (retain) EventsFilterOption * selectedPriceFilterOption;
@property (retain) EventsFilterOption * selectedDateFilterOption;
@property (retain) EventsFilterOption * selectedTimeFilterOption;
@property (retain) EventsFilterOption * selectedLocationFilterOption;
@property BOOL isDrawerOpen;
@property BOOL isSearchOn;
@property BOOL problemViewWasShowing;
@property (readonly) BOOL problemViewIsShowing;
@property (copy) NSString * oldFilterString;
@property (copy) NSString * categoryURI;
@property (copy) NSString * oldFilterStringProposed;
@property (copy) NSString * categoryURIProposed;
@property (retain) NSIndexPath * indexPathOfRowAttemptingToDelete;
@property (retain) NSIndexPath * indexPathOfSelectedRow;

/////////////////////
// Views properties

@property (retain) IBOutlet UITableView * tableView;
@property (retain) IBOutlet UIView   * pushableContainerView;
@property (retain) IBOutlet UIView   * pushableContainerShadowCheatView;
@property (retain) IBOutlet UIView   * filtersSummaryAndSearchContainerView;
@property (retain) IBOutlet UILabel  * filtersSummaryLabel;
@property (retain) IBOutlet UIView   * searchButtonContainerView;
@property (retain) IBOutlet UIButton * searchButton;
@property (retain) IBOutlet UIView   * filtersContainerView;
@property (retain) IBOutlet UIView   * filtersContainerShadowCheatView;
@property (retain) IBOutlet UIView   * filtersContainerShadowCheatWayBelowView;
@property (retain) IBOutlet UIButton * filterButtonCategories;
@property (retain) IBOutlet UIButton * filterButtonPrice;
@property (retain) IBOutlet UIButton * filterButtonDate;
@property (retain) IBOutlet UIButton * filterButtonLocation;
@property (retain) IBOutlet UIButton * filterButtonTime;
@property (retain) IBOutlet SegmentedHighlighterView * activeFilterHighlightsContainerView;
@property (retain) IBOutlet UIScrollView * drawerScrollView;
@property (retain) IBOutlet UIView * drawerViewsContainer;
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
// Drawer view categories
@property (retain) IBOutlet UIView * drawerViewCategories;
// Drawer view time
@property (retain) IBOutlet UIView * drawerViewTime;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonMorning;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonAfternoon;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonEvening;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonNight;
@property (retain) IBOutlet UIButtonWithOverlayView * dvTimeButtonAny;
// Drawer view location
@property (retain) IBOutlet UIView * drawerViewLocation;
@property (retain) IBOutlet UITextField * dvLocationTextField;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonWalking;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonNeighborhood;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonBorough;
@property (retain) IBOutlet UIButtonWithOverlayView * dvLocationButtonCity;
@property (retain) UISearchBar * mySearchBar;
@property (nonatomic, readonly) EGORefreshTableHeaderView *refreshHeaderView;
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

- (void) behaviorWasReset:(NSNotification *)notification;
- (void) categoryButtonPressed:(UIButton *)categoryButton;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) dataSourceEventsUpdated:(NSNotification *)notification;
- (IBAction) filterButtonPressed:(id)sender;
- (IBAction) priceFilterOptionButtonTouched:(id)sender;
- (IBAction) dateFilterOptionButtonTouched:(id)sender;
- (IBAction) timeFilterOptionButtonTouched:(id)sender;
- (IBAction) locationFilterOptionButtonTouched:(id)sender;
- (EventsFilter *) filterForDrawerScrollViewContentOffset:(CGPoint)contentOffset;
- (EventsFilter *) filterForFilterButton:(UIButton *)filterButton;
- (EventsFilter *) filterForPositionX:(CGFloat)x;
- (EventsFilterOption *) filterOptionForFilterOptionButton:(UIButton *)filterOptionButton inFilterOptionsArray:(NSArray *)filterOptions;
- (void) forceSearchBarCancelButtonToBeEnabled;
- (void) hideProblemViewAnimated:(BOOL)animated;
- (void) hideWebLoadingViews;
- (void) homeButtonPressed;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) loginActivity:(NSNotification *)notification;
- (IBAction) searchButtonPressed:(id)sender;
- (void) setDrawerToShowFilter:(EventsFilter *)filter animated:(BOOL)animated;
- (void) setImagesForCategoryButton:(UIButton *)button forCategory:(Category *)category;
- (void) setProblemViewVisible:(BOOL)showView withMessage:(NSString *)message animated:(BOOL)animated;
- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable;
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
- (void) updateFiltersSummaryLabelWithCurrentSelectedFilterOptions;
- (void) webConnectGetEventsListWithCurrentOldFilterAndCategory;
- (void) webConnectGetEventsListWithOldFilter:(NSString *)theProposedOldFilterString categoryURI:(NSString *)theProposedCategoryURI;

@end

@implementation EventsViewController
@synthesize filters;
@synthesize filtersContainerView, filtersContainerShadowCheatView, filtersContainerShadowCheatWayBelowView, filterButtonCategories, filterButtonPrice, filterButtonDate, filterButtonLocation, filterButtonTime;
@synthesize pushableContainerView, pushableContainerShadowCheatView, filtersSummaryAndSearchContainerView, filtersSummaryLabel, searchButtonContainerView, searchButton;
@synthesize drawerScrollView, activeFilterHighlightsContainerView, drawerViewsContainer;
@synthesize drawerViewPrice, dvPriceButtonAny, dvPriceButtonFree, dvPriceButtonUnder20, dvPriceButtonUnder50;
@synthesize drawerViewDate, dvDateButtonAny, dvDateButtonToday, dvDateButtonThisWeekend, dvDateButtonThisWeek, dvDateButtonThisMonth;
@synthesize drawerViewCategories;
@synthesize drawerViewTime, dvTimeButtonAny, dvTimeButtonMorning, dvTimeButtonAfternoon, dvTimeButtonEvening, dvTimeButtonNight;
@synthesize drawerViewLocation, dvLocationTextField, dvLocationButtonWalking, dvLocationButtonNeighborhood, dvLocationButtonBorough, dvLocationButtonCity;
@synthesize activeFilterInUI;
@synthesize selectedPriceFilterOption, selectedDateFilterOption, selectedTimeFilterOption, selectedLocationFilterOption;
@synthesize tableView=tableView_;
@synthesize mySearchBar,eventsFromSearch, events,coreDataModel,webActivityView,concreteParentCategoriesDictionary;
@synthesize refreshHeaderView, concreteParentCategoriesArray;
@synthesize oldFilterString, categoryURI, oldFilterStringProposed, categoryURIProposed;
@synthesize isSearchOn;
@synthesize problemView, problemLabel;
@synthesize cardPageViewController;
@synthesize indexPathOfRowAttemptingToDelete, indexPathOfSelectedRow;
@synthesize isDrawerOpen;
@synthesize problemViewWasShowing;

- (void)dealloc {
    [activeFilterInUI release];
    [activeFilterHighlightsContainerView release];
    [selectedDateFilterOption release];
    [selectedLocationFilterOption release];
    [selectedPriceFilterOption release];
    [selectedTimeFilterOption release];
    [filters release];
    [filtersContainerView release];
    [filtersContainerShadowCheatView release];
    [filtersContainerShadowCheatWayBelowView release];
    [filterButtonCategories release];
    [filterButtonPrice release];
    [filterButtonDate release];
    [filterButtonLocation release];
    [filterButtonTime release];
    [pushableContainerView release];
    [pushableContainerShadowCheatView release];
    [filtersSummaryAndSearchContainerView release];
    [filtersSummaryLabel release];
    [searchButtonContainerView release];
    [searchButton release];
    [drawerScrollView release];
    [drawerViewsContainer release];
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
    // Drawer view categories
    [drawerViewCategories release];
    // Drawer view time
    [drawerViewTime release];
    [dvTimeButtonMorning release];
    [dvTimeButtonAfternoon release];
    [dvTimeButtonEvening release];
    [dvTimeButtonNight release];
    [dvTimeButtonAny release];
    // Drawer view location
    [drawerViewLocation release];
    [dvLocationTextField release];
    [dvLocationButtonWalking release];
    [dvLocationButtonNeighborhood release];
    [dvLocationButtonBorough release];
    [dvLocationButtonCity release];
    [tableView_ release];
    [concreteParentCategoriesDictionary release];
    [concreteParentCategoriesArray release];
	[mySearchBar release];
	[eventsFromSearch release];
	[events release];
    [coreDataModel release];
	[refreshHeaderView release];
	[webActivityView release];
    [oldFilterString release];
    [categoryURI release];
    [oldFilterStringProposed release];
    [categoryURIProposed release];
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
    self.drawerScrollView.contentSize = self.drawerViewsContainer.bounds.size;
    self.drawerScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.drawerScrollView.userInteractionEnabled = NO;
    self.drawerScrollView.layer.masksToBounds = YES;
    [self.drawerScrollView addSubview:self.drawerViewsContainer];
    self.drawerScrollView.delegate = self;
    //self.drawerViewsContainer.backgroundColor = [UIColor clearColor];
    self.drawerViewsContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    
    // Shadows
    self.filtersContainerShadowCheatView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.filtersContainerShadowCheatView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filtersContainerShadowCheatView.layer.shadowOpacity = 1.0;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowColor = self.filtersContainerShadowCheatView.layer.shadowColor;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOffset = self.filtersContainerShadowCheatView.layer.shadowOffset;
    self.filtersContainerShadowCheatWayBelowView.layer.shadowOpacity = self.filtersContainerShadowCheatView.layer.shadowOpacity;
    self.filtersContainerShadowCheatWayBelowView.alpha = 0.0;
    // More shadows
    self.pushableContainerShadowCheatView.layer.shadowColor = self.filtersContainerShadowCheatView.layer.shadowColor;
    self.pushableContainerShadowCheatView.layer.shadowOffset = self.filtersContainerShadowCheatView.layer.shadowOffset;
    self.pushableContainerShadowCheatView.layer.shadowOpacity = self.filtersContainerShadowCheatView.layer.shadowOpacity;
    self.pushableContainerShadowCheatView.layer.shouldRasterize = YES;
    // More shadows
    self.filtersSummaryAndSearchContainerView.layer.shadowColor = self.filtersContainerShadowCheatView.layer.shadowColor;
    self.filtersSummaryAndSearchContainerView.layer.shadowOffset = self.filtersContainerShadowCheatView.layer.shadowOffset;
    self.filtersSummaryAndSearchContainerView.layer.shadowOpacity = self.filtersContainerShadowCheatView.layer.shadowOpacity;
    self.filtersSummaryAndSearchContainerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, self.filtersSummaryAndSearchContainerView.bounds.size.width, self.filtersSummaryAndSearchContainerView.bounds.size.height - 10)] CGPath];
    
    // Add category buttons to categories background
    int initial_x = 10;
    int initial_y = 20;
    int index = 0;
    for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
            UIView * categoryBackgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(initial_x + x*100, initial_y + y*80, 100, 100)];
            categoryBackgroundView.userInteractionEnabled = YES;
//            categoryBackgroundView.userInteractionEnabled = YES;
            UIButton * categoryButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 0, 50, 50)];
            categoryButton.enabled = YES;
            UILabel * categoryTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 100, 25)];
            //if 1st column in 1st row, make all view
            Category * category = nil;
            if (y == 0 && x == 0) {
                categoryButton.tag = -1;
                categoryTitleLabel.text = @"All Categories";
                category = nil;
            } else {
                //set icon image here
                category = (Category *)[self.concreteParentCategoriesArray objectAtIndex:index-1];
                categoryTitleLabel.text = category.title;
                categoryButton.tag = index-1;
            }
            [self setImagesForCategoryButton:categoryButton forCategory:category];
            [categoryButton addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            categoryTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
            categoryTitleLabel.textAlignment = UITextAlignmentCenter;
            categoryTitleLabel.backgroundColor = [UIColor clearColor];
            [categoryBackgroundView addSubview:categoryTitleLabel];
            [categoryBackgroundView addSubview:categoryButton];
            [self.drawerViewCategories addSubview:categoryBackgroundView];
            [categoryTitleLabel release];
            [categoryButton release];
            [categoryBackgroundView release];
            
            index = index + 1;
        }
    }
        
	// Create the UITableView
//    self.myTableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 80, 320, 332)] autorelease];
	self.tableView.rowHeight = 76;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.myTableView.separatorColor = [UIColor clearColor]; // Unnecessary, considering we set separatorStyle to UITableViewCellSeparatorStyleNone?
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    self.tableView.showsVerticalScrollIndicator = YES;
    
    UISwipeGestureRecognizer * swipeDownFiltersGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToShowDrawer:)];
    swipeDownFiltersGR.direction = UISwipeGestureRecognizerDirectionDown;
    [self.filtersContainerView addGestureRecognizer:swipeDownFiltersGR];
    [swipeDownFiltersGR release];
    UISwipeGestureRecognizer * swipeDownFiltersGRSupplemental = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToShowDrawer:)];
    swipeDownFiltersGRSupplemental.direction = UISwipeGestureRecognizerDirectionDown;
    [self.filtersSummaryAndSearchContainerView addGestureRecognizer:swipeDownFiltersGRSupplemental];
    [swipeDownFiltersGRSupplemental release];
    
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
	
//	self.searchButton = [[[UIButton alloc]initWithFrame:CGRectMake(280,5,32,32)] autorelease];
	[self.searchButton setBackgroundImage:[UIImage imageNamed:@"btn_search.png"] forState: UIControlStateNormal];
	[self.searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    // Search bar
	self.mySearchBar = [[[UISearchBar alloc]initWithFrame:CGRectMake(0, -44, 320, 44)] autorelease];
	self.mySearchBar.showsCancelButton = YES;
	self.mySearchBar.delegate = self;
    self.mySearchBar.tintColor = [UIColor blackColor]; // Nice! So easy.
	[self.view addSubview:mySearchBar];
	
	// Pull table initialization
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, 320.0f, self.tableView.bounds.size.height)];
//    self.refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.refreshHeaderView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.refreshHeaderView.bottomBorderThickness = 0.0;
    [self.refreshHeaderView setLastRefreshDate:[DefaultsModel loadLastEventsListGetDate]];
    [self.tableView addSubview:self.refreshHeaderView];
    
    // Create the "no results" view
    self.problemView = [[UIView alloc] initWithFrame:CGRectMake(/*self.myTableView.frame.origin.x + */20.0, /*self.myTableView.frame.origin.y + */70.0, self.tableView.frame.size.width - 40.0, 100.0)];
    self.problemView.backgroundColor = [UIColor clearColor];//[UIColor whiteColor];
//    self.noResultsView.layer.cornerRadius = 20.0;
//    self.noResultsView.layer.masksToBounds = YES;
//    self.noResultsView.layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
//    self.noResultsView.layer.borderWidth = 1.0;
    [self.tableView addSubview:self.problemView];
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
                              [EventsFilterOption eventsFilterOptionWithCode:@"free" 
                                                              readableString:@"Free" 
                                                                  buttonView:self.dvPriceButtonFree],
                              [EventsFilterOption eventsFilterOptionWithCode:@"under20" 
                                                              readableString:@"Under $20" 
                                                                  buttonView:self.dvPriceButtonUnder20],
                              [EventsFilterOption eventsFilterOptionWithCode:@"under50" 
                                                              readableString:@"Under $50" 
                                                                  buttonView:self.dvPriceButtonUnder50],
                              [EventsFilterOption eventsFilterOptionWithCode:@"anyprice" 
                                                              readableString:nil 
                                                                  buttonView:self.dvPriceButtonAny],
                              nil];
    NSArray * dateOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption eventsFilterOptionWithCode:@"today" 
                                                             readableString:@"Today" 
                                                                 buttonView:self.dvDateButtonToday],
                             [EventsFilterOption eventsFilterOptionWithCode:@"thisweekend" 
                                                             readableString:@"This Weekend" 
                                                                 buttonView:self.dvDateButtonThisWeekend],
                             [EventsFilterOption eventsFilterOptionWithCode:@"thisweek" 
                                                             readableString:@"This Week" 
                                                                 buttonView:self.dvDateButtonThisWeek],
                             [EventsFilterOption eventsFilterOptionWithCode:@"thismonth" 
                                                             readableString:@"This Month" 
                                                                 buttonView:self.dvDateButtonThisMonth],
                             [EventsFilterOption eventsFilterOptionWithCode:@"anydate" 
                                                             readableString:nil
                                                                 buttonView:self.dvDateButtonAny],
                             nil];
    NSArray * timeOptions = [NSArray arrayWithObjects:
                             [EventsFilterOption eventsFilterOptionWithCode:@"morning" 
                                                             readableString:@"In the Morning" 
                                                                 buttonView:self.dvTimeButtonMorning],
                             [EventsFilterOption eventsFilterOptionWithCode:@"afternoon" 
                                                             readableString:@"In the Afternoon" 
                                                                 buttonView:self.dvTimeButtonAfternoon],
                             [EventsFilterOption eventsFilterOptionWithCode:@"evening" 
                                                             readableString:@"In the Evening" 
                                                                 buttonView:self.dvTimeButtonEvening],
                             [EventsFilterOption eventsFilterOptionWithCode:@"night" 
                                                             readableString:@"At Night" 
                                                                 buttonView:self.dvTimeButtonNight],
                             [EventsFilterOption eventsFilterOptionWithCode:@"anytime" 
                                                             readableString:nil
                                                                 buttonView:self.dvTimeButtonAny],
                             nil];
    NSArray * locationOptions = [NSArray arrayWithObjects:
                                 [EventsFilterOption eventsFilterOptionWithCode:@"walkingdistance" 
                                                                 readableString:@"Within Walking Distance of" 
                                                                     buttonView:self.dvLocationButtonWalking],
                                 [EventsFilterOption eventsFilterOptionWithCode:@"neighborhood" 
                                                                 readableString:@"In the Same Neighborhood as" 
                                                                     buttonView:self.dvLocationButtonNeighborhood],
                                 [EventsFilterOption eventsFilterOptionWithCode:@"borough" 
                                                                 readableString:@"In the Same Borough as" 
                                                                     buttonView:self.dvLocationButtonBorough],
                                 [EventsFilterOption eventsFilterOptionWithCode:@"city" 
                                                                 readableString:nil
                                                                     buttonView:self.dvLocationButtonCity],
                                 nil];
    
    // New filter "view models"
    self.filters = [NSMutableArray arrayWithObjects:
                    [EventsFilter eventsFilterWithCode:EVENTS_FILTER_PRICE button:self.filterButtonPrice drawerView:self.drawerViewPrice options:priceOptions],
                    [EventsFilter eventsFilterWithCode:EVENTS_FILTER_DATE button:self.filterButtonDate drawerView:self.drawerViewDate options:dateOptions],
                    [EventsFilter eventsFilterWithCode:EVENTS_FILTER_CATEGORIES button:self.filterButtonCategories drawerView:self.drawerViewCategories options:nil],
                    [EventsFilter eventsFilterWithCode:EVENTS_FILTER_TIME button:self.filterButtonTime drawerView:self.drawerViewTime options:timeOptions],
                    [EventsFilter eventsFilterWithCode:EVENTS_FILTER_LOCATION button:self.filterButtonLocation drawerView:self.drawerViewLocation options:locationOptions],
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
    
    for (EventsFilter * filter in self.filters) {
        filter.drawerView.backgroundColor = [UIColor clearColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
        filter.button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:9.0];
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [filter.button setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        SEL filterOptionButtonSelector = [[filterOptionButtonSelectors objectForKey:filter.code] pointerValue];
        for (EventsFilterOption * filterOption in filter.options) {
            [filterOption.buttonView.button addTarget:self action:filterOptionButtonSelector forControlEvents:UIControlEventTouchUpInside];
            filterOption.buttonView.cornerRadius = 5.0;
            filterOption.buttonView.layer.shadowRadius = 1.0;
            [filterOption.buttonView.button setBackgroundImage:[UIImage imageNamed:@"btn_filter_option_unselected.png"] forState:UIControlStateNormal];
            [filterOption.buttonView.button setBackgroundImage:[UIImage imageNamed:@"btn_filter_option_unselected_touch.png"] forState:UIControlStateHighlighted];
        }
    }
    self.activeFilterHighlightsContainerView.highlightColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_select_glow.png"]];
    self.activeFilterHighlightsContainerView.numberOfSegments = self.filters.count;
    self.activeFilterInUI = [self.filters objectAtIndex:0];
    [self setDrawerToShowFilter:self.activeFilterInUI animated:NO];
    [self updateActiveFilterHighlights];
    self.selectedPriceFilterOption = priceOptions.lastObject;
    self.selectedDateFilterOption = dateOptions.lastObject;
    self.selectedTimeFilterOption = timeOptions.lastObject;
    self.selectedLocationFilterOption = locationOptions.lastObject;
    self.oldFilterString = EVENTS_OLDFILTER_RECOMMENDED;
    self.categoryURI = nil;
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
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
    
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory]; // Don't need to reloadData until we get a response back from this web connection attempt.
    
}

// On viewDidAppear, we should deselect the highlighted row (if there is one).
- (void)viewDidAppear:(BOOL)animated
{
    // Call super
	[super viewDidAppear:animated];
    [self suggestToRedrawEventsList];
    // Following if statement should never return true, but that's OK.
    if (![self.mySearchBar isFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    // Deselect selected row, if there is one
    [tableView_ deselectRowAtIndexPath:[tableView_ indexPathForSelectedRow] animated:YES]; // There is something weird going on with the animation - it is going really slowly. Figure this out later. It doesn't look horrible right now though, so, I'm just going to leave it.
    
    if (self.webConnector.connectionInProgress) {
        [self showWebLoadingViews];
    } else if ([self.eventsForCurrentSource count] == 0) {
        if (self.isSearchOn) {
            // Not going to do anything on this path for now... Just leave the list blank?
        } else {
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
        webConnector.allowSimultaneousConnection = NO;
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
    self.oldFilterStringProposed = theProposedOldFilterString;
    self.categoryURIProposed = theProposedCategoryURI;
    [self showWebLoadingViews];
    [self.webConnector getEventsListWithFilter:self.oldFilterStringProposed categoryURI:self.categoryURIProposed];
    
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
        [self.refreshHeaderView setLastRefreshDate:now];
        
    }

    // Save our core data changes
    [self.coreDataModel coreDataSave];
        
    // Make sure filterString and categoryURI are updated
    self.oldFilterString = self.oldFilterStringProposed;

    self.categoryURI = self.categoryURIProposed;
    self.oldFilterStringProposed = nil;
    self.categoryURIProposed = nil;
    
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
    
    // Make sure filterString and categoryURI are updated
    self.oldFilterString = self.oldFilterStringProposed;
    self.categoryURI = self.categoryURIProposed;
    self.oldFilterStringProposed = nil;
    self.categoryURIProposed = nil;
    
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
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    if (self.eventsForCurrentSource && [self.eventsForCurrentSource count] > 0) {
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
                [self.mySearchBar becomeFirstResponder];
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
    }

}

- (void) forceToReloadEventsList {
    [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
}

// Pulling the table down enough triggers a web reload.
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView
                   willDecelerate:(BOOL)decelerate {
    
    if (scrollView == self.tableView && 
        !self.isSearchOn && 
        scrollView.contentOffset.y <= -(65.0f + self.filtersSummaryAndSearchContainerView.frame.size.height)) {
        
        [self.refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top + 65.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        [self webConnectGetEventsListWithCurrentOldFilterAndCategory];
        
	}
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && 
        !self.isSearchOn) {
        
        //        NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
        if (scrollView.contentOffset.y <= -(65.0f + self.filtersSummaryAndSearchContainerView.frame.size.height)) {
            [self.refreshHeaderView setState:EGOOPullRefreshPulling];
        } else {
            [self.refreshHeaderView setState:EGOOPullRefreshNormal];
        }
        
    } else if (scrollView == self.drawerScrollView) {
        
        [self updateActiveFilterHighlights];
        
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
    if (!self.isDrawerOpen ||
        oldActiveFilterInUI == newActiveFilterInUI) {
        [self toggleDrawerAnimated];
    }
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

- (void) toggleSearchMode {
    self.isSearchOn = !self.isSearchOn;
    // Is new mode search on, or search off
    self.searchButton.enabled = !self.isSearchOn;
    self.refreshHeaderView.hidden = self.isSearchOn;
    [self forceSearchBarCancelButtonToBeEnabled];
    if (self.isSearchOn) {
        // New mode is search on
        // Clear all previous search results / terms etc
        [self.coreDataModel deleteRegularEventsFromSearch];
        [self.eventsFromSearch removeAllObjects];
        self.mySearchBar.text = @"";
        [UIView animateWithDuration:0.25 animations:^{
//            CGRect myTableViewFrame = self.tableView.frame;
//            myTableViewFrame.origin.y -= self.filtersBackgroundView.frame.size.height;
//            myTableViewFrame.size.height += self.filtersBackgroundView.frame.size.height;
//            self.tableView.frame = myTableViewFrame;
//            CGRect filtersBackgroundViewFrame = self.filtersBackgroundView.frame;
//            filtersBackgroundViewFrame.origin.y -= self.filtersBackgroundView.frame.size.height;
//            self.filtersBackgroundView.frame = filtersBackgroundViewFrame;
            CGRect searchBarFrame = self.mySearchBar.frame;
            searchBarFrame.origin.y += searchBarFrame.size.height;
            self.mySearchBar.frame = searchBarFrame;
        }];
//        self.filtersBackgroundView.userInteractionEnabled = NO;
        [self resignFirstResponder];
        [self.mySearchBar becomeFirstResponder];
        problemViewWasShowing = self.problemViewIsShowing;
        [self hideProblemViewAnimated:NO];
    } else {
        // New mode is search off
        [UIView animateWithDuration:0.25 animations:^{
//            CGRect myTableViewFrame = self.tableView.frame;
//            myTableViewFrame.origin.y += self.filtersBackgroundView.frame.size.height;
//            myTableViewFrame.size.height -= self.filtersBackgroundView.frame.size.height;
//            self.tableView.frame = myTableViewFrame;
//            CGRect filtersBackgroundViewFrame = self.filtersBackgroundView.frame;
//            filtersBackgroundViewFrame.origin.y += self.filtersBackgroundView.frame.size.height;
//            self.filtersBackgroundView.frame = filtersBackgroundViewFrame;
            CGRect searchBarFrame = self.mySearchBar.frame;
            searchBarFrame.origin.y -= searchBarFrame.size.height;
            self.mySearchBar.frame = searchBarFrame;
        }];
//        self.filtersBackgroundView.userInteractionEnabled = YES;
        [self.mySearchBar resignFirstResponder];
        [self becomeFirstResponder];
        if (problemViewWasShowing) { [self showProblemViewAnimated:NO]; }
    }
    [self.tableView reloadData];
}

- (void) forceSearchBarCancelButtonToBeEnabled {
	for (UIView *possibleButton in mySearchBar.subviews)
	{
		if ([possibleButton isKindOfClass:[UIButton class]])
		{
			UIButton * cancelButton = (UIButton*)possibleButton;
			cancelButton.enabled = YES;
			break;
		}
	}
}

- (IBAction) searchButtonPressed:(id)sender  {
    
    if (self.isDrawerOpen) {
        [self toggleDrawerAnimated];
    }
    [self toggleSearchMode];

}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar  {
    [self toggleSearchMode];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.webConnector getEventsListForSearchString:self.mySearchBar.text];
    [self showWebLoadingViews];
	//[self searchlist];
	[self.mySearchBar resignFirstResponder];
    [self forceSearchBarCancelButtonToBeEnabled];
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
                cell.locationLabel.text = [cell.locationLabel.text stringByAppendingFormat:@" & %d more locations", [placeCount intValue] - 1];
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
    
    self.cardPageViewController = [[[EventViewController alloc] init] autorelease];
    self.cardPageViewController.coreDataModel = self.coreDataModel;
    self.cardPageViewController.delegate = self;
    self.cardPageViewController.hidesBottomBarWhenPushed = YES;
    
    Event * event = (Event *)[self.eventsForCurrentSource objectAtIndex:indexPath.row];
    
    self.cardPageViewController.event = event;
    
    self.indexPathOfSelectedRow = indexPath;
    [self.webConnector sendLearnedDataAboutEvent:event.uri withUserAction:@"V"]; // Going to wait on this until we know that we have an internet connection. Honestly, there's no point in displaying a blank CardPageViewController, showing an internet error message, and then popping the user back out. So, for now, I am just going to use the response from the learned data web send to know whether we have an internet connection or not. This is sort of a hack. Change / come back to this later.
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    if ([userAction isEqualToString:@"V"] && self.cardPageViewController) {
        [self.navigationController pushViewController:self.cardPageViewController animated:YES];
        //[self presentModalViewController:self.cardPageViewController animated:YES];
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
    
    [self hideWebLoadingViews];
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"V"] && self.cardPageViewController) {
        NSLog(@"foo");
        if (![self.connectionErrorStandardAlertView isVisible]) {
            NSLog(@"foospecial");
            [self.connectionErrorStandardAlertView show];            
        }
        //[self presentModalViewController:self.cardPageViewController animated:YES];
    } else if ([userAction isEqualToString:@"X"]) {
        [self.connectionErrorOnDeleteAlertView show];
    }
    
    [self hideWebLoadingViews];
    
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
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = keyboardSize.height;
    self.tableView.contentInset = insets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = 0;
    self.tableView.contentInset = insets;
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

    // REFRESH HEADER VIEW
    // It shouldn't be a problem if the refresh header view was not being used before, but we still call this code. Don't worry about it for now.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.top = self.filtersSummaryAndSearchContainerView.frame.size.height;
    self.tableView.contentInset = contentInset;
    [UIView commitAnimations];
    [self.refreshHeaderView setState:EGOOPullRefreshNormal];
    
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

- (EventsFilter *) filterForPositionX:(CGFloat)x {
    EventsFilter * matchingFilter = nil;
    x = MAX(0, MIN(x, self.drawerScrollView.contentSize.width));
    NSLog(@"%f", x);
    for (EventsFilter * filter in self.filters) {
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
    EventsFilter * swipedOverFilter = [self filterForPositionX:[swipeGesture locationInView:swipeGesture.view].x];
    NSLog(@"swipeDownToShowDrawer for button with title %@", self.activeFilterInUI.button.titleLabel.text);
    if (!self.isDrawerOpen) {
        self.activeFilterInUI = swipedOverFilter;
        [self setDrawerToShowFilter:self.activeFilterInUI animated:self.isDrawerOpen];
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
    }
}

- (IBAction) priceFilterOptionButtonTouched:(id)sender {
    EventsFilterOption * filterOption = [self filterOptionForFilterOptionButton:sender inFilterOptionsArray:[self filterForFilterButton:self.filterButtonPrice].options];
    self.selectedPriceFilterOption = filterOption;
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
}
- (IBAction) dateFilterOptionButtonTouched:(id)sender {
    EventsFilterOption * filterOption = [self filterOptionForFilterOptionButton:sender inFilterOptionsArray:[self filterForFilterButton:self.filterButtonDate].options];
    self.selectedDateFilterOption = filterOption;
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
}
- (IBAction) timeFilterOptionButtonTouched:(id)sender {
    EventsFilterOption * filterOption = [self filterOptionForFilterOptionButton:sender inFilterOptionsArray:[self filterForFilterButton:self.filterButtonTime].options];
    self.selectedTimeFilterOption = filterOption;
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
}
- (IBAction) locationFilterOptionButtonTouched:(id)sender {
    EventsFilterOption * filterOption = [self filterOptionForFilterOptionButton:sender inFilterOptionsArray:[self filterForFilterButton:self.filterButtonLocation].options];
    self.selectedLocationFilterOption = filterOption;
    [self updateFiltersSummaryLabelWithCurrentSelectedFilterOptions];
}

- (void) updateFiltersSummaryLabelWithCurrentSelectedFilterOptions {
    
    NSString * priceReadable = self.selectedPriceFilterOption.readable;
    NSString * dateReadable = self.selectedDateFilterOption.readable;
    NSString * categoryReadable = self.categoryURI ? [self.coreDataModel getCategoryWithURI:self.categoryURI].title : nil;
    NSString * timeReadable = self.selectedTimeFilterOption.readable;
    NSString * locationReadable = self.selectedLocationFilterOption.readable;
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
    [compositeString replaceOccurrencesOfString:@"You are looking at events." withString:@"Use the filters above to narrow in on the type of events you're interested in." options:0 range:NSMakeRange(0, compositeString.length)];

    self.filtersSummaryLabel.text = compositeString;
    
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
