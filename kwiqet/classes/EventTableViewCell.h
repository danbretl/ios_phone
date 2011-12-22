//
//  EventTableViewCell.h
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINeverClearView.h"
//#import "EventCellContentView.h"

@interface EventTableViewCell : UITableViewCell /*<EventCellContentViewDelegate>*/ {
    
//    EventCellContentView * eventContentView;
    
    UINeverClearView * backgroundColorView;
    UIView * categoryBarContainer;
    UINeverClearView * categoryBarColorView;
    UIImageView * categoryBarIconImageView;
    UILabel * titleLabel;
    UILabel * locationLabel;
    UILabel * dateAndTimeLabel;
    UILabel * priceOriginalLabel;
//    UILabel * priceChangedLabel; // NOT YET IMPLEMENTED
//    UILabel * priceSavingsLabel; // NOT YET IMPLEMENTED
    
    UIColor * categoryColor_;
    UIImage * categoryIcon_;
    CGFloat categoryIconHorizontalOffset_;
    
    BOOL isVenueShowing_;
    
}

//@property (readonly) EventCellContentView * eventContentView;

@property (readonly) UILabel * titleLabel;
@property (readonly) UILabel * locationLabel;
@property (readonly) UILabel * dateAndTimeLabel;
@property (readonly) UILabel * priceOriginalLabel;
//@property (readonly) UILabel * priceChangedLabel; // NOT YET IMPLEMENTED
//@property (readonly) UILabel * priceSavingsLabel; // NOT YET IMPLEMENTED

@property (nonatomic, retain) UIColor * categoryColor;
@property (nonatomic, retain) UIImage * categoryIcon;
@property (nonatomic) CGFloat categoryIconHorizontalOffset;

@property (nonatomic, getter = isVenueShowing) BOOL shouldShowVenue;

@end
