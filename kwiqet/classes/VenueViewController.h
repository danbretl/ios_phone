//
//  VenueViewController.h
//  Kwiqet
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
#import "EventsWebQuery.h"
#import "CoreDataModel.h"
#import "UpcomingEventsHeaderView.h"
#import "WebConnector.h"
#import "EventViewController.h"

@interface VenueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, StackViewControllerDelegate, MapViewControllerDelegate, MKMapViewDelegate, SDWebImageManagerDelegate, UIGestureRecognizerDelegate, WebConnectorDelegate> {
    
    // Delegate
    id<StackViewControllerDelegate> delegate;
    
    // Models
    Place * venue_;
    EventViewController * eventViewControllerSourceOfReferral_;
    WebDataTranslator * webDataTranslator_;
    EventsWebQuery * eventsWebQuery_;
    NSMutableArray * events_;
    CoreDataModel * coreDataModel_;
    WebConnector * webConnector_;
    BOOL isGettingEvents_;
    BOOL isGettingImage_;
    UpcomingEventsHeaderViewMessageType appropriateMessageType_;
    UserLocation * userLocation_;
    BOOL deletedFromEventCard_;
    
    // View models
    NSIndexPath * eventsTableViewIndexPathOfSelectedRowPreserved_;
    CGFloat scrollViewContentOffsetHeightLeftUntilEndPreserved_;
    BOOL scrollViewContentOffsetInfoIsPreserved_;
    
    // Views
    UIView * navBarContainer_;
    UIButton * backButton_;
    UIButton * logoButton_;
    UIButton * followButton_;
    
    UIScrollView * scrollView_;
    UIView * mainContainer_;
    NSArray * mainContainerChainOfDependentlyPositionedViews_;
    ElasticUILabel * nameBar_;
    UIImageView * imageView_;
    CGFloat imageViewNormalHeight;
    UIView * infoContainer_;
    UIView * infoContainerShadowView_;
    UIView * infoContainerBackgroundView_;
    UILabel * addressLabel_;
    UILabel * cityStateZipLabel_;
    UIButton * phoneNumberButton_;
    UIButton * mapButton_;
    MKMapView * mapView_;
    UIView * descriptionContainer_;
    UILabel * descriptionLabel_;
    UIButton * descriptionReadMoreButton_;
    GradientView * descriptionReadMoreCoverView_;
    
    UpcomingEventsHeaderView * eventsHeaderView_;
    UIView * eventsHeaderViewShadow_;
    UITableView * eventsTableView_;
    
    WebActivityView * webActivityView_;
    UIAlertView * connectionErrorStandardAlertView_;
        
    // View Controllers
    MapViewController * mapViewController_;
    EventViewController * eventViewController_;
    
    // Gesture Recognizers
    UISwipeGestureRecognizer * swipeToGoBack_;
    
}

@property (assign) id<StackViewControllerDelegate> delegate;

@property (retain, nonatomic) Place * venue;
@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, retain) UserLocation * userLocation;
@property (assign, nonatomic) EventViewController * eventViewControllerSourceOfReferral;

@end