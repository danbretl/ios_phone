//
//  FacebookManager.h
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "CoreDataModel.h"

static NSString * const FBM_ACCOUNT_ACTIVITY_KEY = @"fbmAccountActivity";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_KEY = @"fbmAccountActivityAction";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT = @"fbmAccountActivityActionLogout";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_LOGIN = @"fbmAccountActivityActionLogin";
static NSString * const FBM_ACCOUNT_ACTIVITY_ACTION_FAILURE = @"fbmAccountActivityActionFailure";
static NSString * const FBM_FRIENDS_UPDATE_SUCCESS_KEY = @"fbmFriendsUpdateSuccess";
static NSString * const FBM_FRIENDS_UPDATE_FAILURE_KEY = @"fbmFriendsUpdateFailure";


@interface FacebookManager : NSObject <FBSessionDelegate, FBRequestDelegate> {
    Facebook * facebook;
    CoreDataModel * coreDataModel;
}

@property (nonatomic, readonly) Facebook * facebook;
@property (nonatomic, readonly) Facebook * fb;
@property (retain) CoreDataModel * coreDataModel;

- (void) pullAuthenticationInfoFromDefaults;
- (void) pushAuthenticationInfoToDefaults;
- (void) authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate;
- (void) login;
- (void) updateFacebookFriends;
- (void) logout;

@end
