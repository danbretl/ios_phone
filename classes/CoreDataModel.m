//
//  CoreDataModel.m
//  Abextra
//
//  Created by John Nichols on 4/11/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "CoreDataModel.h"

@interface CoreDataModel()
- (Event *) getFeaturedEventCreateIfDoesNotExist:(BOOL)createIfDoesNotExist;
@end

@implementation CoreDataModel

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [tempSolutionCategoriesOrderDictionary release];
    [super dealloc];
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

////////////////////
// REGULAR EVENTS //
////////////////////

- (void) addEventWithURI:(NSString *)uri title:(NSString *)title venue:(NSString *)venue priceMinimum:(NSNumber *)priceMinimum priceMaximum:(NSNumber *)priceMaximum summaryAddress:(NSString *)summaryAddress summaryStartDateString:(NSString *)summaryStartDateString summaryStartTimeString:(NSString *)summaryStartTimeString concreteParentCategoryURI:(NSString *)concreteParentCategoryURI {
    
    Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    
    event.uri = uri;
    event.title = title;
    event.venue = venue;
    event.priceMinimum = priceMinimum;
    event.priceMaximum = priceMaximum;
    event.summaryAddress = summaryAddress;
    event.summaryStartDateString = summaryStartDateString;
    event.summaryStartTimeString = summaryStartTimeString;
    
    event.concreteParentCategoryURI = concreteParentCategoryURI;
    Category * concreteParentCategory = [self getCategoryWithURI:concreteParentCategoryURI];
    event.concreteParentCategory = concreteParentCategory;
    
}

- (NSArray *) getRegularEvents {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"featured == %@", [NSNumber numberWithBool:NO]]];
	NSError * error;
	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    return fetchedObjects;
}

-(void)deleteRegularEventForURI:(NSString*)eventID  {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" 
                                              inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uri == %@ && featured == %@", eventID, [NSNumber numberWithBool:NO]]];
    
	NSError * error;

	NSArray * fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    if ([fetchedObjects count] > 0) {
        NSManagedObject * managedObject = [fetchedObjects objectAtIndex:0];
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [self coreDataSave];

}

- (void) deleteRegularEvents {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"featured == %@", [NSNumber numberWithBool:NO]]];
    NSError * error;
    NSArray * fetchedObjects = [[NSArray alloc]initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in fetchedObjects) {
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [fetchedObjects release];
    
    [self coreDataSave];
    
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

@end
