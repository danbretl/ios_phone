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
#import "LocalyticsSession.h"

static NSString * const EVENTS_FILTER_RECOMMENDED = @"recommended";
static NSString * const EVENTS_FILTER_FREE = @"free";
static NSString * const EVENTS_FILTER_POPULAR = @"popular";
static NSString * const EVENTS_FILTER_RECOMMENDED_BUTTON_IMAGE = @"btn_recommend";
static NSString * const EVENTS_FILTER_FREE_BUTTON_IMAGE = @"btn_free";
static NSString * const EVENTS_FILTER_POPULAR_BUTTON_IMAGE = @"btn_popular";
static NSString * const EVENTS_FILTER_BUTTON_HIGHLIGHT_POSTFIX = @"_over";
static NSString * const EVENTS_FILTER_BUTTON_EXTENSION = @".png";

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

- (void) webConnectGetEventsListWithCurrentFilterAndCategory;
- (void) webConnectGetEventsListWithFilter:(NSString *)theProposedFilterString categoryURI:(NSString *)theProposedCategoryURI;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (IBAction)filterButtonPressed:(id)sender;
- (void)toggleCategoriesDrawerAnimated; 
- (void)categoryButtonPressed:(UIButton *)categoryButton;
- (void)homeButtonPressed;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)showWebLoadingViews;
- (void)hideWebLoadingViews;
- (void) showProblemViewNoEventsForFilter:(NSString *)forFilterString categoryTitle:(NSString *)categoryTitle animated:(BOOL)animated;
- (void) showProblemViewBadConnectionAnimated:(BOOL)animated;
- (void) hideProblemViewAnimated:(BOOL)animated;
- (void) showProblemViewAnimated:(BOOL)animated;
- (void) setProblemViewVisible:(BOOL)showView withMessage:(NSString *)message animated:(BOOL)animated;
- (NSString *) filterCodeForFilterButton:(UIButton *)filterButton;
- (void) highlightFilterButton:(UIButton *)filterButton;
- (void) highlightFilterButtonForFilter:(NSString *)filterCode;
- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable;
- (void) dataSourceEventsUpdated:(NSNotification *)notification;
- (void) setLogoButtonImageWithImageNamed:(NSString *)imageName;
- (void) setLogoButtonImageForCategoryURI:(NSString *)categoryURI;
- (void) setSelectedFilterViewToFilterString:(NSString *)theFilterString animated:(BOOL)animated;
- (void) loginActivity:(NSNotification *)notification;
- (void) behaviorWasReset:(NSNotification *)notification;

@property (nonatomic, readonly) UIAlertView * connectionErrorStandardAlertView;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnDeleteAlertView;
@property (nonatomic, copy) NSString * filterString;
@property (nonatomic, copy) NSString * categoryURI;
@property (copy) NSString * filterStringProposed;
@property (copy) NSString * categoryURIProposed;
@property (readonly) BOOL problemViewShowing;
@property (retain) UIView * problemView;
@property (retain) UILabel * problemLabel;
@property (retain) UIButton * searchButton;
@property (retain) UIButton * logoButton;
@property (nonatomic, retain) UITableView * myTableView;
@property (nonatomic, retain) NSIndexPath * indexPathOfRowAttemptingToDelete;
@property (nonatomic, retain) NSIndexPath * indexPathOfSelectedRow;
@property (nonatomic, retain) EventViewController * cardPageViewController;
@property (nonatomic, retain) WebActivityView * webActivityView;
@property (nonatomic, retain) UIView * filtersBackgroundView;
@property (nonatomic, retain) UIButton * recommendedFilterButton;
@property (nonatomic, retain) UIButton * freeFilterButton;
@property (nonatomic, retain) UIButton * popularFilterButton;
@property (nonatomic, retain) UIView * categoriesBackgroundView;
@property (nonatomic, retain) UIView * selectedFilterView;
@property (nonatomic, readonly) NSDictionary * concreteParentCategoriesDictionary;
@property (nonatomic, readonly) NSArray * concreteParentCategoriesArray;
@property (nonatomic, readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, readonly) WebConnector * webConnector;
// Search-related
@property (nonatomic, retain)   UISearchBar *mySearchBar;
@property BOOL isSearchOn;
- (IBAction)searchButtonPressed:(id)sender;
- (void) forceSearchBarCancelButtonToBeEnabled;
- (void) toggleSearchMode;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, retain) NSMutableArray * events;
@property (nonatomic, retain) NSMutableArray * eventsFromSearch;
@property (nonatomic, readonly) NSMutableArray * eventsForCurrentSource;
@property (retain) UIView * tableFooterView;
@property (retain) UIButton * calendarButton;
@end

@implementation EventsViewController
@synthesize myTableView,mySearchBar,eventsFromSearch, events,coreDataModel,webActivityView,concreteParentCategoriesDictionary,freeFilterButton,recommendedFilterButton,popularFilterButton,categoriesBackgroundView, selectedFilterView, filtersBackgroundView;
@synthesize refreshHeaderView, concreteParentCategoriesArray;
@synthesize filterString, categoryURI, filterStringProposed, categoryURIProposed;
@synthesize isSearchOn;
@synthesize problemView, problemLabel;
@synthesize cardPageViewController;
@synthesize indexPathOfRowAttemptingToDelete, indexPathOfSelectedRow, searchButton;
@synthesize logoButton, tableFooterView;
@synthesize calendarButton;
//@synthesize facebookManager;

- (void)dealloc {
    [filtersBackgroundView release];
    [categoriesBackgroundView release];
    [selectedFilterView release];
    [recommendedFilterButton release];
    [freeFilterButton release];
    [popularFilterButton release];
    [concreteParentCategoriesDictionary release];
    [concreteParentCategoriesArray release];
	[myTableView release];
	[mySearchBar release];
	[eventsFromSearch release];
	[events release];
    [coreDataModel release];
	[refreshHeaderView release];
	[webActivityView release];
    [filterString release];
    [categoryURI release];
    [filterStringProposed release];
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
    [logoButton release];
    [tableFooterView release];
    [calendarButton release];
//    [facebookManager release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Create categories background view under UITableView
    self.categoriesBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 255)] autorelease];
    self.categoriesBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay.png"]];
    self.categoriesBackgroundView.userInteractionEnabled = NO;
    self.categoriesBackgroundView.layer.masksToBounds = YES;
    
    // Selected filter view
    self.selectedFilterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 640, 12)] autorelease];
    self.selectedFilterView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cat_overlay-sel.png"]];
    self.selectedFilterView.opaque = NO;
    [self.categoriesBackgroundView addSubview:self.selectedFilterView];
    
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
            if (y == 0 && x == 0) {
                [categoryButton setBackgroundImage:[UIImage imageNamed:@"btn_cat_all.png"] forState: UIControlStateNormal];
                [[categoryButton layer] setCornerRadius:12.0f];
                [[categoryButton layer] setMasksToBounds:YES];
                categoryButton.tag = -1;
                categoryTitleLabel.text = @"All Categories";
            } else {
                //set icon image here
                Category * category = (Category *)[self.concreteParentCategoriesArray objectAtIndex:index-1];
                categoryTitleLabel.text = category.title;
                [categoryButton setBackgroundImage:[UIImage imageNamed:category.buttonThumb] forState: UIControlStateNormal];
                categoryButton.tag = index-1;
            }
            [categoryButton addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            categoryTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
            categoryTitleLabel.textAlignment = UITextAlignmentCenter;
            categoryTitleLabel.backgroundColor = [UIColor clearColor];
            [categoryBackgroundView addSubview:categoryTitleLabel];
            [categoryBackgroundView addSubview:categoryButton];
            [self.categoriesBackgroundView addSubview:categoryBackgroundView];
            [categoryTitleLabel release];
            [categoryButton release];
            [categoryBackgroundView release];
            
            index = index + 1;
        }
    }
    
    [self.view addSubview:categoriesBackgroundView];
    
    // Create filter buttons area - recommended (default), free, popular
    self.filtersBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 36)] autorelease];
//    self.filtersBackgroundView.userInteractionEnabled = YES;

    CGFloat filterButtonHeight = 36.0;
    self.recommendedFilterButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 107, filterButtonHeight)] autorelease];
    self.freeFilterButton = [[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.recommendedFilterButton.frame), 0, 106, filterButtonHeight)] autorelease];
    self.popularFilterButton = [[[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.freeFilterButton.frame), 0, 107, filterButtonHeight)] autorelease];

    [recommendedFilterButton setBackgroundImage:[UIImage imageNamed:@"btn_recommend.png"] forState: UIControlStateNormal];
    [freeFilterButton setBackgroundImage:[UIImage imageNamed:@"btn_free.png"] forState: UIControlStateNormal];
    [popularFilterButton setBackgroundImage:[UIImage imageNamed:@"btn_popular.png"] forState: UIControlStateNormal];

    recommendedFilterButton.tag = 1;
    freeFilterButton.tag = 2;
    popularFilterButton.tag = 3;

    [recommendedFilterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [freeFilterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [popularFilterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.filtersBackgroundView addSubview:recommendedFilterButton];
    [self.filtersBackgroundView addSubview:freeFilterButton];
    [self.filtersBackgroundView addSubview:popularFilterButton];
    [self.view addSubview:self.filtersBackgroundView];
        
	// Create the UITableView
    self.myTableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 80, 320, 332)] autorelease];
	self.myTableView.rowHeight = 76;
	self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.myTableView.separatorColor = [UIColor clearColor]; // Unnecessary, considering we set separatorStyle to UITableViewCellSeparatorStyleNone?
	self.myTableView.dataSource = self;
	self.myTableView.delegate = self;
    self.myTableView.backgroundColor = [UIColor colorWithWhite:EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT alpha:1.0];
    self.myTableView.showsVerticalScrollIndicator = YES;
    
//    // UITableView Footer View
//    tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.myTableView.bounds.size.width, self.filtersBackgroundView.bounds.size.height)];
//    UIButton * reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    reloadButton.frame = self.tableFooterView.bounds;
//    [reloadButton setTitle:@"Load new list of events" forState:UIControlStateNormal];
//    [reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//    reloadButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:20];
//    reloadButton.backgroundColor = [UIColor clearColor];
//    [reloadButton addTarget:self action:@selector(webConnectGetEventsListWithCurrentFilterAndCategory) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableFooterView addSubview:reloadButton];
//    self.myTableView.tableFooterView = self.tableFooterView;
////    self.myTableView.tableFooterView.hidden = YES;
    	
	//nav bar with buttons
	UIImageView * navBar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navbar_blank.png"]];
	navBar.frame = CGRectMake(0, 0, 320, 44);
	
	UIButton * categoriesDrawerButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 5,74,32)];
	[categoriesDrawerButton setBackgroundImage:[UIImage imageNamed:@"btn_filter.png"] forState: UIControlStateNormal];
	[categoriesDrawerButton addTarget:self action:@selector(categoriesDrawerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	self.logoButton = [[[UIButton alloc]initWithFrame:CGRectMake(135,3,53,38)] autorelease];
	[self.logoButton addTarget:self action:@selector(homeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self setLogoButtonImageWithImageNamed:@"logo_btn_cat_all.png"];
    
    self.calendarButton = [[[UIButton alloc] initWithFrame:CGRectMake(238,5,32,32)] autorelease];
    [self.calendarButton setBackgroundImage:[UIImage imageNamed:@"btn_calendar.png"] forState: UIControlStateNormal];
    self.calendarButton.hidden = YES;
    self.calendarButton.userInteractionEnabled = NO;
	
	self.searchButton = [[[UIButton alloc]initWithFrame:CGRectMake(280,5,32,32)] autorelease];
	[self.searchButton setBackgroundImage:[UIImage imageNamed:@"btn_search.png"] forState: UIControlStateNormal];
	[self.searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	//add nav bar and table view to view
	[self.view addSubview:myTableView];	
	[self.view addSubview:navBar];
	[self.view addSubview:categoriesDrawerButton];
	[self.view addSubview:logoButton];
	[self.view addSubview:self.searchButton];
    [self.view addSubview:self.calendarButton];
	
	//clean up
	[categoriesDrawerButton release];
	[logoButton release];
	[searchButton release];
	[navBar release];
    
    // Search bar
	self.mySearchBar = [[[UISearchBar alloc]initWithFrame:CGRectMake(0, -44, 320, 44)] autorelease];
	self.mySearchBar.showsCancelButton = YES;
	self.mySearchBar.delegate = self;
    self.mySearchBar.tintColor = [UIColor blackColor]; // Nice! So easy.
	[self.view addSubview:mySearchBar];
	
	// Pull table initialization
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.myTableView.bounds.size.height, 320.0f, self.myTableView.bounds.size.height)];
//    self.refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.refreshHeaderView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.refreshHeaderView.bottomBorderThickness = 0.0;
    [self.refreshHeaderView setLastRefreshDate:[DefaultsModel loadLastEventsListGetDate]];
    [self.myTableView addSubview:self.refreshHeaderView];
    
    // Create the "no results" view
    self.problemView = [[UIView alloc] initWithFrame:CGRectMake(/*self.myTableView.frame.origin.x + */20.0, /*self.myTableView.frame.origin.y + */70.0, self.myTableView.frame.size.width - 40.0, 100.0)];
    self.problemView.backgroundColor = [UIColor clearColor];//[UIColor whiteColor];
//    self.noResultsView.layer.cornerRadius = 20.0;
//    self.noResultsView.layer.masksToBounds = YES;
//    self.noResultsView.layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
//    self.noResultsView.layer.borderWidth = 1.0;
    [self.myTableView addSubview:self.problemView];
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
    
    self.filterString = EVENTS_FILTER_RECOMMENDED;
    [self highlightFilterButtonForFilter:EVENTS_FILTER_RECOMMENDED];
    self.categoryURI = nil;
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
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
    
    [self webConnectGetEventsListWithCurrentFilterAndCategory]; // Don't need to reloadData until we get a response back from this web connection attempt.
    
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
    [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES]; // There is something weird going on with the animation - it is going really slowly. Figure this out later. It doesn't look horrible right now though, so, I'm just going to leave it.
    
    if (self.webConnector.connectionInProgress) {
        [self showWebLoadingViews];
    } else if ([self.eventsForCurrentSource count] == 0) {
        if (self.isSearchOn) {
            // Not going to do anything on this path for now... Just leave the list blank?
        } else {
            [self webConnectGetEventsListWithCurrentFilterAndCategory];
        }
    } else {
        // Not worried about this path currently...
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        if (!self.isSearchOn) {
            NSLog(@"Shake to reload");
            [self webConnectGetEventsListWithCurrentFilterAndCategory];
        }
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)setLogoButtonImageWithImageNamed:(NSString *)imageName {
//    NSLog(@"setlogobuttonimagewithimagenamed: %@", imageName);
    [self.logoButton setBackgroundImage:[UIImage imageNamed:imageName] forState: UIControlStateNormal];
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

- (void) setSelectedFilterViewToFilterString:(NSString *)theFilterString animated:(BOOL)animated {
    
    void (^shiftSelectedFilterViewFrame) (void) = ^{
        UIButton * filterButton = nil;
        if ([theFilterString isEqualToString:EVENTS_FILTER_RECOMMENDED]) {
            filterButton = self.recommendedFilterButton;
        } else if ([theFilterString isEqualToString:EVENTS_FILTER_FREE]) {
            filterButton = self.freeFilterButton;
        } else if ([theFilterString isEqualToString:EVENTS_FILTER_POPULAR]) {
            filterButton = self.popularFilterButton;
        } else {
            NSLog(@"ERROR in EventsViewController setSelectedFilterViewToFilterString - unrecognized filterString");
        }
        CGRect selectedFilterViewFrame = self.selectedFilterView.frame;
        selectedFilterViewFrame.origin.x = filterButton.frame.origin.x + (filterButton.frame.size.width - self.selectedFilterView.frame.size.width) / 2.0;
        self.selectedFilterView.frame = selectedFilterViewFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:shiftSelectedFilterViewFrame];
    } else {
        shiftSelectedFilterViewFrame();
    }

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

- (void) webConnectGetEventsListWithCurrentFilterAndCategory {
//    NSLog(@"EventsViewController webConnectGetEventsListWithCurrentFilterAndCategory");
    [self webConnectGetEventsListWithFilter:self.filterString categoryURI:self.categoryURI];
}

- (void) webConnectGetEventsListWithFilter:(NSString *)theProposedFilterString categoryURI:(NSString *)theProposedCategoryURI {
//    NSLog(@"EventsViewController webConnectGetEventsListWithFilter");
    self.filterStringProposed = theProposedFilterString;
    self.categoryURIProposed = theProposedCategoryURI;
    [self showWebLoadingViews];
    [self.webConnector getEventsListWithFilter:self.filterStringProposed categoryURI:self.categoryURIProposed];
    
    /////////////////////
    // Localytics below
    NSMutableDictionary * localyticsDictionary = [NSMutableDictionary dictionary];
    NSString * localyticsFilterString = @"recommended";
    if (theProposedFilterString) { 
        localyticsFilterString = theProposedFilterString;
    }
    [localyticsDictionary setValue:localyticsFilterString forKey:@"filter"]; 
    NSString * localyticsCategoryString = @"all";
    if (theProposedCategoryURI) {
        Category * category = [self.coreDataModel getCategoryWithURI:theProposedCategoryURI];
        localyticsCategoryString = category.title;
    }
    [localyticsDictionary setValue:localyticsCategoryString forKey:@"category"];
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Test - Get Events" attributes:localyticsDictionary];
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
    self.filterString = self.filterStringProposed;
    [self highlightFilterButtonForFilter:self.filterString];
    self.categoryURI = self.categoryURIProposed;
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
    self.filterStringProposed = nil;
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
    self.filterString = self.filterStringProposed;
    [self highlightFilterButtonForFilter:self.filterString];
    self.categoryURI = self.categoryURIProposed;
    [self setLogoButtonImageForCategoryURI:self.categoryURI];
    self.filterStringProposed = nil;
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
    
    [self.myTableView reloadData];
    [self.myTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    if (self.eventsForCurrentSource && [self.eventsForCurrentSource count] > 0) {
        // Events were retrieved... They will be displayed.
        [self hideProblemViewAnimated:NO];
    } else {
        // No events were retrieved. Respond accordingly, depending on the reason.
        if ([resultsDetail isEqualToString:EVENTS_UPDATED_USER_INFO_RESULTS_DETAIL_NO_RESULTS]) {
            if (!fromSearch) {
                Category * category = (Category *)[self.concreteParentCategoriesDictionary objectForKey:self.categoryURI];
                [self showProblemViewNoEventsForFilter:self.filterString categoryTitle:category.title animated:NO];
            } else {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"No results" message:@"Sorry, we couldn't find any events matching your search." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
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

- (void) showProblemViewNoEventsForFilter:(NSString *)forFilterString categoryTitle:(NSString *)categoryTitle animated:(BOOL)animated {
    
    NSString * message = nil;
    
    if (forFilterString && categoryTitle) {
        message = [NSString stringWithFormat:@"Sorry, we couldn't find any\n%@ events for you\nin %@.\nTry a different combination.", forFilterString/*[forFilterString capitalizedString]*/, categoryTitle];
    } else if (forFilterString || categoryTitle) {
        NSString * modifier = forFilterString ? forFilterString : categoryTitle;
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

//// This method is not really applicable anymore in my opinion... 
//- (void) suggestToReloadEventsList {
//    
//    NSDate * lastReloadDate = [DefaultsModel loadLastEventsListGetDate];
//    NSDate * nowDate = [NSDate date];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
//    NSString * lastReloadDateString = [dateFormatter stringFromDate:lastReloadDate];
//    NSString * nowDateString = [dateFormatter stringFromDate:nowDate];
//    [dateFormatter release];
//    
//    if (![lastReloadDateString isEqualToString:nowDateString]) {
//        [self forceToReloadEventsList];
//    }
//
//}

- (void) suggestToRedrawEventsList {

    NSDate * lastReloadDate = [DefaultsModel loadLastEventsListGetDate];
    NSDate * nowDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    BOOL lastReloadDateWasToday = [[dateFormatter stringFromDate:lastReloadDate] isEqualToString:[dateFormatter stringFromDate:nowDate]];
    [dateFormatter release];
    
    if (!lastReloadDateWasToday) {
        NSLog(@"Redrawing events list");
        [self.myTableView reloadData];
    }

}

- (void) forceToReloadEventsList {
    [self webConnectGetEventsListWithCurrentFilterAndCategory];
}

#pragma mark popularity tab
-(void)filterButtonPressed:(UIButton *)filterButton {
    
    [self highlightFilterButton:filterButton];
    NSString * filterCode = [self filterCodeForFilterButton:filterButton];
    [self webConnectGetEventsListWithFilter:filterCode categoryURI:self.categoryURI];

}

- (NSString *) filterCodeForFilterButton:(UIButton *)filterButton {
    NSString * filterCode = nil;
    if (filterButton == self.recommendedFilterButton) {
        filterCode = EVENTS_FILTER_RECOMMENDED;
    } else if (filterButton == self.freeFilterButton) {
        filterCode = EVENTS_FILTER_FREE;
    } else if (filterButton == self.popularFilterButton) {
        filterCode = EVENTS_FILTER_POPULAR;
    } else {
        NSLog(@"ERROR in EventsViewController - unrecognized filter button");
        filterCode = @"ERRORERRORERROR";
    }
    return filterCode;
}

- (void) highlightFilterButton:(UIButton *)filterButton {
    NSString * filterCode = [self filterCodeForFilterButton:filterButton];
    [self highlightFilterButtonForFilter:filterCode];
}

- (void) highlightFilterButtonForFilter:(NSString *)filterCode {
    
    BOOL highlightRecommended = [filterCode isEqualToString:EVENTS_FILTER_RECOMMENDED];
    BOOL highlightFree = [filterCode isEqualToString:EVENTS_FILTER_FREE];
    BOOL highlightPopular = [filterCode isEqualToString:EVENTS_FILTER_POPULAR];
    
    if (!(highlightRecommended || highlightFree || highlightPopular)) {
        
        NSLog(@"ERROR in EventsViewController - unrecognized filter button filter code");
        
    } else {
        
        NSString * recommendedHighlightString = highlightRecommended ? EVENTS_FILTER_BUTTON_HIGHLIGHT_POSTFIX : @"";
        NSString * freeHighlightString = highlightFree ? EVENTS_FILTER_BUTTON_HIGHLIGHT_POSTFIX : @"";
        NSString * popularHighlightString = highlightPopular ? EVENTS_FILTER_BUTTON_HIGHLIGHT_POSTFIX : @"";
        NSString * recommendedImageString = [NSString stringWithFormat:@"%@%@%@", 
                                             EVENTS_FILTER_RECOMMENDED_BUTTON_IMAGE, 
                                             recommendedHighlightString, 
                                             EVENTS_FILTER_BUTTON_EXTENSION];
        NSString * freeImageString = [NSString stringWithFormat:@"%@%@%@", 
                                      EVENTS_FILTER_FREE_BUTTON_IMAGE, 
                                      freeHighlightString, 
                                      EVENTS_FILTER_BUTTON_EXTENSION];
        NSString * popularImageString = [NSString stringWithFormat:@"%@%@%@", 
                                         EVENTS_FILTER_POPULAR_BUTTON_IMAGE, 
                                         popularHighlightString, 
                                         EVENTS_FILTER_BUTTON_EXTENSION];
        [self.recommendedFilterButton setBackgroundImage:[UIImage imageNamed:recommendedImageString]
                                                forState:UIControlStateNormal];
        [self.freeFilterButton setBackgroundImage:[UIImage imageNamed:freeImageString] 
                                         forState:UIControlStateNormal];
        [self.popularFilterButton setBackgroundImage:[UIImage imageNamed:popularImageString] 
                                            forState:UIControlStateNormal];
        
    }
    
    [self setSelectedFilterViewToFilterString:filterCode animated:YES];
    
}

// Pulling the table down enough triggers a web reload.
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
				  willDecelerate:(BOOL)decelerate {
    
	if (!self.isSearchOn && scrollView.contentOffset.y <= -65.0f) {

        [self.refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.myTableView.contentInset = UIEdgeInsetsMake(65.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
        [self webConnectGetEventsListWithCurrentFilterAndCategory];

	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isSearchOn) {
        if (scrollView.contentOffset.y <= -65.0f) {
            [self.refreshHeaderView setState:EGOOPullRefreshPulling];
        } else {
            [self.refreshHeaderView setState:EGOOPullRefreshNormal];
        }
    }
}

-(void)homeButtonPressed  {
    if (isCategoriesDrawerOpen) {
        [self toggleCategoriesDrawerAnimated];
    }
    [self webConnectGetEventsListWithCurrentFilterAndCategory];
}

- (IBAction) categoriesDrawerButtonPressed:(id)sender {
	[self toggleCategoriesDrawerAnimated];
}

-(void)toggleCategoriesDrawerAnimated {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
    
    if (isCategoriesDrawerOpen == NO) {
        isCategoriesDrawerOpen = YES;
        CGRect tableViewFrame = self.myTableView.frame;
        tableViewFrame.origin.y += self.categoriesBackgroundView.frame.size.height;
        self.myTableView.frame = tableViewFrame;
        [self setTableViewScrollable:NO selectable:NO];
    }
    else {
        isCategoriesDrawerOpen = NO;
        CGRect tableViewFrame = self.myTableView.frame;
        tableViewFrame.origin.y -= self.categoriesBackgroundView.frame.size.height;
        self.myTableView.frame = tableViewFrame;
        [self setTableViewScrollable:YES selectable:YES];
    }
    self.categoriesBackgroundView.userInteractionEnabled = isCategoriesDrawerOpen;
    
    [UIView commitAnimations];
}

- (void) setTableViewScrollable:(BOOL)scrollable selectable:(BOOL)selectable {
    self.myTableView.scrollEnabled = scrollable;
    self.myTableView.allowsSelection = selectable;
}

-(void)categoryButtonPressed:(UIButton *)categoryButton {
    
    // Get the category for the categoryButton pushed
    // Do a web load with that category (and with whatever filter we're currently using)
    
    if (isCategoriesDrawerOpen) {
        [self toggleCategoriesDrawerAnimated];
    }
    
    int categoryButtonTag = categoryButton.tag;
    NSString * theSelectedCategoryURI = nil;
    if (categoryButtonTag != -1) {
        // Specific category
        int concreteParentCategoryIndex = categoryButtonTag;
        NSDictionary * categoryDictionary = [self.concreteParentCategoriesArray objectAtIndex:concreteParentCategoryIndex];
        theSelectedCategoryURI = [categoryDictionary valueForKey:@"uri"];
    }

    [self webConnectGetEventsListWithFilter:self.filterString categoryURI:theSelectedCategoryURI];
    
}

- (BOOL)problemViewShowing {
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
            CGRect myTableViewFrame = self.myTableView.frame;
            myTableViewFrame.origin.y -= self.filtersBackgroundView.frame.size.height;
            myTableViewFrame.size.height += self.filtersBackgroundView.frame.size.height;
            self.myTableView.frame = myTableViewFrame;
            CGRect filtersBackgroundViewFrame = self.filtersBackgroundView.frame;
            filtersBackgroundViewFrame.origin.y -= self.filtersBackgroundView.frame.size.height;
            self.filtersBackgroundView.frame = filtersBackgroundViewFrame;
            CGRect searchBarFrame = self.mySearchBar.frame;
            searchBarFrame.origin.y += searchBarFrame.size.height;
            self.mySearchBar.frame = searchBarFrame;
        }];
        self.filtersBackgroundView.userInteractionEnabled = NO;
        [self resignFirstResponder];
        [self.mySearchBar becomeFirstResponder];
        problemViewWasShowing = self.problemViewShowing;
        [self hideProblemViewAnimated:NO];
    } else {
        // New mode is search off
        [UIView animateWithDuration:0.25 animations:^{
            CGRect myTableViewFrame = self.myTableView.frame;
            myTableViewFrame.origin.y += self.filtersBackgroundView.frame.size.height;
            myTableViewFrame.size.height -= self.filtersBackgroundView.frame.size.height;
            self.myTableView.frame = myTableViewFrame;
            CGRect filtersBackgroundViewFrame = self.filtersBackgroundView.frame;
            filtersBackgroundViewFrame.origin.y += self.filtersBackgroundView.frame.size.height;
            self.filtersBackgroundView.frame = filtersBackgroundViewFrame;
            CGRect searchBarFrame = self.mySearchBar.frame;
            searchBarFrame.origin.y -= searchBarFrame.size.height;
            self.mySearchBar.frame = searchBarFrame;
        }];
        self.filtersBackgroundView.userInteractionEnabled = YES;
        [self.mySearchBar resignFirstResponder];
        [self becomeFirstResponder];
        if (problemViewWasShowing) { [self showProblemViewAnimated:NO]; }
    }
    [self.myTableView reloadData];
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
    
    if (isCategoriesDrawerOpen) {
        [self toggleCategoriesDrawerAnimated];
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

    static NSString * CellIdentifier = @"EventCellGeneral_v2_WithIcons";
    
    EventTableViewCell * cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event * event = (Event *)[self.eventsForCurrentSource objectAtIndex:indexPath.row];
    
    NSString * title = event.title;
    Category * concreteParentCategory = event.concreteParentCategory;
    NSString * location = event.venue;
    NSString * address = event.summaryAddress;
    NSString * summaryStartDateEarliestString = event.summaryStartDateEarliestString;
    NSString * summaryStartDateLatestString = event.summaryStartDateLatestString;
    NSNumber * summaryStartDateDistinctCount = event.summaryStartDateDistinctCount;
    NSString * summaryStartTimeEarliestString = event.summaryStartTimeEarliestString;
    NSString * summaryStartTimeLatestString = event.summaryStartTimeLatestString;
    NSNumber * summaryStartTimeDistinctCount = event.summaryStartTimeDistinctCount;
    NSNumber * summaryPlaceDistinctCount = event.summaryPlaceDistinctCount;
    NSNumber * priceMin = event.priceMinimum;
    NSNumber * priceMax = event.priceMaximum;
    
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
            if ([summaryPlaceDistinctCount intValue] > 1) {
                cell.locationLabel.text = [cell.locationLabel.text stringByAppendingFormat:@" & %d more locations", [summaryPlaceDistinctCount intValue] - 1];
            }
        } else {
            cell.locationLabel.text = address;
        }
    } else {
        cell.locationLabel.text = @"Location not available";
    }

    
    NSString * dateToDisplay = [self.webDataTranslator eventsListDateRangeStringFromEventDateEarliest:summaryStartDateEarliestString eventDateLatest:summaryStartDateLatestString eventDateDistinctCount:summaryStartDateDistinctCount relativeDates:YES dataUnavailableString:nil];
    NSString * timeToDisplay = [self.webDataTranslator eventsListTimeRangeStringFromEventTimeEarliest:summaryStartTimeEarliestString eventTimeLatest:summaryStartTimeLatestString eventTimeDistinctCount:summaryStartTimeDistinctCount dataUnavailableString:nil];
    
    NSString * divider = summaryStartDateEarliestString && summaryStartTimeEarliestString ? @" | " : @"";
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
//    self.cardPageViewController.facebookManager = self.facebookManager;
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
        [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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
        if ([self.myTableView indexPathForSelectedRow]) {
            [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO]; // This may not always be appropriate, and perhaps we should check to see if we really want to do this depending on why the connection error alert view was shown in the first place, BUT I can't really see how it will hurt things for now.
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
        [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathOfSelectedRow] withRowAnimation:UITableViewRowAnimationFade];
        
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
    UIEdgeInsets insets = self.myTableView.contentInset;
    insets.bottom = keyboardSize.height;
    self.myTableView.contentInset = insets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.myTableView.contentInset;
    insets.bottom = 0;
    self.myTableView.contentInset = insets;
}

- (void)loginActivity:(NSNotification *)notification {
//    NSLog(@"EventsViewController loginActivity");
    //NSString * action = [[notification userInfo] valueForKey:@"action"]; // We don't really care whether the user just logged in or logged out - we should get new events list no matter what.
    if (self.isSearchOn) {
        [self toggleSearchMode];
    }
    if (isCategoriesDrawerOpen) {
        [self toggleCategoriesDrawerAnimated];
    }
    [self webConnectGetEventsListWithFilter:EVENTS_FILTER_RECOMMENDED categoryURI:nil];
}

- (void) behaviorWasReset:(NSNotification *)notification {
    if (self.isSearchOn) {
        [self toggleSearchMode];
    }
    if (isCategoriesDrawerOpen) {
        [self toggleCategoriesDrawerAnimated];
    }
    [self webConnectGetEventsListWithFilter:EVENTS_FILTER_RECOMMENDED categoryURI:nil];
}

#pragma mark color

-(void) showWebLoadingViews  {
    if (self.view.window) {
        
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        
        // USER INTERACTION
        myTableView.userInteractionEnabled = NO;
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
    UIEdgeInsets contentInset = self.myTableView.contentInset;
    contentInset.top = 0.0f;
    self.myTableView.contentInset = contentInset;
    [UIView commitAnimations];
    [self.refreshHeaderView setState:EGOOPullRefreshNormal];
    
    // USER INTERACTION
    self.myTableView.userInteractionEnabled = YES; // Enable user interaction
    self.view.userInteractionEnabled = YES;

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
