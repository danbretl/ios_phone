//
//  EventCellContentView.m
//  kwiqet
//
//  Created by Dan Bretl on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCellContentView.h"

@interface EventCellContentView()
@property BOOL isPriceChanged;
@property (copy) NSString * priceChangedString;
@property (copy) NSString * priceSavingsString;
@end

@implementation EventCellContentView

@synthesize categoryIcon=categoryIcon_, categoryColor=categoryColor_;
@synthesize titleString=titleString_, locationString=locationString_, dateAndTimeString=dateAndTimeString_;
@synthesize priceOriginalString=priceOriginalString_;
@synthesize isPriceChanged=isPriceChanged_, priceChangedString=priceChangedString_, priceSavingsString=priceSavingsString_;
@synthesize highlighted, editing;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
//        self.opaque = YES;
//        self.backgroundColor = [UIColor whiteColor]; // This will be covered.
        self.highlighted = NO;
        self.editing = NO;
        self.isPriceChanged = NO;
    }
    return self;
}

/*
 Design notes:
 - I've exported borders, icons, and textures in 1x and 2x. 
 - Alpha of the icons is .8
 - The way I did borders is weird/interesting. Basically each cell only has a footer. What this does is ensure that in 1x, we only have 1px separating cells but in 2x gives us the illusion that the cells are more 3D. It also acts as a nice footer to the list. The footer I use on each cell is the exact same as the one I made for the search page (events_list_table_search_footer.png). 1px of #626b71 (98,107,113) with 1px of #c9d2d7 (201,210,215) underneath. It's up to you how you'd like to do these changes (Stretchy image or draw it yourself), but I sent you images just in case.
 - Right edge of the color bar is 1px of #626b71 (98,107,113). I also exported a 1x and 2x version of this border called event_card_cell_bar_left.png
 - Fonts:
 Date: 12pt Helvetica Neue LT Light
 Title: No Change (20pt Helv Neue Medium Condensed)
 Venue: 18pt Helv Neue Light Condensed
 Price: 15pt Helv Neue Light Condensed
 Free: 15pt Helv Neue Medium Condensed
 Discount Amount: Same as free, with color R:0 G:161 B:255
 - These files are in the iPhone/patterns/ directory of dropbox.
 */

- (void)drawRect:(CGRect)rect {
    
#define CATEGORY_BAR_WIDTH 10
    
#define DATE_TIME_ORIGIN_Y 14
#define TITLE_ORIGIN_Y 36
#define VENUE_ORIGIN_Y 57
#define PRICE_ORIGIN_Y 75
    
#define DATE_TIME_FONT_SIZE 12
#define TITLE_FONT_SIZE 20
#define VENUE_FONT_SIZE 18
#define PRICE_FONT_SIZE 15
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    
    Call UIGraphicsBeginImageContextWithOptions to create a bitmap context (with the appropriate scale factor) and push it on the graphics stack.
    Use UIKit or Core Graphics routines to draw the content of the image.
    Call UIGraphicsGetImageFromCurrentImageContext to get the bitmap’s contents.
    Call UIGraphicsEndImageContext to pop the context from the stack.
    For example, the following code snippet creates a bitmap that is 200 x 200 pixels. (The number of pixels is determined by multiplying the size of the image by the scale factor.)
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100.0,100.0), NO, 2.0);
    
    
    
    
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(gc, self.categoryColor.CGColor);
    CGContextFillRect(gc, CGRectMake(0, 0, CATEGORY_BAR_WIDTH, self.bounds.size.height));
    
    CGContextSetFillColorWithColor(gc, [UIColor colorWithRed:98 green:107 blue:113 alpha:1.0].CGColor);
    CGContextFillRect(gc, CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>))
    
}

- (void)setHighlighted:(BOOL)setToHighlighted {
    // If highlighted state changes, need to redisplay.
	if (highlighted != setToHighlighted) {
		highlighted = setToHighlighted;	
		[self setNeedsDisplay];
	}
}

- (void)setCategoryIcon:(UIImage *)categoryIcon {
    if (categoryIcon_ != categoryIcon) {
        [categoryIcon_ release];
        categoryIcon_ = [categoryIcon retain];
        [self setNeedsDisplay];
    }
}

- (void)setCategoryColor:(UIColor *)categoryColor {
    if (categoryColor_ != categoryColor) {
        [categoryColor_ release];
        categoryColor_ = [categoryColor retain];
        [self setNeedsDisplay];
        [self.delegate categoryColorWasSetToColor:self.categoryColor];
    }
}

- (void)setTitleString:(NSString *)titleString {
    if (titleString_ != titleString) {
        [titleString_ release];
        titleString_ = [titleString copy];
        [self setNeedsDisplay];
    }
}

- (void)setLocationString:(NSString *)locationString {
    if (locationString_ != locationString) {
        [locationString_ release];
        locationString_ = [locationString copy];
        [self setNeedsDisplay];
    }
}

- (void)setDateAndTimeString:(NSString *)dateAndTimeString {
    if (dateAndTimeString_ != dateAndTimeString) {
        [dateAndTimeString_ release];
        dateAndTimeString_ = [dateAndTimeString copy];
        [self setNeedsDisplay];
    }
}

- (void)setPriceOriginalString:(NSString *)priceOriginalString {
    if (priceOriginalString_ != priceOriginalString) {
        [priceOriginalString_ release];
        priceOriginalString_ = [priceOriginalString copy];
        [self setNeedsDisplay];
    }
}

- (void)setIsPriceChanged:(BOOL)isPriceChanged withPriceChangedString:(NSString *)priceChangedString priceSavingsString:(NSString *)priceSavingsString {
    self.isPriceChanged = isPriceChanged;
    self.priceChangedString = priceChangedString;
    self.priceSavingsString = priceSavingsString;
    [self setNeedsDisplay];
}

@end
