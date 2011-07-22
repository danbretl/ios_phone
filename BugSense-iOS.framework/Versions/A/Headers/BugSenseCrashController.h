//
//  CrashController.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BugSenseCrashLogger;

@protocol BugSenseCrashSaveDelegate
- (void)onCrash;
@end

@interface BugSenseCrashController : NSObject {
	BugSenseCrashLogger *logger;
	id <BugSenseCrashSaveDelegate> delegate;
	NSString *_bugSenseAPIKey;
    NSException *_exception;
}

+ (BugSenseCrashController*)sharedInstance;
+ (BugSenseCrashController*)sharedInstanceWithBugSenseAPIKey:(NSString *)bugSenseAPIKey;
+ (BugSenseCrashController*)sharedInstanceWithBugSenseAPIKey:(NSString *)bugSenseAPIKey andDomainName:(NSString *)domainName;
- (id)initWithAPIKey:(NSString *)bugSenseAPIKey andDomainName:(NSString *)domainName;

- (NSArray*)callstackAsArray;
- (void)handleSignal:(NSDictionary*)userInfo;
- (void)handleNSException:(NSDictionary*)userInfo;

@property (nonatomic, copy) NSException *_exception;
@property (nonatomic, assign) id <BugSenseCrashSaveDelegate> delegate;
@property (nonatomic, assign) BugSenseCrashLogger *logger;

@end
