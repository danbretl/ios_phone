//
//  SegmentedHighlighterView.h
//  Kwiqet
//
//  Created by Dan Bretl on 7/28/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedHighlighterView : UIView {

    int numberOfSegments_;
    float * highlightAmounts;

    UIColor * highlightColor_;
    UIImage * highlightImage_;
    
    BOOL showColor_;
    BOOL showImage_;

}

@property (nonatomic) int numberOfSegments;
@property (nonatomic, retain) UIColor * highlightColor;
@property (nonatomic, retain) UIImage * highlightImage;
@property (nonatomic) BOOL showColor;
@property (nonatomic) BOOL showImage;

- (void) setHighlightAmount:(float)highlightAmount forSegmentAtIndex:(int)index;

@end
