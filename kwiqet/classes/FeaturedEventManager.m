//
//  FeaturedEventManager.m
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeaturedEventManager.h"
#import "WebUtil.h"

@implementation FeaturedEventManager

@synthesize coreDataModel;

- (Event *)featuredEvent {
    return [self.coreDataModel getFeaturedEvent];
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

- (void)processAndAddOrUpdateFeaturedEventCoreDataObjectFromFeaturedEventJSONDictionary:(NSDictionary *)jsonDictionary {
    
    // Add to/update core data
    Event * featured = [self.coreDataModel getOrCreateFeaturedEvent];
    [self.coreDataModel updateEvent:featured usingEventDictionary:jsonDictionary featured:YES fromSearch:NO];

}

- (void)dealloc {
    [coreDataModel release];
    [super dealloc];
}

@end
