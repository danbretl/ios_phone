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
#import "WebActivityView.h"
#import "CoreDataModel.h"
#import "FacebookProfilePictureGetter.h"
#import "UIImageView+WebCache.h"

@protocol ContactsSelectViewControllerDelegate;

@interface ContactsSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FacebookProfilePictureGetterDelegate> {
    
    IBOutlet UIView * navBar;
    IBOutlet UIButton * cancelButton;
    IBOutlet UIButton * doneSelectingButton;
    IBOutlet UIButton * logoButton;
    
    IBOutlet UIView * tabsBar;
    IBOutlet UIButton * showAllFriendsTabButton;
    IBOutlet UIImageView * showAllFriendsTabButtonBorder;
    IBOutlet UIButton * showSelectedFriendsTabButton;
    
    IBOutlet UIView * searchContainerView;
    IBOutlet UINavigationBar * searchNavBarBack;
    IBOutlet UIBarButtonItem * searchCancelButton;
    IBOutlet UISearchBar * searchBar;
    
    IBOutlet UITableView * _friendsTableView;
    IBOutlet UITableView * _selectedTableView;
    
    NSArray * contactsAll;
    NSArray * contactsFiltered;
    NSMutableArray * contactsSelected;
    NSMutableDictionary * contactsGrouped;
    
    id<ContactsSelectViewControllerDelegate> delegate;
    
    BOOL _isSearchOn;
    
    FacebookManager * facebookManager;
    WebActivityView * webActivityView;
    BOOL _isLoadingContacts;

    NSMutableDictionary * profilePictureDownloaders;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (assign) id<ContactsSelectViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray * contactsAll;
@property (retain) NSArray * contactsFiltered;
@property (retain) NSMutableArray * contactsSelected;
@property (readonly) NSMutableDictionary * contactsGrouped;
@property (readonly) NSArray * alphabetArray;
@property (nonatomic, readonly) FacebookManager * facebookManager;
- (void) showWebActivityView;
- (void) hideWebActivityView;
- (void) setShowSelectedTabButtonVisible:(BOOL)selectedVisible animated:(BOOL)animated;

@end

@protocol ContactsSelectViewControllerDelegate <NSObject>

- (void) contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts;

@end