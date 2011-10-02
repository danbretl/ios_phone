//
//  OccurrenceTimeCell.m
//  kwiqet
//
//  Created by Dan Bretl on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OccurrenceTimeCell.h"
#import "UIFont+Kwiqet.h"

@implementation OccurrenceTimeCell

@synthesize timeLabel=timeLabel_;
@synthesize priceAndInfoLabel=priceAndInfoLabel_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView * normalBackgroundView = [[UIView alloc] init];
        normalBackgroundView.backgroundColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
        self.backgroundView = normalBackgroundView;
        [normalBackgroundView release];
        UIView * selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ptn_venue.png"]];
        self.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
        
        timeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, self.contentView.bounds.size.height)];
        self.timeLabel.backgroundColor = [UIColor clearColor];//[UIColor redColor];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        self.timeLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:24.0];
        self.timeLabel.textAlignment = UITextAlignmentRight;
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        
        priceAndInfoLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.timeLabel.frame) + 15, 0, self.contentView.bounds.size.width - (CGRectGetMaxX(self.timeLabel.frame) + 15) - 10, self.contentView.bounds.size.height)];
        self.priceAndInfoLabel.backgroundColor = [UIColor clearColor];//[UIColor yellowColor];
        self.priceAndInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.priceAndInfoLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14.0];
        self.priceAndInfoLabel.textAlignment = UITextAlignmentLeft;
        self.priceAndInfoLabel.numberOfLines = 0;
        self.priceAndInfoLabel.adjustsFontSizeToFitWidth = NO; // We're just hoping that we can fit all the multi-line text for now...
        [self.contentView addSubview:self.priceAndInfoLabel];
        
        self.timeLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];
        self.priceAndInfoLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];

    }
    return self;
}

- (void)dealloc {
    [timeLabel_ release];
    [priceAndInfoLabel_ release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void) setTimesString:(NSString *)timesString {
//    if (timesString_ != timesString) {
//        [timesString_ release];
//        timesString_ = [timesString copy];
//        CGSize neededSize = [self.timesString sizeWithFont:self.timesLabel.font constrainedToSize:CGSizeMake(self.timesLabel.frame.size.width, 3000)];
//        //        NSLog(@"needed size: %@", NSStringFromCGSize(neededSize));
//        self.timesLabel.text = self.timesString;
//        CGRect timesLabelFrame = self.timesLabel.frame;
//        timesLabelFrame.size = CGSizeMake(self.timesLabel.bounds.size.width, neededSize.height);
//        self.timesLabel.frame = timesLabelFrame;
//    }
//}

//+ (CGFloat)cellHeightForTimesString:(NSString *)timesString cellWidth:(CGFloat)cellWidth {
//    CGSize neededSize = [timesString sizeWithFont:[UIFont fontWithName:OVC_TIMES_LABEL_FONT_NAME size:OVC_TIMES_LABEL_FONT_SIZE] constrainedToSize:CGSizeMake(cellWidth, 3000)];
//    return OVC_TIMES_LABEL_ORIGIN_Y + neededSize.height + OVC_VERTICAL_PADDING;
//}

@end
