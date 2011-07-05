//
//  ContactsSelectViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactsSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    
    IBOutlet UITableView * _tableView;
    IBOutlet UISearchBar * searchBar;
    IBOutlet UISearchDisplayController *searchDisplayController;
    
    NSArray * contacts;
    NSMutableArray * contactsFiltered;
    NSMutableArray * contactsSelected;
        
}

@property (nonatomic, retain) NSArray * contacts;
@property (retain) NSMutableArray * contactsFiltered;
@property (retain) NSMutableArray * contactsSelected;

@end
