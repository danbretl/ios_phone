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

#import "WebConnector.h"
#import "WebDataTranslator.h"
#import "CoreDataModel.h"
#import "MapViewController.h"
#import "FacebookManager.h"
#import "WebActivityView.h"
#import "ElasticUILabel.h"

#import "ContactsSelectViewController.h"

extern CGFloat const FEATURED_EVENT_MAP_BUTTON_INACTIVE_ALPHA;
extern CGFloat const FEATURED_EVENT_BACKGROUND_COLOR_ALPHA;

@interface FeaturedEventViewController : UIViewController <MFMailComposeViewControllerDelegate, WebConnectorDelegate, MapViewControllerDelegate, UIActionSheetDelegate, FBRequestDelegate, ContactsSelectViewControllerDelegate>{
    
    Event * featuredEvent;

    // Model, web, etc
    WebConnector * webConnector;
    WebDataTranslator * webDataTranslator;
    CoreDataModel * coreDataModel;
    NSDate * mostRecentGetNewFeaturedEventSuggestionDate;
    FacebookManager * facebookManager;
        
    // Views
    UIView * actionBarView;
    UIButton * letsGoButton;
    UIButton * shareButton;
    UIScrollView * scrollView;
    UIImageView * imageView;
    ElasticUILabel * titleBar;
    
    UIView * detailsView;
    WebActivityView * webActivityView;
    
    UILabel * timeLabel;
    UILabel * dateLabel;
    UILabel * venueNameLabel;
    UILabel * addressFirstLineLabel;
    UILabel * addressSecondLineLabel;
    UIButton * phoneNumberButton;
    UILabel * priceLabel;
    UIView * eventDetailsContainer;
    UILabel * eventDetailsLabel;
    UIButton * mapButton;
    UIView * noFeaturedEventView;
    EGORefreshTableHeaderView * refreshHeaderView;
    
    // Map stuff
    MapViewController * mapViewController;
    
//    UIImage * imageFull;
    
    UIActionSheet * letsGoChoiceActionSheet;
    NSMutableArray * letsGoChoiceActionSheetSelectors;
    UIActionSheet * shareChoiceActionSheet;
    NSMutableArray * shareChoiceActionSheetSelectors;
    
}

@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property(nonatomic, retain) CoreDataModel * coreDataModel;
@property(nonatomic,readonly) EGORefreshTableHeaderView *refreshHeaderView;
@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) FacebookManager * facebookManager;
@property (retain) Event * featuredEvent;

- (void) updateInterfaceFromFeaturedEvent:(Event *)featuredEvent;
//- (void) loadImageWithLocation:(NSString *)imageLocation;
//- (void) displayImage:(UIImage *)image;
- (BOOL) isLastFeaturedEventGetDateToday;
- (void) suggestToGetNewFeaturedEvent; // This method is only a "suggestion" to the object because if the object determines it doesn't NEED to try to get a new featured event from the web, then it will simply ignore the request. (It ignores the request if the date of the last featured event web-get was the same day as "today" i.e. the day of the method call.)
- (void) enableRefreshHeaderView;
- (void) disableRefreshHeaderView;
- (void) tempSolutionResetAndEnableLetsGoButton;
- (void) showWebActivityView;
- (void) hideWebActivityView;

@end
