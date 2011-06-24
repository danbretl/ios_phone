//
//  FacebookManager.h
//  kwiqet
//
//  Created by Dan Bretl on 6/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FacebookManager : NSObject {
    Facebook * facebook;
}

@property (nonatomic, readonly) Facebook * facebook;
@property (nonatomic, readonly) Facebook * fb;

- (void) pullAuthenticationInfoFromDefaults;
- (void) pushAuthenticationInfoToDefaults;
- (void) authorizeWithStandardPermissionsAndDelegate:(id<FBSessionDelegate>)delegate;

@end
