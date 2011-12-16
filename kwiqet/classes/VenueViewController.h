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
#import "StackViewControllerDelegate.h"
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "SDWebImageManager.h"

@interface VenueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, StackViewControllerDelegate, MapViewControllerDelegate, MKMapViewDelegate, SDWebImageManagerDelegate> {
    
    // Delegate
    id<StackViewControllerDelegate> delegate;
    
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
    CGFloat imageViewNormalHeight;
    UIView * infoContainer_;
    UILabel * addressLabel_;
    UILabel * cityStateZipLabel_;
    UIButton * phoneNumberButton_;
    UIButton * mapButton_;
    MKMapView * mapView_;
    UIView * descriptionContainer_;
    UILabel * descriptionLabel_;
    
    UIView * eventsHeaderContainer_;
    UILabel * eventsHeaderLabel_;
    UITableView * eventsTableView_;
    
    // View Controllers
    MapViewController * mapViewController_;
    
}

@property (assign) id<StackViewControllerDelegate> delegate;

@property (retain, nonatomic) Place * venue;

@end