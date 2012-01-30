//
//  FBRequest+Cancel.m
//  Kwiqet
//
//  Created by Dan Bretl on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBRequest+Cancel.h"

@implementation FBRequest (Cancel)

- (void)cancel {
    [_connection cancel];
    [_connection release], _connection = nil;
}

@end
