//
//  OccurrenceVenueCell.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/6/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OccurrenceVenueCell : UITableViewCell {
    
//    NSArray * timesArray; // Array of (hopefully already ordered) NSDate objects representing times
    NSString * timesString_;
    
    UILabel * venueLabel_;
    UILabel * addressLabel_;
    UILabel * timesLabel_;
    UILabel * distanceLabel_;
    
//    NSDateFormatter * timeFormatter;
    
}

//@property (nonatomic, retain) NSArray * times;
@property (nonatomic, copy) NSString * timesString;
@property (nonatomic, readonly) UILabel * venueLabel;
@property (nonatomic, readonly) UILabel * addressLabel;
@property (nonatomic, readonly) UILabel * distanceLabel;
@property (retain, nonatomic) UIColor * venueLabelColor;

- (void) setDistanceInMeters:(double)distanceInMeters;

//+ (CGFloat) cellHeightForTimesArray:(NSArray *)timesArray timeFormatter:(NSDateFormatter *)theTimeFormatter cellWidth:(CGFloat)cellWidth;
+ (CGFloat) cellHeightForTimesString:(NSString *)timesString cellWidth:(CGFloat)cellWidth;

@end
