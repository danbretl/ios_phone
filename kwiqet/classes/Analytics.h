//
//  Analytics.h
//  Kwiqet
//
//  Created by Dan Bretl on 7/22/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalyticsSession.h"
#import "Event.h"
#import "Category.h"

@interface Analytics : NSObject {
    
}

+ (void) localyticsSendGetEventsWithFilter:(NSString *)filterString category:(NSString *)categoryString;

+ (void) localyticsSendShareViaFacebookWithEvent:(Event *)event;
+ (void) localyticsSendShareViaEmailWithEvent:(Event *)event;

+ (void) localyticsSendLetsGoAddToCalendarWithEvent:(Event *)event;
+ (void) localyticsSendLetsGoCreateFacebookEventWithEvent:(Event *)event;

+ (void) localyticsSendWarning:(NSString *)warningName sourceLocation:(NSString *)sourceLocationString attributes:(NSDictionary *)attributes;

@end
