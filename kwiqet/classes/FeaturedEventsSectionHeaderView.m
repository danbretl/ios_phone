//
//  FeaturedEventsSectionHeaderView.m
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedEventsSectionHeaderView.h"
#import "UIFont+Kwiqet.h"


@implementation FeaturedEventsSectionHeaderView

@synthesize titleLabel=titleLabel_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"featured_events_section_bar.png"]];
        titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 2 * 10, frame.size.height)];
        self.titleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor colorWithWhite:53.0/255.0 alpha:1.0];
        self.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.titleLabel];
        self.titleLabel.text = @"Featured Events";
        NSLog(@"self.titleLabel.frame = %@", NSStringFromCGRect(self.titleLabel.frame));
    }
    return self;
}

- (void)dealloc {
    [titleLabel_ release];
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
