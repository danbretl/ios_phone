//
//  FeaturedEventManager.h
//  Abextra
//
//  Created by Dan Bretl on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataModel.h"
#import "WebDataTranslator.h"

@interface FeaturedEventManager : NSObject {
    CoreDataModel * coreDataModel;
    WebDataTranslator * webDataTranslator;
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, readonly) Event * featuredEvent;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;

- (void) processAndAddOrUpdateFeaturedEventCoreDataObjectFromFeaturedEventJSONDictionary:(NSDictionary *)jsonDictionary;


@end
