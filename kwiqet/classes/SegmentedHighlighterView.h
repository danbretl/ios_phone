//
//  SegmentedHighlighterView.h
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedHighlighterView : UIView {
    UIColor * highlightColor;
    int numberOfSegments_;
    float * highlightAmounts;
}

@property (nonatomic) int numberOfSegments;
@property (retain) UIColor * highlightColor;

- (void) setHighlightAmount:(float)highlightAmount forSegmentAtIndex:(int)index;

@end
