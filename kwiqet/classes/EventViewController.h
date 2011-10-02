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
#import "FacebookManager.h"
#import "ContactsSelectViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "OccurrenceInfoOverlayView.h"

typedef enum {
    OCGroupDatesVenues = 1,
    OCGroupTimes = 2
} OccurrencesControlsGroup;

@protocol CardPageViewControllerDelegate;

@interface EventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, ContactsSelectViewControllerDelegate, SDWebImageManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UIView   * backgroundColorView;

    IBOutlet UIView   * navigationBar;
    IBOutlet UIButton * backButton;
    IBOutlet UIButton * logoButton;
    
    IBOutlet UIView   * actionBar;
    IBOutlet UIButton * letsGoButton;
    IBOutlet UIButton * shareButton;
    IBOutlet UIButton * deleteButton;
    
	IBOutlet UIScrollView * scrollView;
    IBOutlet ElasticUILabel * titleBar;
    UIView * shadowTitleBar;
	IBOutlet UIImageView * imageView;
    IBOutlet UIView * breadcrumbsBar;
    IBOutlet UILabel * breadcrumbsLabel;
    
    IBOutlet UIView   * occurrenceInfoContainer;
    BOOL occurrenceInfoContainerIsCollapsed;
    UIView * shadowOccurrenceInfoContainer;
    OccurrenceInfoOverlayView * occurrenceInfoOverlayView;
    IBOutlet UIView   * dateContainer;
    IBOutlet UIButton * dateOccurrenceInfoButton;
    IBOutlet UILabel  * monthLabel;
    IBOutlet UILabel  * dayNumberLabel;
    IBOutlet UILabel  * dayNameLabel;
    IBOutlet UIView   * timeContainer;
    IBOutlet UIButton * timeOccurrenceInfoButton;
    IBOutlet UILabel  * timeStartLabel;
    IBOutlet UILabel  * timeEndLabel;
    IBOutlet UIView   * priceContainer;
    IBOutlet UIButton * priceOccurrenceInfoButton;
    IBOutlet UILabel  * priceLabel;
    IBOutlet UIView   * locationContainer;
    IBOutlet UIButton * locationOccurrenceInfoButton;
    IBOutlet UILabel  * venueLabel;
    IBOutlet UILabel  * addressLabel;
    IBOutlet UILabel  * cityStateZipLabel;
    IBOutlet UIButton * phoneNumberButton;
    IBOutlet UIButton * mapButton;
    
    IBOutlet UIView   * descriptionContainer;
    IBOutlet UIView   * descriptionBackgroundColorView;
    IBOutlet UILabel  * descriptionLabel;
    UIView * shadowDescriptionContainer;

    UIView * darkOverlayViewForMainView;
    UIView * darkOverlayViewForScrollView;
    UISwipeGestureRecognizer * swipeToPullInOccurrencesControls;
    UISwipeGestureRecognizer * swipeToPushOutOccurrencesControls;
    UITapGestureRecognizer * tapToPullInOccurrencesControls;
    BOOL occurrencesControlsPulledOut;
    IBOutlet UIView      * occurrencesControlsContainer;
    IBOutlet UIImageView * occurrencesControlsHandleImageView;
    IBOutlet UIView      * occurrencesControlsNavBar;
    IBOutlet UIView      * occurrencesControlsTableViewContainer;
    IBOutlet UIView      * occurrencesControlsTableViewOverlay;
    IBOutlet UIView      * occurrencesControlsTableViewsContainer;
    IBOutlet UITableView * occurrencesControlsDatesTableView;
    IBOutlet UITableView * occurrencesControlsVenuesTableView;
    IBOutlet UIView      * occurrencesControlsDatesVenuesSeparatorView;
    IBOutlet UIView      * occurrencesControlsVenuesTimesSeparatorView;
    IBOutlet UITableView * occurrencesControlsTimesTableView;
    IBOutlet UIView      * occurrencesControlsNavBarsContainer;
    IBOutlet UIView      * occurrencesControlsDatesVenuesNavBar;
    IBOutlet UIView      * occurrencesControlsTimesNavBar;
    IBOutlet UILabel     * occurrencesControlsVenuesNearHeaderLabel;
    IBOutlet UILabel     * occurrencesControlsVenuesNearLocationLabel;
    IBOutlet UILabel     * occurrencesControlsTimesOnDateLabel;
    IBOutlet UILabel     * occurrencesControlsTimesAtVenueLabel;
    IBOutlet UIButton    * occurrencesControlsCancelButton;
    IBOutlet UIButton    * occurrencesControlsBackButton;
    
    WebActivityView * webActivityView;
    CLLocation * userLocation_; // Currently, this variable is just passed on from the events list. This will obviously need to change, so that the user's location can be changed / updated while the event card is showing.
    NSString * userLocationString_; // Currently, this variable is just passed on from the events list. This will obviously need to change, so that the user's location can be changed / updated while the event card is showing.
    Event * event;
    Occurrence * eventOccurrenceCurrent;
    int eventOccurrenceCurrentDateIndex;
    int eventOccurrenceCurrentVenueIndex;
    int eventOccurrenceCurrentTimeIndex;
    NSMutableArray * eventOccurrencesSummaryArray;
    id<CardPageViewControllerDelegate> delegate;
    CoreDataModel * coreDataModel;
    MapViewController * mapViewController;    
    WebDataTranslator * webDataTranslator;
    NSDateFormatter * occurrenceTimeFormatter;
    NSDateFormatter * occurrencesControlsNavBarDateFormatter;
    WebConnector * webConnector;
    UIAlertView * connectionErrorOnUserActionRequestAlertView;
    BOOL deleteAllowed_;
    BOOL deletedEventDueToGoingToEvent;
    FacebookManager * facebookManager;
    
    UIActionSheet  * letsGoChoiceActionSheet;
    NSMutableArray * letsGoChoiceActionSheetSelectors;
    UIActionSheet  * shareChoiceActionSheet;
    NSMutableArray * shareChoiceActionSheetSelectors;
    
    BOOL debuggingOccurrencesPicker;

}

- (void) setUserLocation:(CLLocation *)userLocation withUserLocationString:(NSString *)userLocationString;
@property (nonatomic, retain) Event * event;
@property (assign) id<CardPageViewControllerDelegate> delegate;
@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, readonly) FacebookManager * facebookManager;
@property (nonatomic) BOOL deleteAllowed;

- (void) viewControllerIsFinished;
- (void) updateViewsFromDataAnimated:(BOOL)animated;
- (void) showWebLoadingViews;
- (void) hideWebLoadingViews;

@end

@protocol CardPageViewControllerDelegate <NSObject>
@required
- (void) cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI;
@end