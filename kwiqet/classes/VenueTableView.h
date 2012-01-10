//
//  VenueTableView.h
//  kwiqet
//
//  Created by Dan Bretl on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElasticUILabel.h"

@interface VenueTableView : UITableView

@property (assign) UIView * titleBarForHitTest;
@property (assign) UIView * infoContainerForHitTest;
@property (assign) UIView * eventsHeaderContainerForHitTest;

@end
