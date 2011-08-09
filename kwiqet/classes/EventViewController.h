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

@protocol CardPageViewControllerDelegate;

@interface EventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, ContactsSelectViewControllerDelegate, SDWebImageManagerDelegate> {
    
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
	IBOutlet UIImageView * imageView;
    IBOutlet UIView * breadcrumbsBar;
    IBOutlet UILabel * breadcrumbsLabel;
    
    IBOutlet UIView   * occurrenceInfoContainer;
    IBOutlet UIView   * dateContainer;
    IBOutlet UILabel  * monthLabel;
    IBOutlet UILabel  * dayNumberLabel;
    IBOutlet UILabel  * dayNameLabel;
    IBOutlet UIView   * timeContainer;
    IBOutlet UILabel  * timeLabel;
    IBOutlet UIView   * priceContainer;
    IBOutlet UILabel  * priceLabel;
    IBOutlet UIView   * locationContainer;
    IBOutlet UILabel  * venueLabel;
    IBOutlet UILabel  * addressLabel;
    IBOutlet UILabel  * cityStateZipLabel;
    IBOutlet UIButton * phoneNumberButton;
    IBOutlet UIButton * mapButton;
    
    IBOutlet UIView   * descriptionContainer;
    IBOutlet UIView   * descriptionBackgroundColorView;
    IBOutlet UILabel  * descriptionLabel;
    UIView * shadowDescriptionContainer;
    
    WebActivityView * webActivityView;
    
    Event * event;
    id<CardPageViewControllerDelegate> delegate;
    CoreDataModel * coreDataModel;
    MapViewController * mapViewController;    
    WebDataTranslator * webDataTranslator;
    WebConnector * webConnector;
    UIAlertView * connectionErrorOnUserActionRequestAlertView;
    BOOL deletedEventDueToGoingToEvent;
//    BOOL loadedImage;
    FacebookManager * facebookManager;
//    UIImage * imageFull;
    NSURLConnection * loadImageURLConnection;
    NSMutableData * loadImageData;
    
    UIActionSheet  * letsGoChoiceActionSheet;
    NSMutableArray * letsGoChoiceActionSheetSelectors;
    UIActionSheet  * shareChoiceActionSheet;
    NSMutableArray * shareChoiceActionSheetSelectors;

}

@property (nonatomic, retain) Event * event;
@property (assign) id<CardPageViewControllerDelegate> delegate;
@property (nonatomic, retain) CoreDataModel * coreDataModel;
@property (nonatomic, readonly) FacebookManager * facebookManager;

- (void) viewControllerIsFinished;
- (void) updateViewsFromData;
- (void) showWebLoadingViews;
- (void) hideWebLoadingViews;

@end

@protocol CardPageViewControllerDelegate <NSObject>
@required
- (void) cardPageViewControllerDidFinish:(EventViewController *)cardPageViewController withEventDeletion:(BOOL)eventWasDeleted eventURI:(NSString *)eventURI;
@end