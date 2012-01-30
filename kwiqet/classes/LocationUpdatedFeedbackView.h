//
//  LocationUpdatedFeedbackView.h
//  Kwiqet
//
//  Created by Dan Bretl on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Updating = 10,
    Updated = 15,
    Custom = 20,
} LocationUpdatedFeedbackMessageType;

@interface LocationUpdatedFeedbackView : UIView {
    
    UILabel * label_;
    UIImageView * backgroundImageView_;
    UIImageView * foregroundImageView_;
    UIView * shadow_;
    
    LocationUpdatedFeedbackMessageType messageType_;
    NSDate * dateLastUpdated_;
    
}

//- (void) setBackgroundImage:(UIImage *)backgroundImage;
//- (void) setForegroundImage:(UIImage *)foregroundImage;

- (void) setVisible:(BOOL)visible animated:(BOOL)animated;
- (void) setLabelText:(NSString *)labelText animated:(BOOL)animated;
- (void) setLabelTextToUpdatingAnimated:(BOOL)animated; // "updating location"
- (void) setLabelTextToUpdatedDate:(NSDate *)dateLastUpdated animated:(BOOL)animated; // "updated ... ago"
- (void) updateLabelTextForCurrentUpdatedDateAnimated:(BOOL)animated;

@end
