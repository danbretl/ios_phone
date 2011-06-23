//
//  kwiqetAppDelegate.h
//  kwiqet
//
//  Created by Dan Bretl on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SplashScreenViewController.h"
#import "FeaturedEventViewController.h"
#import "EventsViewController.h"
#import "SettingsViewController.h"
#import "WebConnector.h"
#import "CoreDataModel.h"
#import "FacebookManager.h"

@interface kwiqetAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, SplashScreenViewControllerDelegate, WebConnectorDelegate> {
    
    UIWindow *window;
    
	UITabBarController *tabBarController;
    FeaturedEventViewController * featuredEventViewController;
    UINavigationController * eventsNavController;
    EventsViewController * eventsViewController;
    SettingsViewController * settingsViewController;
    
    UIImageView *splashView;
    SplashScreenViewController * splashScreenViewController;
    
    BOOL categoryTreeHasBeenRetrieved;
    
    WebConnector * webConnector;
    CoreDataModel * coreDataModel;
    Facebook * facebook;
//    FacebookManager * facebookManager;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (retain) FeaturedEventViewController * featuredEventViewController;
@property (retain) UINavigationController * eventsNavController;
@property (retain) EventsViewController * eventsViewController;
@property (retain) SettingsViewController * settingsViewController;
@property (nonatomic, retain) UIImageView *splashView;
@property (retain) SplashScreenViewController * splashScreenViewController;
@property (nonatomic, readonly) BOOL categoryTreeHasBeenRetrieved;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) CoreDataModel * coreDataModel;
@property (nonatomic, readonly) Facebook * facebook;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;
- (void) processLoadedCategoriesFromHTTPRequest:(ASIHTTPRequest *)httpRequest;

@end
