//
//  FeaturedEventCell.h
//  Kwiqet
//
//  Created by Dan Bretl on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeaturedHubConstants.h"
#import "FeaturedEventBubbleView.h"

@interface FeaturedEventCell : UITableViewCell {
    FeaturedEventBubbleView * bubbleView_;
}

@property (nonatomic, retain) FeaturedEventBubbleView * bubbleView;

@end
