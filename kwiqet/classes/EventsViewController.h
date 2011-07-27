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
    IBOutlet UIScrollView * drawerScrollView;
    IBOutlet UIView * drawerViewsContainer;
    IBOutlet UIView * drawerViewCategories;
    IBOutlet UIView * drawerViewPrice;
    IBOutlet UIView * drawerViewDate;
    IBOutlet UIView * drawerViewLocation;
    IBOutlet UIView * drawerViewTime;
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