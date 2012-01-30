//
//  OccurrenceInfoOverlayView.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/9/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LoadingEventDetails = 1,
    FailedToLoadEventDetails = 2,
    NoOccurrencesExist = 3,
} OccurrenceInfoOverlayMode;

@interface OccurrenceInfoOverlayView : UIView {
    
    UILabel * messagePrimary;
    UILabel * messageSecondary;
    UILabel * messagePrompt;
    UIButton * button;
    
}

@property (readonly) UILabel * messagePrimary;
@property (readonly) UILabel * messageSecondary;
@property (readonly) UILabel * messagePrompt;
@property (readonly) UIButton * button;

- (void) setMessagesForMode:(OccurrenceInfoOverlayMode)mode;

@end
