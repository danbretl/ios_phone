//
//  EventsViewController.h
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CoreDataModel.h"
#import "EGORefreshTableHeaderView.h"
#import "WebConnector.h"
#import "EventViewController.h"
#import "EventTableViewCell.h"
#import "WebDataTranslator.h"
#import "WebActivityView.h"
#import "EventsFilter.h"
#import "EventsFilterOption.h"
#import "SegmentedHighlighterView.h"

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate, CardPageViewControllerDelegate, WebConnectorDelegate, UIScrollViewDelegate> {
    
    ///////////
    // Models
    
	NSMutableArray * events;
	NSMutableArray * eventsFromSearch;
    NSArray * concreteParentCategoriesArray;
    NSDictionary * concreteParentCategoriesDictionary; // Dictionary of Category objects, with their URI's as their keys.
    CoreDataModel * coreDataModel;
    
    //////////////////
    // "View models"

    NSMutableArray * filters;
    EventsFilter * activeFilterInUI;
    EventsFilterOption * selectedPriceFilterOption;
    EventsFilterOption * selectedDateFilterOption;
    EventsFilterOption * selectedTimeFilterOption;
    EventsFilterOption * selectedLocationFilterOption;
    BOOL isDrawerOpen;
    BOOL isSearchOn;
    BOOL problemViewWasShowing;
    NSString * oldFilterString;
    NSString * categoryURI;
    NSString * oldFilterStringProposed;
    NSString * categoryURIProposed;
    NSIndexPath * indexPathOfRowAttemptingToDelete;
    NSIndexPath * indexPathOfSelectedRow;

    //////////
    // Views
    
	IBOutlet UITableView * tableView_;
    IBOutlet UIView   * pushableContainerView;
    IBOutlet UIView   * filtersSummaryAndSearchContainerView;
    IBOutlet UILabel  * filtersSummaryLabel;
    IBOutlet UIView   * searchButtonContainerView;
    IBOutlet UIButton * searchButton;
    IBOutlet UIView   * filtersContainerView;
    IBOutlet UIButton * filterButtonCategories;
    IBOutlet UIButton * filterButtonPrice;
    IBOutlet UIButton * filterButtonDate;
    IBOutlet UIButton * filterButtonLocation;
    IBOutlet UIButton * filterButtonTime;
    IBOutlet SegmentedHighlighterView * activeFilterHighlightsContainerView;
    IBOutlet UIScrollView * drawerScrollView;
    IBOutlet UIView * drawerViewsContainer;
    // Drawer view price
    IBOutlet UIView * drawerViewPrice;
    IBOutlet UIButton * dvPriceButtonFree;
    IBOutlet UIButton * dvPriceButtonUnder20;
    IBOutlet UIButton * dvPriceButtonUnder50;
    IBOutlet UIButton * dvPriceButtonAny;
    // Drawer view date
    IBOutlet UIView * drawerViewDate;
    IBOutlet UIButton * dvDateButtonToday;
    IBOutlet UIButton * dvDateButtonThisWeekend;
    IBOutlet UIButton * dvDateButtonThisWeek;
    IBOutlet UIButton * dvDateButtonThisMonth;
    IBOutlet UIButton * dvDateButtonAny;
    // Drawer view categories
    IBOutlet UIView * drawerViewCategories;
    // Drawer view time
    IBOutlet UIView * drawerViewTime;
    IBOutlet UIButton * dvTimeButtonMorning;
    IBOutlet UIButton * dvTimeButtonAfternoon;
    IBOutlet UIButton * dvTimeButtonEvening;
    IBOutlet UIButton * dvTimeButtonNight;
    IBOutlet UIButton * dvTimeButtonAny;
    // Drawer view location
    IBOutlet UIView * drawerViewLocation;
    IBOutlet UITextField * dvLocationTextField;
    IBOutlet UIButton * dvLocationButtonWalking;
    IBOutlet UIButton * dvLocationButtonNeighborhood;
    IBOutlet UIButton * dvLocationButtonBorough;
    IBOutlet UIButton * dvLocationButtonCity;
	UISearchBar * mySearchBar;
	EGORefreshTableHeaderView *refreshHeaderView;
    WebActivityView * webActivityView;
    UIView * problemView;
    UILabel * problemLabel;
    EventViewController * cardPageViewController;
    UIAlertView * connectionErrorStandardAlertView;
    UIAlertView * connectionErrorOnDeleteAlertView;
    
    ////////
    // Web
    
    WebConnector * webConnector;
    WebDataTranslator * webDataTranslator;

}

//////////////////////
// Public properties

@property (nonatomic, retain) CoreDataModel *coreDataModel;

///////////////////
// Public methods

- (void) suggestToRedrawEventsList;
- (void) forceToReloadEventsList;

@end