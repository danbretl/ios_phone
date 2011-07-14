//
//  EventTableViewCell.m
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventTableViewCell.h"

static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_TITLE = @"Event Title";
static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_LOCATION = @"Location";
static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_DATE_AND_TIME = @"Date | Time";
static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_PRICE = @"Price";

@implementation EventTableViewCell

@synthesize backgroundViewNormal, backgroundViewSelected, categoryColorView, iconImageView, titleLabel, locationLabel, dateAndTimeLabel, priceLabel;
@synthesize categoryColor;

- (void)dealloc
{
    [backgroundViewNormal release];
    [backgroundViewSelected release];
    [categoryColorView release];
    [iconImageView release];
    [titleLabel release];
    [locationLabel release];
    [dateAndTimeLabel release];
    [priceLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Background
        UIImageView * backgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbar.png"]];
        self.backgroundView = backgroundViewWithImage;
        [backgroundViewWithImage release];
        UIImageView * selectedBackgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbarSelected.png"]];
        self.selectedBackgroundView = selectedBackgroundViewWithImage;
        [selectedBackgroundViewWithImage release];
        
        // Category color view
        categoryColorView = [[UINeverClearView alloc] initWithFrame:CGRectMake(0, 1, 20, 75)];
        [self setCategoryColor:[UIColor redColor]];
        [self.contentView addSubview:self.categoryColorView];
        
        // Icon image view
        iconImageView = [[UIImageView alloc] initWithFrame:self.categoryColorView.bounds];
        iconImageView.contentMode = UIViewContentModeCenter;
        [self.categoryColorView addSubview:self.iconImageView];
        
        // Title label
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,5,300,26)];
        self.titleLabel.backgroundColor = [UIColor clearColor]; // This will hurt performance
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:20];
        self.titleLabel.text = EVENT_TABLE_VIEW_CELL_FILLER_TITLE;
        [self.contentView addSubview:self.titleLabel];
        
        // Location label
        locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,25,275,20)];
        self.locationLabel.backgroundColor = [UIColor clearColor]; // This will hurt performance
        self.locationLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:15];
        self.locationLabel.text = EVENT_TABLE_VIEW_CELL_FILLER_LOCATION;
        [self.contentView addSubview:self.locationLabel];
        
        // Date & Time label
        dateAndTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,48,275,17)];
        self.dateAndTimeLabel.backgroundColor = [UIColor clearColor]; // This will hurt performance
        self.dateAndTimeLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
        self.dateAndTimeLabel.text = EVENT_TABLE_VIEW_CELL_FILLER_DATE_AND_TIME;
        [self.contentView addSubview:self.dateAndTimeLabel];
        
        // Price label
        priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,62,275,17)];
        self.priceLabel.backgroundColor = [UIColor clearColor]; // This will hurt performance
        self.priceLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:13];
        self.priceLabel.text = EVENT_TABLE_VIEW_CELL_FILLER_PRICE;
        [self.contentView addSubview:self.priceLabel];
        
    }
    return self;
}

- (void)setCategoryColor:(UIColor *)theCategoryColor {
    if (categoryColor != theCategoryColor) {
        [categoryColor release];
        categoryColor = [theCategoryColor retain];
    }
    self.categoryColorView.backgroundColor = self.categoryColor;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//}

@end
