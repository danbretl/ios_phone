//
//  CoreDataModel.m
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "CoreDataModel.h"
#import "WebUtil.h"

@interface CoreDataModel()
- (Event *) getFeaturedEventCreateIfDoesNotExist:(BOOL)createIfDoesNotExist;
- (NSArray *) getEventsForPredicate:(NSPredicate *)predicate;
- (void) deleteEventsForPredicate:(NSPredicate *)predicate;
@end

@implementation CoreDataModel

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [tempSolutionCategoriesOrderDictionary release];
    [coreDataYes release];
    [coreDataNo release];
    [super dealloc];
}

//////////
// Util //
//////////

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

- (NSNumber *)coreDataYes {
    if (coreDataYes == nil) {
        coreDataYes = [[NSNumber numberWithBool:YES] retain];
    }
    return coreDataYes;
}

- (NSNumber *)coreDataNo {
    if (coreDataNo == nil) {
        coreDataNo = [[NSNumber numberWithBool:NO] retain];
    }
    return coreDataNo;
}

/////////////
// General //
/////////////

- (void) coreDataSave {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

// Flush core data objects associated with given Entity Name
- (void) deleteAllObjectsForEntityName:(NSString*)entityName  {
        
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    NSError * error;
    
    [fetchRequest setEntity:entity];
    NSArray * fetchedObjects = [[NSArray alloc]initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in fetchedObjects) {
        [self.managedObjectContext deleteObject:managedObject];
        //NSLog(@"object deleted");
    }
    
    [fetchedObjects release];
    
    [self coreDataSave];
	
}

////////////////
// Categories //
////////////////

- (NSDictionary *)tempSolutionCategoriesOrderDictionary {
    if (tempSolutionCategoriesOrderDictionary == nil) {
        tempSolutionCategoriesOrderDictionary = 
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithInt:1], @"/api/v1/category/136/",
         [NSNumber numberWithInt:2], @"/api/v1/category/137/",
         [NSNumber numberWithInt:3], @"/api/v1/category/1/",
         [NSNumber numberWithInt:4], @"/api/v1/category/38/",
         [NSNumber numberWithInt:5], @"/api/v1/category/139/",
         [NSNumber numberWithInt:6], @"/api/v1/category/138/",
         [NSNumber numberWithInt:7], @"/api/v1/category/9/",
         [NSNumber numberWithInt:8], @"/api/v1/category/16/",
         nil];
    }
    return tempSolutionCategoriesOrderDictionary;
}

- (void) coreDataAddCategoryWithURI:(NSString *)uri title:(NSString *)titleString color:(NSString *)colorString thumb:(NSString *)thumbnailString {
    
    Category * categoryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    categoryObject.uri = uri;
    categoryObject.title = titleString;
    categoryObject.colorHex = colorString;
    categoryObject.thumbnail = thumbnailString;
    categoryObject.displayOrder = [self.tempSolutionCategoriesOrderDictionary valueForKey:categoryObject.uri];
    
}

- (Category *)getCategoryWithURI:(NSString *)uri {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Category" 
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uri == %@", uri]];
    NSError * error;
    NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    Category * category = nil;
    if ([fetchedObjects count] > 0) {
        category = (Category *)[fetchedObjects objectAtIndex:0];
    }
    
    return category;
}

- (NSArray *) getAllCategories {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

- (NSArray *) getAllCategoriesWithColor {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"colorHex != nil"]];
    
	NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
	NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

- (NSDictionary *) getAllCategoriesWithColorInDictionaryWithURIKeys {
    NSArray * categoriesArray = [self getAllCategoriesWithColor];
    NSMutableDictionary * categoriesDictionary = [NSMutableDictionary dictionary];
    for (Category * category in categoriesArray) {
        [categoriesDictionary setObject:category forKey:category.uri];
    }
    return categoriesDictionary;
}

//////////////////////
// EVENTS - GENERAL //
//////////////////////

- (NSArray *) getEventsForPredicate:(NSPredicate *)predicate {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

- (void) deleteEventsForPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError * error;
    NSArray * fetchedObjects = [[NSArray alloc]initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in fetchedObjects) {
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [fetchedObjects release];
    
    [self coreDataSave];
    
}

////////////////////
// REGULAR EVENTS //
////////////////////

- (void) updateEvent:(Event *)event usingEventSummaryDictionary:(NSDictionary *)eventSummaryDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride {
    
    // Get the rest of the raw event data
    event.uri = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"event"]];
    event.title = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"title"]]; // NSString
    event.venue = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"place_title"]];
    event.summaryAddress = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"place_address"]];
    event.priceMinimum = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"price_quantity_min"]]; // NSNumber
    event.priceMaximum = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"price_quantity_max"]]; // NSNumber
    event.summaryStartDateEarliestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_date_earliest"]];
    event.summaryStartTimeEarliestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_time_earliest"]];
    // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
    if ([event.summaryStartTimeEarliestString isEqualToString:@"00:00:00"]) {
        event.summaryStartTimeEarliestString = nil;
    }
    event.summaryStartDateLatestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_date_latest"]];
    event.summaryStartTimeLatestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_time_latest"]];
    // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
    if ([event.summaryStartTimeLatestString isEqualToString:@"00:00:00"]) {
        event.summaryStartTimeLatestString = nil;
    }
    event.summaryStartDateDistinctCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"start_date_distinct_count"]]; // NSNumber
    event.summaryStartTimeDistinctCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"start_time_distinct_count"]]; // NSNumber
    event.summaryPlaceDistinctCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"place_distinct_count"]]; // NSNumber
    
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"concrete_parent_category"]];
    if (concreteParentCategoryURI) {
        event.concreteParentCategoryURI = concreteParentCategoryURI;
        Category * concreteParentCategory = [self getCategoryWithURI:concreteParentCategoryURI];
        event.concreteParentCategory = concreteParentCategory;        
    }

    if (featuredOverride)   { event.featured = featuredOverride; }
    if (fromSearchOverride) { event.fromSearch = fromSearchOverride; }
    
}

- (void)updateEvent:(Event *)event usingEventDictionary:(NSDictionary *)eventDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride {
    
    // Setup
    NSDictionary * firstOccurrenceDictionary = [[eventDictionary valueForKey:@"occurrences"] objectAtIndex:0];
    
    // Basic
    NSString * uri = [WebUtil stringOrNil:[eventDictionary objectForKey:@"resource_uri"]];
    NSString * titleText = [WebUtil stringOrNil:[eventDictionary objectForKey:@"title"]];
    NSString * descriptionText = [WebUtil stringOrNil:[eventDictionary objectForKey:@"description"]];
    
    // Date and time
    NSString * startDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_date"]];
    NSLog(@"startDate:%@", startDate);
    NSString * endDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_date"]];
    NSLog(@"endDate:%@", endDate);
    NSString * startTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_time"]];
    NSLog(@"startTime:%@", startTime);
    // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
    if ([startTime isEqualToString:@"00:00:00"]) {
        startTime = nil;
    }
    NSString * endTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_time"]];
    NSLog(@"endTime:%@", endTime);
    // Date and time (continued)
    NSDictionary * startAndEndDatetimesDictionary = [self.webDataTranslator datetimesSummaryFromStartTime:startTime endTime:endTime startDate:startDate endDate:endDate];
    NSLog(@"%@", startAndEndDatetimesDictionary);
    NSDate * startDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_START_DATETIME_KEY];
    NSDate * endDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_END_DATETIME_KEY];
    NSNumber * startDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_DATE_VALID_KEY];
    NSNumber * startTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_TIME_VALID_KEY];
    NSNumber * endDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_DATE_VALID_KEY];
    NSNumber * endTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_TIME_VALID_KEY];
    
    // Price
    NSArray * priceArray = [firstOccurrenceDictionary objectForKey:@"prices"];
    NSDictionary * pricesMinMaxDictionary = [self.webDataTranslator pricesSummaryFromPriceArray:priceArray];
    NSNumber * priceMinimum = [pricesMinMaxDictionary objectForKey:@"minimum"];
    NSNumber * priceMaximum = [pricesMinMaxDictionary objectForKey:@"maximum"];
    
    // Address first line
    NSString * addressLineFirst = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"address"]];
    
    // Address second line
    NSString * cityString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"city"]];
    NSString * stateString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"state"]];
    NSString * zipCodeString = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"zip"]];
    
    // Latitude & Longitude
    NSNumber * latitudeValue  = [WebUtil numberOrNil:[[[[[eventDictionary valueForKey:@"occurrences"] objectAtIndex:0]valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"latitude"]];
    NSNumber * longitudeValue = [WebUtil numberOrNil:[[[[[eventDictionary valueForKey:@"occurrences"] objectAtIndex:0] valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"longitude"]];
    
    // Phone Number
    NSString * eventPhoneString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"phone"]];
    
    // Venue
    NSString * venueString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"title"]];
    
    // Image location
    NSString * imageLocation = [WebUtil stringOrNil:[eventDictionary valueForKey:@"image"]];
    if (!imageLocation) {
        imageLocation = [WebUtil stringOrNil:[eventDictionary valueForKey:@"thumbnail_detail"]];
    }
    
    // Concrete parent category
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[eventDictionary objectForKey:@"concrete_parent_category"]];
    
    // Concrete category breadcrumbs
    NSArray * breadcrumbsArray = [eventDictionary valueForKey:@"concrete_category_breadcrumbs"];
    int order = 0;
    for (NSString * categoryURI in breadcrumbsArray) {
        CategoryBreadcrumb * breadcrumb = (CategoryBreadcrumb *)[NSEntityDescription insertNewObjectForEntityForName:@"CategoryBreadcrumb" inManagedObjectContext:self.managedObjectContext];
        breadcrumb.category = [self getCategoryWithURI:categoryURI];
        breadcrumb.event = event;
        breadcrumb.order = [NSNumber numberWithInt:order];
        order++;
    }
    
    event.uri = uri;
    event.concreteParentCategoryURI = concreteParentCategoryURI;
    Category * concreteParentCategory = [self getCategoryWithURI:concreteParentCategoryURI];
    event.concreteParentCategory = concreteParentCategory;
    NSLog(@"category uri is %@", concreteParentCategoryURI);
    NSLog(@"category is %@", concreteParentCategory);
    event.title = titleText;
    event.startDatetime = startDatetime;
    event.endDatetime = endDatetime;
    event.startDateValid = startDateValid;
    event.startTimeValid = startTimeValid;
    event.endDateValid = endDateValid;
    event.endTimeValid = endTimeValid;
    event.venue = venueString;
    event.address = addressLineFirst;
    event.city = cityString;
    event.state = stateString;
    event.zip = zipCodeString;
    event.latitude = latitudeValue;
    event.longitude = longitudeValue;
    event.priceMinimum = priceMinimum;
    event.priceMaximum = priceMaximum;
    event.phone = eventPhoneString;
    event.details = descriptionText;
    event.imageLocation = imageLocation;
    if (featuredOverride)   { event.featured = featuredOverride; }
    if (fromSearchOverride) { event.fromSearch = fromSearchOverride; }
    
    [self coreDataSave];
    
}

- (NSArray *) getRegularEvents {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"featured == %@ && fromSearch == %@", self.coreDataNo, self.coreDataNo];
    return [self getEventsForPredicate:predicate];
    
}

- (NSArray *) getRegularEventsFromSearch {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"featured == %@ && fromSearch == %@", self.coreDataNo, self.coreDataYes];
    return [self getEventsForPredicate:predicate];
    
}

- (void) deleteRegularEvents {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"featured == %@ && fromSearch == %@", self.coreDataNo, self.coreDataNo];
    [self deleteEventsForPredicate:predicate];
    
}

- (void) deleteRegularEventsFromSearch {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"featured == %@ && fromSearch == %@", self.coreDataNo, self.coreDataYes];
    [self deleteEventsForPredicate:predicate];
    
}

- (void)deleteRegularEventForURI:(NSString *)eventID {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uri == %@ && featured == %@", eventID, self.coreDataNo];
    [self deleteEventsForPredicate:predicate];
    
}

/////////////////////
// FEATURED EVENTS //
/////////////////////

- (Event *) getFeaturedEvent {
    
    return [self getFeaturedEventCreateIfDoesNotExist:NO];
    
}

- (Event *)getOrCreateFeaturedEvent {
    
    return [self getFeaturedEventCreateIfDoesNotExist:YES];
    
}

- (Event *)getFeaturedEventCreateIfDoesNotExist:(BOOL)createIfDoesNotExist {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"featured == %@", [NSNumber numberWithBool:YES]]];
    
    NSError * error = nil;
    
    // Fetch all FeaturedEvent objects (though there should only be at most 1 for now)
    NSArray * array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [fetchRequest release];
    
    if (error) {
        NSLog(@"Error fetching Event %@, %@", error, [error userInfo]);
        abort();
    }
    
    Event * featuredEvent = nil;
    if (array && [array count] > 0) {
        featuredEvent = (Event *)[array objectAtIndex:0];
    } else {
        if (createIfDoesNotExist) {
            featuredEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            featuredEvent.featured = [NSNumber numberWithBool:YES];
            [self coreDataSave];            
        }
    }
    
    return featuredEvent;
}

//////////////
// CONTACTS //
//////////////

- (void)addOrUpdateContactsFromFacebook:(NSArray *)fbContacts {
    NSLog(@"addOrUpdateContactsFromFacebook %@", fbContacts);
    
    if (fbContacts) {
    
        // Prepare the sorted array of Facebook contact IDs
        NSArray * fbContactsSortedByID = [fbContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
        NSMutableArray * fbIDs = [NSMutableArray array];
        for (NSDictionary * contactDictionary in fbContactsSortedByID) {
            [fbIDs addObject:[contactDictionary valueForKey:@"id"]];
        }
        
        // Create the fetch request to get all Contacts matching the IDs
        NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(fbID IN %@)", fbIDs]];
        // Make sure the results will be sorted as well
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fbID" ascending:YES]]];
        // Execute the fetch
        NSError * error = nil;
        NSArray * contactsMatchingIDs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        int fbIDsArrayIndex = 0;
        int contactsIndex = 0;
        BOOL moreContactsToCheckAgainst = contactsMatchingIDs && contactsIndex < [contactsMatchingIDs count];
        NSString * fbID;
        Contact * contact;
        
        while (fbIDsArrayIndex < [fbIDs count]) {
            
            fbID = [fbIDs objectAtIndex:fbIDsArrayIndex];
            
            moreContactsToCheckAgainst &= contactsIndex < [contactsMatchingIDs count];
            if (moreContactsToCheckAgainst) {
                contact = (Contact *)[contactsMatchingIDs objectAtIndex:contactsIndex];
            }
            
            if (!moreContactsToCheckAgainst ||
                ![fbID isEqualToString:contact.fbID]) {
                [self addContactWithFacebookID:fbID facebookName:[[fbContactsSortedByID objectAtIndex:fbIDsArrayIndex] valueForKey:@"name"]];
            } else {
                contactsIndex++;
            }
            
            fbIDsArrayIndex++;
            
        }
        
    }
    
}

- (void) addContactWithFacebookID:(NSString *)fbID facebookName:(NSString *)fbName {
    Contact * newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    newContact.fbID = fbID;
    newContact.fbName = fbName;
}

- (NSArray *)getAllContacts {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

@end
