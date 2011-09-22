//
//  EventsFeedbackView.h
//  kwiqet
//
//  Created by Dan Bretl on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomSolo = 1,
    CustomComplex = 2,
    LoadingEvents = 3,
    LookingAtEvents = 4,
    NoEventsFound = 5,
    ConnectionError = 6,
    SetFiltersPrompt = 7,
    CloseDrawerToLoadPrompt = 8,
} EventsFeedbackMessageType;

@interface EventsFeedbackView : UIView {
    
    UIView * backgroundView_;
    UIView * messagesContainer_;
    UILabel * messageHeader_;
    UILabel * messageMain_;
    UILabel * messageFollowup_;
    UILabel * messageSolo_;
    UIButton * button_;
    BOOL isMessageSet_;
    BOOL isCurrentMessageComplex_;
    EventsFeedbackMessageType messageType_;
    
}

- (void) setMessagesToShowMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
- (void) setMessagesToShowCustomMessageSolo:(NSString *)messageSoloString;
- (void) setMessagesToShowCustomMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString;

- (CGSize) sizeForMessagesWithMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
- (CGSize) sizeForMessagesWithMessageSolo:(NSString *)messageSoloString;
- (CGSize) sizeForMessagesWithMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString;

@property (readonly) BOOL isMessageSet;
@property (readonly) BOOL isCurrentMessageComplex;
@property (readonly) EventsFeedbackMessageType messageType;
@property (readonly) UIView * messagesContainer;
@property (readonly) UIButton * button;

+ (BOOL) doesMessageTypeRequireComplexMessage:(EventsFeedbackMessageType)messageType;

@end
