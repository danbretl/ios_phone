//
//  EventTableViewCell.h
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINeverClearView.h"

@interface EventTableViewCell : UITableViewCell {
    
    UIView * backgroundViewNormal;
    UIView * backgroundViewSelected;
    UINeverClearView * categoryColorView;
    UIImageView * iconImageView;
    UILabel * titleLabel;
    UILabel * locationLabel;
    UILabel * dateAndTimeLabel;
    UILabel * priceLabel;
    
    UIColor * categoryColor;
    
}

@property (readonly) UIView * categoryColorView;
@property (readonly) UIImageView * iconImageView;
@property (readonly) UILabel * titleLabel;
@property (readonly) UILabel * locationLabel;
@property (readonly) UILabel * dateAndTimeLabel;
@property (readonly) UILabel * priceLabel;
@property (readonly) UIView * backgroundViewNormal;
@property (readonly) UIView * backgroundViewSelected;

@property (nonatomic, retain) UIColor * categoryColor;

@end
