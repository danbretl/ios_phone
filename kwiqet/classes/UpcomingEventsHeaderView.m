//
//  UpcomingEventsHeaderView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UpcomingEventsHeaderView.h"
#import "UIFont+Kwiqet.h"

static NSString * const UEHV_LOADED_STRING = @"Upcoming Events";
static NSString * const UEHV_LOADING_STRING = @"Loading Upcoming Events";
static NSString * const UEHV_LOAD_ERROR = @"Failed to Load Upcoming Events";
static NSString * const UEHV_LOAD_NO_EVENTS = @"No Upcoming Events";
NSTimeInterval const UEHV_TEXT_CHANGE_ANIMATION_DURATION = 0.25;

@interface UpcomingEventsHeaderView()
- (void) initWithFrameOrCoder;
@property (nonatomic, retain) UILabel * labelAlignedLeft;
@property (nonatomic, retain) UILabel * labelAlignedCenter;
@property (nonatomic) UpcomingEventsHeaderViewMessageType messageType;
- (BOOL) messageTypeIsCentered:(UpcomingEventsHeaderViewMessageType)messageType;
@end

@implementation UpcomingEventsHeaderView

@synthesize button=button_;
@synthesize labelAlignedLeft=labelAlignedLeft_;
@synthesize labelAlignedCenter=labelAlignedCenter_;
@synthesize messageType=messageType_;

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
    
    self.messageType = UpcomingEventsNilMessage;
        
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.button.backgroundColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
    [self addSubview:self.button];
    
    UIColor * lightTextColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    UIFont * textFont = [UIFont kwiqetFontOfType:BoldCondensed size:16.0];
    
    labelAlignedLeft_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 10, self.bounds.size.height)];
    self.labelAlignedLeft.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.labelAlignedLeft.textAlignment = UITextAlignmentLeft;
    self.labelAlignedLeft.textColor = lightTextColor;
    self.labelAlignedLeft.font = textFont;
    self.labelAlignedLeft.backgroundColor = [UIColor clearColor];
    self.labelAlignedLeft.alpha = 0.0;
    self.labelAlignedLeft.userInteractionEnabled = NO;
    [self addSubview:self.labelAlignedLeft];
    
    labelAlignedCenter_ = [[UILabel alloc] initWithFrame:self.bounds];
    self.labelAlignedCenter.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.labelAlignedCenter.textAlignment = UITextAlignmentCenter;
    self.labelAlignedCenter.textColor = lightTextColor;
    self.labelAlignedCenter.font = textFont;
    self.labelAlignedCenter.backgroundColor = [UIColor clearColor];
    self.labelAlignedCenter.alpha = 0.0;
    self.labelAlignedCenter.userInteractionEnabled = NO;
    [self addSubview:self.labelAlignedCenter];
    
}

- (void)dealloc {
    [button_ release];
    [labelAlignedLeft_ release];
    [labelAlignedCenter_ release];
    [super dealloc];
}

- (void)setMessageToShowMessageType:(UpcomingEventsHeaderViewMessageType)messageType animated:(BOOL)animated {
    
    BOOL currentMessageTypeIsCentered = [self messageTypeIsCentered:self.messageType];
    UILabel * labelCurrentlyShowing = self.labelAlignedCenter;
    UILabel * labelCurrentlyNotShowing = self.labelAlignedLeft;
    if (!currentMessageTypeIsCentered) {
        labelCurrentlyShowing = self.labelAlignedLeft;
        labelCurrentlyNotShowing = self.labelAlignedCenter;
    }
    BOOL nextMessageTypeIsCentered = [self messageTypeIsCentered:messageType];
    UILabel * labelNextShowing = nextMessageTypeIsCentered ? self.labelAlignedCenter : self.labelAlignedLeft;
    
    NSString * labelText = @"";
    switch (messageType) {
        case UpcomingEventsLoaded:          labelText = UEHV_LOADED_STRING; break;
        case UpcomingEventsLoading:         labelText = UEHV_LOADING_STRING; break;
        case UpcomingEventsNoEvents:        labelText = UEHV_LOAD_NO_EVENTS; break;
        case UpcomingEventsConnectionError: labelText = UEHV_LOAD_ERROR; break;
        default: break;
    }
    
    self.messageType = messageType;
    if (animated) {
        if (labelCurrentlyShowing == labelNextShowing) {
            [UIView animateWithDuration:UEHV_TEXT_CHANGE_ANIMATION_DURATION/2.0
                             animations:^{
                                 labelNextShowing.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 labelNextShowing.text = labelText;
                                 [UIView animateWithDuration:UEHV_TEXT_CHANGE_ANIMATION_DURATION/2.0 animations:^{
                                     labelNextShowing.alpha = 1.0;
                                 }];
                             }];
        } else {
            labelNextShowing.text = labelText;
            [UIView animateWithDuration:UEHV_TEXT_CHANGE_ANIMATION_DURATION animations:^{
                labelCurrentlyShowing.alpha = 0.0;
                labelNextShowing.alpha = 1.0;
            }];
        }
    } else {
        labelNextShowing.text = labelText;
        labelCurrentlyShowing.alpha = 0.0;
        labelNextShowing.alpha = 1.0;
    }
    self.button.enabled = self.messageType == UpcomingEventsConnectionError;

}

- (BOOL) messageTypeIsCentered:(UpcomingEventsHeaderViewMessageType)messageType {
    return messageType != UpcomingEventsLoaded;
}

@end
