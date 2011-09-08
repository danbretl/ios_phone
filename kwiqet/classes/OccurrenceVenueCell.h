//
//  OccurrenceVenueCell.h
//  kwiqet
//
//  Created by Dan Bretl on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OccurrenceVenueCell : UITableViewCell {
    
//    NSArray * timesArray; // Array of (hopefully already ordered) NSDate objects representing times
    NSString * timesString_;
    
    UILabel * venueLabel_;
    UILabel * addressLabel_;
    UILabel * timesLabel_;
    
//    NSDateFormatter * timeFormatter;
    
}

//@property (nonatomic, retain) NSArray * times;
@property (nonatomic, copy) NSString * timesString;
@property (nonatomic, readonly) UILabel * venueLabel;
@property (nonatomic, readonly) UILabel * addressLabel;
@property (retain, nonatomic) UIColor * venueLabelColor;

//+ (CGFloat) cellHeightForTimesArray:(NSArray *)timesArray timeFormatter:(NSDateFormatter *)theTimeFormatter cellWidth:(CGFloat)cellWidth;
+ (CGFloat) cellHeightForTimesString:(NSString *)timesString cellWidth:(CGFloat)cellWidth;

@end
