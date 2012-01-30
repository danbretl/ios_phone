//
//  OccurrenceTimeCell.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OccurrenceTimeCell : UITableViewCell {
    
    UILabel * timeLabel_;
    UILabel * priceAndInfoLabel_;
    
}

@property (readonly) UILabel * timeLabel;
@property (readonly) UILabel * priceAndInfoLabel;

@end
