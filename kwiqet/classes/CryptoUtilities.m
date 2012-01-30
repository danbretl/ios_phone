//
//  CryptoUtilities.m
//  Kwiqet
//
//  Created by Dan Bretl on 07/08/11.
//  Copyright 2011 Kwiqet. All rights reserved.
//

#import "CryptoUtilities.h"

@implementation CryptoUtilities

// Function definition taken directly from
// http://forums.macrumors.com/showthread.php?t=553135
+ (NSString *) md5Encrypt:(NSString *)str  {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

@end
