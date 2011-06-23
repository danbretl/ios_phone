//
//  WebActivityView.m
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebActivityView.h"
#import <QuartzCore/QuartzCore.h>

float const WEB_ACTIVITY_VIEW_DEFAULT_BACKGROUND_WHITE_VALUE = 0.25;
float const WEB_ACTIVITY_VIEW_DEFAULT_BACKGROUND_ALPHA = 0.15;

@interface WebActivityView()
@property (retain) UIActivityIndicatorView * activityView;
- (void)setVisible:(BOOL)visible animated:(BOOL)animated;
@end

@implementation WebActivityView

@synthesize activityView;

- (void)dealloc {
    [activityView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:WEB_ACTIVITY_VIEW_DEFAULT_BACKGROUND_WHITE_VALUE alpha:WEB_ACTIVITY_VIEW_DEFAULT_BACKGROUND_ALPHA];
        self.layer.cornerRadius = roundf(frame.size.width / 2.0);
        self.layer.masksToBounds = YES;
        self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.activityView.frame = CGRectMake(roundf((self.frame.size.width - self.activityView.frame.size.width) / 2.0) , ((self.frame.size.height - self.activityView.frame.size.height) / 2.0), self.activityView.frame.size.width, self.activityView.frame.size.height);
        [self addSubview:self.activityView];
        [self hideAnimated:NO];
    }
    return self;
}

- (id) initWithSize:(CGSize)size centeredInFrame:(CGRect)parentFrame {
    CGRect webActivityViewFrame;
    webActivityViewFrame.size = size;
    webActivityViewFrame.origin = CGPointMake(roundf((parentFrame.size.width - size.width) / 2), roundf((parentFrame.size.height - size.height) / 2));
    return [self initWithFrame:webActivityViewFrame];
}

- (void)showAnimated:(BOOL)animated {
    [self setVisible:YES animated:animated];
}

- (void)hideAnimated:(BOOL)animated {
    [self setVisible:NO animated:animated];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    void (^changesBlock)(void) = ^{
        self.alpha = visible ? 1.0 : 0.0;
        if (visible) {
            [self.activityView startAnimating];
        } else {
            [self.activityView stopAnimating];
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:changesBlock];
    } else {
        changesBlock();
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
