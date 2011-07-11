//
//  ElasticUILabel.m
//  kwiqet
//
//  Created by Dan Bretl on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ElasticUILabel.h"

CGFloat const ELASTICUILABEL_GRADIENT_VIEW_WIDTH = 45.0;

@interface ElasticUILabel()
@property (nonatomic, retain) GradientView * gradientView;
@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, retain) UILabel * label;
- (void) scrollViewContentOffsetToOriginAnimated;
@end

@implementation ElasticUILabel

@synthesize gradientView, scrollView, label;
@synthesize text, color;

- (void)dealloc {
    [gradientView release];
    [scrollView release];
    [label release];
    [text release];
    [color release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, frame.size.width - 5, frame.size.height)];
        //self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:25];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = UITextAlignmentLeft;
        [self.scrollView addSubview:self.label];
        
        self.gradientView = [[GradientView alloc] initWithFrame:CGRectMake(frame.size.width - ELASTICUILABEL_GRADIENT_VIEW_WIDTH, 0, ELASTICUILABEL_GRADIENT_VIEW_WIDTH, frame.size.height)];
        self.gradientView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.gradientView.userInteractionEnabled = NO;
        [self addSubview:self.gradientView];
        [self bringSubviewToFront:self.gradientView];
        
        self.color = [UIColor blackColor];
        self.text = @"";

    }
    return self;
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
            [self scrollViewContentOffsetToOriginAnimated];
        }
    }
}

- (void) scrollViewContentOffsetToOriginAnimated {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
        self.gradientView.color = self.color;
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
