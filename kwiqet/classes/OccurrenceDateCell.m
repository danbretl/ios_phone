//
//  OccurrenceDateCell.m
//  kwiqet
//
//  Created by Dan Bretl on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OccurrenceDateCell.h"

@interface OccurrenceDateCell()
@property (retain) UILabel * monthLabel;
@property (retain) UILabel * dayNumberLabel;
@property (retain) UILabel * dayNameLabel;
@property (readonly) NSDateFormatter * dateFormatter;
@end

@implementation OccurrenceDateCell

@synthesize date=date_;
@synthesize monthLabel, dayNumberLabel, dayNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView * backgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_date.png"]];
        self.backgroundView = backgroundViewWithImage;
        [backgroundViewWithImage release];
        UIImageView * selectedBackgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_date_highlight.png"]];
        self.selectedBackgroundView = selectedBackgroundViewWithImage;
        [selectedBackgroundViewWithImage release];

        monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, self.contentView.bounds.size.width, 18)];
        self.monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:monthLabel];
        
        dayNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, self.contentView.bounds.size.width, 42)];
        self.dayNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:dayNumberLabel];
        
        dayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 53, self.contentView.bounds.size.width, 18)];
        self.dayNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:dayNameLabel];
        
//        NSLog(@"%@ %@ %@ %@",
//              NSStringFromCGRect(self.contentView.frame),
//              NSStringFromCGRect(self.monthLabel.frame),
//              NSStringFromCGRect(self.dayNumberLabel.frame),
//              NSStringFromCGRect(self.dayNameLabel.frame));
        
        self.monthLabel.textAlignment = UITextAlignmentCenter;
        self.dayNumberLabel.textAlignment = UITextAlignmentCenter;
        self.dayNameLabel.textAlignment = UITextAlignmentCenter;
        
        self.monthLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.dayNumberLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:33];
        self.dayNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
        self.monthLabel.backgroundColor = [UIColor clearColor];
        self.dayNumberLabel.backgroundColor = [UIColor clearColor];
        self.dayNameLabel.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)dealloc {
    [date_ release];
    [monthLabel release];
    [dayNumberLabel release];
    [dayNameLabel release];
    [dateFormatter release];
    [super dealloc];
}

- (NSDateFormatter *)dateFormatter {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    return dateFormatter;
}

- (void)setDate:(NSDate *)date {
    if (date_ != date) {
        [date_ release];
        date_ = [date retain];
        [self.dateFormatter setDateFormat:@"MMM"];
        self.monthLabel.text = [self.dateFormatter stringFromDate:self.date].uppercaseString;
        [self.dateFormatter setDateFormat:@"d"];
        self.dayNumberLabel.text = [self.dateFormatter stringFromDate:self.date];
        [self.dateFormatter setDateFormat:@"EEE"];
        self.dayNameLabel.text = [self.dateFormatter stringFromDate:self.date].uppercaseString;
//        NSLog(@"Date set to %@", self.date);
    }
}

- (void)setDayNumberLabelColor:(UIColor *)dayNumberLabelColor {
    self.dayNumberLabel.textColor = dayNumberLabelColor;
}

- (UIColor *)dayNumberLabelColor {
    return self.dayNumberLabel.textColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
