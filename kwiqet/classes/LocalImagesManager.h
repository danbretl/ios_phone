//
//  LocalImagesManager.h
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocalImagesManager : NSObject {
    
}

+ (void) saveImageData:(NSData *)imageData extraPath:(NSString *)extraPath imageName:(NSString *)imageName;
+ (void) saveImageAsPNG:(UIImage*)image extraPath:(NSString *)extraPath imageName:(NSString*)imageName;
+ (void) removeImage:(NSString*)imagePath;
+ (UIImage *) loadImage:(NSString*)imagePath;
+ (BOOL) imageExistsAtPath:(NSString *)filePath;

+ (void) saveFeaturedEventImageData:(NSData *)imageData imageName:(NSString *)imageName;
+ (void) removeFeaturedEventImage:(NSString*)imageName;
+ (UIImage *) loadFeaturedEventImage:(NSString*)imageName;
+ (BOOL) featuredEventImageExistsWithName:(NSString*)imageName;

+ (void) saveEventImageData:(NSData *)imageData sourceLocation:(NSString *)imageSourceLocation;
+ (void) removeEventImageDataFromSourceLocation:(NSString *)imageSourceLocation;
+ (UIImage *) loadEventImageDataFromSourceLocation:(NSString *)imageSourceLocation;
+ (BOOL) eventImageExistsFromSourceLocation:(NSString *)imageSourceLocation;

@end
