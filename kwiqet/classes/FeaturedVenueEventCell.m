//
//  FeaturedVenueEventCell.m
//  Kwiqet
//
//  Created by Dan Bretl on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedVenueEventCell.h"
#import "FeaturedHubConstants.h"

@implementation FeaturedVenueEventCell

@synthesize bubbleView=bubbleView_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bubbleView_ = [[FeaturedVenueEventBubbleView alloc] initWithFrame:CGRectMake(FHC_BUBBLE_HORIZONTAL_MARGIN, FHC_BUBBLE_VERTICAL_MARGIN, FHC_VENUE_EVENT_BUBBLE_WIDTH, FHC_VENUE_EVENT_BUBBLE_HEIGHT)];
        [self.contentView addSubview:self.bubbleView];
        self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    return self;
}

- (void)dealloc {
    [bubbleView_ release];
    [super dealloc];
}

@end
