//
//  EventsViewController.h
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataModel.h"
#import "WebConnector.h"
#import "EventViewController.h"
#import "EventTableViewCell.h"
#import "WebDataTranslator.h"
#import "WebActivityView.h"
#import "EventsFilter.h"
#import "EventsFilterOption.h"
#import "SegmentedHighlighterView.h"
#import "UIButtonWithOverlayView.h"
#import "EventsWebQuery.h"
#import "EventsFeedbackView.h"
#import <CoreLocation/CoreLocation.h>
#import "SetLocationViewController.h"
#import "LocationUpdatedFeedbackView.h"
#import "LocationUtil.h"
#import "KwiqetLocationManager.h"

typedef enum {
    Browse = 1,
    Search = 2,
} EventsListMode;

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CardPageViewControllerDelegate, WebConnectorDelegate, UIScrollViewDelegate, UITextFieldDelegate, SetLocationViewControllerDelegate, KwiqetLocationManagerDelegate> {
    
    ///////////
    // Models
    
    EventsListMode listMode;
    EventsWebQuery * eventsWebQuery;
    EventsWebQuery * eventsWebQueryFromSearch;
	NSMutableArray * events;
	NSMutableArray * eventsFromSearch;
    NSArray * concreteParentCategoriesArray;
    NSDictionary * concreteParentCategoriesDictionary; // Dictionary of Category objects, with their URI's as their keys.
    CoreDataModel * coreDataModel_;
    
    //////////////////
    // "View models"
    NSArray * filters;
    EventsFilter * activeFilterInUI;
    EventsFilterOption * selectedPriceFilterOption;
    EventsFilterOption * selectedDateFilterOption;
    EventsFilterOption * selectedTimeFilterOption;
    EventsFilterOption * selectedLocationFilterOption;
    EventsFilterOption * selectedCategoryFilterOption;
    NSArray * filtersSearch;
    EventsFilter * activeSearchFilterInUI;
    NSMutableArray * adjustedSearchFiltersOrdered; // Ordered most recently adjusted to least recently adjusted. If a filter does not exist in this array, then it has not been adjusted from its "most general" option.
    EventsFilterOption * selectedDateSearchFilterOption;
    EventsFilterOption * selectedTimeSearchFilterOption;
    EventsFilterOption * selectedLocationSearchFilterOption;
    BOOL isDrawerOpen;
    BOOL shouldReloadOnDrawerClose;
    BOOL isSearchOn;
    EventsFeedbackMessageType feedbackMessageTypeBrowseRemembered;
    EventsFeedbackMessageType feedbackMessageTypeSearchRemembered;
    NSString * oldFilterString;
    NSString * categoryURI;
    NSIndexPath * indexPathOfRowAttemptingToDelete;
    NSIndexPath * indexPathOfSelectedRow;
    CGPoint tableViewContentOffsetPreserved;
    BOOL feedbackViewIsVisible_;
    NSString * eventsSummaryStringBrowse;
    NSString * eventsSummaryStringSearch;
    BOOL deletedFromEventCard;
    BOOL userRequestedToShowLocationSetter_;
    NSString * searchTermSaved_;
    BOOL searchTextFieldWasFirstResponder_;
    BOOL drawerWasOpen_;
    BOOL shouldHaveReloadedOnDrawerClose_;

    //////////
    // Views
    
	IBOutlet UITableView * tableView_;
    UIView * tableViewCoverViewContainer;
    UIView * tableViewCoverView;
    UIView * tableViewBackgroundViewContainer;
    UIView * tableViewStaticHeightBackgroundView;
    UIView * tableViewHeaderForSearch;
    UIView * tableViewFooterForSearch;
    IBOutlet UIImageView * tableViewBackgroundView;
    IBOutlet UIView   * searchContainerView;
    IBOutlet UIView   * searchContainerViewShadowCheatView;
    IBOutlet UIView * searchContainerTopEdgeView;
    IBOutlet UIView * searchContainerTopAboveView;
    IBOutlet UIButton * searchButton;
    IBOutlet UIButton * searchCancelButton;
    IBOutlet UIButton * searchGoButton;
    IBOutlet UITextField * searchTextField;
    IBOutlet UIView   * tableReloadContainerView;
    IBOutlet UIView   * tableReloadContainerShadowCheatView;
    IBOutlet UIView   * pushableContainerView;
    IBOutlet UIView   * pushableContainerShadowCheatView;
    //
    IBOutlet EventsFeedbackView * feedbackView;
    //
    IBOutlet UIView   * filtersContainerView;
    IBOutlet UIView   * filtersContainerShadowCheatView;
    IBOutlet UIView   * filtersContainerShadowCheatWayBelowView;
    IBOutlet SegmentedHighlighterView * activeFilterHighlightsContainerView;
    IBOutlet UIScrollView * drawerScrollView;
    //
    IBOutlet UIView   * filtersBarBrowse;
    IBOutlet UIButton * filterButtonCategories;
    IBOutlet UIButton * filterButtonPrice;
    IBOutlet UIButton * filterButtonDate;
    IBOutlet UIButton * filterButtonLocation;
    IBOutlet UIButton * filterButtonTime;
    //
    IBOutlet UIView   * filtersBarSearch;
    IBOutlet UIButton * filterSearchButtonDate;
    IBOutlet UIButton * filterSearchButtonLocation;
    IBOutlet UIButton * filterSearchButtonTime;
    //
    IBOutlet UIView * drawerViewsBrowseContainer;
    IBOutlet UIView * drawerViewsSearchContainer;
    // Drawer view price
    IBOutlet UIView * drawerViewPrice;
    IBOutlet UIButtonWithOverlayView * dvPriceButtonFree;
    IBOutlet UIButtonWithOverlayView * dvPriceButtonUnder20;
    IBOutlet UIButtonWithOverlayView * dvPriceButtonUnder50;
    IBOutlet UIButtonWithOverlayView * dvPriceButtonAny;
    // Drawer view date
    IBOutlet UIView * drawerViewDate;
    IBOutlet UIButtonWithOverlayView * dvDateButtonToday;
    IBOutlet UIButtonWithOverlayView * dvDateButtonThisWeekend;
    IBOutlet UIButtonWithOverlayView * dvDateButtonThisWeek;
    IBOutlet UIButtonWithOverlayView * dvDateButtonThisMonth;
    IBOutlet UIButtonWithOverlayView * dvDateButtonAny;
    // Drawer view date search
    IBOutlet UIView * drawerViewDateSearch;
    IBOutlet UIButtonWithOverlayView * dvDateSearchButtonToday;
    IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisWeekend;
    IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisWeek;
    IBOutlet UIButtonWithOverlayView * dvDateSearchButtonThisMonth;
    IBOutlet UIButtonWithOverlayView * dvDateSearchButtonAny;
    // Drawer view categories
    IBOutlet UIView * drawerViewCategories;
    // Drawer view time
    IBOutlet UIView * drawerViewTime;
    IBOutlet UIButtonWithOverlayView * dvTimeButtonMorning;
    IBOutlet UIButtonWithOverlayView * dvTimeButtonAfternoon;
    IBOutlet UIButtonWithOverlayView * dvTimeButtonEvening;
    IBOutlet UIButtonWithOverlayView * dvTimeButtonNight;
    IBOutlet UIButtonWithOverlayView * dvTimeButtonAny;
    // Drawer view time search
    IBOutlet UIView * drawerViewTimeSearch;
    IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonMorning;
    IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonAfternoon;
    IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonEvening;
    IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonNight;
    IBOutlet UIButtonWithOverlayView * dvTimeSearchButtonAny;
    // Drawer view location
    IBOutlet UIView * drawerViewLocation;
    IBOutlet UIButton * dvLocationSetLocationButton;
    IBOutlet UIButtonWithOverlayView * dvLocationCurrentLocationButton;
    IBOutlet LocationUpdatedFeedbackView * dvLocationUpdatedView;
    IBOutlet UIButtonWithOverlayView * dvLocationButtonWalking;
    IBOutlet UIButtonWithOverlayView * dvLocationButtonNeighborhood;
    IBOutlet UIButtonWithOverlayView * dvLocationButtonBorough;
    IBOutlet UIButtonWithOverlayView * dvLocationButtonCity;
    // Drawer view location search
    IBOutlet UIView * drawerViewLocationSearch;
    IBOutlet UIButton * dvLocationSearchSetLocationButton;
    IBOutlet UIButtonWithOverlayView * dvLocationSearchCurrentLocationButton;
    IBOutlet LocationUpdatedFeedbackView * dvLocationSearchUpdatedView;
    IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonWalking;
    IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonNeighborhood;
    IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonBorough;
    IBOutlet UIButtonWithOverlayView * dvLocationSearchButtonCity;
    // Location setter views
    SetLocationViewController * setLocationViewController_;
    // Assorted views
    WebActivityView * webActivityView;
    UIAlertView * connectionErrorStandardAlertView;
    UIAlertView * connectionErrorOnDeleteAlertView;
    UIAlertView * resetAllFiltersAlertView;
    // Gesture Recognizers
    UITapGestureRecognizer * tapToHideDrawerGR;
    // Debugging
    UITextView * debugTextView;
    
    /////////////////////
    // View Controllers
    
    EventViewController * cardPageViewController;
    
    ////////
    // Web
    
    WebConnector * webConnector;
    WebDataTranslator * webDataTranslator;
    
    /////////////
    // Location
    
    LocationMode locationMode_;
    UserLocation * userLocationMostRecent_;
    KwiqetLocationManager * locationManager_;
    BOOL shouldSuppressAutoLocationFailureAlerts_;
    BOOL webLoadWaitingForUpdatedUserLocation_;

}

//////////////////////
// Public properties

@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, retain) KwiqetLocationManager * locationManager;
@property (retain) UserLocation * userLocationMostRecent;

///////////////////
// Public methods

- (void) suggestToRedrawEventsList;
- (void) forceToReloadEventsList;

@end