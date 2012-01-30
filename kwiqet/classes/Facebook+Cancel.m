//
//  Facebook+Cancel.m
//  Kwiqet
//
//  Created by Dan Bretl on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Facebook+Cancel.h"
#import "FBRequest+Cancel.h"

@implementation Facebook (Cancel)

- (void) cancelPendingRequest {
    [_request cancel];
    [_request release], _request = nil;
}

@end
