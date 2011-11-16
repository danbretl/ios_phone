//
//  LocationUpdatedFeedbackView.m
//  kwiqet
//
//  Created by Dan Bretl on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationUpdatedFeedbackView.h"
#import "UIFont+Kwiqet.h"
#import <QuartzCore/QuartzCore.h>

double const LUFV_ANIMATION_DURATION = 0.25;
CGFloat const LUFV_LABEL_PADDING_LEFT = 6.0; // Not sure why this looks better, but it does. There is just more space after a lowercase "o" than before a lowercase "u", I guess.
CGFloat const LUFV_LABEL_PADDING_RIGHT = 5.0;

@interface LocationUpdatedFeedbackView()
- (void) initWithFrameOrCoder;
@property (retain) UILabel * label;
@property (retain) UIImageView * backgroundImageView;
@property (retain) UIImageView * foregroundImageView;
@property (retain) UIView * shadow;
@property LocationUpdatedFeedbackMessageType messageType;
@property (retain) NSDate * dateLastUpdated;
@end

@implementation LocationUpdatedFeedbackView

@synthesize label=label_, backgroundImageView=backgroundImageView_, foregroundImageView=foregroundImageView_;
@synthesize shadow=shadow_;
@synthesize messageType=messageType_;
@synthesize dateLastUpdated=dateLastUpdated_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    label_ = [[UILabel alloc] initWithFrame:CGRectMake(LUFV_LABEL_PADDING_LEFT, 0, self.bounds.size.width - (LUFV_LABEL_PADDING_LEFT + LUFV_LABEL_PADDING_RIGHT), self.bounds.size.height/* - 1*/)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.font = [UIFont kwiqetFontOfType:RegularCondensed size:10.0]; // Changed this font from BoldCondensed last minute... It just seemed like the many bold fonts on screen at once were competing with one another. Plus, this information is less important than the location itself, so it makes sense that it would have less font weight.
    self.label.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
    
    backgroundImageView_ = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    UIImage * backgroundImage = [UIImage imageNamed:@"location_updated_feedback_stretchbg.png"];
    if ([backgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    } else {
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    }
    self.backgroundImageView.image = backgroundImage;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.backgroundImageView belowSubview:self.label];
    
    foregroundImageView_ = [[UIImageView alloc] initWithFrame:self.bounds];
    self.foregroundImageView.contentMode = UIViewContentModeScaleToFill;
    UIImage * foregroundImage = [UIImage imageNamed:@"location_updated_feedback_stretchgloss.png"];
    if ([foregroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        foregroundImage = [foregroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(foregroundImage.size.height, 5, 0, 5)];
    } else {
        foregroundImage = [foregroundImage stretchableImageWithLeftCapWidth:5 topCapHeight:foregroundImage.size.height];
    }
    self.foregroundImageView.image = foregroundImage;
    self.foregroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self insertSubview:self.foregroundImageView aboveSubview:self.label];
    
    shadow_ = [[UIView alloc] initWithFrame:self.bounds];
    self.shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.shadow.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadow.layer.shadowOffset = CGSizeMake(0, 1.0);
    self.shadow.layer.shadowOpacity = 0.15;
    self.shadow.layer.shadowRadius = 1.0;
    self.shadow.layer.shouldRasterize = YES;
    self.shadow.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5.0].CGPath;
    [self insertSubview:self.shadow belowSubview:self.backgroundImageView];
    
}

- (void)dealloc {
    [label_ release];
    [backgroundImageView_ release];
    [foregroundImageView_ release];
    [shadow_ release];
    [dateLastUpdated_ release];
    [super dealloc];
}


- (void) setLabelText:(NSString *)labelText animated:(BOOL)animated fadeTextIfAnimated:(BOOL)fadeTextIfAnimated {
    void(^textAlphaBlock)(BOOL) = ^(BOOL setToVisible){
        self.label.alpha = setToVisible ? 1.0 : 0.0;
    };
    void(^resizeBlockForText)(NSString *) = ^(NSString * text){ // resizeBlockForText changes the entire view's frame, which is a bit nonstandard. While it does this, it also maintains the view's rightmost x coordinate.
        CGSize textSize = [text sizeWithFont:self.label.font];
        CGFloat oldSelfWidth = self.frame.size.width;
        NSLog(@"LocationUpdatedFeedbackView frame change, original:%@", NSStringFromCGRect(self.frame));
        CGRect selfFrame = self.frame;
        selfFrame.size.width = textSize.width + LUFV_LABEL_PADDING_LEFT + LUFV_LABEL_PADDING_RIGHT;
        selfFrame.origin.x += (oldSelfWidth - selfFrame.size.width);
        self.frame = selfFrame;
        NSLog(@"LocationUpdatedFeedbackView frame change, modified:%@", NSStringFromCGRect(self.frame));
    };
    if (animated) {
        if (fadeTextIfAnimated) {
            [UIView animateWithDuration:LUFV_ANIMATION_DURATION/2.0 delay:0.0 options:/*UIViewAnimationOptionCurveEaseIn*/0 animations:^{ textAlphaBlock(NO); } completion:^(BOOL finished) {
                self.label.text = labelText;
                [UIView animateWithDuration:LUFV_ANIMATION_DURATION/2.0 delay:0.0 options:/*UIViewAnimationOptionCurveEaseOut*/0 animations:^{ textAlphaBlock(YES); } completion:^(BOOL finished){}];
            }];
        } else {
            self.label.text = labelText;
        }
        [UIView animateWithDuration:LUFV_ANIMATION_DURATION animations:^{
            resizeBlockForText(labelText);
        }];
    } else {
        self.label.text = labelText;
        resizeBlockForText(labelText);
    }
}

- (void) setLabelText:(NSString *)labelText animated:(BOOL)animated {
    [self setLabelText:labelText animated:animated fadeTextIfAnimated:self.messageType != Custom];
    self.messageType = Custom;
}

// "updating location"
// only choice          : "updating location"
- (void) setLabelTextToUpdatingAnimated:(BOOL)animated {
    [self setLabelText:@"updating location" animated:animated fadeTextIfAnimated:self.messageType != Updating];
    self.messageType = Updating;
}

// "updated ... ago"
// tiers:
// - days               : "updated 2 days ago" (rounded down to nearest day)
// - hours              : "updated 3 hrs ago" (rounded down to nearest hour)
// - minutes            : "updated 17 min ago" (rounded down to nearest minute)
// - less than a minute : "updated a moment ago"
- (void) setLabelTextToUpdatedDate:(NSDate *)dateLastUpdated animated:(BOOL)animated {
    self.dateLastUpdated = dateLastUpdated;
    int secondsSinceUpdate = abs((int)[dateLastUpdated timeIntervalSinceNow]);
    int minutesSinceUpdate = secondsSinceUpdate / 60;
    int hoursSinceUpdate = minutesSinceUpdate / 60;
    int daysSinceUpdate = hoursSinceUpdate / 24;
    int value = secondsSinceUpdate;
    NSString * valueUnit = @"seconds";
    BOOL qualitative = NO;
    if (daysSinceUpdate > 0) {
        value = daysSinceUpdate;
        valueUnit = value > 1 ? @"days" : @"day";
    } else if (hoursSinceUpdate > 0) {
        value = hoursSinceUpdate;
        valueUnit = value > 1 ? @"hrs" : @"hr";
    } else if (minutesSinceUpdate > 0) {
        value = minutesSinceUpdate;
        valueUnit = @"min";
    }  else {
        value = 0;
        valueUnit = @"a moment";
        qualitative = YES;
    }
    NSString * valueText = qualitative ? valueUnit : [NSString stringWithFormat:@"%d %@", value, valueUnit];
    NSString * labelText = [NSString stringWithFormat:@"updated %@ ago", valueText];
    [self setLabelText:labelText animated:animated fadeTextIfAnimated:self.messageType != Updated];
    NSLog(@"LocationUpdatedFeedbackView labelText set to %@", labelText);
    self.messageType = Updated;
}

// The implementation of this method is currently quite stupid and wasteful!
- (void) updateLabelTextForCurrentUpdatedDateAnimated:(BOOL)animated {
    if (self.messageType == Updated && self.dateLastUpdated != nil) {
        [self setLabelTextToUpdatedDate:self.dateLastUpdated animated:animated];
    }
}

- (void) setVisible:(BOOL)visible animated:(BOOL)animated {
    void(^alphaChangeBlock)(void)=^{
        self.alpha = visible ? 1.0 : 0.0;
    };
    if (animated) {
        [UIView animateWithDuration:LUFV_ANIMATION_DURATION animations:alphaChangeBlock];
    } else {
        alphaChangeBlock();
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end