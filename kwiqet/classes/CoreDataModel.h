//
//  CoreDataModel.h
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Category.h"
#import "Contact.h"
#import "CategoryBreadcrumb.h"
#import "WebDataTranslator.h"

@interface CoreDataModel : NSObject {
    
    NSManagedObjectContext * managedObjectContext;
    NSManagedObjectModel * managedObjectModel;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    
    NSDictionary * tempSolutionCategoriesOrderDictionary;
    NSDictionary * tempSolutionCategoriesIconThumbsDictionary;
    
    WebDataTranslator * webDataTranslator;
    NSNumber * coreDataYes;
    NSNumber * coreDataNo;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesOrderDictionary;
@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesIconThumbsDictionary;

// Util
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) NSNumber * coreDataYes;
@property (nonatomic, readonly) NSNumber * coreDataNo;

// General
- (void) coreDataSave;
- (void) deleteAllObjectsForEntityName:(NSString *)entityNameGiven;
- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

// Categories
- (void) addOrUpdateConcreteCategories:(NSArray *)concreteCategories deleteOthers:(BOOL)shouldDeleteOthers;
- (void) addCategoryWithURI:(NSString *)uri title:(NSString *)titleString color:(NSString *)colorString buttonThumb:(NSString *)buttonThumbnailString; // This should be updated to allow for/enable updating the category tree after initial category-tree-get.
- (void) updateCategory:(Category *)category withTitle:(NSString *)title color:(NSString *)colorHex buttonThumb:(NSString *)buttonThumb;
- (Category *) getCategoryWithURI:(NSString *)uri;
- (NSArray *) getAllCategories;
- (NSArray *) getAllCategoriesWithColor;
- (NSDictionary *) getAllCategoriesWithColorInDictionaryWithURIKeys;

// Regular Events
- (void) updateEvent:(Event *)event usingEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride orderBrowse:(NSNumber *)orderBrowse orderSearch:(NSNumber *)orderSearch; // This way of handling "order" is such a hack it's not even funny. Just getting the job done for this old deprecated version of the app.
- (void) updateEvent:(Event *)event usingEventDictionary:(NSDictionary *)eventDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride;
- (NSArray *) getRegularEvents;
- (NSArray *) getRegularEventsFromSearch;
- (void) deleteRegularEvents;
- (void) deleteRegularEventsFromSearch;
- (void) deleteRegularEventForURI:(NSString*)eventID;

// Featured Events
- (Event *) getFeaturedEvent;
- (Event *) getOrCreateFeaturedEvent;

// Contacts
- (void) addContactWithFacebookID:(NSString *)fbID facebookName:(NSString *)fbName;
- (void) addOrUpdateContactsFromFacebook:(NSArray *)fbContacts deleteOthers:(BOOL)shouldDeleteOthers;
- (NSArray *) getAllContacts;
- (NSArray *) getAllFacebookContacts;

@end
