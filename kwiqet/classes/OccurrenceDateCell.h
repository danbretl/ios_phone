//
//  OccurrenceDateCell.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/1/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OccurrenceDateCell : UITableViewCell {
    
    NSDate * date_;
    
    UILabel * monthLabel;
    UILabel * dayNumberLabel;
    UILabel * dayNameLabel;
    
    NSDateFormatter * dateFormatter;
    
}

@property (retain, nonatomic) NSDate * date;
@property (retain, nonatomic) UIColor * dayNumberLabelColor;

@end
