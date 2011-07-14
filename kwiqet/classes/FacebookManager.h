//
//  FacebookManager.h
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
//#import "CoreDataModel.h"

static NSString * const FBM_OPEN_URL_OFFERED_HANDLER_KEY = @"FBM_OPEN_URL_OFFERED_HANDLER_KEY";

static NSString * const FBM_ACCOUNT_ACTIVITY_KEY = @"fbmAccountActivity";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_KEY = @"fbmAccountActivityAction";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT = @"fbmAccountActivityActionLogout";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN = @"fbmAccountActivityActionLogin";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_FAILURE = @"fbmAccountActivityActionFailure";
static NSString * const FBM_FRIENDS_UPDATE_SUCCESS_KEY = @"FBM_FRIENDS_UPDATE_SUCCESS_KEY";
static NSString * const FBM_FRIENDS_UPDATE_FAILURE_KEY = @"FBM_FRIENDS_UPDATE_FAILURE_KEY";
static NSString * const FBM_FRIENDS_LOCAL_DATA_UPDATED_KEY = @"FBM_FRIENDS_LOCAL_DATA_UPDATED_KEY";
static NSString * const FBM_CREATE_EVENT_SUCCESS_KEY = @"FBM_CREATE_EVENT_SUCCESS_KEY";
static NSString * const FBM_CREATE_EVENT_FAILURE_KEY = @"FBM_CREATE_EVENT_FAILURE_KEY";
static NSString * const FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY = @"FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY";
static NSString * const FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY = @"FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY";
static NSString * const FBM_AUTH_ERROR_KEY = @"FBM_AUTH_ERROR_KEY";

@interface FacebookManager : NSObject <FBSessionDelegate, FBRequestDelegate> {
    Facebook * facebook;
//    CoreDataModel * coreDataModel;
    NSArray * eventInvitees;
    BOOL shouldForgetFacebookAccessTokenOnLogout;
    NSString * kwiqetIdentifierForWhichToForgetFacebookAccessToken;
}

@property (nonatomic, readonly) Facebook * facebook;
@property (nonatomic, readonly) Facebook * fb;
//@property (retain) CoreDataModel * coreDataModel;

- (void) pullAuthenticationInfoFromDefaults;
- (void) pushAuthenticationInfoToDefaults;

- (void) authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate;
- (void) login;

- (void) logoutAndForgetFacebookAccessToken:(BOOL)shouldForget associatedWithKwiqetIdentfier:(NSString *)kwiqetIdentifier;
 
- (void) updateFacebookFriends;
- (void) getProfilePictureForFacebookID:(NSString *)fbID;
- (void) createFacebookEventWithParameters:(NSMutableDictionary *)parameters inviteContacts:(NSArray *)contactsToInvite;
- (void) inviteToEvent:(NSString *)eventID contacts:(NSArray *)contacts withPersonalMessage:(NSString *)personalMessage;

@end

//@protocol FacebookManagerDelegate <NSObject>
//
//- (void) gotFacebookFriendsSuccess:(NSArray *)friends;
//- (void) gotFacebookFriendsFailure:(NSArray *)friends;
//
//@end
