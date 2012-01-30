//
//  KwiqetAppDelegate.h
//  Kwiqet
//
//  Created by Dan Bretl on 6/20/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashScreenViewController.h"
#import "FeaturedHubViewController.h"
#import "EventsViewController.h"
#import "SettingsViewController.h"
#import "WebConnector.h"
#import "CoreDataModel.h"
#import "FacebookManager.h"
#import "AccountPromptViewController.h"

@interface KwiqetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, SplashScreenViewControllerDelegate, WebConnectorDelegate, ContactsSelectViewControllerDelegate, AccountPromptViewControllerDelegate> {

    UIWindow * window;
    
	UITabBarController * tabBarController;
    FeaturedHubViewController * featuredHubViewController;
    UINavigationController * eventsNavController;
    EventsViewController * eventsViewController;
    UINavigationController * settingsNavController;
    SettingsViewController * settingsViewController;
    AccountPromptViewController * accountPromptViewController;
    
    UIImageView *splashView;
    SplashScreenViewController * splashScreenViewController;
    
    BOOL categoryTreeHasBeenRetrieved;
    
    WebConnector * webConnector;
    CoreDataModel * coreDataModel;
    FacebookManager * facebookManager;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UITabBarController * tabBarController;
@property (nonatomic, retain) FeaturedHubViewController * featuredHubViewController;
@property (retain) UINavigationController * eventsNavController;
@property (retain) EventsViewController * eventsViewController;
@property (retain) UINavigationController * settingsNavController;
@property (retain) SettingsViewController * settingsViewController;
@property (retain) AccountPromptViewController * accountPromptViewController;
@property (nonatomic, retain) UIImageView *splashView;
@property (retain) SplashScreenViewController * splashScreenViewController;
@property (nonatomic, readonly) BOOL categoryTreeHasBeenRetrieved;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) CoreDataModel * coreDataModel;
@property (nonatomic, readonly) FacebookManager * facebookManager;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void) processLoadedCategoriesFromHTTPRequest:(ASIHTTPRequest *)httpRequest;

@end
