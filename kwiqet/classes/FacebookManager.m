//
//  FacebookManager.m
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "FacebookManager.h"
#import "DefaultsModel.h"
#import "Contact.h"
#import "URLBuilder.h"
#import "WebDataTranslator.h"
#import "Occurrence.h"
#import "Place.h"

static NSString * const FB_FACEBOOK_APP_ID = @"210861478950952";
static NSString * const FB_FACEBOOK_ACCESS_TOKEN_KEY = @"FBAccessTokenKey";
static NSString * const FB_FACEBOOK_EXPIRATION_DATE_KEY = @"FBExpirationDateKey";
static NSString * const FBM_REQUEST_UPDATE_FRIENDS = @"fbmRequestTypeUpdateFriends";
static NSString * const FBM_REQUEST_GET_LIKES = @"fbmRequestGetLikes";
static NSString * const FBM_REQUEST_CREATE_EVENT = @"fbmRequestTypeCreateEvent";
static NSString * const FBM_REQUEST_INVITE_FRIENDS_TO_EVENT = @"fbmRequestTypeInviteFriendsToEvent";
static NSString * const FBM_NO_ASSOCIATED_KWIQET_IDENTIFIER = @"FBM_NO_ASSOCIATED_KWIQET_IDENTIFIER";
static NSString * const FBM_REQUEST_PROFILE_PICTURE = @"FBM_REQUEST_PROFILE_PICTURE";

@interface FacebookManager()
@property (retain) FBRequest * currentRequest;
@property (copy) NSString * currentRequestType;
@property (retain) NSArray * eventInvitees;
@property BOOL shouldForgetFacebookAccessTokenOnLogout;
@property (copy) NSString * kwiqetIdentifierForWhichToForgetFacebookAccessToken;
@property (readonly) UIAlertView * postToWallSuccessfulAlertView;
@property (readonly) UIAlertView * postToWallFailureAlertView;
@end

@implementation FacebookManager

//@synthesize coreDataModel;
@synthesize currentRequest, currentRequestType;
@synthesize eventInvitees;
@synthesize shouldForgetFacebookAccessTokenOnLogout;
@synthesize kwiqetIdentifierForWhichToForgetFacebookAccessToken;
@synthesize ignoreRequestResults;
@synthesize postToWallSuccessfulAlertView, postToWallFailureAlertView;

- (void)dealloc {
    [facebook release];
//    [coreDataModel release];
    [currentRequest release];
    [currentRequestType release];
    [eventInvitees release];
    [kwiqetIdentifierForWhichToForgetFacebookAccessToken release];
    [postToWallSuccessfulAlertView release];
    [postToWallFailureAlertView release];
    [super dealloc];
}

- (Facebook *)facebook {
    if (facebook == nil) {
//        facebook = [[Facebook alloc] initWithAppId:FB_FACEBOOK_APP_ID];
        facebook = [[Facebook alloc] initWithAppId:FB_FACEBOOK_APP_ID andDelegate:self];
    }
    return facebook;
}
- (Facebook *)fb { return self.facebook; }

- (UIAlertView *)postToWallSuccessfulAlertView {
    if (postToWallSuccessfulAlertView == nil) {
        postToWallSuccessfulAlertView = [[UIAlertView alloc] initWithTitle:@"Posted to Facebook" message:@"Your Facebook wall post was successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return postToWallSuccessfulAlertView;
}

- (UIAlertView *)postToWallFailureAlertView {
    if (postToWallFailureAlertView == nil) {
        postToWallFailureAlertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"There was a problem while trying to post to your Facebook wall. Check your settings and try again, or if the problem persists, disconnect and reconnect Facebook in the 'Settings' tab." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return postToWallFailureAlertView;
}

- (void)pushAuthenticationInfoToDefaults {
    NSString * kwiqetIdentifier = [DefaultsModel retrieveKwiqetUserIdentifierFromUserDefaults];
    if (!kwiqetIdentifier) {
        kwiqetIdentifier = FBM_NO_ASSOCIATED_KWIQET_IDENTIFIER;
    }
    [DefaultsModel saveFacebookAccessToken:self.fb.accessToken expirationDate:self.fb.expirationDate attachedToKwiqetIdentifier:kwiqetIdentifier];
    [DefaultsModel synchronize];
}

- (void)pullAuthenticationInfoFromDefaults {
//    NSLog(@"FacebookManager pullAuthenticationInfoFromDefaults");
    NSString * kwiqetIdentifier = [DefaultsModel retrieveKwiqetUserIdentifierFromUserDefaults];
    if (!kwiqetIdentifier) {
//        NSLog(@"no kwiqet id available");
        kwiqetIdentifier = FBM_NO_ASSOCIATED_KWIQET_IDENTIFIER;
    }
    NSDictionary * accessInfo = [DefaultsModel retrieveFacebookAccessInfoAttachedToKwiqetIdentifier:kwiqetIdentifier];
    if (accessInfo) {
//        NSLog(@"accessInfo exists? = %@", accessInfo);
        self.fb.accessToken = [accessInfo objectForKey:DM_FACEBOOK_ACCESS_INFO_DICTIONARY_ACCESS_TOKEN_KEY];
        self.fb.expirationDate = [accessInfo objectForKey:DM_FACEBOOK_ACCESS_INFO_DICTIONARY_EXPIRATION_DATE_KEY];
    }
}

- (void) login {
    NSLog(@"FacebookManager login");
    [self authorizeWithStandardPermissionsAndDelegate:self];
}

- (void)authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate {
    NSLog(@"FacebookManager authorizeWithStandardPermissionsAndDelegate");
    NSArray * permissions = [NSArray arrayWithObjects:@"user_events", @"create_event", @"rsvp_event", @"user_likes", @"user_interests", @"user_religion_politics", @"offline_access", nil];
//    [self.fb authorize:permissions delegate:delegate];
    [self.fb authorize:permissions];
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

- (void) postToFacebookWallWithEvent:(Event *)event {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:event.url forKey:@"link"];
    [parameters setValue:event.title forKey:@"name"];
    NSURL * url = [URLBuilder imageURLForImageLocation:event.imageLocation];
    [parameters setValue:[url absoluteString] forKey:@"picture"];
    // Occurrences below... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    Occurrence * firstOccurrence = [event.occurrencesChronological objectAtIndex:0];
    // Occurrences above... TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. TEMP, NOT IMPLEMENTED YET. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN. EVERYTHING RELATED TO TEMPRANDOMOCCURRENCE NEEDS TO BE LOOKED OVER AND REWRITTEN.
    NSString * captionString = firstOccurrence.place.title ? firstOccurrence.place.title : [WebDataTranslator fullLocationStringFromAddress:firstOccurrence.place.address city:firstOccurrence.place.city state:firstOccurrence.place.state zip:firstOccurrence.place.zip];
    if (captionString) {
        [parameters setValue:captionString forKey:@"caption"];
    }
    [parameters setValue:event.eventDescription forKey:@"description"];
    [self.fb dialog:@"feed" andParams:parameters andDelegate:self];
}

- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"Facebook wall post complete");
    if (!([self.postToWallFailureAlertView isVisible] ||
          [self.postToWallSuccessfulAlertView isVisible])) {
        [self.postToWallSuccessfulAlertView show];
    }
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"Facebook wall post did not complete");
}

- (void) dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    NSLog(@"Facebook wall post failed");
    if (!([self.postToWallFailureAlertView isVisible] ||
          [self.postToWallSuccessfulAlertView isVisible])) {
        [self.postToWallFailureAlertView show];
    }
}

- (void) updateFacebookFriends {
    self.currentRequestType = FBM_REQUEST_UPDATE_FRIENDS;
    self.currentRequest = [self.fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void) getLikes {
    self.currentRequestType = FBM_REQUEST_GET_LIKES;
    self.currentRequest = [self.fb requestWithGraphPath:@"me/likes" andDelegate:self];
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
//    self.currentRequest = [self.fb requestWithMethodName:@"events.invite" andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:eventID, @"eid", friendIDs, @"uids", personalMessage, @"personal_message", nil] andHttpMethod:@"POST" andDelegate:self];
    self.currentRequest = [self.fb requestWithGraphPath:[NSString stringWithFormat:@"/%@/invited", eventID] andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:friendIDs, @"users", nil] andHttpMethod:@"POST" andDelegate:self];
    
}

- (void) getProfilePictureForFacebookID:(NSString *)fbID {
    self.currentRequestType = FBM_REQUEST_PROFILE_PICTURE;
    self.currentRequest = [self.fb requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", fbID] andDelegate:self];
}


- (void) request:(FBRequest *)request didLoad:(id)result {
//    NSLog(@"FB request success %@ - %@", request, result);
    
    if (self.ignoreRequestResults) {
        NSLog(@"Ignoring Facebook results");
    } else {
        if ([self.currentRequestType isEqualToString:FBM_REQUEST_UPDATE_FRIENDS]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_UPDATE_SUCCESS_KEY object:self userInfo:result];
            
        } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_GET_LIKES]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_GET_LIKES_SUCCESS_KEY object:self userInfo:result];
            
        } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_CREATE_EVENT]) {
            
            if ([result objectForKey:@"id"]) {
                [self inviteToEvent:[result objectForKey:@"id"] contacts:self.eventInvitees withPersonalMessage:@"Test invitation message"];
            }
            
        } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_INVITE_FRIENDS_TO_EVENT]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:self userInfo:nil];
            
        } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_PROFILE_PICTURE]) {
            
            //        NSLog(@"result class is %@", NSStringFromClass([result class]));
            UIImage * image = [UIImage imageWithData:result];  
            NSLog(@"result image is %f by %f", image.size.width, image.size.height);
            
        } else {
            NSLog(@"ERROR in FacebookManager - unrecognized FBRequest type");
        }
    }
                
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    
    if (self.ignoreRequestResults) {
        NSLog(@"Ignoring Facebook results");
    } else {
        NSLog(@"FB request failed: %@", [error localizedDescription]);
        NSLog(@"FB error details: %@", [error description]);
        NSLog(@"FB error userInfo: %@", [error userInfo]);
        
        NSLog(@"%@", [[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]);
        if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FBM_AUTH_ERROR_KEY object:self userInfo:nil];
            
        } else {
            
            if ([self.currentRequestType isEqualToString:FBM_REQUEST_UPDATE_FRIENDS]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_UPDATE_FAILURE_KEY object:self userInfo:[error userInfo]];
                
            } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_GET_LIKES]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FBM_GET_LIKES_FAILURE_KEY object:self userInfo:[error userInfo]];
                
            } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_CREATE_EVENT]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FBM_CREATE_EVENT_FAILURE_KEY object:self userInfo:[error userInfo]];
                //            [self.currentRequest connect];
                
            } else if ([self.currentRequestType isEqualToString:FBM_REQUEST_INVITE_FRIENDS_TO_EVENT]) {
                
                // TEMPORARY HACK - FOR SOME REASON, WE ARE GETTING A FACEBOOK ERROR CODE 10000, BUT STILL THE INVITE IS SUCCESSFUL. SO, FOR NOW, WE ARE GOING TO CHECK IF THE ERROR CODE IS 10000, AND IF IT IS, WE ARE GOING TO HOPE/ASSUME THAT EVERYTHING WENT GREAT.
                if ([error code] == 10000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:self userInfo:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY object:self userInfo:[error userInfo]];
                }
                
            } else {
                NSLog(@"ERROR in FacebookManager - unrecognized FBRequest type");
            }
            
        }
        
        self.currentRequest = nil;
        self.currentRequestType = nil;

    }

}

- (void) logoutAndForgetFacebookAccessToken:(BOOL)shouldForget associatedWithKwiqetIdentfier:(NSString *)kwiqetIdentifier {
    self.shouldForgetFacebookAccessTokenOnLogout = shouldForget;
    self.kwiqetIdentifierForWhichToForgetFacebookAccessToken = kwiqetIdentifier;
    [self.fb logout:self];
}

- (void)fbDidLogout {
    NSLog(@"fbDidLogout");
    // This comment is old, and needs updating. --- We don't really NEED to do the following, but I think it provides a "more trustworthy" user experience. If we didn't do the following, then the user could touch to disconnect facebook, then touch to connect facebook again, and they might automatically be connected without any sort of dialog or anything (because the access token was still valid for the given expiration date). That is convenient, but a user would rarely be trying to do this, and I would argue that it would be more likely that logout and login would be touched in a way that would expect a dialog. (Bad sentence, but hopefully you get my point.)
    if (self.shouldForgetFacebookAccessTokenOnLogout) {
        NSLog(@"shouldForgetFacebookAccessTokenOnLogout");
        NSString * kwiqetIdentifier = self.kwiqetIdentifierForWhichToForgetFacebookAccessToken;
        if (!kwiqetIdentifier) {
            kwiqetIdentifier = FBM_NO_ASSOCIATED_KWIQET_IDENTIFIER;
        }
        [DefaultsModel deleteFacebookAccessInfoAttachedToKwiqetIdentifier:kwiqetIdentifier];
    }
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:FBM_ACCOUNT_ACTIVITY_ACTION_LOGOUT, FBM_ACCOUNT_ACTIVITY_ACTION_KEY, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_ACCOUNT_ACTIVITY_KEY object:self userInfo:userInfo];
}

@end
