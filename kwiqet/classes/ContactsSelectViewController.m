//
//  ContactsSelectViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactsSelectViewController.h"

@interface ContactsSelectViewController()
@property (retain) UIView * navBar;
@property (retain) UIButton * cancelButton;
@property (retain) UIButton * doneSelectingButton;
@property (retain) UIButton * logoButton;
@property (retain) UIView * tabsBar;
@property (retain) UIButton * friendsTabButton;
@property (retain) UIButton * selectedTabButton;
@property (retain) UIView * searchContainerView;
@property (retain) UISearchBar * searchBar;
@property (retain) UINavigationBar * searchNavBarBack;
@property (retain) UIBarButtonItem * searchCancelButton;
@property (retain) UITableView * friendsTableView;
@property (retain) UITableView * selectedTableView;
@property BOOL isSearchOn;
- (void) tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact;
- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath;
- (IBAction) cancelButtonPushed;
- (IBAction) doneSelectingButtonPushed;
- (IBAction) tabButtonPushed:(UIButton *)tabButton;
//- (void) forceSearchBarCancelButtonTitle;
- (void) updateSelectedCountViewWithCount:(int)count;
@end

@implementation ContactsSelectViewController
@synthesize delegate;
@synthesize navBar, cancelButton, doneSelectingButton, logoButton;
@synthesize tabsBar, friendsTabButton, selectedTabButton;
@synthesize searchContainerView, searchBar, searchNavBarBack, searchCancelButton;
@synthesize friendsTableView = _friendsTableView, selectedTableView = _selectedTableView;
@synthesize contactsAll, contactsFiltered, contactsSelected, contactsGrouped;
@synthesize isSearchOn=_isSearchOn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [navBar release];
    [cancelButton release];
    [doneSelectingButton release];
    [logoButton release];
    [tabsBar release];
    [friendsTabButton release];
    [selectedTabButton release];
    [searchContainerView release];
    [searchBar release];
    [searchNavBarBack release];
    [searchCancelButton release];
    [_friendsTableView release];
    [_selectedTableView release];
    [contactsAll release];
    [contactsFiltered release];
    [contactsSelected release];
    [contactsGrouped release];
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
    [self.friendsTableView reloadData];
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    self.friendsTableView.tableHeaderView = self.searchContainerView;
    if ([self.friendsTableView numberOfRowsInSection:0]) {
        [self.friendsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    [self updateSelectedCountViewWithCount:0];
    // Do any additional setup after loading the view from its nib.
//    [self forceSearchBarCancelButtonTitle];
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

- (void)setContactsAll:(NSArray *)theContacts {
    NSLog(@"ContactsSelectViewController setContacts");
    if (contactsAll != theContacts) {
        [contactsAll release];
        contactsAll = [theContacts retain];
        self.contactsFiltered = [NSMutableArray arrayWithCapacity:[contactsAll count]];
        self.contactsSelected = [NSMutableArray arrayWithCapacity:[contactsAll count]];
        for (Contact * contact in contactsAll) {
            NSString * firstLetterUppercase = [[contact.fbName substringToIndex:1] uppercaseString];
            NSMutableArray * group = [self.contactsGrouped objectForKey:firstLetterUppercase];
            if (!group) {
                group = [self.contactsGrouped objectForKey:@"#"];
            }
            [group addObject:contact];
        }
    }
    NSLog(@"ContactsSelectViewController setContacts finished");
}

- (NSMutableDictionary *) contactsGrouped {
    if (contactsGrouped == nil) {
        NSArray * theAlphabetArray = self.alphabetArray;
        contactsGrouped = [[NSMutableDictionary dictionaryWithCapacity:[theAlphabetArray count]] retain];
        for (int alphabetIndex = 0; alphabetIndex < [theAlphabetArray count]; alphabetIndex++) {
            [contactsGrouped setObject:[NSMutableArray array] forKey:[theAlphabetArray objectAtIndex:alphabetIndex]];
        }
    }
    return contactsGrouped;
}

- (NSArray *)alphabetArray {
    return [NSArray arrayWithObjects:
            @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", 
            @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", 
            @"U", @"V", @"W", @"X", @"Y", @"Z", @"#",
            nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 1;
    if (tableView == self.friendsTableView && !self.isSearchOn) {
        numberOfSections = [self.alphabetArray count];
    }
    return numberOfSections;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray * sectionIndexTitlesArray = nil;
    if (tableView == self.friendsTableView && !self.isSearchOn) {
        sectionIndexTitlesArray = [NSMutableArray arrayWithArray:self.alphabetArray];
        [sectionIndexTitlesArray insertObject:UITableViewIndexSearch atIndex:0];
    }
    return sectionIndexTitlesArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger returnIndex = index - 1;
    if (index == 0) {
        [tableView scrollRectToVisible:[[tableView tableHeaderView] bounds] animated:NO];
        returnIndex = -1;
    }
    return returnIndex;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * titleForHeader = nil;
    if (tableView == self.friendsTableView && !self.isSearchOn) {
        titleForHeader = [self.alphabetArray objectAtIndex:section];
    }
    return titleForHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (tableView == self.friendsTableView) {
        if (self.isSearchOn) {
            numberOfRows = [self.contactsFiltered count];
        } else {
            NSString * c = [self.alphabetArray objectAtIndex:section];
            NSArray * group = [self.contactsGrouped objectForKey:c];
            numberOfRows = [group count];
        }
    } else {
        numberOfRows = [self.contactsSelected count];
    }
    
    return numberOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * contactsArray = nil;
    if (tableView == self.friendsTableView) {
        if (self.isSearchOn) {
            contactsArray = self.contactsFiltered;
        } else {
            NSString * c = [self.alphabetArray objectAtIndex:indexPath.section];
            contactsArray = [self.contactsGrouped objectForKey:c];
        }
    } else {
        contactsArray = self.contactsSelected;
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
    cell.accessoryType = [self.contactsSelected containsObject:contact] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
}

- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = accessoryType;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * contactsArrayTouched = nil;
    if (tableView == self.friendsTableView) {
        if (self.isSearchOn) {
            contactsArrayTouched = self.contactsFiltered;
        } else {
            NSString * c = [self.alphabetArray objectAtIndex:indexPath.section];
            contactsArrayTouched = [self.contactsGrouped objectForKey:c];
        }
    } else {
        contactsArrayTouched = self.contactsSelected;
    }
    
    Contact * contact = (Contact *)[contactsArrayTouched objectAtIndex:indexPath.row];
    BOOL contactWasSelected = (contactsArrayTouched == self.contactsSelected || 
                               [self.contactsSelected containsObject:contact]);
    
    UITableViewCellAccessoryType accessoryType;
    if (contactWasSelected) {
        [self.contactsSelected removeObject:contact];
        accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.contactsSelected addObject:contact];
        accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self updateSelectedCountViewWithCount:[self.contactsSelected count]];
    
    [self tableView:tableView setCellAccessoryType:accessoryType forCellWithIndexPath:indexPath];
    if (tableView == self.selectedTableView) {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
    
}

- (void) updateSelectedCountViewWithCount:(int)count {
    NSString * buttonText = @"Selected";
    if (count > 0) {
        buttonText = [buttonText stringByAppendingFormat:@" (%d)", count];
    }
    [self.selectedTabButton setTitle:buttonText forState:UIControlStateNormal];
    [self.selectedTabButton setTitle:buttonText forState:UIControlStateHighlighted];
}


- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearchOn = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
//    [UIView animateWithDuration:0.25 
//                     animations:^{
//                         CGRect searchBarFrame = self.searchBar.frame;
//                         searchBarFrame.size.width = 320;
//                         self.searchBar.frame = searchBarFrame;
//                     }];
    self.contactsFiltered = [self.contactsAll mutableCopy];
    [self.friendsTableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearchOn = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
//    [UIView animateWithDuration:0.25 
//                     animations:^{
//                         CGRect searchBarFrame = self.searchBar.frame;
//                         searchBarFrame.size.width = 290;
//                         self.searchBar.frame = searchBarFrame;
//                     }];
    self.searchBar.text = @"";
    [self.friendsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.contactsFiltered removeAllObjects];
    // It seems like the following loop is going to be craaaazy expensive in terms of processing time. What if someone has 1000 friends? How quickly can we loop through those? Time will tell...
    if ([searchText length] > 0) {
        for (Contact * contact in self.contactsAll) {
            NSComparisonResult result = [contact.fbName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame) {
                [self.contactsFiltered insertObject:contact atIndex:[self.contactsFiltered count]];
                //            [self.contactsFiltered addObject:contact];
            }
        }        
    } else {
        self.contactsFiltered = [self.contactsAll mutableCopy];
    }
    [self.friendsTableView reloadData];
//    NSLog(@"%@", self.contactsFiltered);
}

- (void)cancelButtonPushed {
    [self.delegate contactsSelectViewController:self didFinishWithCancel:YES selectedContacts:nil];
}

- (void)doneSelectingButtonPushed {
    [self.delegate contactsSelectViewController:self didFinishWithCancel:NO selectedContacts:self.contactsSelected];
}

- (void)tabButtonPushed:(UIButton *)tabButton {
    if (tabButton == self.friendsTabButton) {
        NSLog(@"Friends tab button touched");
        self.friendsTableView.hidden = NO;
        [self.friendsTableView reloadData];
    } else if (tabButton == self.selectedTabButton) {
        NSLog(@"Selected tab button touched");
        self.friendsTableView.hidden = YES;
        [self.selectedTableView reloadData];
    } else {
        NSLog(@"ERROR in ContactsSelectViewController - unrecognized tabButton");
    }
}

//- (void) forceSetSearchBarCancelButtonAlpha:(float)alpha {
//	for (UIView * possibleButton in self.searchBar.subviews)
//	{
//		if ([possibleButton isKindOfClass:[UIButton class]]) {
//			UIButton * searchBarCancelButton = (UIButton *)possibleButton;
//			searchBarCancelButton.alpha = alpha;
//            NSLog(@"Found button %@", searchBarCancelButton);
//			break;
//		}
//	}
//}

@end
