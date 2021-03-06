//
//  ContactsSelectViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactsSelectViewController.h"
#import "ContactCell.h"
//#import "LocalImagesManager.h"

float const CSVC_TAB_BUTTON_ANIMATION_DURATION = .25;

@interface ContactsSelectViewController()
@property (retain) UIView * navBar;
@property (retain) UIButton * cancelButton;
@property (retain) UIButton * doneSelectingButton;
@property (retain) UIButton * logoButton;
@property (retain) UIView * tabsBar;
@property (retain) UIButton * showAllFriendsTabButton;
@property (retain) UIImageView * showAllFriendsTabButtonBorder;
@property (retain) UIButton * showSelectedFriendsTabButton;
@property (retain) UIView * searchContainerView;
@property (retain) UISearchBar * searchBar;
@property (retain) UINavigationBar * searchNavBarBack;
@property (retain) UIBarButtonItem * searchCancelButton;
@property (retain) UITableView * friendsTableView;
@property (retain) UITableView * selectedTableView;
@property BOOL isSearchOn;
@property (nonatomic, retain) WebActivityView * webActivityView;
@property BOOL isLoadingContacts;
@property (retain) NSMutableDictionary * profilePictureDownloaders;
- (void) tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact;
- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCell:(UITableViewCell *)cell;
- (void) tableView:(UITableView *)tableView setCellPicture:(UIImage *)picture forCellWithIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView setCellPicture:(UIImage *)picture forCell:(UITableViewCell *)cell;
- (IBAction) cancelButtonPushed;
- (IBAction) doneSelectingButtonPushed;
- (IBAction) tabButtonPushed:(UIButton *)tabButton;
//- (void) forceSearchBarCancelButtonTitle;
- (void) updateSelectedCountViewWithCount:(int)count;
- (void) forceSearchBarCancelButtonToBeEnabled;
- (void) forceSetSearchBarCancelButtonTitle:(NSString *)title;
- (void) toggleSearch;
- (void) killScrollForScrollView:(UIScrollView *)scrollView;
- (void) contactsUpdatedLocally:(NSNotification *)notification;
- (void) setSelectedTabButton:(UIButton *)tabButton;
- (void) startProfilePictureDownloadForContact:(Contact *)contact atIndexPath:(NSIndexPath *)indexPath;
- (void) facebookProfilePictureGetterFinished:(FacebookProfilePictureGetter *)profilePictureGetter withImage:(UIImage *)image;
- (void) ignoreAllPendingProfilePictureDownloads;
- (void)facebookAuthFailure:(NSNotification *)notification;
@end

@implementation ContactsSelectViewController
@synthesize delegate;
@synthesize navBar, cancelButton, doneSelectingButton, logoButton;
@synthesize tabsBar, showAllFriendsTabButton, showAllFriendsTabButtonBorder, showSelectedFriendsTabButton;
@synthesize searchContainerView, searchBar, searchNavBarBack, searchCancelButton;
@synthesize friendsTableView = _friendsTableView, selectedTableView = _selectedTableView;
@synthesize contactsAll, contactsFiltered, contactsSelected, contactsGrouped;
@synthesize isSearchOn=_isSearchOn;
@synthesize webActivityView;
@synthesize isLoadingContacts=_isLoadingContacts;
@synthesize coreDataModel;
@synthesize profilePictureDownloaders;

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
    [showAllFriendsTabButton release];
    [showAllFriendsTabButtonBorder release];
    [showSelectedFriendsTabButton release];
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
    facebookManager = nil;
    [facebookManager release];
    [webActivityView release];
    [coreDataModel release];
    [profilePictureDownloaders release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
//    [self ignoreAllPendingProfilePictureDownloads];
}

- (void) ignoreAllPendingProfilePictureDownloads {
    NSArray * allProfilePictureDownloaders = [self.profilePictureDownloaders allValues];
    [allProfilePictureDownloaders makeObjectsPerformSelector:@selector(cancelDownload)];
//    [allProfilePictureDownloaders makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAuthFailure:) name:FBM_AUTH_ERROR_KEY object:nil];
    
//    [LocalImagesManager removeAllFacebookProfilePictures];
    
    self.profilePictureDownloaders = [NSMutableDictionary dictionary];
    
    [self.friendsTableView reloadData];
    self.friendsTableView.scrollsToTop = YES;
    self.selectedTableView.scrollsToTop = NO;
    
    self.navBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    
    self.showAllFriendsTabButton.imageView.contentMode = UIViewContentModeCenter;
    self.showAllFriendsTabButton.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.showAllFriendsTabButton.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self setSelectedTabButton:self.showAllFriendsTabButton];
    
    self.friendsTableView.tableHeaderView = self.searchContainerView;
    if ([self.friendsTableView numberOfRowsInSection:0]) {
        [self.friendsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    [self updateSelectedCountViewWithCount:0];
    self.showSelectedFriendsTabButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:15.0];
    UIEdgeInsets selectedTabButtonTitleEdgeInsets = self.showSelectedFriendsTabButton.titleEdgeInsets;
    selectedTabButtonTitleEdgeInsets.top = 9.0;
    self.showSelectedFriendsTabButton.titleEdgeInsets = selectedTabButtonTitleEdgeInsets;
    [self.showSelectedFriendsTabButton setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.showSelectedFriendsTabButton setTitleColor:[UIColor colorWithWhite:251.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    [self.showSelectedFriendsTabButton setTitleColor:[UIColor colorWithWhite:190.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [self setShowSelectedTabButtonVisible:(self.contactsSelected && [self.contactsSelected count] > 0) animated:NO];
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.frame];
    [self.view addSubview:self.webActivityView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsUpdatedLocally:) name:FBM_FRIENDS_LOCAL_DATA_UPDATED_KEY object:nil];
    self.isLoadingContacts = YES;
    [self.facebookManager updateFacebookFriends];
    
//    [self forceSearchBarCancelButtonTitle];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isLoadingContacts) {
        [self showWebActivityView];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self ignoreAllPendingProfilePictureDownloads];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    [self ignoreAllPendingProfilePictureDownloads];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (FacebookManager *)facebookManager {
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
        [facebookManager pullAuthenticationInfoFromDefaults];
    }
    return facebookManager;
}

- (void)contactsUpdatedLocally:(NSNotification *)notification {
    self.isLoadingContacts = NO;
    self.contactsAll = [self.coreDataModel getAllFacebookContacts];
    [self.friendsTableView reloadData];
    [self hideWebActivityView];
    [self.friendsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];   
}

- (void) showWebActivityView  {
    if (self.view.window) {
        // ACTIVITY VIEWS
        [self.webActivityView showAnimated:NO];
        // USER INTERACTION
        self.doneSelectingButton.userInteractionEnabled = NO;
        self.tabsBar.userInteractionEnabled = NO;
        self.friendsTableView.userInteractionEnabled = NO;
        self.selectedTableView.userInteractionEnabled = NO;
        self.searchContainerView.userInteractionEnabled = NO;
    }
}

- (void) hideWebActivityView  {
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.doneSelectingButton.userInteractionEnabled = YES;
    self.tabsBar.userInteractionEnabled = YES;
    self.friendsTableView.userInteractionEnabled = YES;
    self.selectedTableView.userInteractionEnabled = YES;
    self.searchContainerView.userInteractionEnabled = YES;
}

- (void)setContactsAll:(NSArray *)theContacts {
    NSLog(@"ContactsSelectViewController setContacts");
    if (contactsAll != theContacts) {
        [contactsAll release];
        contactsAll = [theContacts retain];
        self.contactsFiltered = [NSArray array];
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString * titleForHeader = nil;
//    if (tableView == self.friendsTableView && !self.isSearchOn) {
//        titleForHeader = [self.alphabetArray objectAtIndex:section];
//    }
//    return titleForHeader;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeaderView = nil;
    if ([self tableView:tableView numberOfRowsInSection:section] > 0 ||
        self.isSearchOn || 
        tableView == self.selectedTableView) {
        sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)] autorelease];
        UIImageView * shBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider_cell.png"]];
        shBackgroundImageView.frame = sectionHeaderView.bounds;
        [sectionHeaderView addSubview:shBackgroundImageView];
        [shBackgroundImageView release];
        CGFloat shLabelOriginX = 8;
        UILabel * shLabel = [[UILabel alloc] initWithFrame:CGRectMake(shLabelOriginX, -2, tableView.bounds.size.width - shLabelOriginX, 30)];
        shLabel.backgroundColor = [UIColor clearColor];
        shLabel.textAlignment = UITextAlignmentLeft;
        shLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:15.0];
        shLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        shLabel.shadowColor = [UIColor colorWithWhite:0.25 alpha:0.75];
        shLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [sectionHeaderView addSubview:shLabel];
        [shLabel release];
        if (tableView == self.friendsTableView) {
            if (!self.isSearchOn) {
                shLabel.text = [self.alphabetArray objectAtIndex:section];
            } else {
                shLabel.text = @"Search Results";
            }
        } else {
            shLabel.text = @"Selected Friends";
        }    
    }
    return sectionHeaderView;
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
        cell = [[[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
    }
    
    Contact * contact = (Contact *)[contactsArray objectAtIndex:indexPath.row];
    [self tableView:tableView configureCell:cell withIndexPath:indexPath usingContact:contact];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath usingContact:(Contact *)contact {
    
    ContactCell * contactCell = (ContactCell *)cell;
    contactCell.nameLabel.text = contact.fbName;
    UITableViewCellAccessoryType accessoryType = [self.contactsSelected containsObject:contact] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    [self.facebookManager getProfilePictureForFacebookID:contact.fbID];
    [self tableView:tableView setCellAccessoryType:accessoryType forCell:cell];
    
    // Profile picture...
    [contactCell.pictureImageView setImageWithURL:[FacebookProfilePictureGetter urlForFacebookProfilePictureForFacebookID:contact.fbID] placeholderImage:[UIImage imageNamed:@"fbPicturePlaceholder.png"]];
//    FacebookProfilePictureGetter * profilePictureGetter = [self.profilePictureDownloaders objectForKey:indexPath];
//    if (profilePictureGetter != nil &&
//        profilePictureGetter.image != nil) {
//        [self tableView:tableView setCellPicture:profilePictureGetter.image forCell:cell];
//    } else {
//        [self tableView:tableView setCellPicture:nil forCell:cell];
//        [self startProfilePictureDownloadForContact:contact atIndexPath:indexPath];
//    }
    
}

- (void) startProfilePictureDownloadForContact:(Contact *)contact atIndexPath:(NSIndexPath *)indexPath {
    FacebookProfilePictureGetter * profilePictureGetter = [self.profilePictureDownloaders objectForKey:indexPath];
    if (profilePictureGetter == nil) {
        profilePictureGetter = [[[FacebookProfilePictureGetter alloc] init] autorelease];
        profilePictureGetter.indexPathInTableView = indexPath;
        profilePictureGetter.delegate = self;
        profilePictureGetter.facebookID = contact.fbID;
        [self.profilePictureDownloaders setObject:profilePictureGetter forKey:indexPath];
    }
    [profilePictureGetter startDownload];
}

- (void)facebookProfilePictureGetterFinished:(FacebookProfilePictureGetter *)profilePictureGetter withImage:(UIImage *)image {
    [self tableView:self.friendsTableView setCellPicture:image forCellWithIndexPath:profilePictureGetter.indexPathInTableView]; // THIS IS GOING TO MISS THE MARK A LOT OF THE TIME. DEAL WITH THIS LATER.
}

- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCellWithIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self tableView:tableView setCellAccessoryType:accessoryType forCell:cell];
    
}

- (void) tableView:(UITableView *)tableView setCellAccessoryType:(UITableViewCellAccessoryType)accessoryType forCell:(UITableViewCell *)cell {
    
    cell.accessoryType = accessoryType;
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        UIImageView * checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check-icon.png"]];
        cell.accessoryView = checkImageView;
        [checkImageView release];
    } else {
        cell.accessoryView = nil;
    }
    
}

- (void) tableView:(UITableView *)tableView setCellPicture:(UIImage *)picture forCellWithIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [self tableView:tableView setCellPicture:picture forCell:cell];
    
}

- (void) tableView:(UITableView *)tableView setCellPicture:(UIImage *)picture forCell:(UITableViewCell *)cell {
    
    ContactCell * contactCell = (ContactCell *)cell;
    contactCell.picture = picture;
    
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
        if ([self.contactsSelected count] == 0) {
            [self tabButtonPushed:self.showAllFriendsTabButton];
        }
    } else {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
        [self setShowSelectedTabButtonVisible:(self.contactsSelected && [self.contactsSelected count] > 0) animated:YES];
    }
    
}

- (void) updateSelectedCountViewWithCount:(int)count {
    NSLog(@"ContactsSelectViewController updateSelectedCountViewWithCount:%d", count);
    NSString * countText = @"None ";
    NSString * selectedWord = @"Selected";
//    if (count > 0) {
        countText = [NSString stringWithFormat:@"%d ", count];
        selectedWord = [selectedWord capitalizedString];
//    }
    NSString * buttonText = [NSString stringWithFormat:@"%@%@", countText, selectedWord];
//    NSString * buttonText = [NSString stringWithFormat:@"%d", count];
    NSLog(@"%@", self.showSelectedFriendsTabButton);
    [self.showSelectedFriendsTabButton setTitle:buttonText forState:UIControlStateNormal];
    [self.showSelectedFriendsTabButton setTitle:buttonText forState:UIControlStateHighlighted];
    [self.showSelectedFriendsTabButton setTitle:buttonText forState:UIControlStateSelected];
}

- (void)toggleSearch {
    [self.searchBar setShowsCancelButton:!self.isSearchOn animated:YES];
    if (self.isSearchOn) {
        [self.searchBar resignFirstResponder];
        //    [UIView animateWithDuration:0.25 
        //                     animations:^{
        //                         CGRect searchBarFrame = self.searchBar.frame;
        //                         searchBarFrame.size.width = 290;
        //                         self.searchBar.frame = searchBarFrame;
        //                     }];
    } else {
        [self forceSetSearchBarCancelButtonTitle:@"Cancel"];
        //    [UIView animateWithDuration:0.25 
        //                     animations:^{
        //                         CGRect searchBarFrame = self.searchBar.frame;
        //                         searchBarFrame.size.width = 320;
        //                         self.searchBar.frame = searchBarFrame;
        //                     }];
        self.contactsFiltered = self.contactsAll;
    }
    self.isSearchOn = !self.isSearchOn;
    self.searchBar.text = @"";
    [self.friendsTableView reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (!self.isSearchOn) {
        [self toggleSearch];
    } else {
        [self forceSetSearchBarCancelButtonTitle:@"Cancel"];
    }
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    self.isSearchOn = NO;
//    [self.searchBar setShowsCancelButton:NO animated:YES];
////    [UIView animateWithDuration:0.25 
////                     animations:^{
////                         CGRect searchBarFrame = self.searchBar.frame;
////                         searchBarFrame.size.width = 290;
////                         self.searchBar.frame = searchBarFrame;
////                     }];
//    self.searchBar.text = @"";
//    [self.friendsTableView reloadData];
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    [self.contactsFiltered removeAllObjects];
    // It seems like the following loop is going to be craaaazy expensive in terms of processing time. What if someone has 1000 friends? How quickly can we loop through those? Time will tell...
    if ([searchText length] > 0) {
        self.contactsFiltered = [self.contactsAll filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fbName contains[cd] %@", searchText]];// mutableCopy];
    } else {
        self.contactsFiltered = self.contactsAll;//[self.contactsAll mutableCopy];
    }
    [self.friendsTableView reloadData];
//    NSLog(@"%@", self.contactsFiltered);
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    [self toggleSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self.searchBar resignFirstResponder];
    [self forceSetSearchBarCancelButtonTitle:@"Done"];
    [self forceSearchBarCancelButtonToBeEnabled];
}

- (void)cancelButtonPushed {
//    [self ignoreAllPendingProfilePictureDownloads];
    self.facebookManager.ignoreRequestResults = YES;
    [self.delegate contactsSelectViewController:self didFinishWithCancel:YES selectedContacts:nil];
}

- (void)doneSelectingButtonPushed {
//    [self ignoreAllPendingProfilePictureDownloads];
    [self.delegate contactsSelectViewController:self didFinishWithCancel:NO selectedContacts:self.contactsSelected];
}

- (void) killScrollForScrollView:(UIScrollView *)scrollView {
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < 0 ||
        scrollView.contentSize.height <= scrollView.bounds.size.height) { 
        offset.y = 0;
    } else {
        offset.y = MIN(scrollView.contentSize.height - scrollView.bounds.size.height, offset.y);
    }
    [scrollView setContentOffset:offset animated:NO];
    
}

- (void)tabButtonPushed:(UIButton *)tabButton {
    if (self.isSearchOn) {
        [self.searchBar resignFirstResponder];
        [self forceSetSearchBarCancelButtonTitle:@"Done"];
        [self forceSearchBarCancelButtonToBeEnabled];
//        [self toggleSearch];
    }
    UITableView * activeTableView = self.friendsTableView.hidden ? self.selectedTableView : self.friendsTableView;
    [self killScrollForScrollView:activeTableView];
    activeTableView.scrollsToTop = NO;
    if (tabButton == self.showAllFriendsTabButton) {
        NSLog(@"Friends tab button touched");
        self.friendsTableView.hidden = NO;
        [self.friendsTableView reloadData];
        self.friendsTableView.scrollsToTop = YES;
        [self setShowSelectedTabButtonVisible:(self.contactsSelected && [self.contactsSelected count] > 0) animated:YES];
    } else if (tabButton == self.showSelectedFriendsTabButton) {
        NSLog(@"Selected tab button touched");
        self.friendsTableView.hidden = YES;
        [self.selectedTableView reloadData];
        self.selectedTableView.scrollsToTop = YES;
    } else {
        NSLog(@"ERROR in ContactsSelectViewController - unrecognized tabButton");
    }
    [self setSelectedTabButton:tabButton];
}

- (void) setSelectedTabButton:(UIButton *)tabButton {
    if (tabButton == self.showAllFriendsTabButton) {
        
        self.showAllFriendsTabButton.selected = YES;
        self.showSelectedFriendsTabButton.selected = NO;
        self.showAllFriendsTabButton.userInteractionEnabled = NO;
        self.showSelectedFriendsTabButton.userInteractionEnabled = YES;
        
//        [self.showAllFriendsTabButton setImage:[UIImage imageNamed:@"btn_selectall.png"] forState:UIControlStateNormal];
//        [self.showSelectedFriendsTabButton setImage:[UIImage imageNamed:@"btn_selected_notext.png"] forState:UIControlStateNormal];
        
    } else if (tabButton == self.showSelectedFriendsTabButton) {
        
        self.showAllFriendsTabButton.selected = NO;
        self.showSelectedFriendsTabButton.selected = YES;
        self.showAllFriendsTabButton.userInteractionEnabled = YES;
        self.showSelectedFriendsTabButton.userInteractionEnabled = NO;
        
//        [self.showAllFriendsTabButton setImage:[UIImage imageNamed:@"btn_selectall_full_norightborder.png"] forState:UIControlStateNormal];
//        [self.showSelectedFriendsTabButton setImage:[UIImage imageNamed:@"btn_selected_touch_notext.png"] forState:UIControlStateNormal];

    } else {
        NSLog(@"ERROR in ContactsSelectViewController - unrecognized selected tab button");
    }
}

- (void) setShowSelectedTabButtonVisible:(BOOL)selectedVisible animated:(BOOL)animated {

    self.showSelectedFriendsTabButton.userInteractionEnabled = selectedVisible;
    
    void (^frameShiftBlock)(void) = ^{
        CGRect friendsTabButtonFrame = self.showAllFriendsTabButton.frame;
        if (selectedVisible) {
            friendsTabButtonFrame.size.width = 206;
        } else {
            friendsTabButtonFrame.size.width = 321;
        }
        self.showAllFriendsTabButton.frame = friendsTabButtonFrame;
        self.showAllFriendsTabButtonBorder.frame = friendsTabButtonFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:CSVC_TAB_BUTTON_ANIMATION_DURATION animations:frameShiftBlock];
    } else {
        frameShiftBlock();
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {
    if (theScrollView == self.friendsTableView &&
        self.isSearchOn &&
        [self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self forceSetSearchBarCancelButtonTitle:@"Done"];
        [self forceSearchBarCancelButtonToBeEnabled];
//        CGRect searchBarFrame = self.searchBar.frame;
//        searchBarFrame.origin.y = MAX(0, theScrollView.contentOffset.y);
//        self.searchBar.frame = searchBarFrame;
//        [theScrollView bringSubviewToFront:self.searchBar];
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

- (void) forceSearchBarCancelButtonToBeEnabled {
	for (UIView * possibleButton in self.searchBar.subviews)
	{
		if ([possibleButton isKindOfClass:[UIButton class]]) {
			UIButton * searchBarCancelButton = (UIButton *)possibleButton;
			searchBarCancelButton.enabled = YES;
			break;
		}
	}
}

- (void) forceSetSearchBarCancelButtonTitle:(NSString *)title {
	for (UIView * possibleButton in self.searchBar.subviews)
	{
		if ([possibleButton isKindOfClass:[UIButton class]]) {
			UIButton * searchBarCancelButton = (UIButton *)possibleButton;
            [searchBarCancelButton setTitle:title forState:UIControlStateNormal];
            [searchBarCancelButton setTitle:title forState:UIControlStateHighlighted];
            [searchBarCancelButton setTitle:title forState:UIControlStateSelected];
			searchBarCancelButton.enabled = YES;
			break;
		}
	}
}

- (void)facebookAuthFailure:(NSNotification *)notification {
    if (self.view.window) {
        [self hideWebActivityView];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"Something appears to have gone wrong with your Facebook connection. Please go to settings and try reconnecting - that should fix the problem." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self.delegate contactsSelectViewController:self didFinishWithCancel:YES selectedContacts:nil];
    }
}

@end
