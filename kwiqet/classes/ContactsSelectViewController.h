//
//  ContactsSelectViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol ContactsSelectViewControllerDelegate;

@interface ContactsSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    
    IBOutlet UIBarButtonItem * cancelButton;
    IBOutlet UIBarButtonItem * doneSelectingButton;
    IBOutlet UITableView * _tableView;
    IBOutlet UISearchBar * searchBar;
    IBOutlet UISearchDisplayController *searchDisplayController;
    
    NSArray * contacts;
    NSMutableArray * contactsFiltered;
    NSMutableArray * contactsSelected;
    
    id<ContactsSelectViewControllerDelegate> delegate;
    
}

@property (assign) id<ContactsSelectViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray * contacts;
@property (retain) NSMutableArray * contactsFiltered;
@property (retain) NSMutableArray * contactsSelected;

@end

@protocol ContactsSelectViewControllerDelegate <NSObject>

- (void) contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts;

@end