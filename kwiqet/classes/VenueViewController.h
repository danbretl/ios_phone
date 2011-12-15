//
//  VenueViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElasticUILabel.h"
#import "Place.h"
#import "WebDataTranslator.h"

@protocol VenueViewControllerDelegate;

@interface VenueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Delegate
    id<VenueViewControllerDelegate> delegate;
    
    // Models
    Place * venue_;
    WebDataTranslator * webDataTranslator_;
    
    // Views
    UIView * navBarContainer_;
    UIButton * backButton_;
    UIButton * logoButton_;
    UIButton * followButton_;
    
    UIView * mainContainer_;
    ElasticUILabel * nameBar_;
    UIImageView * imageView_;
    UIView * infoContainer_;
    UILabel * addressLabel_;
    UILabel * cityStateZipLabel_;
    UIButton * phoneNumberButton_;
    UIButton * mapButton_;
    UIView * descriptionContainer_;
    UILabel * descriptionLabel_;
    
    UITableView * eventsTableView_;
    
}

@property (assign) id<VenueViewControllerDelegate> delegate;

@property (retain, nonatomic) Place * venue;

@end

@protocol VenueViewControllerDelegate <NSObject>
@required
- (void) venueViewControllerDidFinish:(VenueViewController *)venueViewController;
- (void) venueViewControllerDidRequestStackCollapse:(VenueViewController *)venueViewController;
@end