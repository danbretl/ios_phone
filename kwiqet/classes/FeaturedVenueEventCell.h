//
//  FeaturedVenueEventCell.h
//  kwiqet
//
//  Created by Dan Bretl on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeaturedHubConstants.h"
#import "FeaturedVenueEventBubbleView.h"

@interface FeaturedVenueEventCell : UITableViewCell {
    FeaturedVenueEventBubbleView * bubbleView_;
}

@property (nonatomic, retain) FeaturedVenueEventBubbleView * bubbleView;

@end
