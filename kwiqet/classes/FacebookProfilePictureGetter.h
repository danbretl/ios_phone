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
    NSOperationQueue * operationQueue;
    NSMutableData * imageData;
    UIImage * imagePrivate;
    NSURLConnection * imageConnection;
    
}

@property (nonatomic, assign) id<FacebookProfilePictureGetterDelegate> delegate;
@property (nonatomic, copy) NSString * facebookID;
@property (nonatomic, retain) NSIndexPath * indexPathInTableView;
@property (nonatomic, readonly) UIImage * image;

- (void) startDownload;
- (void) cancelDownload;

@end

@protocol FacebookProfilePictureGetterDelegate <NSObject>

- (void) facebookProfilePictureGetterFinished:(FacebookProfilePictureGetter *)profilePictureGetter withImage:(UIImage *)image;

@end
