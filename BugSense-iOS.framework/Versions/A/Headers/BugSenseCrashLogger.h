//
//  CrashLogger.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BugSenseCrashLogger : NSObject {
	BOOL finishPump;
	NSString *_bugSenseAPIKey;
	NSString *_domainName;
	
	NSDictionary *_saveddata;
	BOOL sendingOldCrashes;
	NSMutableArray *_connections;
	NSMutableArray *_savedCrashes;
}

- (id)initWithBugSenseAPIKey:(NSString *)bugSenseAPIKey andDomainName:(NSString *)domainName;
- (void)postDictionary:(NSDictionary *)dictionary toURL:(NSString *)url;
- (void)sendCrash:(NSDictionary*)crash;
- (void)pumpRunLoop;
- (void)sendSavedCrashes;
- (void)saveCrashes;

@property BOOL finishPump;

@end

