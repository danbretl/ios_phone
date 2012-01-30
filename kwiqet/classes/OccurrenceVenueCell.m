//
//  OccurrenceVenueCell.m
//  Kwiqet
//
//  Created by Dan Bretl on 9/6/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "OccurrenceVenueCell.h"
#import "UIFont+Kwiqet.h"

float const OVC_VENUE_LABEL_ORIGIN_Y = 4;
float const OVC_DISTANCE_LABEL_ORIGIN_Y = 28;
float const OVC_DISTANCE_LABEL_MARGIN_RIGHT = 10;
float const OVC_DISTANCE_LABEL_WIDTH = 40;
float const OVC_ADDRESS_LABEL_ORIGIN_X = 10;
float const OVC_ADDRESS_LABEL_ORIGIN_Y = 30;
float const OVC_TIMES_LABEL_ORIGIN_Y = 50;
KwiqetFontType const OVC_TIMES_LABEL_KWIQET_FONT_TYPE = RegularNormal;
//static NSString * const OVC_TIMES_LABEL_FONT_NAME = @"HelveticaNeue";
float const OVC_TIMES_LABEL_FONT_SIZE = 10;
float const OVC_TIMES_LABEL_MARGIN_BOTTOM = 8;

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
@synthesize distanceLabel=distanceLabel_;

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
        
        venueLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, OVC_VENUE_LABEL_ORIGIN_Y, self.contentView.bounds.size.width - 10 - 10, 32)];
        self.venueLabel.backgroundColor = [UIColor clearColor];//[UIColor redColor];
        self.venueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.venueLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:21];
        self.venueLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:21];
        self.venueLabel.adjustsFontSizeToFitWidth = NO;
        [self.contentView addSubview:self.venueLabel];
        
        distanceLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - OVC_DISTANCE_LABEL_MARGIN_RIGHT - OVC_DISTANCE_LABEL_WIDTH, OVC_DISTANCE_LABEL_ORIGIN_Y, OVC_DISTANCE_LABEL_WIDTH, 24)];
        self.distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.distanceLabel.backgroundColor = [UIColor clearColor];//[UIColor yellowColor];
        self.distanceLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:14];
        self.distanceLabel.textAlignment = UITextAlignmentRight;
        self.distanceLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.distanceLabel.numberOfLines = 1;
        self.distanceLabel.adjustsFontSizeToFitWidth = NO;
        [self.contentView addSubview:self.distanceLabel];
//        NSLog(@"OCCURRENCE_VENUE_CELL DISTANCE_LABEL FRAME=%@ where contentviewboundswidth is %f", NSStringFromCGRect(self.distanceLabel.frame), self.contentView.bounds.size.width);
        
        addressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(OVC_ADDRESS_LABEL_ORIGIN_X, OVC_ADDRESS_LABEL_ORIGIN_Y, CGRectGetMinX(self.distanceLabel.frame) - OVC_ADDRESS_LABEL_ORIGIN_X - 10, 20)];
        self.addressLabel.backgroundColor = [UIColor clearColor];//[UIColor yellowColor];
        self.addressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //        self.addressLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:14];
        self.addressLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:13];
        self.addressLabel.adjustsFontSizeToFitWidth = NO;
        [self.contentView addSubview:self.addressLabel];
        
        timesLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, OVC_TIMES_LABEL_ORIGIN_Y, self.contentView.bounds.size.width - 10 - 10, 40)];
        self.timesLabel.backgroundColor = [UIColor clearColor];//[UIColor orangeColor];
        self.timesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.timesLabel.font = [UIFont fontWithName:OVC_TIMES_LABEL_FONT_NAME size:OVC_TIMES_LABEL_FONT_SIZE];
        self.timesLabel.font = [UIFont kwiqetFontOfType:OVC_TIMES_LABEL_KWIQET_FONT_TYPE size:OVC_TIMES_LABEL_FONT_SIZE];
        self.timesLabel.numberOfLines = 0;
        self.timesLabel.adjustsFontSizeToFitWidth = NO;
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
    [distanceLabel_ release];
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

- (void)setDistanceInMeters:(double)distanceInMeters {
    double distanceInFeet = distanceInMeters * 3.2808399;
    double distanceInMiles = distanceInFeet / 5280.0;
    if (distanceInMiles >= 10) {
        self.distanceLabel.text = @"10+mi";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%3.1fmi", distanceInMiles];
    }
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
    CGSize neededSize = [timesString sizeWithFont:[UIFont kwiqetFontOfType:OVC_TIMES_LABEL_KWIQET_FONT_TYPE size:OVC_TIMES_LABEL_FONT_SIZE] constrainedToSize:CGSizeMake(cellWidth, 3000)];
    return OVC_TIMES_LABEL_ORIGIN_Y + neededSize.height + OVC_TIMES_LABEL_MARGIN_BOTTOM;
}

@end
