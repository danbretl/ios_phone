//
//  FacebookProfilePictureGetter.m
//  Kwiqet
//
//  Created by Dan Bretl on 7/14/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "FacebookProfilePictureGetter.h"
//#import "LocalImagesManager.h"

static NSString * const FPPG_BASE_URL = @"http://graph.facebook.com/";
static NSString * const FPPG_PICTURE_URL_POSTFIX = @"/picture";

@interface FacebookProfilePictureGetter()
@property (nonatomic, retain) NSMutableData * imageData;
@property (nonatomic, retain) UIImage * imagePrivate;
@property (nonatomic, retain) NSOperationQueue * operationQueue;
@property (nonatomic, retain) NSURLConnection * imageConnection;
- (void) loadImage;
- (void) notifyMainThread;
@end

@implementation FacebookProfilePictureGetter

@synthesize delegate;
@synthesize facebookID;
@synthesize indexPathInTableView;
@synthesize imageData;
@synthesize imagePrivate;
@synthesize operationQueue;
@synthesize imageConnection;

- (void)dealloc {
    [facebookID release];
    [indexPathInTableView release];
    [imageData release];
    [imageConnection release];
    [imagePrivate release];
    [operationQueue release];
    [super dealloc];
}

+ (NSURL *)urlForFacebookProfilePictureForFacebookID:(NSString *)fbID {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", FPPG_BASE_URL, fbID, FPPG_PICTURE_URL_POSTFIX]];
}

- (void) startDownload {
    
    if (self.imageData == nil &&
        self.imageConnection == nil) {
        self.imageConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[FacebookProfilePictureGetter urlForFacebookProfilePictureForFacebookID:self.facebookID]] delegate:self];
    }
    
//    if (self.image == nil &&
//        self.imageData == nil) {
//        operationQueue = [[NSOperationQueue alloc] init];
//        NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
//        [self.operationQueue addOperation:operation];
//        [operation release];
//    }
    
}

- (void) loadImage {
    self.imageData = [NSData dataWithContentsOfURL:[FacebookProfilePictureGetter urlForFacebookProfilePictureForFacebookID:self.facebookID]];
//    [LocalImagesManager saveFacebookProfilePicture:self.imageData facebookID:self.facebookID];
    self.imagePrivate = [UIImage imageWithData:self.imageData];
    [self performSelectorOnMainThread:@selector(notifyMainThread) withObject:nil waitUntilDone:NO];
}

- (void) notifyMainThread {
    if (self.delegate != nil) {
        [self.delegate facebookProfilePictureGetterFinished:self withImage:self.image];        
    }
}

- (UIImage *)image {
    return self.imagePrivate;
}

- (void) cancelDownload {
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.imageData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.imageData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [LocalImagesManager saveFacebookProfilePicture:self.imageData facebookID:self.facebookID];
    self.imageConnection = nil;
    self.imagePrivate = [UIImage imageWithData:self.imageData];
    [self performSelectorOnMainThread:@selector(notifyMainThread) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.imageData = nil;
    self.imageConnection = nil;
}

@end
