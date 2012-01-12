//
//  UpcomingEventsHeaderView.h
//  kwiqet
//
//  Created by Dan Bretl on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UpcomingEventsNilMessage = 0,
    UpcomingEventsLoaded = 5,
    UpcomingEventsLoading = 10,
    UpcomingEventsConnectionError = 15,
    UpcomingEventsNoEvents = 20,
} UpcomingEventsHeaderViewMessageType;

@interface UpcomingEventsHeaderView : UIView {
    
    UIButton * button_;
    UILabel * labelAlignedLeft_;
    UILabel * labelAlignedCenter_;
    UpcomingEventsHeaderViewMessageType messageType_;
    
}

@property (nonatomic, retain) UIButton * button;
- (void)setMessageToShowMessageType:(UpcomingEventsHeaderViewMessageType)messageType animated:(BOOL)animated;

@end
