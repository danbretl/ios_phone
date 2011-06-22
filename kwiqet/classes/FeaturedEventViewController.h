//
//  FeaturedEventViewController.h
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import <YAJL/YAJL.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "EGORefreshTableHeaderView.h"

#import "FeaturedEventManager.h"
#import "WebConnector.h"
#import "WebDataTranslator.h"
#import "CoreDataModel.h"
#import "MapViewController.h"
#import "FBConnect.h"

extern CGFloat const FEATURED_EVENT_MAP_BUTTON_INACTIVE_ALPHA;
extern CGFloat const FEATURED_EVENT_BACKGROUND_COLOR_ALPHA;

@interface FeaturedEventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate, UIActionSheetDelegate, FBRequestDelegate>{

    // Model, web, etc
    FeaturedEventManager * featuredEventManager;
    WebConnector * webConnector;
    WebDataTranslator * webDataTranslator;
    CoreDataModel * coreDataModel;
    NSDate * mostRecentGetNewFeaturedEventSuggestionDate;
    Facebook * facebook;
        
    // Views
    UIView * actionBarView;
    UIButton * letsGoButton;
    UIButton * shareButton;
    UIScrollView * scrollView;
    UIImageView * imageView;
    UIView * titleBarView;
    UILabel * titleLabel;
    UIView * detailsView;
    UIActionSheet * shareChoiceActionSheet;
    
    UILabel * timeLabel;
    UILabel * dateLabel;
    UILabel * venueNameLabel;
    UILabel * addressFirstLineLabel;
    UILabel * addressSecondLineLabel;
    UIButton * phoneNumberButton;
    UILabel * priceLabel;
    UILabel * eventDetailsLabel;
    UIButton * mapButton;
    UIView * noFeaturedEventView;
    EGORefreshTableHeaderView * refreshHeaderView;
    
    // Map stuff
    MapViewController * mapViewController;

}

@property (nonatomic, readonly) FeaturedEventManager * featuredEventManager;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property(nonatomic, retain) CoreDataModel * coreDataModel;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, retain) Facebook * facebook;

- (void) updateInterfaceFromFeaturedEvent:(Event *)featuredEvent;
-(IBAction)makeMapView:(id)sender;
-(IBAction)shareButtonClicked:(id)sender;
- (void)loadImageWithLocation:(NSString *)imageLocation;
- (void)displayImage:(UIImage *)image;
- (BOOL) isLastFeaturedEventGetDateToday;
-(void)suggestToGetNewFeaturedEvent; // This method is only a "suggestion" to the object because if the object determines it doesn't NEED to try to get a new featured event from the web, then it will simply ignore the request. (It ignores the request if the date of the last featured event web-get was the same day as "today" i.e. the day of the method call.)
- (void) enableRefreshHeaderView;
- (void) disableRefreshHeaderView;
- (void) tempSolutionResetAndEnableLetsGoButton;
- (void) makeAndShowEmailViewController;

@end
