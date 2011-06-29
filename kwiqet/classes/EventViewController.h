//
//  CardPageViewController.h
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <YAJL/YAJL.h>
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreDataModel.h"
#import "WebConnector.h"
#import "MapViewController.h"
#import "WebDataTranslator.h"
#import "ElasticUILabel.h"
#import "WebActivityView.h"

@protocol CardPageViewControllerDelegate;

@interface EventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate, UIScrollViewDelegate> {
    
    UIView * backgroundColorView;
    UIView * navigationBar;
    UIButton * backButton;
    UIButton * logoButton;
    
    UIView * actionBar;
    UIButton * letsGoButton;
    UIButton * shareButton;
    UIButton * deleteButton;
    
    ElasticUILabel * titleBar;
    UIView * titleBarBorderCheatView;
    
	UIScrollView * scrollView;
	UIImageView * imageView;
    UIView * breadcrumbsBar;
    UILabel * breadcrumbsLabel;
    
    UIView * eventInfoDividerView;
    UILabel * monthLabel;
    UILabel * dayNumberLabel;
    UILabel * dayNameLabel;
    
    UILabel * priceLabel;
    UILabel * timeLabel;
    
    UILabel * venueLabel;
    UILabel * addressLabel;
    UILabel * cityStateZipLabel;
    UIButton * phoneNumberButton;
    UIButton * mapButton;
    
    UIView * detailsContainer;
    UIView * detailsBackgroundColorView;
    UILabel * detailsLabel;
    
    WebActivityView * webActivityView;
    
    Event * event;
    id<CardPageViewControllerDelegate> delegate;
    CoreDataModel * coreDataModel;
    MapViewController * mapViewController;    
    WebDataTranslator * webDataTranslator;
    WebConnector * webConnector;
    UIAlertView * connectionErrorOnUserActionRequestAlertView;
    BOOL deletedEventDueToGoingToEvent;

}

@property (nonatomic, retain) Event * event;
@property (assign) id<CardPageViewControllerDelegate> delegate;
@property (nonatomic, retain) CoreDataModel * coreDataModel;

- (void) viewControllerIsFinished;
- (void) updateViewsFromData;
- (void) makeAndShowEmailViewController;
- (void) showWebLoadingViews;
- (void) hideWebLoadingViews;

@end

@protocol CardPageViewControllerDelegate <NSObject>
@required
- (void) cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI;
@end