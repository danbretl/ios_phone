//
//  EventsFeedbackView.h
//  Kwiqet
//
//  Created by Dan Bretl on 9/16/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomSolo = 10,
    CustomComplex = 15,
    LoadingEvents = 20,
    LoadingEventsTrue = 25,
    LookingAtEvents = 30,
    NoEventsFound = 40,
    ConnectionError = 45,
    SetFiltersPrompt = 50,
    CloseDrawerToLoadPrompt = 55,
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
