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
    [tempSolutionCategoriesIconThumbsDictionary release];
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

- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    if (predicate) { [fetchRequest setPredicate:predicate]; }
    if (sortDescriptors) { [fetchRequest setSortDescriptors:sortDescriptors]; }
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

////////////////
// Categories //
////////////////

- (NSDictionary *)tempSolutionCategoriesOrderDictionary {
    if (tempSolutionCategoriesOrderDictionary == nil) {
        tempSolutionCategoriesOrderDictionary = 
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithInt: 5], @"/api/v1/category/136/",
         [NSNumber numberWithInt:10], @"/api/v1/category/137/",
         [NSNumber numberWithInt:15], @"/api/v1/category/1/"  ,
         [NSNumber numberWithInt:20], @"/api/v1/category/38/" ,
         [NSNumber numberWithInt:25], @"/api/v1/category/139/",
         [NSNumber numberWithInt:30], @"/api/v1/category/138/",
         [NSNumber numberWithInt:35], @"/api/v1/category/9/"  ,
         [NSNumber numberWithInt:40], @"/api/v1/category/16/" ,
         nil];
    }
    return tempSolutionCategoriesOrderDictionary;
}

- (NSDictionary *)tempSolutionCategoriesIconThumbsDictionary {
    if (tempSolutionCategoriesIconThumbsDictionary == nil) {
        tempSolutionCategoriesIconThumbsDictionary = 
        [[NSDictionary alloc] initWithObjectsAndKeys:
         @"icon_movies&media.png",      @"/api/v1/category/136/",
         @"icon_music.png",             @"/api/v1/category/137/",
         @"icon_sports&recreation.png", @"/api/v1/category/1/"  ,
         @"icon_food&drink.png",        @"/api/v1/category/38/" ,
         @"icon_arts&theater.png",      @"/api/v1/category/139/",
         @"icon_hobbies&interest.png",  @"/api/v1/category/138/",
         @"icon_gatherings.png",        @"/api/v1/category/9/"  ,
         @"icon_nightlife.png",         @"/api/v1/category/16/" ,
         nil];
    }
    return tempSolutionCategoriesIconThumbsDictionary;
}

- (void) addOrUpdateConcreteCategories:(NSArray *)concreteCategories deleteOthers:(BOOL)shouldDeleteOthers {
    
    NSLog(@"CoreDataModel addOrUpdateConcreteCategories(%d)", concreteCategories ? [concreteCategories count] : 0);
    
    if (concreteCategories) {
        
        // Prepare the sorted array of new categories
        NSArray * newConcreteCategoriesSortedByResourceURI = [concreteCategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"resource_uri" ascending:YES]]];
        NSMutableArray * newConcreteCategoryURIs = [NSMutableArray array];
        for (NSDictionary * newConcreteCategoryDictionary in newConcreteCategoriesSortedByResourceURI) {
            [newConcreteCategoryURIs addObject:[newConcreteCategoryDictionary valueForKey:@"resource_uri"]];
        }
        
        // Create the fetch request to get all existing Categories matching the new URIs
        NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(uri IN %@)", newConcreteCategoryURIs]];
        // Make sure the results will be sorted as well
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uri" ascending:YES]]];
        // Execute the fetch
        NSError * error = nil;
        NSArray * existingConcreteCategoriesMatchingURIs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        int newConcreteCategoryURIsIndex = 0;
        int existingConcreteCategoriesIndex = 0;
        BOOL moreExistingCategoriesToCheckAgainst = existingConcreteCategoriesMatchingURIs && existingConcreteCategoriesIndex < [existingConcreteCategoriesMatchingURIs count];
        NSString * newConcreteCategoryURI;
        Category * existingCategory;
        
        while (newConcreteCategoryURIsIndex < [newConcreteCategoryURIs count]) {
            
            newConcreteCategoryURI = [newConcreteCategoryURIs objectAtIndex:newConcreteCategoryURIsIndex];
            
            moreExistingCategoriesToCheckAgainst &= existingConcreteCategoriesIndex < [existingConcreteCategoriesMatchingURIs count];
            if (moreExistingCategoriesToCheckAgainst) {
                existingCategory = (Category *)[existingConcreteCategoriesMatchingURIs objectAtIndex:existingConcreteCategoriesIndex];
            }
            
            BOOL newAndExistingCategoriesMatchURIs = moreExistingCategoriesToCheckAgainst && [newConcreteCategoryURI isEqualToString:existingCategory.uri];
            BOOL shouldCreateNewCategory = (!moreExistingCategoriesToCheckAgainst ||
                                            !newAndExistingCategoriesMatchURIs);
            
            NSDictionary * newConcreteCategoryDictionary = nil;
            NSString * newConcreteCategoryTitle = nil;
            NSString * newConcreteCategoryColor = nil;
            NSString * newConcreteCategoryButtonThumb = nil;
            if (shouldCreateNewCategory || newAndExistingCategoriesMatchURIs) {
                newConcreteCategoryDictionary = [newConcreteCategoriesSortedByResourceURI objectAtIndex:newConcreteCategoryURIsIndex];
                newConcreteCategoryTitle = [WebUtil stringOrNil:[newConcreteCategoryDictionary valueForKey:@"title"]];
                newConcreteCategoryColor = [WebUtil stringOrNil:[newConcreteCategoryDictionary valueForKey:@"color"]];
                newConcreteCategoryButtonThumb = [WebUtil stringOrNil:[newConcreteCategoryDictionary valueForKey:@"button_icon"]];
            }
            
            if (shouldCreateNewCategory) {
                NSLog(@"Creating new category");
                [self addCategoryWithURI:newConcreteCategoryURI title:newConcreteCategoryTitle color:newConcreteCategoryColor buttonThumb:newConcreteCategoryButtonThumb];
            } else {
                if (newAndExistingCategoriesMatchURIs) {
                    NSLog(@"Updating category");
                    [self updateCategory:existingCategory withTitle:newConcreteCategoryTitle color:newConcreteCategoryColor buttonThumb:newConcreteCategoryButtonThumb];
                }
                existingConcreteCategoriesIndex++;
            }
            
            newConcreteCategoryURIsIndex++;
            
        }
        
        if (shouldDeleteOthers) {
            NSLog(@"Should delete other categories that were not in the new group we just pulled down and processed.");
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"!(uri IN %@)", newConcreteCategoryURIs]];
            NSArray * existingConcreteCategoriesUnmatched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (existingConcreteCategoriesUnmatched && [existingConcreteCategoriesUnmatched count] > 0) {
                NSLog(@"Deleting %d categories", [existingConcreteCategoriesUnmatched count]);
                for (Category * categoryToDelete in existingConcreteCategoriesUnmatched) {
                    [self.managedObjectContext deleteObject:categoryToDelete];
                }
            } else {
                NSLog(@"Not deleting any categories");
            }
        }
        
    }
    
}

- (void) addCategoryWithURI:(NSString *)uri title:(NSString *)titleString color:(NSString *)colorString buttonThumb:(NSString *)buttonThumbnailString {
    
    Category * categoryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    categoryObject.uri = uri;
    [self updateCategory:categoryObject withTitle:titleString color:colorString buttonThumb:buttonThumbnailString];
    
}

- (void) updateCategory:(Category *)category withTitle:(NSString *)title color:(NSString *)colorHex buttonThumb:(NSString *)buttonThumb {
    category.title = title;
    category.colorHex = colorHex;
    category.buttonThumb = buttonThumb;
    category.displayOrder = [self.tempSolutionCategoriesOrderDictionary valueForKey:category.uri];
    category.iconThumb = [self.tempSolutionCategoriesIconThumbsDictionary valueForKey:category.uri];
}

- (Category *)getCategoryWithURI:(NSString *)uri {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uri == %@", uri];
    NSArray * categories = [self getAllObjectsForEntityName:@"Category" predicate:predicate sortDescriptors:nil];
    Category * category = nil;
    if (categories && [categories count] > 0) {
        category = (Category *)[categories objectAtIndex:0];
    }
    return category;
}

- (NSArray *) getAllCategories {
    return [self getAllObjectsForEntityName:@"Category" predicate:nil sortDescriptors:nil];
}

- (NSArray *) getAllCategoriesWithColor {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"colorHex != nil"];
    NSArray * sortDescriptors = [NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]];
    return [self getAllObjectsForEntityName:@"Category" predicate:predicate sortDescriptors:sortDescriptors];
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
    return [self getAllObjectsForEntityName:@"Event" predicate:predicate sortDescriptors:nil];
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
    
    // Basic info
    NSString * uri = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"event"]];
    NSString * title = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"title"]];
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"concrete_parent_category"]];
    // Locations
    NSString * placeTitle = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"place_title"]];
    NSString * placeAddressEtc = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"place_address"]];
    NSNumber * placeCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"place_distinct_count"]];
    // Prices
    NSNumber * priceMinimum = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"price_quantity_min"]];
    NSNumber * priceMaximum = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"price_quantity_max"]];
    // Dates
    NSNumber * startDateCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"start_date_distinct_count"]];
    NSDate * startDateEarliest = [self.webDataTranslator dateDatetimeFromDateString:[WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_date_earliest"]]];
    NSDate * startDateLatest = [self.webDataTranslator dateDatetimeFromDateString:[WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_date_latest"]]];
    // Times
    NSNumber * startTimeCount = [WebUtil numberOrNil:[eventSummaryDictionary valueForKey:@"start_time_distinct_count"]];
    NSString * summaryStartTimeEarliestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_time_earliest"]];
    // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
    if ([summaryStartTimeEarliestString isEqualToString:@"00:00:00"]) {
        summaryStartTimeEarliestString = nil;
    }
    NSDate * startTimeEarliest = [self.webDataTranslator timeDatetimeFromTimeString:summaryStartTimeEarliestString];
    NSString * summaryStartTimeLatestString = [WebUtil stringOrNil:[eventSummaryDictionary valueForKey:@"start_time_latest"]];
    // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
    if ([summaryStartTimeLatestString isEqualToString:@"00:00:00"]) {
        summaryStartTimeLatestString = nil;
    }
    NSDate * startTimeLatest = [self.webDataTranslator timeDatetimeFromTimeString:summaryStartTimeLatestString];

    // Set the URI
    event.uri = uri ? uri : event.uri;
    // Set the category
    if (concreteParentCategoryURI) {
        Category * concreteParentCategory = [self getCategoryWithURI:concreteParentCategoryURI];
        event.concreteParentCategory = concreteParentCategory;
    }
    // Create the summary if necessary
    if (event.summary == nil) {
        event.summary = [NSEntityDescription insertNewObjectForEntityForName:@"EventSummary" inManagedObjectContext:self.managedObjectContext];
    }
    // Set summary info
    event.summary.title = title;
    event.summary.placeTitle = placeTitle;
    event.summary.placeAddressEtc = placeAddressEtc;
    event.summary.placeCount = placeCount;
    event.summary.priceMinimum = priceMinimum;
    event.summary.priceMaximum = priceMaximum;
    event.summary.startDateCount = startDateCount;
    event.summary.startDateEarliest = startDateEarliest;
    event.summary.startDateLatest = startDateLatest;
    event.summary.startTimeCount = startTimeCount;
    event.summary.startTimeEarliest = startTimeEarliest;
    event.summary.startTimeLatest = startTimeLatest;
    // Internal stuff
    if (featuredOverride)   { event.featured = featuredOverride; }
    if (fromSearchOverride) { event.fromSearch = fromSearchOverride; }
    
}

- (void)updateEvent:(Event *)event usingEventDictionary:(NSDictionary *)eventDictionary featuredOverride:(NSNumber *)featuredOverride fromSearchOverride:(NSNumber *)fromSearchOverride {
    
    // Basic
    NSString * uri = [WebUtil stringOrNil:[eventDictionary objectForKey:@"resource_uri"]];
    NSString * titleText = [WebUtil stringOrNil:[eventDictionary objectForKey:@"title"]];
    NSString * descriptionText = [WebUtil stringOrNil:[eventDictionary objectForKey:@"description"]];
    
    // Web
    NSString * url = [WebUtil stringOrNil:[eventDictionary objectForKey:@"url"]];
        
    // Image location
    NSString * imageLocation = [WebUtil stringOrNil:[eventDictionary valueForKey:@"thumbnail_detail"]];
    if (!imageLocation) { imageLocation = @""; }
    
    // Concrete parent category
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[eventDictionary objectForKey:@"concrete_parent_category"]];
    
    // Concrete category breadcrumbs
    NSArray * breadcrumbsArray = [eventDictionary valueForKey:@"concrete_category_breadcrumbs"];
    if (breadcrumbsArray && [breadcrumbsArray count] > 0) {
        // Using brute force currently - flush any old breadcrumbs, and create all new ones
        event.concreteCategoryBreadcrumbs = nil;
        for (CategoryBreadcrumb * breadcrumb in event.concreteCategoryBreadcrumbs) {
            [self.managedObjectContext deleteObject:breadcrumb];
        }
        int order = 0;
        for (NSString * categoryURI in breadcrumbsArray) {
            CategoryBreadcrumb * breadcrumb = (CategoryBreadcrumb *)[NSEntityDescription insertNewObjectForEntityForName:@"CategoryBreadcrumb" inManagedObjectContext:self.managedObjectContext];
            breadcrumb.category = [self getCategoryWithURI:categoryURI];
            breadcrumb.event = event;
            breadcrumb.order = [NSNumber numberWithInt:order];
            order++;
        }
    }
    
    event.uri = uri ? uri : event.uri;
    if (concreteParentCategoryURI) {
//        event.concreteParentCategoryURI = concreteParentCategoryURI;
        Category * concreteParentCategory = [self getCategoryWithURI:concreteParentCategoryURI];
        event.concreteParentCategory = concreteParentCategory;
    }
    event.title = titleText;// ? titleText : event.title;
    event.url = url;// ? url : event.url;
    event.eventDescription = descriptionText;// ? descriptionText : event.eventDescription;
    event.imageLocation = imageLocation;// ? imageLocation : event.imageLocation;
    if (featuredOverride)   { event.featured = featuredOverride; }
    if (fromSearchOverride) { event.fromSearch = fromSearchOverride; }
    
    [self coreDataSave];
    
}

- (void)updateEvent:(Event *)event withExhaustiveOccurrencesArray:(NSArray *)exhaustiveOccurrences {
    
    NSLog(@"Update event withExhaustiveOccurrencesArray");
    
    [event removeOccurrences:event.occurrences]; // Does this suffice? Do we need to delete them more directly instead? This must take care of it.
    
    for (NSDictionary * occurrenceDictionary in exhaustiveOccurrences) {
        
        // Create the occurrence object
        Occurrence * occurrence = [NSEntityDescription insertNewObjectForEntityForName:@"Occurrence" inManagedObjectContext:self.managedObjectContext];
        
        // Date and time - getting
        NSDate * startDate = [self.webDataTranslator dateDatetimeFromDateString:
                              [WebUtil stringOrNil:[occurrenceDictionary objectForKey:@"start_date"]]];
        NSString * startTimeString = [WebUtil stringOrNil:[occurrenceDictionary objectForKey:@"start_time"]];
        // THE FOLLOWING IS A TEMPORARY HACK COVERING UP THE FACT THAT OUR SCRAPES ARE NOT DEALING WITH THE FACT THAT VILLAGE VOICE INPUTS A TIME OF 00:00:00 WHEN THEY DON'T HAVE A VALID TIME. THUS, WE ARE CURRENTLY HACKISHLY ASSUMING THAT ANY TIME OF 00:00:00 MEANS AN INVALID UNKNOWN TIME.
        if ([startTimeString isEqualToString:@"00:00:00"]) {
            startTimeString = nil;
        }
        NSDate * startTime = [self.webDataTranslator timeDatetimeFromTimeString:startTimeString];
        NSDate * endDate = [self.webDataTranslator dateDatetimeFromDateString:
                            [WebUtil stringOrNil:[occurrenceDictionary objectForKey:@"end_date"]]];
        NSDate * endTime = [self.webDataTranslator timeDatetimeFromTimeString:
                            [WebUtil stringOrNil:[occurrenceDictionary objectForKey:@"end_time"]]];
        // NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day' - NEED TO GET AND SET (and use in various places later) 'is_all_day'
        // Date and time - setting
        occurrence.startDate = startDate;
        occurrence.startTime = startTime;
        occurrence.endDate = endDate;
        occurrence.endTime = endTime;

        // Price - getting & setting
        NSArray * priceArray = [occurrenceDictionary objectForKey:@"prices"];
        for (NSDictionary * priceDictionary in priceArray) {
            Price * price = [NSEntityDescription insertNewObjectForEntityForName:@"Price" inManagedObjectContext:self.managedObjectContext];
            price.value = [WebUtil numberOrNil:[priceDictionary valueForKey:@"quantity"]];
            [occurrence addPricesObject:price];
        }
        
        // Location - getting
        // NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place' - NEED TO GET AND SET (and use in various places later) 'one_off_place'
        // Address first line
        NSString * placeURI = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"resource_uri"]];// NSLog(@"Place URI is %@", placeURI);
        NSString * placeDescription = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"description"]];
        NSString * placeEmail = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"email"]];
        NSString * placeUnit = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"unit"]];
        NSString * placeURL = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"url"]];
        // Address second line
        NSString * addressLineFirst = [WebUtil stringOrNil:[[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"address"]];
        NSString * cityString = [WebUtil stringOrNil:[[[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"city"]];
        NSString * stateString = [WebUtil stringOrNil:[[[[occurrenceDictionary valueForKey:@"place"]valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"state"]];
        NSString * zipCodeString = [WebUtil stringOrNil:[[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"zip"]];
        // Latitude & Longitude
        NSNumber * latitudeValue  = [WebUtil numberOrNil:[[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"latitude"]];
        NSNumber * longitudeValue = [WebUtil numberOrNil:[[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"longitude"]];
        // Phone Number
        NSString * eventPhoneString = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"phone"]];
        // Venue
        NSString * venueString = [WebUtil stringOrNil:[[occurrenceDictionary valueForKey:@"place"] valueForKey:@"title"]];// NSLog(@"Place title is %@", venueString);
        // Location - setting
        Place * place = [self getPlaceWithURI:placeURI];
        if (place == nil) {
            place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
        }
        place.uri = placeURI;
        place.title = venueString;
        place.placeDescription = placeDescription;
        place.email = placeEmail;
        place.url = placeURL;
        place.address = addressLineFirst;
        place.city = cityString;
        place.state = stateString;
        place.zip = zipCodeString;
        place.unit = placeUnit;
        place.latitude = latitudeValue;
        place.longitude = longitudeValue;
        place.phone = eventPhoneString;
        
        occurrence.place = place;
        occurrence.event = event;
        
//        NSLog(@"Just set event %@ place to %@", event.title, occurrence.place.title);

    }
    
//    NSLog(@"Checking occurrences...");
//    NSMutableString * occurrencesDebugString = [NSMutableString string];
//    for (Occurrence * occurrence in event.occurrencesChronological) {
//        [occurrencesDebugString appendFormat:@"\n(%@, %@, %@)", occurrence.startDate, occurrence.place.title, occurrence.startTime];
//    }
//    NSLog(@"Occurrences: %@", occurrencesDebugString);
    
}

- (Place *)getPlaceWithURI:(NSString *)placeURI {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uri == %@", placeURI];
    NSArray * matchingPlaces = [self getAllObjectsForEntityName:@"Place" predicate:predicate sortDescriptors:nil];
    Place * place = nil;
    if (matchingPlaces && matchingPlaces.count > 0) {
        place = (Place *)[matchingPlaces objectAtIndex:0];
    }
    return place;
    
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

// Events continued - Occurrences & the like
- (NSArray *) getDistinctOccurrenceDatesForEvent:(Event *)event {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription * occurrenceEntity = [NSEntityDescription entityForName:@"Occurrence" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = occurrenceEntity;
    NSPropertyDescription * startDateProperty = [occurrenceEntity.attributesByName objectForKey:@"startDate"];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:startDateProperty];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:
                                    [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES],
                                    nil];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"event == %@", event];
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

- (NSArray *) getDistinctOccurrencePlacesForEvent:(Event *)event onDate:(NSDate *)date {
    return nil;
}

- (NSArray *) getDistinctOccurrenceTimesForEvent:(Event *)event onDate:(NSDate *)date atPlace:(Place *)place {
    return nil;
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

- (void) addOrUpdateContactsFromFacebook:(NSArray *)fbContacts deleteOthers:(BOOL)shouldDeleteOthers {
    
    if (fbContacts && [fbContacts count] > 0) {
    
        // Prepare the sorted array of Facebook contact IDs
        NSArray * newContactsSortedByID = [fbContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]]];
        NSMutableArray * newContactIDs = [NSMutableArray array];
        for (NSDictionary * newContactDictionary in newContactsSortedByID) {
            [newContactIDs addObject:[newContactDictionary valueForKey:@"id"]];
        }
        
        // Create the fetch request to get all Contacts matching the IDs
        NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(fbID IN %@)", newContactIDs]];
        // Make sure the results will be sorted as well
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fbID" ascending:YES]]];
        // Execute the fetch
        NSError * error = nil;
        NSArray * existingContactsMatchingIDs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        int newContactIDsIndex = 0;
        int existingContactsIndex = 0;
        BOOL moreExistingContactsToCheckAgainst = existingContactsMatchingIDs && existingContactsIndex < [existingContactsMatchingIDs count];
        NSString * newContactID;
        Contact * existingContact;
        
        while (newContactIDsIndex < [newContactIDs count]) {
            
            newContactID = [newContactIDs objectAtIndex:newContactIDsIndex];
            
            moreExistingContactsToCheckAgainst &= existingContactsIndex < [existingContactsMatchingIDs count];
            if (moreExistingContactsToCheckAgainst) {
                existingContact = (Contact *)[existingContactsMatchingIDs objectAtIndex:existingContactsIndex];
            }
            
            BOOL newAndExistingContactsMatchIDs = moreExistingContactsToCheckAgainst && [newContactID isEqualToString:existingContact.fbID];
            BOOL shouldCreateNewContact = (!moreExistingContactsToCheckAgainst ||
                                           !newAndExistingContactsMatchIDs);
            
            NSDictionary * newContactDictionary = nil;
            NSString * newContactName = nil;
            if (shouldCreateNewContact || newAndExistingContactsMatchIDs) {
                newContactDictionary = [newContactsSortedByID objectAtIndex:newContactIDsIndex];
                newContactName = [newContactDictionary valueForKey:@"name"];
            }
            
            if (shouldCreateNewContact) {
                [self addContactWithFacebookID:newContactID facebookName:newContactName];
            } else {
                if (newAndExistingContactsMatchIDs) {
                    existingContact.fbName = newContactName;
                }
                existingContactsIndex++;
            }
            
            newContactIDsIndex++;
            
        }
        
        if (shouldDeleteOthers) {
            NSLog(@"Should delete other contacts that were not in the new group we just pulled down and processed.");
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"!(fbID IN %@)", newContactIDs]];
            NSArray * existingContactsUnmatched = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (existingContactsUnmatched && [existingContactsUnmatched count] > 0) {
                NSLog(@"Deleting %d contacts", [existingContactsUnmatched count]);
                for (Contact * contactToDelete in existingContactsUnmatched) {
                    [self.managedObjectContext deleteObject:contactToDelete];
                }
            } else {
                NSLog(@"Not deleting any categories");
            }
        }
        
    }
    
}

- (void) addContactWithFacebookID:(NSString *)fbID facebookName:(NSString *)fbName {
    Contact * newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    newContact.fbID = fbID;
    newContact.fbName = fbName;
}

- (NSArray *) getAllContacts {
    return [self getAllObjectsForEntityName:@"Contact" predicate:nil sortDescriptors:nil];
}

- (NSArray *) getAllFacebookContacts {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fbID != nil"];
    NSArray * sortDescriptors = [NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"fbName" ascending:YES]];
    return [self getAllObjectsForEntityName:@"Contact" predicate:predicate sortDescriptors:sortDescriptors];
}

@end
