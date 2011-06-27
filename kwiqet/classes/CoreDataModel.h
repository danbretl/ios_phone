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
    
    WebDataTranslator * webDataTranslator;
    NSNumber * coreDataYes;
    NSNumber * coreDataNo;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesOrderDictionary;

// Util
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) NSNumber * coreDataYes;
@property (nonatomic, readonly) NSNumber * coreDataNo;

// General
- (void) coreDataSave;
- (void) deleteAllObjectsForEntityName:(NSString*)entityNameGiven;

// Categories
- (void) coreDataAddCategoryWithURI:(NSString *)uri title:(NSString *)titleString color:(NSString *)colorString thumb:(NSString *)thumbnailString; // This should be updated to allow for/enable updating the category tree after initial category-tree-get.
- (Category *) getCategoryWithURI:(NSString *)uri;
- (NSArray *) getAllCategories;
- (NSArray *) getAllCategoriesWithColor;
- (NSDictionary *) getAllCategoriesWithColorInDictionaryWithURIKeys;

// Regular Events
- (void) addEventWithURI:(NSString *)uri title:(NSString *)title venue:(NSString *)venue priceMinimum:(NSNumber *)priceMinimum priceMaximum:(NSNumber *)priceMaximum summaryAddress:(NSString *)summaryAddress summaryStartDateString:(NSString *)summaryStartDateString summaryStartTimeString:(NSString *)summaryStartTimeString concreteParentCategoryURI:(NSString *)concreteParentCategoryURI fromSearch:(BOOL)fromSearch;
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
- (void) addOrUpdateContactsFromFacebook:(NSArray *)fbContacts;
- (NSArray *) getAllContacts;

@end
