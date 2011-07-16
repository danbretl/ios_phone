
//
//  kwiqetAppDelegate.m
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "kwiqetAppDelegate.h"
#import "URLBuilder.h"
#import "DefaultsModel.h"
#import "WebUtil.h"
#import "ContactsSelectViewController.h"
#import "LocalyticsSession.h"

@interface kwiqetAppDelegate()
- (void) facebookAuthError:(NSNotification *)notification;
- (void) facebookFriendsRetrieved:(NSNotification *)notification;
@end

@implementation kwiqetAppDelegate
@synthesize window;
@synthesize splashView, splashScreenViewController;
@synthesize tabBarController;
@synthesize featuredEventViewController, eventsNavController, eventsViewController, settingsNavController, settingsViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Setup stuff
    // Caching...
    NSLog(@"%d", [[NSURLCache sharedURLCache] memoryCapacity]);
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*10]; // http://stackoverflow.com/questions/1870004/does-nsurlconnection-take-advantage-of-nsurlcache/3900432#3900432
    NSLog(@"%d", [[NSURLCache sharedURLCache] memoryCapacity]);
    // Notifications...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookAuthError:) name:FBM_AUTH_ERROR_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookFriendsRetrieved:) name:FBM_FRIENDS_UPDATE_SUCCESS_KEY object:nil];
    // Variables...
    BOOL forceGetCategoryTree = NO;
    
    // Order of operations:
    // - kwiqetAppDelegate should make the categoryRequest (NOT the categoryTreeModel itself) immediately, IF the category tree has not already previous been retrieved and processed.
    categoryTreeHasBeenRetrieved = NO || [DefaultsModel loadCategoryTreeHasBeenRetrieved];
    self.splashScreenViewController = [[[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.splashScreenViewController.delegate = self;
    [self.splashScreenViewController showConnectionErrorTextView:NO animated:NO];
    [self.window addSubview:self.splashScreenViewController.view];
    if (!self.categoryTreeHasBeenRetrieved) {
        [self.webConnector getCategoryTree];
    } else {
        NSDate * categoryTreeMostRecentRetrievalDate = [DefaultsModel loadCategoryTreeMostRecentRetrievalDate];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        if (forceGetCategoryTree ||
            !categoryTreeMostRecentRetrievalDate ||
            ![[dateFormatter stringFromDate:categoryTreeMostRecentRetrievalDate] isEqualToString:[dateFormatter stringFromDate:[NSDate date]]]) {
            [self.webConnector getCategoryTree];
        } else {
            [self.splashScreenViewController explodeAndFadeViewAnimated];
        }
        [dateFormatter release];
    }
    
    // - kwiqetAppDelegate should alloc/init a SplashScreenViewController and add its view to the window. This VC should remain until the AppDelegate receives a response from the categoryRequest.
    // - If the categoryRequest is successful (i.e. internet connection is OK, and no timeout occurs, etc), then the AppDelegate should alloc/init its categoryTreeModel if it doesn't already exist, and inform it that it has made a successful categoryRequest. (We'll let the categoryTreeModel handle things from there for now.) At that point, the AppDelegate should alloc/init the main UITabBarController etc, add its view to the window, and then finally animate out the SplashScreenViewController. // SEE NOTE BELOW about why we are actually still creating the tab bar controller and its view controllers before a successful categoryRequest call and response.
    // - If the categoryRequest is NOT succesful (i.e. some internet connection problem occurred), then there isn't much the app can do really. We should inform the user that a problem has occurred / suggest that they check their internet connection and try the app again later.
    
    // THE PROBLEM currently with waiting to create the tab bar controller and its assorted view controllers is that the web request for content for featuredEventViewController isn't made until featuredEventViewController exists. (So, there is potentially a slight delay between the time when the splash screen fades away once all of that business is done, and when the featuredEventViewController displays its content underneath.)
    
    BOOL facebookTesting = NO;
    
    if (!facebookTesting) {
        
        // Tab Bar Controller
        self.tabBarController = [[[UITabBarController alloc] init] autorelease];
        self.tabBarController.delegate = self;
        
        // Featured Event View Controller
        self.featuredEventViewController = [[[FeaturedEventViewController alloc] init] autorelease];
        self.featuredEventViewController.coreDataModel = self.coreDataModel;
        UITabBarItem * featuredEventTabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0] autorelease];
        self.featuredEventViewController.tabBarItem = featuredEventTabBarItem;
//        self.featuredEventViewController.facebookManager = self.facebookManager;
        
        // Events List View Controller
        self.eventsViewController = [[[EventsViewController alloc] init] autorelease];
        self.eventsViewController.coreDataModel = self.coreDataModel;
        UITabBarItem * eventsTabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Events" image:[UIImage imageNamed:@"tab_home.png"] tag:1] autorelease];
        self.eventsViewController.tabBarItem = eventsTabBarItem;
//        self.eventsViewController.facebookManager = self.facebookManager;
        // Events List Navigation Controller
        self.eventsNavController = [[[UINavigationController alloc] initWithRootViewController:self.eventsViewController] autorelease];
        self.eventsNavController.navigationBarHidden = YES;
        
        // Settings View Controller
        self.settingsViewController = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]] autorelease];
        UITabBarItem * settingsTabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"tab_settings.png"] tag:2] autorelease];
        self.settingsViewController.tabBarItem = settingsTabBarItem;
//        self.settingsViewController.facebookManager = self.facebookManager;
        self.settingsViewController.coreDataModel = self.coreDataModel;
        // Settings Navigation Controller
        settingsNavController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
        self.settingsNavController.navigationBarHidden = YES;
        
        // Setting it all up
        self.tabBarController.viewControllers = [NSArray arrayWithObjects:self.featuredEventViewController, self.eventsNavController, self.settingsNavController, nil];
        [self.window addSubview:tabBarController.view];
        [self.window bringSubviewToFront:self.splashScreenViewController.view]; // Make sure the splash screen stays in front

        // Taking care of assorted things...
        application.applicationSupportsShakeToEdit = YES; // This is the default iOS behavior. Any reason for setting it explicitly?
        
        [self.facebookManager pullAuthenticationInfoFromDefaults];
        
        self.tabBarController.selectedIndex = [DefaultsModel loadTabBarSelectedIndex];
        
    } else {
        
        ContactsSelectViewController * csvc = [[ContactsSelectViewController alloc] initWithNibName:@"ContactsSelectViewController" bundle:[NSBundle mainBundle]];
//        csvc.contactsAll = [self.coreDataModel getAllFacebookContacts];
        csvc.delegate = self;
        csvc.coreDataModel = self.coreDataModel;
        [UIApplication sharedApplication].statusBarHidden = YES;
        [self.window addSubview:csvc.view];
        //[csvc release];
        
    }
    
    [self.window makeKeyAndVisible];
    //[self animateSplashScreen];
    
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"197b1a7c8264f82ee994c7c-0c5db5e8-af3b-11e0-037d-007f58cb3154"];
    
    return YES;
}

- (void) navigateToSettingsViewController {
    [self.tabBarController setSelectedViewController:self.settingsNavController];
}

- (void) facebookAuthError:(NSNotification *)notification {
    [self.facebookManager logoutAndForgetFacebookAccessToken:YES associatedWithKwiqetIdentfier:[DefaultsModel retrieveKwiqetUserIdentifierFromUserDefaults]];
}

- (void) facebookFriendsRetrieved:(NSNotification *)notification {
    [self.coreDataModel addOrUpdateContactsFromFacebook:[[notification userInfo] objectForKey:@"data"] deleteOthers:YES];
    [self.coreDataModel coreDataSave];
    [[NSNotificationCenter defaultCenter] postNotificationName:FBM_FRIENDS_LOCAL_DATA_UPDATED_KEY object:self];
}

- (void)contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts {
    NSLog(@"contactsSelectViewController didFinish");
    NSLog(@"Did cancel? %d", didCancel);
    NSLog(@"selectedContacts: %@", selectedContacts);
}

// FOR NOW, the only reason we'd have to handle an open url is to handle Facebook's login response. If that ever changes, then the logic of this method will obviously have to get more complicated.
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL returnVal = [self.settingsViewController.facebookManager.fb handleOpenURL:url];
//    BOOL returnVal = [self.facebookManager.fb handleOpenURL:url];
//    if (returnVal) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HANDLED_FACEBOOK_OPEN_URL" object:self userInfo:nil];
//    }
    return returnVal;
}

- (FacebookManager *)facebookManager {
    if (facebookManager == nil) {
        facebookManager = [[FacebookManager alloc] init];
//        facebookManager.coreDataModel = self.coreDataModel;
        [facebookManager pullAuthenticationInfoFromDefaults];
    }
    return facebookManager;
}

- (WebConnector *) webConnector {
    if (webConnector == nil) {
        webConnector = [[WebConnector alloc] init];
        webConnector.delegate = self;
    }
    return webConnector;
}

- (void)webConnector:(WebConnector *)theWebConnector getCategoryTreeSuccess:(ASIHTTPRequest *)request {
    
    // The following is a RIDICULOUS way to check that we got valid input.
    BOOL allGoodForProcessing = NO;
    NSString * responseString = [request responseString];
    if (responseString) {
        NSDictionary * dictionary = [responseString yajl_JSON];
        if (dictionary) {
            NSArray * categoriesArray = [dictionary valueForKey:@"objects"];
            if (categoriesArray && [categoriesArray count] > 0) {
                allGoodForProcessing = YES;
            }
        }
    }
    
    if (allGoodForProcessing) {
        [self processLoadedCategoriesFromHTTPRequest:request];
        categoryTreeHasBeenRetrieved = YES;
        // Animate out the SplashScreenViewController's view
        [self.eventsViewController forceToReloadEventsList]; // We currently need to make SURE that the events list gets reloaded sometime AFTER we get the category tree - otherwise the categories do not appear correctly in that view controller.
        [DefaultsModel saveCategoryTreeHasBeenRetrieved:self.categoryTreeHasBeenRetrieved];
        [DefaultsModel saveCategoryTreeMostRecentRetrievalDate:[NSDate date]];
        [self.splashScreenViewController explodeAndFadeViewAnimated];
    } else {
        [self webConnector:theWebConnector getCategoryTreeFailure:request];
    }
    
}

- (void) webConnector:(WebConnector *)webConnector getCategoryTreeFailure:(ASIHTTPRequest *)request {
    //	NSString *statusMessage = [request responseStatusMessage];
    //	NSLog(@"%@",statusMessage);
    //	NSError *error = [request error];
    //	NSLog(@"%@",error);
    if ([DefaultsModel loadCategoryTreeHasBeenRetrieved]) {
        [self.splashScreenViewController explodeAndFadeViewAnimated];
    } else {
        [self.splashScreenViewController showConnectionErrorTextView:YES animated:YES];
    }
}

- (void) processLoadedCategoriesFromHTTPRequest:(ASIHTTPRequest *)httpRequest {
    
//    [self.coreDataModel deleteAllObjectsForEntityName:@"Category"];
	
    NSDictionary * dictionaryFromJSON = [[httpRequest responseString] yajl_JSON];
    NSArray * categoriesArray = [dictionaryFromJSON valueForKey:@"objects"];
    
    [self.coreDataModel addOrUpdateConcreteCategories:categoriesArray deleteOthers:YES];
    [self.coreDataModel coreDataSave];
    
}

- (CoreDataModel *)coreDataModel {
    if (coreDataModel == nil) {
        coreDataModel = [[CoreDataModel alloc] init];
        coreDataModel.managedObjectContext = self.managedObjectContext;
        coreDataModel.managedObjectModel = self.managedObjectModel;
        coreDataModel.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return coreDataModel;
}

- (void)splashScreenViewControllerExplodeAndFadeViewAnimationCompleted:(SplashScreenViewController *)_splashScreenViewController {
    if (_splashScreenViewController == self.splashScreenViewController) {
        [self.splashScreenViewController.view removeFromSuperview];
        self.splashScreenViewController = nil;
    }
}

- (BOOL)categoryTreeHasBeenRetrieved {
    return categoryTreeHasBeenRetrieved;
}

//- (void) animateSplashScreen
//{
//	//SplashScreen 
//	splashView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)]autorelease];
//	splashView.image = [UIImage imageNamed:@"Default.png"];
//	[window addSubview:splashView];
//	[window bringSubviewToFront:splashView];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(removeSplashScreen)
//                                                 name:@"categoriesLoaded"
//                                               object:nil];
//}

//-(void)removeSplashScreen  {
//    //fade time
//	CFTimeInterval animationDuration = 0.5;
//    //Animation (fade away with zoom effect)
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:animationDuration];
//	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
//	[UIView setAnimationDelegate:splashView]; 
//	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
//    {
//        splashView.alpha = 0.0;
//        splashView.frame = CGRectMake(-60, -60, 440, 600);
//    }
//	[UIView commitAnimations];
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //save todays date in user defaults
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentDate = [dateFormatter stringFromDate:today];
    [dateFormatter release];
    
    [DefaultsModel saveBackgroundDate:currentDate];
    [DefaultsModel saveCategoryTreeHasBeenRetrieved:self.categoryTreeHasBeenRetrieved];
    
    [self saveContext];
    
    [self.splashScreenViewController showConnectionErrorTextView:NO animated:NO];
    
    [DefaultsModel saveTabBarSelectedIndex:self.tabBarController.selectedIndex];
    
    [[LocalyticsSession sharedLocalyticsSession] close];
	[[LocalyticsSession sharedLocalyticsSession] upload];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self.facebookManager pullAuthenticationInfoFromDefaults];
    
    categoryTreeHasBeenRetrieved = NO || [DefaultsModel loadCategoryTreeHasBeenRetrieved];
    
    if (!self.categoryTreeHasBeenRetrieved) {
        [self.webConnector getCategoryTree];
        [self.splashScreenViewController showConnectionErrorTextView:NO animated:NO];
    }
    
    [self.featuredEventViewController tempSolutionResetAndEnableLetsGoButton];
    [self.featuredEventViewController suggestToGetNewFeaturedEvent]; NSLog(@"FROM THE APP DELEGATE LINE 189");
    [self.eventsViewController suggestToRedrawEventsList];
    
//    self.tabBarController.selectedIndex = [DefaultsModel loadTabBarSelectedIndex]; // Duh - we get this for free with multitasking.
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"kwiqet" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"kwiqet.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                              [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                              nil];
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [splashView release];
    [splashScreenViewController release];
	
    [tabBarController release];
    [featuredEventViewController release];
    [eventsNavController release];
    [eventsViewController release];
    [settingsNavController release];
    [settingsViewController release];
    
    [webConnector release];
    [coreDataModel release];
    
    [window release];
    [super dealloc];
}

@end

