//
//  FacebookProfilePictureGetter.h
//  kwiqet
//
//  Created by Dan Bretl on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FacebookProfilePictureGetterDelegate;

@interface FacebookProfilePictureGetter : NSObject {
    
    id<FacebookProfilePictureGetterDelegate> delegate;
    NSString * facebookID;
    NSIndexPath * indexPathInTableView;
    
    NSMutableData * imageData;
//    NSURLConnection * imageConnection;
    
}

@property (assign) id<FacebookProfilePictureGetterDelegate> delegate;
@property (copy) NSString * facebookID;
@property (retain) NSIndexPath * indexPathInTableView;

- (void) startDownload;
//- (void) cancelDownload;

@end

@protocol FacebookProfilePictureGetterDelegate <NSObject>

- (void) facebookProfilePictureGetterFinished:(FacebookProfilePictureGetter *)profilePictureGetter;

@end
