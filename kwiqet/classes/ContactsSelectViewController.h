//
//  ContactsSelectViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "FacebookManager.h"

@protocol ContactsSelectViewControllerDelegate;

@interface ContactsSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * doneSelectingButton;
    IBOutlet UIButton * logoButton;
    
    IBOutlet UIView * tabsBar;
    IBOutlet UIButton * friendsTabButton;
    IBOutlet UIButton * selectedTabButton;
    
    IBOutlet UIView * searchContainerView;
    IBOutlet UINavigationBar * searchNavBarBack;
    IBOutlet UIBarButtonItem * searchCancelButton;
    IBOutlet UISearchBar * searchBar;
    
    IBOutlet UITableView * _friendsTableView;
    IBOutlet UITableView * _selectedTableView;
    
    NSArray * contactsAll;
    NSMutableArray * contactsFiltered;
    NSMutableArray * contactsSelected;
    NSMutableDictionary * contactsGrouped;
    
    id<ContactsSelectViewControllerDelegate> delegate;
    
    BOOL _isSearchOn;
    
    FacebookManager * facebookManager;
    
}

@property (assign) id<ContactsSelectViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray * contactsAll;
@property (retain) NSMutableArray * contactsFiltered;
@property (retain) NSMutableArray * contactsSelected;
@property (readonly) NSMutableDictionary * contactsGrouped;
@property (readonly) NSArray * alphabetArray;
@property (nonatomic, readonly) FacebookManager * facebookManager;

@end

@protocol ContactsSelectViewControllerDelegate <NSObject>

- (void) contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts;

@end