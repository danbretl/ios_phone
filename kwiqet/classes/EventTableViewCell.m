//
//  EventTableViewCell.m
//  Abextra
//
//  Created by Dan Bretl on 6/8/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "EventTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GradientView.h"
#import "UIFont+Kwiqet.h"

//static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_TITLE = @"Event Title";
//static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_LOCATION = @"Location";
//static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_DATE_AND_TIME = @"Date | Time";
//static NSString * const EVENT_TABLE_VIEW_CELL_FILLER_PRICE = @"Price";
float const EC_CONTENT_VIEW_PADDING_RIGHT = 10;
float const EC_LABELS_LEFTMOST_MARGIN_LEFT = 5;
float const EC_LABELS_INDENTED_MARGIN_LEFT = 10;
CGFloat const EC_VENUE_LABEL_ORIGIN_Y = 40;
CGFloat const EC_PRICE_LABEL_ORIGIN_Y_VENUE_SHOWING = 61;
CGFloat const EC_PRICE_LABEL_ORIGIN_Y_VENUE_NOT_SHOWING = 41;

@interface EventTableViewCell()
@property (retain) UINeverClearView * backgroundColorView;
@property (retain) UIView * categoryBarContainer;
@property (retain) UINeverClearView * categoryBarColorView;
@property (retain) UIImageView * categoryBarIconImageView;
@end

@implementation EventTableViewCell

//@synthesize eventContentView;

@synthesize titleLabel, locationLabel, dateAndTimeLabel, priceOriginalLabel;
//@synthesize priceChangedLabel, priceSavingsLabel; // NOT YET IMPLEMENTED
@synthesize backgroundColorView;
@synthesize categoryBarContainer, categoryBarColorView, categoryBarIconImageView;
@synthesize categoryColor=categoryColor_, categoryIcon=categoryIcon_, categoryIconHorizontalOffset=categoryIconHorizontalOffset_;
@synthesize shouldShowVenue = isVenueShowing_;

- (void)dealloc
{
//    [eventContentView release];
    [categoryColor_ release];
    [categoryIcon_ release];
    [backgroundColorView release];
    [categoryBarContainer release];
    [categoryBarColorView release];
    [categoryBarIconImageView release];
    [titleLabel release];
    [locationLabel release];
    [dateAndTimeLabel release];
    [priceOriginalLabel release];
//    [priceChangedLabel release]; // NOT YET IMPLEMENTED
//    [priceSavingsLabel release]; // NOT YET IMPLEMENTED
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        BOOL debuggingFrames = NO;
        isVenueShowing_ = YES;
        
        UIView * backgroundTextureView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundTextureView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_cell_bg.png"]];
        self.backgroundView = backgroundTextureView;
        [backgroundTextureView release];
        
        UIView * selectedBackgroundTextureView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundTextureView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_cell_bg.png"]];
        self.selectedBackgroundView = selectedBackgroundTextureView;
        [selectedBackgroundTextureView release];
        
        backgroundColorView = [[UINeverClearView alloc] initWithFrame:self.selectedBackgroundView.bounds];
        self.backgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.selectedBackgroundView addSubview:self.backgroundColorView];
        
        // Cell - bottom border
        UINeverClearView * cellBottomBorderView = [[UINeverClearView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        cellBottomBorderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        cellBottomBorderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_cell_border_bottom.png"]];
        [self addSubview:cellBottomBorderView];
        [cellBottomBorderView release];
        
//        eventContentView = [[EventCellContentView alloc] initWithFrame:self.contentView.bounds];
//        eventContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        eventContentView.delegate = self;
//        [self.contentView addSubview:eventContentView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Category Bar
        categoryBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, self.contentView.bounds.size.height)];
        self.categoryBarContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.categoryBarContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.categoryBarContainer];
        // Category Bar - Color
        categoryBarColorView = [[UINeverClearView alloc] initWithFrame:self.categoryBarContainer.bounds];
        self.categoryBarColorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.categoryBarContainer addSubview:self.categoryBarColorView];
        // Category Bar - Icon
        CGFloat iconDimension = 50;
        CGFloat originX = 0; // This should get overridden.
        CGFloat originY = 2;
        categoryBarIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, iconDimension, iconDimension)];
        self.categoryBarIconImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.categoryBarIconImageView.contentMode = UIViewContentModeTopLeft;
        self.categoryBarIconImageView.alpha = 0.8;
        [self.categoryBarContainer addSubview:self.categoryBarIconImageView];
        // Category Bar - Gradient
        GradientView * clearToWhiteGradientView = [[GradientView alloc] initWithFrame:self.categoryBarContainer.bounds];
        clearToWhiteGradientView.colorEnd = [UIColor colorWithWhite:1.0 alpha:0.2];
        clearToWhiteGradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.categoryBarContainer addSubview:clearToWhiteGradientView];
        [clearToWhiteGradientView release];
        //        CAGradientLayer * gradient = [CAGradientLayer layer]; // Problem with this technique is that the CAGradientLayer does not autoresize when its parent view changes dimensions. Stupid.
        //        gradient.frame = self.categoryBarColorView.bounds;
        //        gradient.startPoint = CGPointMake(0.0, 0.0);
        //        gradient.endPoint = CGPointMake(1.0, 0.0);
        //        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.2].CGColor, nil];
        //        [self.categoryBarColorView.layer insertSublayer:gradient atIndex:0];
        // Category Bar - right border
        UINeverClearView * categoryBarRightBorderView = [[UINeverClearView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.categoryBarContainer.frame)-1, 0, 1, self.categoryBarContainer.bounds.size.height)];
        categoryBarRightBorderView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        categoryBarRightBorderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_cell_category_bar_border_right.png"]];
        [self.categoryBarContainer addSubview:categoryBarRightBorderView];
        [categoryBarRightBorderView release];
        
        CGFloat labelsLeftmostOriginX = CGRectGetMaxX(self.categoryBarContainer.frame) + EC_LABELS_LEFTMOST_MARGIN_LEFT;
        CGFloat labelsLeftmostWidth = self.bounds.size.width - EC_CONTENT_VIEW_PADDING_RIGHT - labelsLeftmostOriginX;
        CGFloat labelsIndentedOriginX = CGRectGetMaxX(self.categoryBarContainer.frame) + EC_LABELS_INDENTED_MARGIN_LEFT;
        CGFloat labelsIndentedWidth = self.bounds.size.width - EC_CONTENT_VIEW_PADDING_RIGHT - labelsIndentedOriginX;
        
        // Date & Time label
        dateAndTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelsLeftmostOriginX, 3, labelsLeftmostWidth, 15)];
        //        self.dateAndTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dateAndTimeLabel.backgroundColor = debuggingFrames ? [UIColor colorWithWhite:0.0 alpha:0.2] : [UIColor clearColor]; // This will hurt performance
        self.dateAndTimeLabel.font = [UIFont kwiqetFontOfType:LightNormal size:12.0];
        [self.contentView addSubview:self.dateAndTimeLabel];
        
        // Title label
//        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelsLeftmostOriginX, 17, labelsLeftmostWidth, 25)];
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelsLeftmostOriginX, 22, labelsLeftmostWidth, 25)]; // See note below.
//        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleLabel.backgroundColor = debuggingFrames ? [UIColor colorWithWhite:0.0 alpha:0.2] : [UIColor clearColor]; // This will hurt performance
//        self.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:20.0]; // THIS FONT IS WAY TOO BOLD. ALLEN WAS STILL DESIGNING WITH DIFFERENT FONTS THAN WE HAVE IN OUR SYSTEM. HE WAS DESIGNING WITH HELVETICA NEUE FAMILY. FOR NOW, GOING BACK TO OLD FONT AND ITS ASSOCIATED SIZING / POSITIONING.
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:20]; // See note above.
        [self.contentView addSubview:self.titleLabel];
        
        // Location label
        locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelsIndentedOriginX, EC_VENUE_LABEL_ORIGIN_Y, labelsIndentedWidth, 22)];
//        self.locationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.locationLabel.backgroundColor = debuggingFrames ? [UIColor colorWithWhite:0.0 alpha:0.2] : [UIColor clearColor]; // This will hurt performance
        self.locationLabel.font = [UIFont kwiqetFontOfType:LightCondensed size:17.0];
        [self.contentView addSubview:self.locationLabel];
        
        // Price label
        priceOriginalLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelsIndentedOriginX, EC_PRICE_LABEL_ORIGIN_Y_VENUE_SHOWING, labelsIndentedWidth, 18)];
        self.priceOriginalLabel.backgroundColor = debuggingFrames ? [UIColor colorWithWhite:0.0 alpha:0.2] : [UIColor clearColor]; // This will hurt performance
        self.priceOriginalLabel.font = [UIFont kwiqetFontOfType:LightCondensed size:14.0];
        [self.contentView addSubview:self.priceOriginalLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentViewConditionalRightPadding = self.isEditing ? 0 : EC_CONTENT_VIEW_PADDING_RIGHT;

    CGRect dateAndTimeLabelFrame = self.dateAndTimeLabel.frame;
    dateAndTimeLabelFrame.size.width = self.contentView.bounds.size.width - contentViewConditionalRightPadding - dateAndTimeLabelFrame.origin.x;
    self.dateAndTimeLabel.frame = dateAndTimeLabelFrame;
    
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.size.width = self.contentView.bounds.size.width - contentViewConditionalRightPadding - titleLabelFrame.origin.x;
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect locationLabelFrame = self.locationLabel.frame;
    locationLabelFrame.size.width = self.contentView.bounds.size.width - contentViewConditionalRightPadding - locationLabelFrame.origin.x;
    self.locationLabel.frame = locationLabelFrame;
    
    CGRect priceOriginalLabelFrame = self.priceOriginalLabel.frame;
    priceOriginalLabelFrame.origin.y = self.isVenueShowing ? EC_PRICE_LABEL_ORIGIN_Y_VENUE_SHOWING : EC_PRICE_LABEL_ORIGIN_Y_VENUE_NOT_SHOWING;
    priceOriginalLabelFrame.size.width = self.contentView.bounds.size.width - contentViewConditionalRightPadding - priceOriginalLabelFrame.origin.x;
    self.priceOriginalLabel.frame = priceOriginalLabelFrame;

}

//- (void)setCategoryColor:(UIColor *)theCategoryColor {
//    if (categoryColor != theCategoryColor) {
//        [categoryColor release];
//        categoryColor = [theCategoryColor retain];
//    }
//    self.backgroundColorView.backgroundColor = self.categoryColor;
//}

- (void)setCategoryColor:(UIColor *)categoryColor {
    if (categoryColor_ != categoryColor) {
        [categoryColor_ release];
        categoryColor_ = [categoryColor retain];
//        self.eventContentView.categoryColor = self.categoryColor;
    }
    self.categoryBarColorView.backgroundColor = self.categoryColor;
    self.backgroundColorView.backgroundColor = [self.categoryColor colorWithAlphaComponent:0.15];
}

- (void) setCategoryIcon:(UIImage *)categoryIcon {
    if (categoryIcon_ != categoryIcon) {
        [categoryIcon_ release];
        categoryIcon_ = [categoryIcon retain];
    }
    self.categoryBarIconImageView.image = self.categoryIcon;
}

- (void) setCategoryIconHorizontalOffset:(CGFloat)categoryIconHorizontalOffset {
    if (categoryIconHorizontalOffset_ != categoryIconHorizontalOffset) {
        categoryIconHorizontalOffset_ = categoryIconHorizontalOffset;
    }
    CGRect categoryBarIconImageViewFrame = self.categoryBarIconImageView.frame;
    categoryBarIconImageViewFrame.origin.x = self.categoryIconHorizontalOffset;
    self.categoryBarIconImageView.frame = categoryBarIconImageViewFrame;
}

//- (void)categoryColorWasSetToColor:(UIColor *)categoryColor {
//    self.categoryColor = categoryColor;
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//}

- (void)setShouldShowVenue:(BOOL)shouldShowVenue {
    if (isVenueShowing_ != shouldShowVenue) {
        isVenueShowing_ = shouldShowVenue;
        self.locationLabel.hidden = !self.isVenueShowing;
        [self setNeedsLayout];
    }
}

@end
