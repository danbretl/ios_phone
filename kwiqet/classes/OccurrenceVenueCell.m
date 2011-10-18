//
//  OccurrenceVenueCell.m
//  kwiqet
//
//  Created by Dan Bretl on 9/6/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "OccurrenceVenueCell.h"

float const OVC_VERTICAL_PADDING = 5;
static NSString * const OVC_TIMES_LABEL_FONT_NAME = @"HelveticaNeue";
float const OVC_TIMES_LABEL_FONT_SIZE = 10;
float const OVC_TIMES_LABEL_ORIGIN_Y = 42;

@interface OccurrenceVenueCell()
@property (retain) UILabel * timesLabel;
//@property (nonatomic, readonly) NSDateFormatter * timeFormatter;
@end

@implementation OccurrenceVenueCell

@synthesize timesString=timesString_;
//@synthesize times=timesArray;
@synthesize venueLabel=venueLabel_;
@synthesize addressLabel=addressLabel_;
@synthesize timesLabel=timesLabel_;

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
        
        venueLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, OVC_VERTICAL_PADDING, self.contentView.bounds.size.width - 10 - 10, 32)];
        self.venueLabel.backgroundColor = [UIColor clearColor];//[UIColor redColor];
        self.venueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.venueLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:21];
        [self.contentView addSubview:self.venueLabel];
        
        addressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, self.contentView.bounds.size.width - 10 - 10, 20)];
        self.addressLabel.backgroundColor = [UIColor clearColor];//[UIColor yellowColor];
        self.addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.addressLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:14];
        [self.contentView addSubview:self.addressLabel];
        
        timesLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, OVC_TIMES_LABEL_ORIGIN_Y, self.contentView.bounds.size.width - 10 - 10, 40)];
        self.timesLabel.backgroundColor = [UIColor clearColor];//[UIColor orangeColor];
        self.timesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.timesLabel.font = [UIFont fontWithName:OVC_TIMES_LABEL_FONT_NAME size:OVC_TIMES_LABEL_FONT_SIZE];
        self.timesLabel.numberOfLines = 0;
        [self.contentView addSubview:self.timesLabel];
        
        self.addressLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];
        self.timesLabel.textColor = [UIColor colorWithWhite:0.20 alpha:1.0];
        
        // Debugging...
        // ...
        
    }
    return self;
}

- (void)dealloc {
//    [timesArray release];
    [timesString_ release];
    [venueLabel_ release];
    [addressLabel_ release];
    [timesLabel_ release];
//    [timeFormatter release];
    [super dealloc];
}

//- (NSDateFormatter *)timeFormatter {
//    if (timeFormatter == nil) {
//        timeFormatter = [[NSDateFormatter alloc] init];
//        [timeFormatter setDateFormat:@"h:mm"];
//    }
//    return timeFormatter;
//}

//- (void)setTimes:(NSArray *)times {
//    if (timesArray != times) {
//        [timesArray release];
//        timesArray = [times retain];
//        NSMutableString * developingTimesString = [NSMutableString string];
//        for (NSDate * time in self.times) {
//            [developingTimesString appendFormat:@"%@, ", [self.timeFormatter stringFromDate:time]];
//        }
//        self.timesString = [developingTimesString substringToIndex:developingTimesString.length - 2];
//    }
//}

- (void) setTimesString:(NSString *)timesString {
    if (timesString_ != timesString) {
        [timesString_ release];
        timesString_ = [timesString copy];
        CGSize neededSize = [self.timesString sizeWithFont:self.timesLabel.font constrainedToSize:CGSizeMake(self.timesLabel.frame.size.width, 3000)];
//        NSLog(@"needed size: %@", NSStringFromCGSize(neededSize));
        self.timesLabel.text = self.timesString;
        CGRect timesLabelFrame = self.timesLabel.frame;
        timesLabelFrame.size = CGSizeMake(self.timesLabel.bounds.size.width, neededSize.height);
        self.timesLabel.frame = timesLabelFrame;
    }
}

- (void)setVenueLabelColor:(UIColor *)venueLabelColor {
    self.venueLabel.textColor = venueLabelColor;
}

- (UIColor *)venueLabelColor {
    return self.venueLabel.textColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//+ (CGFloat) cellHeightForTimesArray:(NSArray *)timesArray timeFormatter:(NSDateFormatter *)theTimeFormatter cellWidth:(CGFloat)cellWidth {
//    NSMutableString * developingTimesString = [NSMutableString string];
//    for (NSDate * time in timesArray) {
//        [developingTimesString appendFormat:@"%@, ", [theTimeFormatter stringFromDate:time]];
//    }
//    return [OccurrenceVenueCell cellHeightForTimesString:[developingTimesString substringToIndex:developingTimesString.length - 2] cellWidth:cellWidth];
//}

+ (CGFloat)cellHeightForTimesString:(NSString *)timesString cellWidth:(CGFloat)cellWidth {
    CGSize neededSize = [timesString sizeWithFont:[UIFont fontWithName:OVC_TIMES_LABEL_FONT_NAME size:OVC_TIMES_LABEL_FONT_SIZE] constrainedToSize:CGSizeMake(cellWidth, 3000)];
    return OVC_TIMES_LABEL_ORIGIN_Y + neededSize.height + OVC_VERTICAL_PADDING;
}

@end
