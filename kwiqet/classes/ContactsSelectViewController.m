//
//  ContactsSelectViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactsSelectViewController.h"

@interface ContactsSelectViewController()
@property (retain) UIBarButtonItem * cancelButton;
@property (retain) UIBarButtonItem * doneSelectingButton;
@property (retain) UITableView * tableView;
@property (retain) UISearchBar * searchBar;
@property (retain) UISearchDisplayController * searchDisplayController;
- (void) tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact;
- (void) tableView:(UITableView *)tableView configureCellWithIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact;
- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath;
- (IBAction) cancelButtonPushed;
- (IBAction) doneSelectingButtonPushed;
@end

@implementation ContactsSelectViewController
@synthesize delegate;
@synthesize cancelButton, doneSelectingButton;
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
    [cancelButton release];
    [doneSelectingButton release];
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
        self.contactsSelected = [NSMutableArray arrayWithCapacity:[contacts count]];
    }
    NSLog(@"ContactsSelectViewController setContacts finished");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * title = nil;
    if (section == 0) {
        NSString * selectedCountString = @"";
//        NSString * selectedCountString = [self.contactsSelected count] ? [NSString stringWithFormat:@" (%d)", [self.contactsSelected count]] : @"";
        title = [NSString stringWithFormat:@"Selected%@", selectedCountString];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0;
    if (indexPath.section == 0) {
        height = 30.0;
    }
    return height;
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
    }
    
    Contact * contact = (Contact *)[contactsArray objectAtIndex:indexPath.row];
    [self tableView:tableView configureCell:cell withIndexPath:indexPath usingContact:contact];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact {
    
    cell.textLabel.text = contact.fbName;
    if (indexPath.section == 0 ||
        [self.contactsSelected containsObject:contact]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void) tableView:(UITableView *)tableView configureCellWithIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self tableView:tableView configureCell:cell withIndexPath:indexPath usingContact:contact];
}

- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = accessoryType;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL searchWasOn = tableView == self.searchDisplayController.searchResultsTableView;
    NSArray * contactsArrayTouched = nil;
    if (indexPath.section == 0) {
        contactsArrayTouched = self.contactsSelected;
    } else {
        /* If the requesting table view is the search display controller's table view, return the count of the filtered list, otherwise return the count of the main list. */
        contactsArrayTouched = searchWasOn ? self.contactsFiltered : self.contacts;
    }
    
    Contact * contact = (Contact *)[contactsArrayTouched objectAtIndex:indexPath.row];
    BOOL contactWasSelected = (indexPath.section == 0 || 
                               [self.contactsSelected containsObject:contact]);

    NSIndexPath * indexPathForContactSelected = nil;
    NSIndexPath * indexPathForContactFiltered = nil;
    NSIndexPath * indexPathForContactGeneral  = nil;
    
    if (contactWasSelected) {
        indexPathForContactSelected = indexPath.section == 0 ? indexPath : [NSIndexPath indexPathForRow:[self.contactsSelected indexOfObject:contact] inSection:0];
    } else {
        indexPathForContactSelected = [NSIndexPath indexPathForRow:[self.contactsSelected count] inSection:0];
    }
    
    if (searchWasOn) {
        indexPathForContactFiltered = [NSIndexPath indexPathForRow:[self.contactsFiltered indexOfObject:contact] inSection:1];
    }
    
    indexPathForContactGeneral = [NSIndexPath indexPathForRow:[self.contacts indexOfObject:contact] inSection:1];
    
    NSLog(@"searchWasOn=%d", searchWasOn);
    NSLog(@"contactWasSelected=%d", contactWasSelected);
    NSLog(@"indexPathForContactSelected=%@", indexPathForContactSelected);
    NSLog(@"indexPathForContactFiltered=%@", indexPathForContactFiltered);
    NSLog(@"indexPathForContactGeneral=%@",  indexPathForContactGeneral);
    
    if (contactWasSelected) {
        [self.contactsSelected removeObject:contact];
        if (searchWasOn) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForContactSelected] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForContactSelected] withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        [self.contactsSelected addObject:contact];
        if (searchWasOn) {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForContactSelected] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForContactSelected] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    UITableViewCellAccessoryType accessoryType = contactWasSelected ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    if (searchWasOn) {
        [self tableView:tableView setCellAccessoryType:accessoryType forCellWithIndexPath:indexPathForContactFiltered];
    }
    [self tableView:self.tableView setCellAccessoryType:accessoryType forCellWithIndexPath:indexPathForContactGeneral];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
//    [self performSelector:@selector(foo) withObject:nil afterDelay:0.3]; // THIS IS A HUGE HACK. It's causing some weirdnesses as well. Taking it out.
    
}
     
//- (void) foo {
//    if (self.searchDisplayController.active) {
//        [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    }
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.contactsFiltered removeAllObjects];
    // It seems like the following loop is going to be craaaazy expensive in terms of processing time. What if someone has 1000 friends? How quickly can we loop through those? Time will tell...
    for (Contact * contact in self.contacts) {
        NSComparisonResult result = [contact.fbName compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [self.contactsFiltered insertObject:contact atIndex:[self.contactsFiltered count]];
//            [self.contactsFiltered addObject:contact];
        }
    }
    if ([controller.searchResultsTableView numberOfSections] >= 2 && [controller.searchResultsTableView numberOfRowsInSection:1] >= 1) {
        [controller.searchResultsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    return YES;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"searchDisplayControllerDidEndSearch");
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)cancelButtonPushed {
    [self.delegate contactsSelectViewController:self didFinishWithCancel:YES selectedContacts:nil];
}

- (void)doneSelectingButtonPushed {
    [self.delegate contactsSelectViewController:self didFinishWithCancel:NO selectedContacts:self.contactsSelected];
}

@end
