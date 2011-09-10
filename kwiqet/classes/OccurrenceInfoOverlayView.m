//
//  OccurrenceInfoOverlayView.m
//  kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OccurrenceInfoOverlayView.h"
#import "UIFont+Kwiqet.h"

@implementation OccurrenceInfoOverlayView

@synthesize messagePrimary, messageSecondary, messagePrompt;
@synthesize button;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.20 alpha:0.8];
        
        messagePrimary = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2.0)];
        self.messagePrimary.font = [UIFont kwiqetFontOfType:BoldNormal size:18];
        self.messagePrimary.adjustsFontSizeToFitWidth = NO;
        self.messagePrimary.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
        self.messagePrimary.textAlignment = UITextAlignmentCenter;
        self.messagePrimary.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.messagePrimary];
        
        messageSecondary = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.messagePrimary.frame), frame.size.width - 100, frame.size.height / 2.0)];
        self.messageSecondary.font = [UIFont kwiqetFontOfType:LightNormal size:14.0];
        self.messageSecondary.adjustsFontSizeToFitWidth = NO;
        self.messageSecondary.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
        self.messageSecondary.textAlignment = UITextAlignmentRight;
        [self addSubview:self.messageSecondary];
        
        messagePrompt = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.messageSecondary.frame), self.messageSecondary.frame.origin.y, 100, self.messageSecondary.frame.size.height)];
        self.messageSecondary.font = [UIFont kwiqetFontOfType:RegularNormal size:14.0];
        self.messageSecondary.adjustsFontSizeToFitWidth = NO;
        self.messageSecondary.textColor = [UIColor greenColor];
        self.messageSecondary.textAlignment = UITextAlignmentLeft;
        [self addSubview:self.messagePrompt];
        
        button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        self.button.frame = self.bounds;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.button];
        [self bringSubviewToFront:self.button];
        
//        self.messagePrimary.backgroundColor = [UIColor yellowColor]; // Debugging
//        self.messageSecondary.backgroundColor = [UIColor redColor]; // Debugging
//        self.messagePrompt.backgroundColor = [UIColor orangeColor]; // Debugging
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
