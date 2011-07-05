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

@synthesize coreDataModel;

- (void)dealloc {
    [facebook release];
    [coreDataModel release];
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



- (void)login {
    [self pullAuthenticationInfoFromDefaults];
    [self authorizeWithStandardPermissionsAndDelegate:self];
}

- (void)authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate {
    NSArray * permissions = [NSArray arrayWithObjects:@"user_events", @"create_event", @"rsvp_event", @"user_likes", @"user_interests", @"user_religion_politics", nil];
    [self.fb authorize:permissions delegate:delegate];
}

- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    [self pushAuthenticationInfoToDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_ACCOUNT_ACTIVITY_KEY object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN, FBM_ACCOUNT_ACTIVITY_ACTION_KEY, nil]];
    [self updateFacebookFriends];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_ACCOUNT_ACTIVITY_KEY object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:FBM_ACCOUNT_ACTIVITY_ACTION_FAILURE, FBM_ACCOUNT_ACTIVITY_ACTION_KEY, nil]];
}



- (void) updateFacebookFriends {
    [self.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)requestLoading:(FBRequest *)request {
    NSLog(@"FB request loading...");
}

- (void) request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"FB request success %@ - %@", request, result);
    [self.coreDataModel addOrUpdateContactsFromFacebook:[result objectForKey:@"data"]];
    [self.coreDataModel coreDataSave];
    NSLog(@"%@", [self.coreDataModel getAllContacts]);
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_UPDATE_SUCCESS_KEY object:self userInfo:nil];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"FB request failed - %@", error);
}



- (void)logout {
    [self.fb logout:self];
}

- (void)fbDidLogout {
    NSLog(@"fbDidLogout");
    // We don't really NEED to do the following, but I think it provides a "more trustworthy" user experience. If we didn't do the following, then the user could touch to disconnect facebook, then touch to connect facebook again, and they might automatically be connected without any sort of dialog or anything (because the access token was still valid for the given expiration date). That is convenient, but a user would rarely be trying to do this, and I would argue that it would be more likely that logout and login would be touched in a way that would expect a dialog. (Bad sentence, but hopefully you get my point.)
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT, FBM_ACCOUNT_ACTIVITY_ACTION_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_ACCOUNT_ACTIVITY_KEY object:self userInfo:userInfo];
}

@end
