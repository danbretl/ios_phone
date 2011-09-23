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
+ (CGPoint) originNeededToCenterChildFrameOfSize:(CGSize)childFrameSize withinParentFrame:(CGRect)parentFrame;
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
    webActivityViewFrame.origin = [WebActivityView originNeededToCenterChildFrameOfSize:size withinParentFrame:parentFrame];
    return [self initWithFrame:webActivityViewFrame];
}

+ (CGPoint) originNeededToCenterChildFrameOfSize:(CGSize)childFrameSize withinParentFrame:(CGRect)parentFrame {
    return CGPointMake(parentFrame.origin.x + roundf((parentFrame.size.width - childFrameSize.width) / 2.0), 
                       parentFrame.origin.y +roundf((parentFrame.size.height - childFrameSize.height) / 2.0));
}

- (void) recenterInFrame:(CGRect)parentFrame {
    CGRect selfFrame = self.frame;
    selfFrame.origin = [WebActivityView originNeededToCenterChildFrameOfSize:selfFrame.size withinParentFrame:parentFrame];
    self.frame = selfFrame;
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
