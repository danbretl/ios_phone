//
//  LocationSetterView.m
//  kwiqet
//
//  Created by Dan Bretl on 10/18/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import "LocationSetterView.h"
#import "UIFont+Kwiqet.h"

BOOL const LSV_DEBUGGING = YES;

float const LSV_HEADER_BAR_HEIGHT = 44.0;
float const LSV_HEADER_BAR_HORIZONTAL_PADDING = 10.0;
float const LSV_HEADER_BAR_ELEMENT_SPACING = 5.0;

@interface LocationSetterView()
@property (retain) UIView * headerBar;
@property (retain) UIButton * cancelButton;
@property (retain) UILabel * headerLabel;
@property (retain) UIButton * doneButton;
@property (retain) UITextField * locationTextField;
@property (retain) UIButton * currentLocationButton;
@end

@implementation LocationSetterView

@synthesize headerBar=headerBar_, cancelButton=cancelButton_, headerLabel=headerLabel_, doneButton=doneButton_;
@synthesize locationTextField=locationTextField_, currentLocationButton=currentLocationButton_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor redColor];
        
        headerBar_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, LSV_HEADER_BAR_HEIGHT)];
        self.headerBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.headerBar];
        
        UIImage * cancelButtonImage = [UIImage imageNamed:@"btn_cancel.png"];
        UIImage * cancelButtonImageTouch = [UIImage imageNamed:@"btn_cancel_touch.png"];
        UIImage * doneButtonImage = [UIImage imageNamed:@"btn_done.png"];
        UIImage * doneButtonImageTouch = [UIImage imageNamed:@"btn_done_touch.png"];
        
        cancelButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        self.cancelButton.frame = CGRectMake(LSV_HEADER_BAR_HORIZONTAL_PADDING, (self.headerBar.frame.size.height - cancelButtonImage.size.height) / 2.0, cancelButtonImage.size.width, cancelButtonImage.size.height);
        self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
        [self.cancelButton setImage:cancelButtonImageTouch forState:UIControlStateHighlighted];
        [self.headerBar addSubview:self.cancelButton];
        
        doneButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        self.doneButton.frame = CGRectMake(self.headerBar.frame.size.width - LSV_HEADER_BAR_HORIZONTAL_PADDING - doneButtonImage.size.width, (self.headerBar.frame.size.height - doneButtonImage.size.height) / 2.0, doneButtonImage.size.width, doneButtonImage.size.height);
        self.doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.doneButton setImage:doneButtonImage forState:UIControlStateNormal];
        [self.doneButton setImage:doneButtonImageTouch forState:UIControlStateHighlighted];
        [self.headerBar addSubview:self.doneButton];
        
        CGFloat headerLabelMinX = CGRectGetMaxX(self.cancelButton.frame) + LSV_HEADER_BAR_ELEMENT_SPACING;
        CGFloat headerLabelMaxX = CGRectGetMinX(self.doneButton.frame) - LSV_HEADER_BAR_ELEMENT_SPACING;
        headerLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelMinX, 0, headerLabelMaxX - headerLabelMinX, self.headerBar.frame.size.height)];
        self.headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.headerLabel.textAlignment = UITextAlignmentCenter;
        self.headerLabel.text = @"Set Location";
        [self.headerBar addSubview:self.headerLabel];
        
        
        
        if (LSV_DEBUGGING) {
            self.headerBar.backgroundColor = [UIColor yellowColor];
            self.headerLabel.backgroundColor = [UIColor greenColor];
        }
        
    }
    return self;
}

- (void)dealloc {
    [headerBar_ release];
    [cancelButton_ release];
    [headerLabel_ release];
    [doneButton_ release];
    [locationTextField_ release];
    [currentLocationButton_ release];
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
