//
//  FeaturedVenueEventsCell.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedVenueEventsCell.h"
#import "FeaturedHubConstants.h"

@implementation FeaturedVenueEventsCell

@synthesize tableView=tableView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIScrollView * wrapperScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, FHC_VENUE_EVENT_BUBBLE_HEIGHT + FHC_BUBBLE_VERTICAL_MARGIN * 2)] autorelease]; // This fixes a bug where bouncing does not work from the edge of the table view.
        [self addSubview:wrapperScrollView];
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, FHC_VENUE_EVENT_BUBBLE_HEIGHT + FHC_BUBBLE_VERTICAL_MARGIN * 2 * 2, 320)] autorelease];
        self.tableView.alwaysBounceVertical = YES;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        self.tableView.frame = CGRectMake(0, 0, 320, FHC_VENUE_EVENT_BUBBLE_HEIGHT + FHC_BUBBLE_VERTICAL_MARGIN * 2);
        self.tableView.rowHeight = FHC_VENUE_EVENT_BUBBLE_WIDTH + 2 * FHC_BUBBLE_HORIZONTAL_MARGIN;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.allowsSelection = NO;
        self.tableView.directionalLockEnabled = YES;
        self.tableView.pagingEnabled = YES;
        [wrapperScrollView addSubview:self.tableView];
        
    }
    return self;
}

- (void)dealloc {
    [tableView_ release];
    [super dealloc];
}

@end