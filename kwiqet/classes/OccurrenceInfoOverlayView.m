//
//  OccurrenceInfoOverlayView.m
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OccurrenceInfoOverlayView.h"
#import "UIFont+Kwiqet.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const OIOV_SECONDARY_PROMPT_HORIZONTAL_SPACING = 5.0;

@implementation OccurrenceInfoOverlayView

@synthesize messagePrimary, messageSecondary, messagePrompt;
@synthesize button;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:53.0/255.0 alpha:0.9];
        self.layer.shadowColor = [UIColor colorWithWhite:53.0/255.0 alpha:.6].CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 1.0;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        
        messagePrimary = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, frame.size.width, 19)];
        self.messagePrimary.font = [UIFont kwiqetFontOfType:BoldNormal size:15];
        self.messagePrimary.adjustsFontSizeToFitWidth = NO;
        self.messagePrimary.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
        self.messagePrimary.textAlignment = UITextAlignmentCenter;
        self.messagePrimary.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.messagePrimary.backgroundColor = [UIColor clearColor];
        [self addSubview:self.messagePrimary];
        
        messageSecondary = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, frame.size.width - 100, 15.0)];
        self.messageSecondary.font = [UIFont kwiqetFontOfType:LightNormal size:12.0];
        self.messageSecondary.adjustsFontSizeToFitWidth = NO;
        self.messageSecondary.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
        self.messageSecondary.textAlignment = UITextAlignmentRight;
        self.messageSecondary.backgroundColor = [UIColor clearColor];
        [self addSubview:self.messageSecondary];
        
        messagePrompt = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.messageSecondary.frame), 27, 100, 15.0)];
        self.messagePrompt.font = [UIFont kwiqetFontOfType:BoldNormal size:12.0];
        self.messagePrompt.adjustsFontSizeToFitWidth = NO;
        self.messagePrompt.textColor = [UIColor colorWithRed:153.0/255.0 green:243.0/255.0 blue:147.0/255.0 alpha:1.0];
        self.messagePrompt.textAlignment = UITextAlignmentLeft;
        self.messagePrompt.backgroundColor = [UIColor clearColor];
        [self addSubview:self.messagePrompt];
        
        button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        self.button.frame = self.bounds;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.button];
        [self bringSubviewToFront:self.button];
        
//        self.messagePrimary.backgroundColor = [UIColor orangeColor]; // Debugging
//        self.messageSecondary.backgroundColor = [UIColor blueColor]; // Debugging
//        self.messagePrompt.backgroundColor = [UIColor redColor]; // Debugging
    }
    return self;
}

- (void)setMessagesForMode:(OccurrenceInfoOverlayMode)mode {
    switch (mode) {
        case LoadingEventDetails:
            self.messagePrimary.text = @"Loading event details...";
            self.messageSecondary.text = @"It should take just a moment.";
            self.messagePrompt.text = @"";
            break;
        case FailedToLoadEventDetails:
            self.messagePrimary.text = @"Failed to load event details.";
            self.messageSecondary.text = @"Sorry for the inconvenience.";
            self.messagePrompt.text = @"Press to retry.";
            break;
        case NoOccurrencesExist:
            self.messagePrimary.text = @"No event details to be found...";
            self.messageSecondary.text = @"This event has probably already passed!";
            self.messagePrompt.text = @"";
            break;            
        default:
            break;
    }
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self.messageSecondary sizeToFit];
    [self.messagePrompt sizeToFit];
    CGFloat secondaryPromptSpacing = self.messageSecondary.text.length > 0 && self.messagePrompt.text.length > 0 ? OIOV_SECONDARY_PROMPT_HORIZONTAL_SPACING : 0;
    CGFloat secondaryAndPromptCombinedWidth = self.messageSecondary.bounds.size.width + secondaryPromptSpacing + self.messagePrompt.bounds.size.width;
    NSLog(@"combined width we'll need is %f", secondaryAndPromptCombinedWidth);
    CGRect messageSecondaryFrame = self.messageSecondary.frame;
    messageSecondaryFrame.origin.x = floorf((self.bounds.size.width - secondaryAndPromptCombinedWidth) / 2.0);
    self.messageSecondary.frame = messageSecondaryFrame;
    CGRect messagePromptFrame = self.messagePrompt.frame;
    messagePromptFrame.origin.x = CGRectGetMaxX(self.messageSecondary.frame) + secondaryPromptSpacing;
    self.messagePrompt.frame = messagePromptFrame;
    NSLog(@"-------- -------- -------- -------- %@ %@", NSStringFromCGRect(self.messageSecondary.frame), NSStringFromCGRect(self.messagePrompt.frame));
}

- (void)dealloc {
    [messagePrimary release];
    [messageSecondary release];
    [messagePrompt release];
    [button release];
    [super dealloc];
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
