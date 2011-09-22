//
//  EventsFeedbackView.m
//  kwiqet
//
//  Created by Dan Bretl on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsFeedbackView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Kwiqet.h"

@interface EventsFeedbackView()
- (void) initWithFrameOrCoder;
- (CGFloat) heightForSingleMessage:(NSString *)messageString inMessageLabel:(UILabel *)messageLabel;
- (CGSize) sizeForSingleMessage:(NSString *)messageString inMessageLabel:(UILabel *)messageLabel;
- (CGSize) sizeForComplexMessage:(BOOL)complexMessage shouldMakeAdjustments:(BOOL)shouldMakeAdjustments withMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString messageSolo:(NSString *)messageSoloString;
- (CGSize) sizeForComplexMessage:(BOOL)complexMessage shouldMakeAdjustments:(BOOL)shouldMakeAdjustments withMessageHeaderSize:(CGSize)messageHeaderSize messageMainSize:(CGSize)messageMainSize messageFollowupSize:(CGSize)messageFollowupSize messageSoloSize:(CGSize)messageSoloSize;
- (void) setMessagesToShowComplexMessage:(BOOL)complexMessage withMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString messageSolo:(NSString *)messageSoloString;
- (NSString *) messageSoloForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
- (NSString *) messageHeaderForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
- (NSString *) messageMainForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
- (NSString *) messageFollowupForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString;
@property (readonly) UIView * backgroundView;
@property (readonly) UILabel * messageHeader;
@property (readonly) UILabel * messageMain;
@property (readonly) UILabel * messageFollowup;
@property (readonly) UILabel * messageSolo;
@end

@implementation EventsFeedbackView

@synthesize backgroundView=backgroundView_, messagesContainer=messagesContainer_, messageHeader=messageHeader_, messageMain=messageMain_, messageFollowup=messageFollowup_, messageSolo=messageSolo_, button=button_, isMessageSet=isMessageSet_, isCurrentMessageComplex=isCurrentMessageComplex_, messageType=messageType_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self initWithFrameOrCoder];
    }
    return self;
}

- (void) initWithFrameOrCoder {
    
    isMessageSet_ = NO;
    
    backgroundView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height+10)];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithWhite:0.0/255.0 alpha:0.9];
    self.backgroundView.layer.cornerRadius = 10.0;
    self.backgroundView.layer.shadowColor = [UIColor colorWithWhite:53.0/255.0 alpha:0.6].CGColor;
    self.backgroundView.layer.shadowOpacity = 1.0;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    self.backgroundView.layer.shadowRadius = 1.0;
//    self.backgroundView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundView.bounds cornerRadius:self.backgroundView.layer.cornerRadius].CGPath;
    [self addSubview:self.backgroundView];
    
    messagesContainer_ = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 10 * 2, self.bounds.size.height)];
    self.messagesContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messagesContainer.backgroundColor = [UIColor clearColor];//[UIColor orangeColor];
    [self insertSubview:self.messagesContainer aboveSubview:self.backgroundView];
    
    messageHeader_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.messagesContainer.bounds.size.width, 40)];
    self.messageHeader.font = [UIFont kwiqetFontOfType:BoldNormal size:25];
    self.messageHeader.adjustsFontSizeToFitWidth = NO;
    self.messageHeader.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.messageHeader.textAlignment = UITextAlignmentLeft;
    self.messageHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageHeader.backgroundColor = [UIColor clearColor];//[UIColor redColor];
    [self.messagesContainer addSubview:self.messageHeader];
    
    messageMain_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.messagesContainer.bounds.size.width, 40)];
    self.messageMain.font = [UIFont kwiqetFontOfType:LightNormal size:15];
    self.messageMain.adjustsFontSizeToFitWidth = NO;
    self.messageMain.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.messageMain.textAlignment = UITextAlignmentLeft;
    self.messageMain.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageMain.backgroundColor = [UIColor clearColor];//[UIColor blueColor];
    self.messageMain.numberOfLines = 0;
    [self.messagesContainer addSubview:self.messageMain];
    
    messageFollowup_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, self.messagesContainer.bounds.size.width, 40)];
    self.messageFollowup.font = [UIFont kwiqetFontOfType:BoldNormal size:15];
    self.messageFollowup.adjustsFontSizeToFitWidth = NO;
    self.messageFollowup.textColor = [UIColor colorWithRed:153.0/255.0 green:243.0/255.0 blue:147.0/255.0 alpha:1.0];
    self.messageFollowup.textAlignment = UITextAlignmentLeft;
    self.messageFollowup.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageFollowup.backgroundColor = [UIColor clearColor];//[UIColor purpleColor];
    [self.messagesContainer addSubview:self.messageFollowup];
    
    messageSolo_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, self.messagesContainer.bounds.size.width, self.messagesContainer.bounds.size.height)];
    self.messageSolo.font = [UIFont kwiqetFontOfType:BoldNormal size:10];
    self.messageSolo.adjustsFontSizeToFitWidth = NO;
    self.messageSolo.textColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    self.messageSolo.textAlignment = UITextAlignmentLeft;
    self.messageSolo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageSolo.backgroundColor = [UIColor clearColor];//[UIColor greenColor];
    self.messageSolo.numberOfLines = 0;
    [self.messagesContainer addSubview:self.messageSolo];
    
    button_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.button.enabled = YES;
    [self addSubview:self.button];
    [self bringSubviewToFront:self.button];
    
    self.userInteractionEnabled = NO;
    
}

- (void)dealloc {
    [backgroundView_ release];
    [messagesContainer_ release];
    [messageHeader_ release];
    [messageMain_ release];
    [messageFollowup_ release];
    [messageSolo_ release];
    [button_ release];
    [super dealloc];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    self.backgroundView.backgroundColor = backgroundColor;
}

// This method duplicates a lot of math happening in sizeForComplexMessage... Should figure out a way to consolidate, because these two methods could get out of sync very easily. // UPDATE: Fixed! All the logic now resides in sizeForComplexMessage...
- (void)layoutSubviews {
    [super layoutSubviews];
    [self sizeForComplexMessage:self.isCurrentMessageComplex shouldMakeAdjustments:YES withMessageHeader:self.messageHeader.text messageMain:self.messageMain.text messageFollowup:self.messageFollowup.text messageSolo:self.messageSolo.text];    
}

- (CGSize) sizeForComplexMessage:(BOOL)complexMessage shouldMakeAdjustments:(BOOL)shouldMakeAdjustments withMessageHeaderSize:(CGSize)messageHeaderSize messageMainSize:(CGSize)messageMainSize messageFollowupSize:(CGSize)messageFollowupSize messageSoloSize:(CGSize)messageSoloSize {
    
    CGFloat messagesContainerHeight = 0;
    
    if (complexMessage) {
    
        CGFloat verticalSpacingAfterHeader = messageHeaderSize.height > 0 ? 6 : 0;
        CGFloat verticalSpacingAfterMain = messageMainSize.height > 0 ? 9 : 0;
        CGFloat verticalSpacingAfterFollowup = messageFollowupSize.height > 0 ? 10 : 0;
        
        if (shouldMakeAdjustments) {
            CGRect messageHeaderFrame = self.messageHeader.frame;
            messageHeaderFrame.size.height = messageHeaderSize.height;
            self.messageHeader.frame = messageHeaderFrame;
            CGRect messageMainFrame = self.messageMain.frame;
            messageMainFrame.origin.y = messageHeaderFrame.origin.y + messageHeaderFrame.size.height + verticalSpacingAfterHeader;
            messageMainFrame.size.height = messageMainSize.height;
            self.messageMain.frame = messageMainFrame;
            CGRect messageFollowupFrame = self.messageFollowup.frame;
            messageFollowupFrame.origin.y = messageMainFrame.origin.y + messageMainFrame.size.height + verticalSpacingAfterMain;
            messageFollowupFrame.size.height = messageFollowupSize.height;
            self.messageFollowup.frame = messageFollowupFrame;
        }
        
        messagesContainerHeight = self.messageHeader.frame.origin.y + messageHeaderSize.height + verticalSpacingAfterHeader + messageMainSize.height + verticalSpacingAfterMain + messageFollowupSize.height + verticalSpacingAfterFollowup;
        
    } else {
        
        CGFloat verticalSpacingAfterSolo = messageSoloSize.height > 0 ? 7 : 0;
        
        if (shouldMakeAdjustments) {
            CGRect messageSoloFrame = self.messageSolo.frame;
            messageSoloFrame.size = messageSoloSize;
            messageSoloFrame.origin.x = roundf((self.messagesContainer.bounds.size.width - messageSoloFrame.size.width) / 2.0);
            self.messageSolo.frame = messageSoloFrame;
        }
        
        messagesContainerHeight = self.messageSolo.frame.origin.y + messageSoloSize.height + verticalSpacingAfterSolo;
        
    }
    
    if (shouldMakeAdjustments) {
        CGRect messagesContainerFrame = self.messagesContainer.frame;
        messagesContainerFrame.size.height = messagesContainerHeight;
        self.messagesContainer.frame = messagesContainerFrame;
    }
    CGSize compositeMessageSize = CGSizeMake(self.bounds.size.width, messagesContainerHeight);
    
    // The responsibility is now put on the programmer to do the following self.frame adjustment from outside of this class. This is more work for the programmer, but it is more flexible, and is much more appropriate.
//    if (shouldMakeAdjustments) {
//        CGRect selfFrame = self.frame;
//        selfFrame.size = compositeMessageSize;
//        self.frame = selfFrame;
//    }
    
    NSLog(@"EventsFeedbackView, calculated %@compositeMessageSize of %@ (built up from %@)", shouldMakeAdjustments ? @"(and implemented) " : @"", NSStringFromCGSize(compositeMessageSize), complexMessage ? [NSString stringWithFormat:@"headerFrame=%@ mainFrame=%@ followupFrame=%@", NSStringFromCGRect(self.messageHeader.frame), NSStringFromCGRect(self.messageMain.frame), NSStringFromCGRect(self.messageFollowup.frame)] : [NSString stringWithFormat:@"soloFrame=%@", NSStringFromCGRect(self.messageSolo.frame)]);

    return compositeMessageSize;
}

- (CGSize)sizeForComplexMessage:(BOOL)complexMessage shouldMakeAdjustments:(BOOL)shouldMakeAdjustments withMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString messageSolo:(NSString *)messageSoloString {
    CGSize messageHeaderSize = CGSizeZero;
    CGSize messageMainSize = CGSizeZero;
    CGSize messageFollowupSize = CGSizeZero;
    CGSize messageSoloSize = CGSizeZero;
    if (complexMessage) {
        messageHeaderSize = [self sizeForSingleMessage:messageHeaderString inMessageLabel:self.messageHeader];
        messageMainSize = [self sizeForSingleMessage:messageMainString inMessageLabel:self.messageMain];
        messageFollowupSize = [self sizeForSingleMessage:messageFollowupString inMessageLabel:self.messageFollowup];
    } else {
        messageSoloSize = [self sizeForSingleMessage:messageSoloString inMessageLabel:self.messageSolo];
    }
    return [self sizeForComplexMessage:complexMessage shouldMakeAdjustments:shouldMakeAdjustments withMessageHeaderSize:messageHeaderSize messageMainSize:messageMainSize messageFollowupSize:messageFollowupSize messageSoloSize:messageSoloSize];
}

- (CGFloat) heightForSingleMessage:(NSString *)messageString inMessageLabel:(UILabel *)messageLabel {
    return [self sizeForSingleMessage:messageString inMessageLabel:messageLabel].height;
}

- (CGSize)sizeForSingleMessage:(NSString *)messageString inMessageLabel:(UILabel *)messageLabel {
    CGSize messageSize = [messageString sizeWithFont:messageLabel.font constrainedToSize:CGSizeMake(self.messagesContainer.bounds.size.width, 1000) lineBreakMode:UILineBreakModeWordWrap];
    return messageSize;
}

- (CGSize)sizeForMessagesWithMessageSolo:(NSString *)messageSoloString {
    return [self sizeForComplexMessage:NO shouldMakeAdjustments:NO withMessageHeader:nil messageMain:nil messageFollowup:nil messageSolo:messageSoloString];
}

- (CGSize)sizeForMessagesWithMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString {
    return [self sizeForComplexMessage:YES shouldMakeAdjustments:NO withMessageHeader:messageHeaderString messageMain:messageMainString messageFollowup:messageFollowupString messageSolo:nil];
}

- (CGSize) sizeForMessagesWithMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    BOOL complexMessage = [EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType];
    NSString * messageHeader = complexMessage ? [self messageHeaderForMessageType:messageType withEventsString:eventsString searchString:searchString] : nil;
    NSString * messageMain = complexMessage ? [self messageMainForMessageType:messageType withEventsString:eventsString searchString:searchString] : nil;
    NSString * messageFollowup = complexMessage ? [self messageFollowupForMessageType:messageType withEventsString:eventsString searchString:searchString] : nil;
    NSString * messageSolo = complexMessage ? nil : [self messageSoloForMessageType:messageType withEventsString:eventsString searchString:searchString];
    return [self sizeForComplexMessage:complexMessage 
                 shouldMakeAdjustments:NO 
                     withMessageHeader:messageHeader
                           messageMain:messageMain
                       messageFollowup:messageFollowup
                           messageSolo:messageSolo];
}

- (void) setMessagesToShowComplexMessage:(BOOL)complexMessage withMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString messageSolo:(NSString *)messageSoloString {
    
    isMessageSet_ = YES; // We could make this more complex, to check if the string to be set was nil or empty, but, we're not going to for now.
    isCurrentMessageComplex_ = complexMessage;
    self.userInteractionEnabled = complexMessage;
    if (complexMessage) {
        self.messageHeader.text = messageHeaderString;
        self.messageMain.text = messageMainString;
        self.messageFollowup.text = messageFollowupString;
        self.messageHeader.alpha = 1.0;
        self.messageMain.alpha = 1.0;
        self.messageFollowup.alpha = 1.0;
        self.messageSolo.alpha = 0.0;
    } else {
        self.messageSolo.text = messageSoloString;
        self.messageSolo.alpha = 1.0;
        self.messageHeader.alpha = 0.0;
        self.messageMain.alpha = 0.0;
        self.messageFollowup.alpha = 0.0;
    }
    [self layoutSubviews];
}

- (void) setMessagesToShowCustomMessageHeader:(NSString *)messageHeaderString messageMain:(NSString *)messageMainString messageFollowup:(NSString *)messageFollowupString {
    messageType_ = CustomComplex;
    [self setMessagesToShowComplexMessage:YES withMessageHeader:messageHeaderString messageMain:messageMainString messageFollowup:messageFollowupString messageSolo:nil];
}

- (void) setMessagesToShowCustomMessageSolo:(NSString *)messageSoloString {
    messageType_ = CustomSolo;
    [self setMessagesToShowComplexMessage:NO withMessageHeader:nil messageMain:nil messageFollowup:nil messageSolo:messageSoloString];
}

- (NSString *) messageSoloForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    NSString * messageSolo = nil;
    if (![EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType]) {
        if (messageType == LoadingEvents ||
            messageType == LookingAtEvents ||
            messageType == CloseDrawerToLoadPrompt) {
            NSString * leadIn = nil;
            switch (messageType) {
                case LoadingEvents: /*leadIn = @"Loading"; break;*/ // The feedback view is getting a little busy with extremely frequent string updates. For now, I'm going to just make "Loading" messages the same as "Displaying" messages - effectively eliminating the former.
                case LookingAtEvents: leadIn = @"Displaying"; break;
                case CloseDrawerToLoadPrompt: leadIn = @"Swipe up to load"; break;                    
                default:break;
            }
            messageSolo = [NSString stringWithFormat:@"%@ %@.", leadIn, eventsString];            
        } else if (messageType == SetFiltersPrompt) {
            messageSolo = @"Use the filters above to narrow in on the type of events you're interested in.";
        } else {
            NSLog(@"ERROR in EventsFeedbackView - unrecognized simple message type in messageSoloForMessageType...");
        }
    } else {
        NSLog(@"ERROR in EventsFeedbackView - asking for a message solo from an inappropriate message type.");
    }
    return messageSolo;
}

- (NSString *) messageHeaderForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    NSString * message = nil;
    if ([EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType]) {
        message = @"Sorry!";
    } else {
        NSLog(@"ERROR in EventsFeedbackView - asking for a message header from an inappropriate message type.");
    }
    return message;
}

- (NSString *) messageMainForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    NSString * message = nil;
    if ([EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType]) {
        NSString * mainLeadIn = (messageType == NoEventsFound) ? @"We couldn't find any" : @"There was a connection error while trying to load";
        NSString * mainConclusion = (messageType == NoEventsFound) ? @"Try adjusting your filters up top." : @"Check your network settings.";
        message = [NSString stringWithFormat:@"%@ %@. %@", mainLeadIn, eventsString, mainConclusion];
    } else {
        NSLog(@"ERROR in EventsFeedbackView - asking for a message main from an inappropriate message type.");
    }
    return message;
}

- (NSString *) messageFollowupForMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    NSString * message = nil;
    if ([EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType]) {
        message = @"Or, touch here to try again.";
    } else {
        NSLog(@"ERROR in EventsFeedbackView - asking for a message followup from an inappropriate message type.");
    }
    return message;
}

- (void) setMessagesToShowMessageType:(EventsFeedbackMessageType)messageType withEventsString:(NSString *)eventsString searchString:(NSString *)searchString {
    if (messageType == CustomSolo || 
        messageType == CustomComplex) {
        NSLog(@"ERROR in EventsFeedbackView - trying to show a custom message with setMessagesToShowMessageType. Should be using setMessagesToShowCustomMessage... methods instead. Ignoring this method call.");
    } else {
        
        messageType_ = messageType;
        BOOL complexMessage = [EventsFeedbackView doesMessageTypeRequireComplexMessage:messageType];
        NSString * messageHeader = nil;
        NSString * messageMain = nil;
        NSString * messageFollowup = nil;
        NSString * messageSolo = nil;
        
        if (messageType == LoadingEvents ||
            messageType == LookingAtEvents ||
            messageType == SetFiltersPrompt ||
            messageType == CloseDrawerToLoadPrompt) {
            messageSolo = [self messageSoloForMessageType:messageType withEventsString:eventsString searchString:searchString];
        } else if (messageType == NoEventsFound ||
                   messageType == ConnectionError) {
            messageHeader = [self messageHeaderForMessageType:messageType withEventsString:eventsString searchString:searchString];
            messageMain = [self messageMainForMessageType:messageType withEventsString:eventsString searchString:searchString];
            messageFollowup = [self messageFollowupForMessageType:messageType withEventsString:eventsString searchString:searchString];
        } else {
            NSLog(@"ERROR in EventsFeedbackView - undefined message type.");
        }
        
        [self setMessagesToShowComplexMessage:complexMessage withMessageHeader:messageHeader messageMain:messageMain messageFollowup:messageFollowup messageSolo:messageSolo];
        
    }
}

+ (BOOL) doesMessageTypeRequireComplexMessage:(EventsFeedbackMessageType)messageType {
    BOOL complexMessageRequired = (messageType == NoEventsFound || 
                                   messageType == ConnectionError ||
                                   messageType == CustomComplex);
    return complexMessageRequired;
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
