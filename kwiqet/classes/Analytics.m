//
//  Analytics.m
//  kwiqet
//
//  Created by Dan Bretl on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Analytics.h"

static NSString * const ANALYTICS_SHARE_METHOD_EMAIL = @"email";
static NSString * const ANALYTICS_SHARE_METHOD_FACEBOOK = @"facebook";
static NSString * const ANALYTICS_LETS_GO_METHOD_CALENDAR = @"calendar";
static NSString * const ANALYTICS_LETS_GO_METHOD_FACEBOOK = @"facebook";

@interface Analytics()
+ (void) localyticsSendShareEvent:(Event *)event usingMethod:(NSString *)shareMethod;
+ (void) localyticsSendLetsGoToEvent:(Event *)event usingMethod:(NSString *)letsGoMethod;
@end

@implementation Analytics

+ (void) localyticsSendGetEventsWithFilter:(NSString *)filterString category:(NSString *)categoryString {
    
    NSMutableDictionary * localyticsDictionary = [NSMutableDictionary dictionary];
    
    if (filterString) {
        [localyticsDictionary setValue:filterString forKey:@"filter"];
    }
    if (categoryString) {
        [localyticsDictionary setValue:categoryString forKey:@"category"];
    }
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Get Events" attributes:localyticsDictionary];

}

+ (void) localyticsSendShareEvent:(Event *)event usingMethod:(NSString *)shareMethod {
    
    NSMutableDictionary * localyticsDictionary = [NSMutableDictionary dictionary];
    
    if (event.title) {
        [localyticsDictionary setValue:event.title forKey:@"event title"];
    }
    if (event.concreteParentCategory.title) {
        [localyticsDictionary setValue:event.concreteParentCategory.title forKey:@"concrete parent category title"];
    }
    [localyticsDictionary setValue:shareMethod forKey:@"share method"];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Share Event" attributes:localyticsDictionary];
    
}

+ (void) localyticsSendShareViaEmailWithEvent:(Event *)event {
    [self localyticsSendShareEvent:event usingMethod:ANALYTICS_SHARE_METHOD_EMAIL];
}

+ (void) localyticsSendShareViaFacebookWithEvent:(Event *)event {
    [self localyticsSendShareEvent:event usingMethod:ANALYTICS_SHARE_METHOD_FACEBOOK];
}

+ (void) localyticsSendLetsGoToEvent:(Event *)event usingMethod:(NSString *)letsGoMethod {
    
    NSMutableDictionary * localyticsDictionary = [NSMutableDictionary dictionary];
    
    if (event.title) {
        [localyticsDictionary setValue:event.title forKey:@"event title"];
    }
    if (event.concreteParentCategory.title) {
        [localyticsDictionary setValue:event.concreteParentCategory.title forKey:@"concrete parent category title"];
    }
    [localyticsDictionary setValue:letsGoMethod forKey:@"let's go method"];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Let's Go to Event" attributes:localyticsDictionary];
    
}

+ (void) localyticsSendLetsGoAddToCalendarWithEvent:(Event *)event {
    [self localyticsSendLetsGoToEvent:event usingMethod:ANALYTICS_LETS_GO_METHOD_CALENDAR];
}

+ (void) localyticsSendLetsGoCreateFacebookEventWithEvent:(Event *)event {
    [self localyticsSendLetsGoToEvent:event usingMethod:ANALYTICS_LETS_GO_METHOD_FACEBOOK];    
}

@end
