//
//  FacebookProfilePictureGetter.m
//  kwiqet
//
//  Created by Dan Bretl on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookProfilePictureGetter.h"
#import "LocalImagesManager.h"

static NSString * const FPPG_BASE_URL = @"http://graph.facebook.com/";
static NSString * const FPPG_PICTURE_URL_POSTFIX = @"/picture";

@interface FacebookProfilePictureGetter()
@property (retain) NSMutableData * imageData;
//@property (retain) NSURLConnection * imageConnection;
- (void) loadImage;
- (void) notifyMainThread;
@end

@implementation FacebookProfilePictureGetter

@synthesize delegate;
@synthesize facebookID;
@synthesize indexPathInTableView;
@synthesize imageData;
//@synthesize imageConnection;

- (void)dealloc {
    [facebookID release];
    [indexPathInTableView release];
    [imageData release];
//    [imageConnection release];
    NSLog(@"fppg!");
    [super dealloc];
}

- (void) startDownload {
    
//    if (self.imageData == nil &&
//        self.imageConnection == nil) {
//        self.imageConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", FPPG_BASE_URL, self.facebookID, FPPG_PICTURE_URL_POSTFIX]]] delegate:self];
//    }
    
    if (self.imageData == nil) {
        NSOperationQueue * queue = [NSOperationQueue new];
        NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage) object:nil];
        [queue addOperation:operation];
        [operation release];
        [queue release];
    }
    
}

- (void) loadImage {
    self.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", FPPG_BASE_URL, self.facebookID, FPPG_PICTURE_URL_POSTFIX]]];
    [LocalImagesManager saveFacebookProfilePicture:self.imageData facebookID:self.facebookID];
    [self performSelectorOnMainThread:@selector(notifyMainThread) withObject:nil waitUntilDone:NO];
}

- (void) notifyMainThread {
    [self.delegate facebookProfilePictureGetterFinished:self];
}

//- (void) cancelDownload {
//    [self.imageConnection cancel];
//    self.imageConnection = nil;
//    self.imageData = nil;
//}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    self.imageData = [NSMutableData data];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.imageData appendData:data];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    [LocalImagesManager saveFacebookProfilePicture:self.imageData facebookID:self.facebookID];
//    [self.delegate facebookProfilePictureGetterFinished:self];
//    self.imageConnection = nil;
////    [self performSelectorOnMainThread:@selector(notifyMainThread) withObject:nil waitUntilDone:NO];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    self.imageData = nil;
//    self.imageConnection = nil;
//}

@end
