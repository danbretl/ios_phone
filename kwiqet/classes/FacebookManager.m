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
static NSString * const FBM_REQUEST_UPDATE_FRIENDS = @"fbmRequestTypeUpdateFriends";
static NSString * const FBM_REQUEST_CREATE_EVENT = @"fbmRequestTypeCreateEvent";
static NSString * const FBM_REQUEST_INVITE_FRIENDS_TO_EVENT = @"fbmRequestTypeInviteFriendsToEvent";

@interface FacebookManager()
@property (retain) FBRequest * currentRequest;
@property (copy) NSString * currentRequestType;
@property (retain) NSArray * eventInvitees;
@end

@implementation FacebookManager

@synthesize coreDataModel;
@synthesize currentRequest, currentRequestType;
@synthesize eventInvitees;

- (void)dealloc {
    [facebook release];
    [coreDataModel release];
    [currentRequest release];
    [currentRequestType release];
    [eventInvitees release];
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
    NSArray * permissions = [NSArray arrayWithObjects:@"user_events", @"create_event", @"rsvp_event", @"user_likes", @"user_interests", @"user_religion_politics", @"offline_access", nil];
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



- (void)requestLoading:(FBRequest *)request {
    NSLog(@"Facebook request loading... %@", self.currentRequestType);
}

- (void) updateFacebookFriends {
    self.currentRequestType = FBM_REQUEST_UPDATE_FRIENDS;
    self.currentRequest = [self.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)createFacebookEventWithParameters:(NSMutableDictionary *)parameters inviteContacts:(NSArray *)contactsToInvite {
    self.eventInvitees = contactsToInvite;
    self.currentRequestType = FBM_REQUEST_CREATE_EVENT;
    self.currentRequest = [self.fb requestWithGraphPath:@"me/events"
                                              andParams:parameters 
                                          andHttpMethod:@"POST"
                                            andDelegate:self];
}

- (void) inviteToEvent:(NSString *)eventID contacts:(NSArray *)contacts withPersonalMessage:(NSString *)personalMessage {
    
    NSMutableString * friendIDs = [NSMutableString stringWithString:@""];
    if (contacts && [contacts count] > 0) {
        for (int i=0; i<[contacts count]; i++) {
            if (i != 0) {
                [friendIDs appendString:@","];
            }
            Contact * friend = (Contact *)[contacts objectAtIndex:i];
            [friendIDs appendString:friend.fbID];
        }
    }
    
    self.currentRequestType = FBM_REQUEST_INVITE_FRIENDS_TO_EVENT;
    self.currentRequest = [self.fb requestWithMethodName:@"events.invite" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:eventID, @"eid", friendIDs, @"uids", personalMessage, @"personal_message", nil] andHttpMethod:@"POST" andDelegate:self];
    
}


- (void) request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"FB request success %@ - %@", request, result);
        
    if ([self.currentRequestType isEqualToString:FBM_REQUEST_UPDATE_FRIENDS]) {
        
        [self.coreDataModel addOrUpdateContactsFromFacebook:[result objectForKey:@"data"]];
        [self.coreDataModel coreDataSave];
        [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_UPDATE_SUCCESS_KEY object:self userInfo:nil];
        
    } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_CREATE_EVENT]) {
        
        if ([result objectForKey:@"id"]) {
            [self inviteToEvent:[result objectForKey:@"id"] contacts:self.eventInvitees withPersonalMessage:@"Test invitation message"];
        }
        
    } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_INVITE_FRIENDS_TO_EVENT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:self userInfo:nil];
        
    } else {
        NSLog(@"ERROR in FacebookManager - unrecognized FBRequest type");
    }
        
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {

    NSLog(@"FB request failed: %@", [error localizedDescription]);
    NSLog(@"FB error details: %@", [error description]);
    NSLog(@"FB error userInfo: %@", [error userInfo]);
    
    if ([self.currentRequestType isEqualToString:FBM_REQUEST_UPDATE_FRIENDS]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_UPDATE_FAILURE_KEY object:self userInfo:nil];
        
    } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_CREATE_EVENT]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FBM_CREATE_EVENT_FAILURE_KEY object:self userInfo:nil];
        
    } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_INVITE_FRIENDS_TO_EVENT]) {
        
        // TEMPORARY HACK - FOR SOME REASON, WE ARE GETTING A FACEBOOK ERROR CODE 10000, BUT STILL THE INVITE IS SUCCESSFUL. SO, FOR NOW, WE ARE GOING TO CHECK IF THE ERROR CODE IS 10000, AND IF IT IS, WE ARE GOING TO HOPE/ASSUME THAT EVERYTHING WENT GREAT.
        if ([error code] == 10000) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:self userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY object:self userInfo:nil];
        }
        
    } else {
        NSLog(@"ERROR in FacebookManager - unrecognized FBRequest type");
    }
    
    self.currentRequest = nil;
    self.currentRequestType = nil;
    
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
