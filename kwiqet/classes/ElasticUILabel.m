//
//  ElasticUILabel.m
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "ElasticUILabel.h"

CGFloat const ELASTICUILABEL_GRADIENT_VIEW_WIDTH = 45.0;

@interface ElasticUILabel()
@property (nonatomic, retain) GradientView * gradientView;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, retain) UILabel * label;
- (void) initWithFrameOrCoder;
@end

@implementation ElasticUILabel

@synthesize gradientView, scrollView, label;
@synthesize text, color;
@synthesize overlayView = overlayView_;

- (void)dealloc {
    [gradientView release];
    [scrollView release];
    [label release];
    [text release];
    [color release];
    [overlayView_ release];
    [super dealloc];
}

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
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, self.frame.size.width - 5, self.frame.size.height)];
    //self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.label.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:25];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = UITextAlignmentLeft;
    [self.scrollView addSubview:self.label];
    
    gradientView = [[GradientView alloc] initWithFrame:CGRectMake(self.frame.size.width - ELASTICUILABEL_GRADIENT_VIEW_WIDTH, 0, ELASTICUILABEL_GRADIENT_VIEW_WIDTH, self.frame.size.height)];
    self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.gradientView.userInteractionEnabled = NO;
    [self insertSubview:self.gradientView aboveSubview:self.label];
    
    self.color = [UIColor blackColor];
    self.text = @"";
    
}

- (void)setOverlayView:(UIView *)overlayView {
    if (overlayView_ != overlayView) {
        [self.overlayView removeFromSuperview];
        [overlayView_ release];
        overlayView_ = [overlayView retain];
        [self addSubview:self.overlayView];
        [self bringSubviewToFront:self.overlayView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)theScrollView willDecelerate:(BOOL)decelerate {
    if (theScrollView == self.scrollView) {
        if (self.scrollView.contentOffset.x > 0) {
            if (!decelerate) {
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)theScrollView {
    if (theScrollView == self.scrollView) {
        if (self.scrollView.contentOffset.x > 0) {
            [self scrollTextToOriginAnimated:YES];
        }
    }
}

- (void) scrollTextToOriginAnimated:(BOOL)animated {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animated];
}

- (void)setText:(NSString *)theText {
    if (text != theText) {
        [text release];
        text = [theText copy];
        self.label.text = self.text;
        [self.label sizeToFit];
        BOOL textIsTooBig = (self.label.frame.origin.x + self.label.bounds.size.width + 5 > self.scrollView.bounds.size.width);
//        NSLog(@"textIsTooBig?=%d", textIsTooBig);
        self.scrollView.scrollEnabled = textIsTooBig;
        self.gradientView.hidden = !textIsTooBig;
        self.scrollView.contentSize = CGSizeMake(self.label.bounds.size.width + ELASTICUILABEL_GRADIENT_VIEW_WIDTH, self.scrollView.bounds.size.height);
    }
}

- (void)setColor:(UIColor *)theColor {
    if (color != theColor) {
//        NSLog(@"ElasticUILabel setColor:%@", theColor);
        [color release];
        color = [theColor retain];
        self.backgroundColor = self.color;
        self.gradientView.colorEnd = self.color;
    }
}

//- (void)flashScrollBar {
//    [self.scrollView flashScrollIndicators];
//}

//- (void)wiggleLabel {
//    
//    void (^labelLeft)(void) = ^{
//        [self.scrollView setContentOffset:CGPointMake(-10.0, 0.0)];
//    };
//    void (^labelRight)(void) = ^{
//        [self.scrollView setContentOffset:CGPointMake(10.0, 0.0)];
//    };
//    void (^labelNorm)(void) = ^{
//        [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)];
//    };
//    
//    [UIView animateWithDuration:0.2 
//                     animations:^{
//                         labelLeft();
//                     }
//                     completion:^(BOOL finished){
//                         [UIView animateWithDuration:0.2 
//                                          animations:^{
//                                              labelRight();
//                                          }
//                                          completion:^(BOOL finished) {
//                                              labelNorm();
//                                          }];
//                     }];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
 */

@end
