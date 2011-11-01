//
//  EventCellContentView.h
//  kwiqet
//
//  Created by Dan Bretl on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventCellContentViewDelegate;

@interface EventCellContentView : UIView {
    
    UIImage * categoryIcon_;
    UIColor * categoryColor_;
    
    NSString * titleString_;
    NSString * locationString_;
    NSString * dateAndTimeString_;
    
    NSString * priceOriginalString_;
    BOOL isPriceChanged_;
    NSString * priceChangedString_;
    NSString * priceSavingsString_;
    
    BOOL highlighted;
    BOOL editing;
    
    id<EventCellContentViewDelegate> delegate;
    
}

@property (nonatomic, retain) UIImage * categoryIcon;
@property (nonatomic, retain) UIColor * categoryColor;

@property (nonatomic, copy) NSString * titleString;
@property (nonatomic, copy) NSString * locationString;
@property (nonatomic, copy) NSString * dateAndTimeString;

@property (nonatomic, copy) NSString * priceOriginalString;
- (void) setIsPriceChanged:(BOOL)isPriceChanged withPriceChangedString:(NSString *)priceChangedString priceSavingsString:(NSString *)priceSavingsString;

@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;

@property (assign) id<EventCellContentViewDelegate> delegate;

@end

@protocol EventCellContentViewDelegate <NSObject>
@required
- (void) categoryColorWasSetToColor:(UIColor *)categoryColor;
@end
