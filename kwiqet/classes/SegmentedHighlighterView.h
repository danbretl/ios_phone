//
//  SegmentedHighlighterView.h
//  kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedHighlighterView : UIView {
    NSMutableArray * segmentHighlightAmounts;
    UIColor * highlightColor;
}

@property (nonatomic) int numberOfSegments;
@property (retain) UIColor * highlightColor;

- (void) setHighlightAmount:(float)highlightAmount forSegmentAtIndex:(int)index;

@end
