//
//  FeaturedHubViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataModel.h"

@interface FeaturedHubViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    
    BOOL debugging;
    
    CoreDataModel * coreDataModel_;
    
    NSArray * featuredEvents_;
    NSArray * featuredVenues_;
    NSDictionary * featuredEventsForVenues_;
    
    UITableView * tableView_;
//    CGPoint featuredEventsContentOffset_;
    NSMutableDictionary * tableViewSectionHeaderViews_;
    NSMutableDictionary * tableViewVenueEventsGroupIndexes_;
    
}

@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, retain) NSArray * featuredEvents;
@property (nonatomic, retain) NSArray * featuredVenues;
@property (nonatomic, retain) NSDictionary * featuredEventsForVenues;

@end
