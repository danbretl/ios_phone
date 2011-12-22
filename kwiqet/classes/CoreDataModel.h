//
//  CoreDataModel.h
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "EventSummary.h"
#import "Category.h"
#import "Contact.h"
#import "CategoryBreadcrumb.h"
#import "WebDataTranslator.h"
#import "Occurrence.h"
#import "Place.h"
#import "Price.h"
#import "EventsWebQuery.h"
#import "UserLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface CoreDataModel : NSObject {
    
    NSManagedObjectContext * managedObjectContext;
    NSManagedObjectModel * managedObjectModel;
    NSPersistentStoreCoordinator * persistentStoreCoordinator;
    
    NSDictionary * tempSolutionCategoriesOrderDictionary;
    NSDictionary * tempSolutionCategoriesIconThumbsDictionary;
    NSDictionary * tempSolutionCategoriesIconThumbsBigDictionary;
    NSDictionary * tempSolutionCategoriesIconThumbsBigHorizontalOffsetDictionary;
    
    WebDataTranslator * webDataTranslator;
    NSNumber * coreDataYes;
    NSNumber * coreDataNo;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesOrderDictionary;
@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesIconThumbsDictionary;
@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesIconThumbsBigDictionary;
@property (nonatomic, readonly) NSDictionary * tempSolutionCategoriesIconThumbsBigHorizontalOffsetDictionary;

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

// Events Web Query Records
- (EventsWebQuery *) getMostRecentEventsWebQuery;
- (EventsWebQuery *) getMostRecentEventsRecommendedWebQuery;
- (EventsWebQuery *) getMostRecentEventsSearchWebQuery;
- (EventsWebQuery *) getMostRecentEventsSearchWebQueryWithSearchTerm:(NSString *)searchTerm;
- (EventsWebQuery *) getMostRecentEventsWebQueryForVenue:(Place *)venue;
//- (void) updateEventsWebQuery:(EventsWebQuery *)eventsWebQuery
//               WithSearchTerm:(NSSet *)searchTerm
//             filterCategories:(NSSet *)filterCategories
//       filterDateBucketString:(NSString *)filterDateBucketString
//   filterDistanceBucketString:(NSString *)filterDistanceBucketString
//   filterLocationBucketString:(NSString *)filterLocationBucketString
//      filterPriceBucketString:(NSString *)filterPriceBucketString
//       filterTimeBucketString:(NSString *)filterTimeBucketString;
//- (void) updateEventsWebQuery:(EventsWebQuery *)eventsWebQuery 
//                   withEvents:(NSSet *)events;

// Events
- (Event *) getEventWithURI:(NSString *)eventURI;

// Regular Events
- (void) updateEvent:(Event *)event usingEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride;
- (void) updateEvent:(Event *)event usingEventDictionary:(NSDictionary *)eventDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride;
- (void)updateEvent:(Event *)event withExhaustiveOccurrencesArray:(NSArray *)exhaustiveOccurrences;
- (NSArray *) getRegularEvents;
- (NSArray *) getRegularEventsFromSearch;
- (void) deleteRegularEvents;
- (void) deleteRegularEventsFromSearch;
- (void) deleteRegularEventForURI:(NSString*)eventID;
- (Place *) getPlaceWithURI:(NSString *)placeURI;

// Events continued - Occurrences & the like
- (NSArray *) getDistinctOccurrenceDatesForEvent:(Event *)event;
- (NSArray *) getDistinctOccurrencePlacesForEvent:(Event *)event onDate:(NSDate *)date;
- (NSArray *) getDistinctOccurrenceTimesForEvent:(Event *)event onDate:(NSDate *)date atPlace:(Place *)place;

// Featured Events
- (Event *) getFeaturedEvent;
- (Event *) getOrCreateFeaturedEvent;

// Contacts
- (void) addContactWithFacebookID:(NSString *)fbID facebookName:(NSString *)fbName;
- (void) addOrUpdateContactsFromFacebook:(NSArray *)fbContacts deleteOthers:(BOOL)shouldDeleteOthers;
- (NSArray *) getAllContacts;
- (NSArray *) getAllFacebookContacts;

// User Locations
- (void) addSeedUserLocationNYC;
- (UserLocation *) addUserLocationThatIsManual:(BOOL)isManual withLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude accuracy:(NSNumber *)accuracy addressFormatted:(NSString *)addressFormatted typeGoogle:(NSString *)typeGoogle;
- (void) updateUserLocation:(UserLocation *)location isManual:(BOOL)isManual latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude accuracy:(NSNumber *)accuracy addressFormatted:(NSString *)addressFormatted typeGoogle:(NSString *)typeGoogle updateDatetimeRecorded:(BOOL)shouldUpdateDatetimeRecorded updateDatetimeLastUsed:(BOOL)shouldUpdateDatetimeLastUsed;
- (void) updateUserLocationLastUseDate:(UserLocation *)location;
- (NSArray *) getRecentUserLocations;
- (NSArray *) getRecentAutoUserLocations;
- (NSArray *) getRecentManualUserLocations;
- (UserLocation *) getMostRecentUserLocation;
- (UserLocation *) getMostRecentAutoUserLocation;
- (UserLocation *) getMostRecentManualUserLocation;

@end
