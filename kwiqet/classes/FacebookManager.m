//
//  FacebookManager.m
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookManager.h"

static NSString * const FB_FACEBOOK_APP_ID = @"210861478950952";
static NSString * const FB_FACEBOOK_ACCESS_TOKEN_KEY = @"FBAccessTokenKey";
static NSString * const FB_FACEBOOK_EXPIRATION_DATE_KEY = @"FBExpirationDateKey";

@implementation FacebookManager

- (void)dealloc {
    [facebook release];
    [super dealloc];
}

- (Facebook *)facebook {
    if (facebook == nil) {
        facebook = [[Facebook alloc] initWithAppId:FB_FACEBOOK_APP_ID];
    }
    return facebook;
}
- (Facebook *)fb { return self.facebook; }

- (void)pullAuthenticationInfoFromDefaults {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:FB_FACEBOOK_ACCESS_TOKEN_KEY] && 
        [defaults objectForKey:FB_FACEBOOK_EXPIRATION_DATE_KEY]) {
        self.fb.accessToken = [defaults objectForKey:FB_FACEBOOK_ACCESS_TOKEN_KEY];
        self.fb.expirationDate = [defaults objectForKey:FB_FACEBOOK_EXPIRATION_DATE_KEY];
    }
}

- (void)pushAuthenticationInfoToDefaults {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.fb.accessToken forKey:FB_FACEBOOK_ACCESS_TOKEN_KEY];
    [defaults setObject:self.fb.expirationDate forKey:FB_FACEBOOK_EXPIRATION_DATE_KEY];
    [defaults synchronize];
}

- (void)authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate {
    NSArray * permissions = [NSArray arrayWithObjects:@"user_events", @"create_event", @"rsvp_event", @"user_likes", @"user_interests", @"user_religion_politics", nil];
    [self.fb authorize:permissions delegate:delegate];
}

@end
