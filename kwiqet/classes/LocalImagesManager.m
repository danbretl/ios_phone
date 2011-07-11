//
//  LocalImagesManager.m
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocalImagesManager.h"
#import "CryptoUtilities.h"

static NSString * const LOCAL_IMAGES_MANAGER_SAVED_IMAGES_ROOT_FOLDER_PATH = @"SavedImages/";
static NSString * const LOCAL_IMAGES_MANAGER_FEATURED_EVENT_IMAGES_PATH = @"FeaturedEventImages/";
static NSString * const LOCAL_IMAGES_MANAGER_EVENT_IMAGES_PATH = @"EventImages/";

@implementation LocalImagesManager

//saving an image

+ (void) saveImageData:(NSData *)imageData extraPath:(NSString *)extraPath imageName:(NSString *)imageName {
    
    NSFileManager * fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString * folderPath = [documentsDirectory stringByAppendingPathComponent:LOCAL_IMAGES_MANAGER_SAVED_IMAGES_ROOT_FOLDER_PATH];
    folderPath = [folderPath stringByAppendingPathComponent:extraPath];
    [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSString * fullPath = [folderPath stringByAppendingPathComponent:imageName];
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
}

+ (void) saveImageAsPNG:(UIImage*)image extraPath:(NSString *)extraPath imageName:(NSString*)imageName {
    
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    [self saveImageData:imageData extraPath:extraPath imageName:imageName];
    
}

//removing an image

+ (void)removeImage:(NSString*)imagePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [[documentsDirectory stringByAppendingPathComponent:LOCAL_IMAGES_MANAGER_SAVED_IMAGES_ROOT_FOLDER_PATH] stringByAppendingPathComponent:imagePath];
    
    [fileManager removeItemAtPath:fullPath error:NULL];
    
    NSLog(@"image removed");
    
}

//loading an image

+ (UIImage*)loadImage:(NSString*)imagePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [[documentsDirectory stringByAppendingPathComponent:LOCAL_IMAGES_MANAGER_SAVED_IMAGES_ROOT_FOLDER_PATH] stringByAppendingPathComponent:imagePath];
    
    NSLog(@"image loaded");
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

+ (BOOL) imageExistsAtPath:(NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * fullPath = [[documentsDirectory stringByAppendingPathComponent:LOCAL_IMAGES_MANAGER_SAVED_IMAGES_ROOT_FOLDER_PATH] stringByAppendingPathComponent:filePath];
    return [fileManager fileExistsAtPath:fullPath];
}



+ (void) saveFeaturedEventImageData:(NSData *)imageData imageName:(NSString *)imageName {
    [self saveImageData:imageData extraPath:LOCAL_IMAGES_MANAGER_FEATURED_EVENT_IMAGES_PATH imageName:imageName];
}

+ (void) removeFeaturedEventImage:(NSString*)imageName {
    [self removeImage:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_FEATURED_EVENT_IMAGES_PATH, imageName]];
}

+ (UIImage*) loadFeaturedEventImage:(NSString*)imageName {
    return [self loadImage:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_FEATURED_EVENT_IMAGES_PATH, imageName]];
}

+ (BOOL) featuredEventImageExistsWithName:(NSString*)imageName {
    return [self imageExistsAtPath:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_FEATURED_EVENT_IMAGES_PATH, imageName]];
}

+ (void) saveEventImageData:(NSData *)imageData sourceLocation:(NSString *)imageSourceLocation {
    [self saveImageData:imageData extraPath:LOCAL_IMAGES_MANAGER_EVENT_IMAGES_PATH imageName:[imageSourceLocation stringByReplacingOccurrencesOfString:@"/" withString:@""]];
}
+ (void) removeEventImageDataFromSourceLocation:(NSString *)imageSourceLocation {
    [self removeImage:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_EVENT_IMAGES_PATH, [imageSourceLocation stringByReplacingOccurrencesOfString:@"/" withString:@""]]];
}
+ (UIImage *) loadEventImageDataFromSourceLocation:(NSString *)imageSourceLocation {
    return [self loadImage:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_EVENT_IMAGES_PATH, [imageSourceLocation stringByReplacingOccurrencesOfString:@"/" withString:@""]]];
}
+ (BOOL) eventImageExistsFromSourceLocation:(NSString *)imageSourceLocation {
    return [self imageExistsAtPath:[NSString stringWithFormat:@"%@%@", LOCAL_IMAGES_MANAGER_EVENT_IMAGES_PATH, [imageSourceLocation stringByReplacingOccurrencesOfString:@"/" withString:@""]]];
}

@end
