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

@protocol CardPageViewControllerDelegate;

@interface EventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate> {
    
    UIView * navigationBar;
    UIButton * backButton;
    UIButton * logoButton;
    
    UIView * actionBar;
    UIButton * letsGoButton;
    UIButton * shareButton;
    UIButton * deleteButton;
    
    ElasticUILabel * titleBar;
    
	UIScrollView * scrollView;
	UIImageView * imageView;
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
    
    UILabel * detailsLabel;
    
    
    
    

    NSString *categoryColor;
	
	NSDictionary *eventDictionary;
	
	NSDate *eventStartDatetime;
    NSDate *eventEndDatetime;
	NSString *phoneString;
    
    NSString *eventDetailID;
    NSString *eventTime;
    NSString *costString;
    
    CoreDataModel * coreDataModel;
    
    id<CardPageViewControllerDelegate> delegate;
    
    WebConnector * webConnector;
    UIAlertView * connectionErrorOnUserActionRequestAlertView;
    
    BOOL deletedEventDueToGoingToEvent;
    
    // Map stuff
    MapViewController * mapViewController;
    
    WebDataTranslator * webDataTranslator;

}

@property (assign) id<CardPageViewControllerDelegate> delegate;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnUserActionRequestAlertView;
@property (nonatomic,retain) NSDictionary * eventDictionary;
@property (nonatomic,retain) NSDate * eventStartDatetime;
@property (nonatomic,retain) NSDate * eventEndDatetime;
@property (nonatomic,retain) NSString * phoneString;
@property (nonatomic,retain) NSString * categoryColor;
@property (nonatomic,retain) NSString * eventDetailID;
@property (nonatomic,retain) NSString * eventTime;
@property (nonatomic,retain) NSString * costString;
@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (retain) MapViewController * mapViewController;

- (void) makeSubViews;
- (void) viewControllerIsFinished;
- (void) breadcrumbs;

- (IBAction) bookedButtonClicked:(id)sender;

- (IBAction) addCalendar:(id)sender;
- (IBAction) shareButtonClicked:(id)sender;
- (IBAction) deleteEvent:(id)sender;
- (IBAction) phoneCall:(id)sender;
- (IBAction) makeMapView:(id)sender;

- (void) eventRequestWithID:(NSString*)eventID;
- (void) buildArrayFromRequest:(NSString*)string;

@end

@protocol CardPageViewControllerDelegate <NSObject>
@required
- (void) cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI;
@end