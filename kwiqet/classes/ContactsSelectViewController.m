//
//  ContactsSelectViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactsSelectViewController.h"

@interface ContactsSelectViewController()
@property (retain) UITableView * tableView;
@property (retain) UISearchBar * searchBar;
@property (retain) UISearchDisplayController * searchDisplayController;
@end

@implementation ContactsSelectViewController

@synthesize tableView = _tableView;
@synthesize searchBar, searchDisplayController;
@synthesize contacts, contactsFiltered, contactsSelected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [searchBar release];
    [searchDisplayController release];
    [contacts release];
    [contactsFiltered release]; 
    [contactsSelected release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setContacts:(NSArray *)theContacts {
    NSLog(@"ContactsSelectViewController setContacts");
    if (contacts != theContacts) {
        [contacts release];
        contacts = [theContacts retain];
        self.contactsFiltered = [NSMutableArray arrayWithCapacity:[contacts count]];
    }
    NSLog(@"ContactsSelectViewController setContacts finished");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * title = nil;
    if (section == 0) {
        title = @"Selected";
    } else {
        title = @"Contacts";
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray * contactsArray = nil;
    if (section == 0) {
        contactsArray = self.contactsSelected;
    } else {
        /* If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list. */
        contactsArray = (tableView == self.searchDisplayController.searchResultsTableView) ? self.contactsFiltered : self.contacts;
    }
    
    return [contactsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * contactsArray = nil;
    if (indexPath.section == 0) {
        contactsArray = self.contactsSelected;
    } else {
        /* If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list. */
        contactsArray = (tableView == self.searchDisplayController.searchResultsTableView) ? self.contactsFiltered : self.contacts;
    }
    
    static NSString * cellID = @"ContactCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    Contact * contact = nil;
    contact = [contactsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.fbName;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"1");
    [self.contactsFiltered removeAllObjects];
    NSLog(@"2");
    // It seems like the following loop is going to be craaaazy expensive in terms of processing time. What if someone has 1000 friends? How quickly can we loop through those? Time will tell...
    for (Contact * contact in self.contacts) {
        NSLog(@"3");
        NSComparisonResult result = [contact.fbName compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [self.contactsFiltered insertObject:contact atIndex:[self.contactsFiltered count]];
//            [self.contactsFiltered addObject:contact];
        }
    }
    return YES;
}

@end
