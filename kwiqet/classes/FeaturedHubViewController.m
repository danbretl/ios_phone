//
//  FeaturedHubViewController.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FeaturedHubViewController.h"
#import "FeaturedBubbleView.h"
#import "FeaturedEventBubbleView.h"
#import "FeaturedVenueEventBubbleView.h"
#import "FeaturedEventsSectionHeaderView.h"
#import "FeaturedVenueSectionHeaderView.h"
#import "FeaturedHubConstants.h"
#import "FeaturedEventsCell.h"
#import "FeaturedEventCell.h"
#import "FeaturedVenueEventsCell.h"
#import "FeaturedVenueEventCell.h"

@interface FeaturedHubViewController()
@property (nonatomic, retain) UITableView * tableView;
//@property (nonatomic) CGPoint featuredEventsContentOffset;
@property (nonatomic, retain) NSMutableDictionary * tableViewSectionHeaderViews;
@property (nonatomic, retain) NSMutableDictionary * tableViewVenueEventsGroupIndexes;
- (void) venueButtonTouched:(UIButton *)venueButton;
@end

@implementation FeaturedHubViewController

@synthesize coreDataModel=coreDataModel_;
@synthesize tableView=tableView_;
//@synthesize featuredEventsContentOffset=featuredEventsContentOffset_;
@synthesize tableViewSectionHeaderViews=tableViewSectionHeaderViews_, tableViewVenueEventsGroupIndexes=tableViewVenueEventsGroupIndexes_;
@synthesize featuredEvents=featuredEvents_, featuredVenues=featuredVenues_, featuredEventsForVenues=featuredEventsForVenues_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        debugging = YES;
        if (debugging) {
            self.featuredEvents = [NSArray arrayWithObjects:@"Event1", @"Event2", @"Event3", @"Event4", @"Event5", nil];
            self.featuredVenues = [NSArray arrayWithObjects:@"Venue1", @"Venue2", @"Venue3", @"Venue4", @"Venue5", @"Venue6", nil];
            self.featuredEventsForVenues = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSArray arrayWithObjects:@"Venue1-Event1", @"Venue1-Event2", @"Venue1-Event3", @"Venue1-Event4", @"Venue1-Event5", @"Venue1-Event6", nil], @"Venue1",
                                            [NSArray arrayWithObjects:@"Venue2-Event1", @"Venue2-Event2", @"Venue2-Event3", @"Venue2-Event4", @"Venue2-Event5", @"Venue2-Event6", nil], @"Venue2",
                                            [NSArray arrayWithObjects:@"Venue3-Event1", @"Venue3-Event2", @"Venue3-Event3", @"Venue3-Event4", @"Venue3-Event5", @"Venue3-Event6", nil], @"Venue3",
                                            [NSArray arrayWithObjects:@"Venue4-Event1", @"Venue4-Event2", @"Venue4-Event3", @"Venue4-Event4", @"Venue4-Event5", @"Venue4-Event6", nil], @"Venue4",
                                            [NSArray arrayWithObjects:@"Venue5-Event1", @"Venue5-Event2", @"Venue5-Event3", @"Venue5-Event4", @"Venue5-Event5", @"Venue5-Event6", nil], @"Venue5",
                                            [NSArray arrayWithObjects:@"Venue6-Event1", @"Venue6-Event2", @"Venue6-Event3", @"Venue6-Event4", @"Venue6-Event5", @"Venue6-Event6", nil], @"Venue6",
                                            nil];            
        }
        self.tableViewVenueEventsGroupIndexes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [coreDataModel_ release];
    [tableView_ release];
    [tableViewSectionHeaderViews_ release];
    [tableViewVenueEventsGroupIndexes_ release];
    [featuredEvents_ release];
    [featuredVenues_ release];
    [featuredEventsForVenues_ release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UIView * rootView = [[UIView alloc] init];
    self.view = rootView;
    [rootView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewSectionHeaderViews = [NSMutableDictionary dictionary];
    
    self.view.backgroundColor = [UIColor colorWithWhite:43.0/255.0 alpha:1.0];
//    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:32.0/255.0 alpha:1.0].CGColor, (id)[UIColor colorWithWhite:53.0/255.0 alpha:1.0].CGColor, nil];
//    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
//    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
//    gradientLayer.frame = self.view.bounds;
//    [self.view.layer addSublayer:gradientLayer];
    
    tableView_ = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.directionalLockEnabled = YES;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionsCount = 1;
    if (tableView == self.tableView) {
        sectionsCount = 1 + self.featuredVenues.count;
    }
    NSLog(@"Number of sections in table view %@ : %d sections", tableView, sectionsCount);
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsCount = 1;
    if (tableView != self.tableView) {
        if (tableView.tag == 0) {
            rowsCount = self.featuredEvents.count;
        } else {
            NSString * venue = [self.featuredVenues objectAtIndex:tableView.tag - 1];
            NSArray * venueEvents = [self.featuredEventsForVenues objectForKey:venue];
            rowsCount = venueEvents.count;
        }
    }
    NSLog(@"Number of rows in section %d in table view %@ : %d rows", section, tableView, rowsCount);
    return rowsCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionHeaderView = nil;
    if (tableView == self.tableView) {
        CGRect helperStartingFrame = CGRectMake(0, 0, tableView.frame.size.width, [self tableView:tableView heightForHeaderInSection:section]); // We're doing this just so because otherwise the autoresizing in the section header view's subviews goes all crazy.
        if (section == 0) {
            FeaturedEventsSectionHeaderView * featuredSectionView = [[[FeaturedEventsSectionHeaderView alloc] initWithFrame:helperStartingFrame] autorelease];
            sectionHeaderView = featuredSectionView;
        } else {
            FeaturedVenueSectionHeaderView * featuredSectionView = [[[FeaturedVenueSectionHeaderView alloc] initWithFrame:helperStartingFrame] autorelease];
            if (debugging) {
                if (section - 1 == 0) {
                    featuredSectionView.venueNameString = @"Sullivan Hall";
                } else {
                    featuredSectionView.venueNameString = [self.featuredVenues objectAtIndex:section - 1];                    
                }
                featuredSectionView.selectedHighlightIndex = [[self.tableViewVenueEventsGroupIndexes objectForKey:[NSNumber numberWithInt:section]] intValue];
                featuredSectionView.button.tag = section; // Kind of a hack. But an acceptable one, I think.
                [featuredSectionView.button addTarget:self action:@selector(venueButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            }
            [self.tableViewSectionHeaderViews setObject:featuredSectionView forKey:[NSNumber numberWithInt:section]];
            sectionHeaderView = featuredSectionView;
        }
    }
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat sectionHeight = 0;
    if (tableView == self.tableView) {
        sectionHeight = section == 0 ? FHC_EVENTS_SECTION_HEADER_HEIGHT : FHC_VENUE_SECTION_HEADER_HEIGHT;
    }
    return sectionHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath:%d-%d", indexPath.section, indexPath.row);
    
    if (tableView == self.tableView) {
        
        if (indexPath.section == 0) {
            
            static NSString * FeaturedEventsCellID = @"FeaturedEventsCell";
            
            FeaturedEventsCell * cell = (FeaturedEventsCell *)[tableView dequeueReusableCellWithIdentifier:FeaturedEventsCellID];
            if (cell == nil) {
                cell = [[[FeaturedEventsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeaturedEventsCellID] autorelease];
            }
            cell.tableView.delegate = self;
            cell.tableView.dataSource = self;
            cell.tableView.tag = indexPath.section;
            [cell.tableView reloadData];
            
            return cell;
            
        } else {
            
            static NSString * FeaturedVenueEventsCellID = @"FeaturedVenueEventsCell";
            
            FeaturedVenueEventsCell * cell = (FeaturedVenueEventsCell *)[tableView dequeueReusableCellWithIdentifier:FeaturedVenueEventsCellID];
            if (cell == nil) {
                cell = [[[FeaturedVenueEventsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeaturedVenueEventsCellID] autorelease];
            }
            cell.tableView.delegate = self;
            cell.tableView.dataSource = self;
            cell.tableView.tag = indexPath.section;
            [cell.tableView reloadData];
            cell.tableView.contentOffset = CGPointMake(0, 320 * [[self.tableViewVenueEventsGroupIndexes objectForKey:[NSNumber numberWithInt:indexPath.section]] intValue]);
            
            return cell;
            
        }
        
    } else {
        
        if (tableView.tag == 0) {
            
            static NSString * FeaturedEventCellID = @"FeaturedEventCell";
            
            FeaturedEventCell * cell = (FeaturedEventCell *)[tableView dequeueReusableCellWithIdentifier:FeaturedEventCellID];
            if (cell == nil) {
                cell = [[[FeaturedEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeaturedEventCellID] autorelease];
            }
            
            if (indexPath.row == 0) {
                cell.bubbleView.imageView.image = [UIImage imageNamed:@"1_steaksmain.jpg"];
                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                cell.bubbleView.dateTimeLabel.text = @"Friday, January 20 at 7:30 PM";
                cell.bubbleView.titleLabel.text = @"Prisoners of 2nd Avenue";
                cell.bubbleView.venueLabel.text = @"Hiro Ballroom";
                cell.bubbleView.priceLabel.text = @"$25";
            } else if (indexPath.row == 1) {
                cell.bubbleView.imageView.image = [UIImage imageNamed:@"2_dbd_cameo_12.jpg"];
                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                cell.bubbleView.dateTimeLabel.text = @"January 26 at 8:00 PM";
                cell.bubbleView.titleLabel.text = @"Deadbeat Darling";
                cell.bubbleView.venueLabel.text = @"Hiro Ballroom";
                cell.bubbleView.priceLabel.text = @"$15";
            } else if (indexPath.row == 2) {
                cell.bubbleView.imageView.image = [UIImage imageNamed:@"3_dj_vector.jpg"];
                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                cell.bubbleView.dateTimeLabel.text = @"February 10 at 11:00 PM";
                cell.bubbleView.titleLabel.text = @"The Prince & Michael Experience";
                cell.bubbleView.venueLabel.text = @"Brooklyn Bowl";
                cell.bubbleView.priceLabel.text = @"$10";
            } else if (indexPath.row == 3) {
                cell.bubbleView.imageView.image = [UIImage imageNamed:@"4_boss1.jpg"];
                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                cell.bubbleView.dateTimeLabel.text = @"February 11 at 7:30 PM";
                cell.bubbleView.titleLabel.text = @"Tramps Like Us: Bruce Springstein Tribute";
                cell.bubbleView.venueLabel.text = @"B.B. King Blues Club & Grill";
                cell.bubbleView.priceLabel.text = @"$30";
            } else if (indexPath.row == 4) {
                cell.bubbleView.imageView.image = [UIImage imageNamed:@"5_rom.jpg"];
                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                cell.bubbleView.dateTimeLabel.text = @"February 11 at 11:00 PM";
                cell.bubbleView.titleLabel.text = @"Rebirth Brass Band";
                cell.bubbleView.venueLabel.text = @"Hiro Ballroom";
                cell.bubbleView.priceLabel.text = @"$35";
            }
            
//            if (indexPath.row % 4 == 0) {
//                cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_1.jpg"];
//                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
//                cell.bubbleView.dateTimeLabel.text = @"Friday, January 13 at 5:30 PM";
//                cell.bubbleView.titleLabel.text = @"Coeur de Pirate Concert";
//                cell.bubbleView.venueLabel.text = @"Highline Ballroom";
//                cell.bubbleView.priceLabel.text = @"$15";
//            } else if (indexPath.row % 4 == 1) {
//                cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_2.jpg"];
//                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.87 green:.66 blue:.13 alpha:1.0];
//                cell.bubbleView.dateTimeLabel.text = @"Saturday, December 17 at 6:00 PM";
//                cell.bubbleView.titleLabel.text = @"Never There Opening Reception by Kaws";
//                cell.bubbleView.venueLabel.text = @"Animazing Gallery";
//                cell.bubbleView.priceLabel.text = @"Free";
//            } else if (indexPath.row % 4 == 2) {
//                cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_3.jpg"];
//                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
//                cell.bubbleView.dateTimeLabel.text = @"Saturday, January 20 at 9:30 PM";
//                cell.bubbleView.titleLabel.text = @"Kanye West Concert";
//                cell.bubbleView.venueLabel.text = @"Madison Square Garden";
//                cell.bubbleView.priceLabel.text = @"$179";
//            } else if (indexPath.row % 4 == 3) {
//                cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_4.jpg"];
//                cell.bubbleView.colorBarColor = [UIColor colorWithRed:.34 green:.73 blue:.28 alpha:1.0];
//                cell.bubbleView.dateTimeLabel.text = @"Sunday, January 15 at 4:30 PM";
//                cell.bubbleView.titleLabel.text = @"NY Giants vs. Green Bay Packers";
//                cell.bubbleView.venueLabel.text = @"MetLife Stadium";
//                cell.bubbleView.priceLabel.text = @"$150 - $800";
//            }
            
            return cell;

            
        } else {
            
            static NSString * FeaturedVenueEventCellID = @"FeaturedVenueEventCell";
            
            FeaturedVenueEventCell * cell = (FeaturedVenueEventCell *)[tableView dequeueReusableCellWithIdentifier:FeaturedVenueEventCellID];
            if (cell == nil) {
                cell = [[[FeaturedVenueEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FeaturedVenueEventCellID] autorelease];
            }
            
            if (tableView.tag - 1 == 0) {
                
                switch (indexPath.row) {
                    case 0:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"1_69_Edp.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Jan 19 at 8:30 PM";
                        cell.bubbleView.titleLabel.text = @"Greensky Bluegrass";
                        break;
                    case 1:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"2_49_Edp.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Jan 20 at 7:30 PM";
                        cell.bubbleView.titleLabel.text = @"Small Mountain Bear: CD Release Party";
                        break;
                    case 2:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"3_49_Edp-1.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Feb 17 at 7:30 PM";
                        cell.bubbleView.titleLabel.text = @"The Big Mean Sound Machine";
                        break;
                    case 3:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"4_29_Edp.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Feb 25 at 7:30 PM";
                        cell.bubbleView.titleLabel.text = @"Dopapod / Turbine";
                        break;
                    case 4:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"5_89_Edp.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Mar 24 at 7:30 PM";
                        cell.bubbleView.titleLabel.text = @"Joe Krown Trio";
                        break;
                    case 5:
                        cell.bubbleView.imageView.image = [UIImage imageNamed:@"6_89_Edp-1.jpg"];
                        cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                        cell.bubbleView.dateTimeLabel.text = @"Mar 29 at 7:30 PM";
                        cell.bubbleView.titleLabel.text = @"Work Hard, Play Harder!";
                        break;                        
                    default:
                        break;
                }
                
            } else {
            
                if ((indexPath.row + tableView.tag) % 4 == 0) {
                    cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_1.jpg"];
                    cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                    cell.bubbleView.dateTimeLabel.text = @"Jan 13 at 5:30 PM";
                    cell.bubbleView.titleLabel.text = @"Coeur de Pirate Concert";
                } else if ((indexPath.row + tableView.tag) % 4 == 1) {
                    cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_2.jpg"];
                    cell.bubbleView.colorBarColor = [UIColor colorWithRed:.87 green:.66 blue:.13 alpha:1.0];
                    cell.bubbleView.dateTimeLabel.text = @"Dec 17 at 6:00 PM";
                    cell.bubbleView.titleLabel.text = @"Never There Opening Reception by Kaws";
                } else if ((indexPath.row + tableView.tag) % 4 == 2) {
                    cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_3.jpg"];
                    cell.bubbleView.colorBarColor = [UIColor colorWithRed:.22 green:.68 blue:.77 alpha:1.0];
                    cell.bubbleView.dateTimeLabel.text = @"Jan 20 at 9:30 PM";
                    cell.bubbleView.titleLabel.text = @"Kanye West Concert";
                } else if ((indexPath.row + tableView.tag) % 4 == 3) {
                    cell.bubbleView.imageView.image = [UIImage imageNamed:@"fakeFeaturedEvent_4.jpg"];
                    cell.bubbleView.colorBarColor = [UIColor colorWithRed:.34 green:.73 blue:.28 alpha:1.0];
                    cell.bubbleView.dateTimeLabel.text = @"Jan 15 at 4:30 PM";
                    cell.bubbleView.titleLabel.text = @"NY Giants vs. Green Bay Packers";
                }
                
            }
            
            return cell;
            
        }
                
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = tableView.rowHeight;
    if (tableView == self.tableView) {
        rowHeight = FHC_BUBBLE_VERTICAL_MARGIN * 2 + (indexPath.section == 0 ? FHC_EVENT_BUBBLE_HEIGHT : FHC_VENUE_EVENT_BUBBLE_HEIGHT);
    }
    return rowHeight;
}

- (void)venueButtonTouched:(UIButton *)venueButton {
    NSLog(@"Venue button touched for section %d - should push venue card for %@", venueButton.tag, [self.featuredVenues objectAtIndex:venueButton.tag - 1]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.tableView &&
        scrollView.tag != 0) {
        NSLog(@"%f / %f = %f", scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.contentOffset.y / scrollView.frame.size.width);
        int updatedHighlightIndex = (int)(scrollView.contentOffset.y / scrollView.frame.size.width);
        FeaturedVenueSectionHeaderView * venueSectionHeaderView = [self.tableViewSectionHeaderViews objectForKey:[NSNumber numberWithInt:scrollView.tag]];
        venueSectionHeaderView.selectedHighlightIndex = updatedHighlightIndex;
        [self.tableViewVenueEventsGroupIndexes setObject:[NSNumber numberWithInt:updatedHighlightIndex] forKey:[NSNumber numberWithInt:scrollView.tag]];
        NSLog(@"updatedHighlightIndex = %d for table view within section %d of master table view", updatedHighlightIndex, scrollView.tag);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.tableView &&
        scrollView.tag != 0 &&
        !decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

@end
