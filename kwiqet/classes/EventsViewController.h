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
#import "FacebookManager.h"

extern float const EVENTS_TABLE_VIEW_BACKGROUND_COLOR_WHITE_AMOUNT;

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIAlertViewDelegate, CardPageViewControllerDelegate, WebConnectorDelegate> {
    
	UITableView * myTableView;
    UIView * tableFooterView;
    
	NSMutableArray * events;
	NSMutableArray * eventsFromSearch;
    
    NSString * filterString;
    NSString * categoryURI;
    NSString * filterStringProposed;
    NSString * categoryURIProposed;
    
    UIView   * filtersBackgroundView;
    UIButton * recommendedFilterButton;
    UIButton * freeFilterButton;
    UIButton * popularFilterButton;
    
    UIButton * logoButton;
	
    CoreDataModel * coreDataModel;
    
    UIView * problemView;
    UILabel * problemLabel;
    
	EGORefreshTableHeaderView *refreshHeaderView;
	
    BOOL isCategoriesDrawerOpen;
	
    WebActivityView * webActivityView;
    UIView * categoriesBackgroundView;
    UIView * selectedFilterView;
    
    NSArray * concreteParentCategoriesArray;
    NSDictionary * concreteParentCategoriesDictionary; // Dictionary of Category objects, with their URI's as their keys.
    
    WebConnector * webConnector;
    UIAlertView * connectionErrorStandardAlertView;
    UIAlertView * connectionErrorOnDeleteAlertView;
    WebDataTranslator * webDataTranslator;
    
    EventViewController * cardPageViewController;
    
    NSIndexPath * indexPathOfRowAttemptingToDelete;
    NSIndexPath * indexPathOfSelectedRow;
    
    BOOL isSearchOn;
	UISearchBar * mySearchBar;
    UIButton * searchButton;
    
    BOOL problemViewWasShowing;
    
    FacebookManager * facebookManager;

}

@property (nonatomic, retain) FacebookManager * facebookManager;
@property (nonatomic, retain) CoreDataModel *coreDataModel;
//- (void) suggestToReloadEventsList; // This method is only a "suggestion" to the object because if the object determines it doesn't NEED to try to get a new featured event from the web, then it will simply ignore the request. (It ignores the request if the date of the last events list web-get was the same day as "today" i.e. the day of the method call.)
- (void) suggestToRedrawEventsList;
- (void) forceToReloadEventsList;

@end