//
//  CryptoUtilities.h
//  kwiqet
//
//  Created by Dan Bretl on 07/08/11.
//  Copyright 2011 kwiqet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface CryptoUtilities : NSObject {

}

+ (NSString *) md5Encrypt:(NSString *)str;

@end
