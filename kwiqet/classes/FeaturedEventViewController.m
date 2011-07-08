//
//  FeaturedEventViewController.m
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "FeaturedEventViewController.h"
#import "DefaultsModel.h"
#import "URLBuilder.h"
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocalImagesManager.h"
#import "WebUtil.h"
#import "ActionsManagement.h"

// "Data not available" strings
static NSString * const FEATURED_EVENT_TITLE_NOT_AVAILABLE = @"Event";
static NSString * const FEATURED_EVENT_DATE_NOT_AVAILABLE = @"Date not available";
static NSString * const FEATURED_EVENT_TIME_NOT_AVAILABLE = @"Time not available";
static NSString * const FEATURED_EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
static NSString * const FEATURED_EVENT_COST_NOT_AVAILABLE = @"Not available";
static NSString * const FEATURED_EVENT_ADDRESS_NOT_AVAILABLE = @"Address not available";
static NSString * const FEATURED_EVENT_PHONE_NUMBER_NOT_AVAILABLE = @"Phone number not available";

// Alpha constants
float const FEATURED_EVENT_MAP_BUTTON_INACTIVE_ALPHA = 0.5;
float const FEATURED_EVENT_BACKGROUND_COLOR_ALPHA = 0.15;

// View constants
CGFloat const FEV_ACTION_BAR_HEIGHT      =  36.0;
CGFloat const FEV_ACTION_BAR_PADDING     =   5.0; // Respected on the left, top, and right sides, but the bottom is not guaranteed.
CGFloat const FEV_ACTION_BUTTON_HEIGHT   =  25.0;
CGFloat const FEV_ACTION_BUTTON_WIDTH    = 100.0;
CGFloat const FEV_IMAGE_VIEW_HEIGHT      = 180.0;
CGFloat const FEV_TITLE_BAR_HEIGHT       =  32.0;
CGFloat const FEV_TITLE_BAR_PADDING      =   5.0; // Respected on the left, top, and right sides, but the bottom is not guaranteed.
CGFloat const FEV_TITLE_LABEL_HEIGHT     =  34.0;
static NSString * const FEV_TITLE_LABEL_FONT_NAME = @"HelveticaNeueLTStd-BdCn";
CGFloat const FEV_TITLE_LABEL_FONT_SIZE  =  25.0;
CGFloat const FEV_DETAILS_VIEW_HEIGHT    = 161.0;
CGFloat const FEV_DETAILS_PADDING_HOR   =   20.0; // This is not necessarily respected by the map button
CGFloat const FEV_TIME_LABEL_ORIGIN_Y    =  11.0;
CGFloat const FEV_TIME_LABEL_HEIGHT      =  25.0;
CGFloat const FEV_DATE_LABEL_HEIGHT      =  25.0;
CGFloat const FEV_DATE_LABEL_ORIGIN_Y_DIFF_FROM_TIME_LABEL = 20.0;
CGFloat const FEV_VENUE_LABEL_ORIGIN_Y = 60.0;
CGFloat const FEV_VENUE_LABEL_HEIGHT = 30.0;
CGFloat const FEV_ADDRESS_LABELS_HEIGHT = 25.0;
CGFloat const 
  FEV_ADDRESS_FIRST_LABEL_ORIGIN_Y_DIFF_FROM_VENUE_LABEL = 24.0;
CGFloat const 
  FEV_ADDRESS_SECOND_LABEL_ORIGIN_Y_DIFF_FROM_VENUE_LABEL = 43.0;
CGFloat const 
  FEV_MAP_BUTTON_PADDING  =  10.0;
CGFloat const FEV_MAP_BUTTON_WIDTH = 64.0;
CGFloat const FEV_MAP_BUTTON_HEIGHT = 20.0;
CGFloat const FEV_MAP_BUTTON_ORIGIN_Y_CALC_OFFSET = -6.0;
CGFloat const FEV_PRICE_LABEL_ORIGIN_Y = 138.0;
CGFloat const FEV_PRICE_LABEL_WIDTH = 150.0;
CGFloat const FEV_PRICE_LABEL_HEIGHT = 25.0;
CGFloat const FEV_PHONE_BUTTON_PADDING_RIGHT = 10.0;
CGFloat const FEV_PHONE_BUTTON_ORIGIN_Y = 141.0;
CGFloat const FEV_PHONE_BUTTON_HEIGHT = 20.0;
CGFloat const FEV_DESCRIPTION_LABEL_PADDING_VERTICAL = 10.0;
CGFloat const FEV_DESCRIPTION_LABEL_PADDING_HORIZONTAL = 20.0;

@interface FeaturedEventViewController()
// Views
@property (retain) UIView * actionBarView;
@property (retain) UIButton * letsGoButton;
@property (retain) UIButton * shareButton;
@property (retain) UIScrollView * scrollView;
@property (retain) UIImageView * imageView;
@property (retain) UIView * titleBarView;
@property (retain) UILabel * titleLabel;
@property (retain) UIView * detailsView;
@property (retain) UIActionSheet * letsGoChoiceActionSheet;
@property (retain) WebActivityView * webActivityView;

@property (retain) NSDate * mostRecentGetNewFeaturedEventSuggestionDate;
@property (retain) UILabel * timeLabel;
@property (retain) UILabel * dateLabel;
@property (retain) UILabel * venueNameLabel;
@property (retain) UILabel * addressFirstLineLabel;
@property (retain) UILabel * addressSecondLineLabel;
@property (retain) UIButton * phoneNumberButton;
@property (retain) UILabel * priceLabel;
@property (retain) UIView * eventDetailsContainer;
@property (retain) UILabel * eventDetailsLabel;
@property (retain) UIButton * mapButton;
@property (retain) UIView * noFeaturedEventView;
@property (retain) UIImage * imageFull;

- (void) mapButtonTouched;
- (void) shareButtonTouched;
- (void) letsGoButtonTouched;

- (void) facebookEventCreateSuccess:(NSNotification *)notification;
- (void) facebookEventCreateFailure:(NSNotification *)notification;
- (void) facebookEventInviteSuccess:(NSNotification *)notification;
- (void) facebookEventInviteFailure:(NSNotification *)notification;

@end

@implementation FeaturedEventViewController
@synthesize mostRecentGetNewFeaturedEventSuggestionDate, coreDataModel, facebookManager;
@synthesize mapViewController;
@synthesize actionBarView, letsGoButton, shareButton, scrollView, imageView, titleBarView, titleLabel, detailsView, letsGoChoiceActionSheet, webActivityView;
@synthesize timeLabel, dateLabel, venueNameLabel, addressFirstLineLabel, addressSecondLineLabel, phoneNumberButton, priceLabel, eventDetailsContainer, eventDetailsLabel, mapButton, noFeaturedEventView, refreshHeaderView;
@synthesize imageFull;

#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 self = [super initWithStyle:style];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

- (void)dealloc {
    // Views
    [actionBarView release];
    [letsGoButton release];
    [shareButton release];
    [scrollView release];
    [imageView release];
    [titleBarView release];
    [titleLabel release];
    [detailsView release];
    [letsGoChoiceActionSheet release];
    [webActivityView release];
    
    [webConnector release];
    [coreDataModel release];
    [facebookManager release];
    [mostRecentGetNewFeaturedEventSuggestionDate release];
    [mapViewController release];

    [timeLabel release];
    [dateLabel release];
    [venueNameLabel release];
    [addressFirstLineLabel release];
    [addressSecondLineLabel release];
    [phoneNumberButton release];
    [priceLabel release];
    [eventDetailsContainer release];
    [eventDetailsLabel release];
    [mapButton release];
    [noFeaturedEventView release];
    [refreshHeaderView release];
    
    [imageFull release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:FEATURED_EVENT_BACKGROUND_COLOR_ALPHA];
	
    // Action bar
    self.actionBarView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, FEV_ACTION_BAR_HEIGHT)] autorelease];
    self.actionBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"actbar.png"]];
    [self.view addSubview:self.actionBarView];
    {
        // Let's go button
        self.letsGoButton = [[[UIButton alloc] initWithFrame:CGRectMake(FEV_ACTION_BAR_PADDING, FEV_ACTION_BAR_PADDING, FEV_ACTION_BUTTON_WIDTH, FEV_ACTION_BUTTON_HEIGHT)] autorelease];
        [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_letsgo.png"] forState: UIControlStateNormal];
        [self.letsGoButton addTarget:self action:@selector(letsGoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBarView addSubview:self.letsGoButton];
        
        // Share button
        self.shareButton = [[[UIButton alloc]initWithFrame:CGRectMake(self.actionBarView.bounds.size.width - FEV_ACTION_BUTTON_WIDTH - FEV_ACTION_BAR_PADDING, FEV_ACTION_BAR_PADDING, FEV_ACTION_BUTTON_WIDTH, FEV_ACTION_BUTTON_HEIGHT)] autorelease];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"btn_share.png"] forState: UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBarView addSubview:self.shareButton];
    }
    
    // Scroll view
    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.actionBarView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.actionBarView.frame))] autorelease];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollView.bouncesZoom = YES;
	[self.scrollView setContentSize:self.scrollView.bounds.size];
    [self.view addSubview:self.scrollView];
    {
        // Image view
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, FEV_IMAGE_VIEW_HEIGHT)];
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.imageView];
        
        // Title bar
        self.titleBarView = [[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.scrollView.bounds.size.width, FEV_TITLE_BAR_HEIGHT)] autorelease];
        self.titleBarView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:self.titleBarView];
        {
            // Title Label
            self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(FEV_TITLE_BAR_PADDING, FEV_TITLE_BAR_PADDING, self.titleBarView.bounds.size.width - FEV_TITLE_BAR_PADDING * 2, FEV_TITLE_LABEL_HEIGHT)] autorelease];
            self.titleLabel.font = [UIFont fontWithName:FEV_TITLE_LABEL_FONT_NAME size:FEV_TITLE_LABEL_FONT_SIZE];
            self.titleLabel.backgroundColor = [UIColor clearColor];
            self.titleLabel.textColor = [UIColor whiteColor];
            self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.titleLabel.textAlignment = UITextAlignmentLeft;
            [self.titleBarView addSubview:self.titleLabel];
        }
        
        // Event details view
        self.detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleBarView.frame), self.scrollView.bounds.size.width, FEV_DETAILS_VIEW_HEIGHT)];
        self.detailsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"eotd_card.png"]];
        [self.scrollView addSubview:self.detailsView];
        {
            // Time label
            self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR,FEV_TIME_LABEL_ORIGIN_Y,self.detailsView.bounds.size.width - 2 * FEV_DETAILS_PADDING_HOR,FEV_TIME_LABEL_HEIGHT)] autorelease];
            self.timeLabel.backgroundColor = [UIColor clearColor];
            self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.timeLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:(20)];
            self.timeLabel.numberOfLines = 0;
            self.timeLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.timeLabel];
            
            // Date label
            self.dateLabel =[[[UILabel alloc]initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR, self.timeLabel.frame.origin.y + FEV_DATE_LABEL_ORIGIN_Y_DIFF_FROM_TIME_LABEL, self.detailsView.bounds.size.width - 2 * FEV_DETAILS_PADDING_HOR, FEV_DATE_LABEL_HEIGHT)] autorelease];
            self.dateLabel.backgroundColor = [UIColor clearColor];
            self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.dateLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:(16)];
            self.dateLabel.numberOfLines = 0;
            self.dateLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.dateLabel];
            
            // Venue label
            self.venueNameLabel = [[[UILabel alloc]initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR, FEV_VENUE_LABEL_ORIGIN_Y, self.detailsView.bounds.size.width - 2 * FEV_DETAILS_PADDING_HOR,FEV_VENUE_LABEL_HEIGHT)] autorelease];
            self.venueNameLabel.backgroundColor = [UIColor clearColor];
            self.venueNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.venueNameLabel.numberOfLines = 0;
            self.venueNameLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:(20)];
            self.venueNameLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.venueNameLabel];
            
            // Address label
            self.addressFirstLineLabel = [[[UILabel alloc]initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR,self.venueNameLabel.frame.origin.y + FEV_ADDRESS_FIRST_LABEL_ORIGIN_Y_DIFF_FROM_VENUE_LABEL,self.detailsView.frame.size.width - FEV_DETAILS_PADDING_HOR - FEV_MAP_BUTTON_PADDING * 2 - FEV_MAP_BUTTON_WIDTH,FEV_ADDRESS_LABELS_HEIGHT)] autorelease];
            self.addressFirstLineLabel.backgroundColor = [UIColor clearColor];
            self.addressFirstLineLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.addressFirstLineLabel.numberOfLines = 0;
            self.addressFirstLineLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:(16)];
            self.addressFirstLineLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.addressFirstLineLabel];
            
            // Address second line label
            self.addressSecondLineLabel= [[[UILabel alloc]initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR, self.venueNameLabel.frame.origin.y + FEV_ADDRESS_SECOND_LABEL_ORIGIN_Y_DIFF_FROM_VENUE_LABEL,self.detailsView.frame.size.width - FEV_DETAILS_PADDING_HOR - FEV_MAP_BUTTON_PADDING * 2 - FEV_MAP_BUTTON_WIDTH,FEV_ADDRESS_LABELS_HEIGHT)] autorelease];
            self.addressSecondLineLabel.backgroundColor = [UIColor clearColor];
            self.addressSecondLineLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.addressSecondLineLabel.numberOfLines = 0;
            self.addressSecondLineLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:(16)];
            self.addressSecondLineLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.addressSecondLineLabel];
            
            // Map button
            CGFloat midpointYOfAddressLabels = (CGRectGetMinY(self.addressFirstLineLabel.frame) + CGRectGetMaxY(self.addressSecondLineLabel.frame)) / 2.0;
            self.mapButton = [[[UIButton alloc]initWithFrame:CGRectMake(self.detailsView.bounds.size.width - FEV_MAP_BUTTON_WIDTH - FEV_MAP_BUTTON_PADDING, midpointYOfAddressLabels - FEV_MAP_BUTTON_HEIGHT / 2.0 + FEV_MAP_BUTTON_ORIGIN_Y_CALC_OFFSET, FEV_MAP_BUTTON_WIDTH,FEV_MAP_BUTTON_HEIGHT)] autorelease];
            [mapButton setBackgroundImage:[UIImage imageNamed:@"btn_map.png"] forState: UIControlStateNormal];
            [mapButton addTarget:self action:@selector(mapButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            mapButton.alpha = FEATURED_EVENT_MAP_BUTTON_INACTIVE_ALPHA;
            [self.detailsView addSubview:mapButton];
            [mapButton release];
            
            // Phone number button
            CGFloat dummyOriginX = 170;
            CGFloat dummyWidth = 150;
            self.phoneNumberButton = [[[UIButton alloc] initWithFrame:CGRectMake(dummyOriginX, FEV_PHONE_BUTTON_ORIGIN_Y, dummyWidth, FEV_PHONE_BUTTON_HEIGHT)] autorelease];
            self.phoneNumberButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [self.phoneNumberButton setTitle:FEATURED_EVENT_PHONE_NUMBER_NOT_AVAILABLE forState:UIControlStateNormal];
            [self.phoneNumberButton sizeToFit];
            CGRect phoneNumberButtonFrame = self.phoneNumberButton.frame;
            phoneNumberButtonFrame.origin.x = self.detailsView.frame.size.width - FEV_PHONE_BUTTON_PADDING_RIGHT - phoneNumberButtonFrame.size.width;
            self.phoneNumberButton.frame = phoneNumberButtonFrame;
            self.phoneNumberButton.userInteractionEnabled = NO;
            [self.phoneNumberButton setTitleColor:[UIColor colorWithRed:0.2549 green:0.41568 blue:0.70196 alpha:1.0]forState:UIControlStateNormal];
            [self.phoneNumberButton addTarget:self action:@selector(phoneCall:) forControlEvents:UIControlEventTouchUpInside];
            self.phoneNumberButton.backgroundColor = [UIColor clearColor];
            self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:(12)];
            self.phoneNumberButton.titleLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.phoneNumberButton];
            
            // Price label
            self.priceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(FEV_DETAILS_PADDING_HOR,FEV_PRICE_LABEL_ORIGIN_Y,FEV_PRICE_LABEL_WIDTH,FEV_PRICE_LABEL_HEIGHT)] autorelease];
            self.priceLabel.backgroundColor = [UIColor clearColor];
            self.priceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            self.priceLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:(16)];
            self.priceLabel.numberOfLines = 0;
            self.priceLabel.textAlignment = UITextAlignmentLeft;
            [self.detailsView addSubview:self.priceLabel];
            
        }
        
        // Event details container
        eventDetailsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.detailsView.frame), self.scrollView.bounds.size.width, 0.0)];
        [self.scrollView addSubview:self.eventDetailsContainer];
        // Event details label
        eventDetailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(FEV_DESCRIPTION_LABEL_PADDING_HORIZONTAL, FEV_DESCRIPTION_LABEL_PADDING_VERTICAL, self.eventDetailsContainer.bounds.size.width - FEV_DESCRIPTION_LABEL_PADDING_HORIZONTAL * 2.0, 0)];
        self.eventDetailsLabel.adjustsFontSizeToFitWidth = NO;
        self.eventDetailsLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16];
        self.eventDetailsLabel.textColor = [UIColor blackColor];
        self.eventDetailsLabel.backgroundColor = [UIColor clearColor];
        self.eventDetailsLabel.numberOfLines = 0;
        [self.eventDetailsContainer addSubview:self.eventDetailsLabel];
        
    }
    
    // Subviews for if/when we have no featured event to display. Should disable UI, display an apologetic message describing the problem, and provide a reload/retry button.
    self.noFeaturedEventView = [[[UIView alloc] initWithFrame:CGRectMake(20.0, 67.0, self.view.frame.size.width - 40.0, 200.0)] autorelease];
    self.noFeaturedEventView.backgroundColor = [UIColor clearColor];// [UIColor colorWithWhite:1.0 alpha:1.0];
    self.noFeaturedEventView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.noFeaturedEventView.layer.cornerRadius = 10.0;
    self.noFeaturedEventView.layer.masksToBounds = YES;
    self.noFeaturedEventView.alpha = 0.0;
    [self.view addSubview:self.noFeaturedEventView];
    [self.view bringSubviewToFront:self.noFeaturedEventView];
    UILabel * errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.noFeaturedEventView.bounds.size.width - 0.0, self.noFeaturedEventView.bounds.size.height)];
    errorMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    errorMessage.numberOfLines = 0;
    errorMessage.text = WEB_CONNECTION_ERROR_MESSAGE_STANDARD;
    errorMessage.backgroundColor = [UIColor clearColor];
    errorMessage.textColor = [UIColor whiteColor];
    errorMessage.userInteractionEnabled = NO;
    errorMessage.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    [self.noFeaturedEventView addSubview:errorMessage];
    [errorMessage release];
    
    // Pull-to-refresh view
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrameRelativeToFrame:CGRectMake(0.0, 0.0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    [self disableRefreshHeaderView];
    [self.scrollView addSubview:refreshHeaderView];
    
    // Web activity view
    self.webActivityView = [[[WebActivityView alloc] initWithSize:CGSizeMake(60.0, 60.0) centeredInFrame:self.view.frame] autorelease];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    [self suggestToGetNewFeaturedEvent]; NSLog(@"FROM EVENT DAY VIEW CONTROLLER VIEW DID LOAD LINE 291");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventCreateSuccess:) name:FBM_CREATE_EVENT_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventCreateFailure:) name:FBM_CREATE_EVENT_FAILURE_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventInviteSuccess:) name:FBM_EVENT_INVITE_FRIENDS_SUCCESS_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEventInviteFailure:) name:FBM_EVENT_INVITE_FRIENDS_FAILURE_KEY object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [self suggestToGetNewFeaturedEvent]; NSLog(@"FROM EVENT DAY VIEW CONTROLLER VIEW WILL APPEAR LINE 291");
    [self tempSolutionResetAndEnableLetsGoButton];
    
}

- (void) tempSolutionResetAndEnableLetsGoButton {
    [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_letsgo.png"] forState: UIControlStateNormal];
    self.letsGoButton.enabled = YES;
}

- (BOOL) isLastFeaturedEventGetDateToday {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    NSDateComponents * lastFeaturedEventGetDateComponents = [calendar components:flags fromDate:[DefaultsModel loadLastFeaturedEventGetDate]];
    NSDateComponents * nowDateComponents = [calendar components:flags fromDate:[NSDate date]];
    
    NSDate * lastDate = [calendar dateFromComponents:lastFeaturedEventGetDateComponents];
    NSDate * nowDate = [calendar dateFromComponents:nowDateComponents];
    
    return [lastDate isEqualToDate:nowDate];
}

- (WebConnector *) webConnector {
    if (webConnector == nil) {
        webConnector = [[WebConnector alloc] init];
        webConnector.delegate = self;
    }
    return webConnector;
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator == nil) {
        webDataTranslator = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator;
}

// Ignore the suggestion if...
// - We have already been suggested less than 1 second previously // This is kind of a hack, but I'm OK with it for now. Basically, we were getting suggested twice almost simultaneously by viewDidLoad and viewWillAppear. Maybe I'm just having an off-day, but the issue was harder to deal with logically than I would have thought, since I did want to suggest we get a new featured event in both of those cases usually. (Just not on first app launch, which is when the double-up was happening.)
// - The last time we got a new featured event was the same day as the day on which we are currently being suggested to get a new featured event
- (void)suggestToGetNewFeaturedEvent {
    if (!self.mostRecentGetNewFeaturedEventSuggestionDate || 
        ([[NSDate date] timeIntervalSinceDate:self.mostRecentGetNewFeaturedEventSuggestionDate] > 1.0)) {
        self.mostRecentGetNewFeaturedEventSuggestionDate = [NSDate date];
        if (![self isLastFeaturedEventGetDateToday]) {
            [self.webConnector getFeaturedEvent];
//            [self showWebActivityView];
        } else {
            [self updateInterfaceFromFeaturedEvent:[self.coreDataModel getFeaturedEvent]];
        }        
    }
}

- (void) showWebActivityView {
    [self.webActivityView showAnimated:NO];
    self.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) hideWebActivityView {
    [self.webActivityView hideAnimated:NO];
    self.view.userInteractionEnabled = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) webConnector:(WebConnector *)webConnector getFeaturedEventSuccess:(ASIHTTPRequest *)request {
    
    [self disableRefreshHeaderView];
    NSString * responseString = [request responseString];
	NSError * error = nil;
    NSDictionary * featuredEventJSONDictionary = [[[NSDictionary dictionaryWithDictionary:[responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error]] valueForKey:@"objects"] objectAtIndex:0];
    
    // Add to/update core data
    Event * featured = [self.coreDataModel getOrCreateFeaturedEvent];
    [self.coreDataModel updateEvent:featured usingEventDictionary:featuredEventJSONDictionary featuredOverride:[NSNumber numberWithBool:YES] fromSearchOverride:[NSNumber numberWithBool:NO]];
    
    [DefaultsModel saveLastFeaturedEventGetDate:[NSDate date]];
    [self updateInterfaceFromFeaturedEvent:[self.coreDataModel getFeaturedEvent]];
//    [self hideWebActivityView];
    
}

- (void)webConnector:(WebConnector *)webConnector getFeaturedEventFailure:(ASIHTTPRequest *)request {
	NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
	//[self serverError];
    [self updateInterfaceFromFeaturedEvent:[self.coreDataModel getFeaturedEvent]]; // This could be an old featured event, or it could be nothing.
//    [self hideWebActivityView];
}

- (void) enableRefreshHeaderView {
    self.refreshHeaderView.alpha = 0.0;
}

- (void) disableRefreshHeaderView {
    self.refreshHeaderView.alpha = 0.0;
}

- (void) updateInterfaceFromFeaturedEvent:(Event *)featuredEvent {
    
    if (featuredEvent) {
        self.noFeaturedEventView.alpha = 0.0;
        self.noFeaturedEventView.userInteractionEnabled = NO;
        self.letsGoButton.alpha = 1.0;
        self.shareButton.alpha = 1.0;
        self.phoneNumberButton.alpha = 1.0;
        self.scrollView.userInteractionEnabled = YES;
        if ([self isLastFeaturedEventGetDateToday]) {
            [self disableRefreshHeaderView];
        } else {
            [self enableRefreshHeaderView];
        }
    } else {
        self.noFeaturedEventView.alpha = 1.0;
        self.noFeaturedEventView.userInteractionEnabled = YES;
        self.letsGoButton.alpha = 0.5;
        self.shareButton.alpha = 0.5;
        self.phoneNumberButton.alpha = 0.5;
        self.scrollView.userInteractionEnabled = NO;
        [self.scrollView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:NO];
        [self enableRefreshHeaderView];
    }
    
    if (featuredEvent) {

        // Title
        NSString * title = featuredEvent.title;
        if (!title) { title = FEATURED_EVENT_TITLE_NOT_AVAILABLE; }

        // Date & Time
        NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:featuredEvent.startTimeDatetime endDatetime:featuredEvent.endTimeDatetime dataUnavailableString:FEATURED_EVENT_TIME_NOT_AVAILABLE];
        NSString * date = [self.webDataTranslator dateSpanStringFromStartDatetime:featuredEvent.startDateDatetime endDatetime:featuredEvent.endDateDatetime relativeDates:YES dataUnavailableString:FEATURED_EVENT_DATE_NOT_AVAILABLE];
                
        // Price
        NSString * price = [self.webDataTranslator priceRangeStringFromMinPrice:featuredEvent.priceMinimum maxPrice:featuredEvent.priceMaximum dataUnavailableString:FEATURED_EVENT_COST_NOT_AVAILABLE];
        price = [NSString stringWithFormat:@"Price: %@", price];
        
        // Location & Address
        NSString * addressFirstLine = featuredEvent.address;
        NSString * addressSecondLine = [self.webDataTranslator addressSecondLineStringFromCity:featuredEvent.city state:featuredEvent.state zip:featuredEvent.zip];
        BOOL someLocationInfo = addressFirstLine || addressSecondLine;
        if (!addressFirstLine) { addressFirstLine = FEATURED_EVENT_ADDRESS_NOT_AVAILABLE; }
        BOOL mapButtonActive = featuredEvent.latitude && featuredEvent.longitude;
        
        // Venue
        NSString * theVenue = featuredEvent.venue;
        if (!theVenue) { 
            if (someLocationInfo) {
                theVenue = @"Location:";
            } else {
                theVenue = @"Location not available";
            }
        }
        
        // Phone number
        NSString * phoneNumber = featuredEvent.phone;
        if (!phoneNumber) { phoneNumber = FEATURED_EVENT_PHONE_NUMBER_NOT_AVAILABLE; }
        
        // Description
        NSString * theDescription = featuredEvent.details;
        if (!theDescription) { theDescription = FEATURED_EVENT_DESCRIPTION_NOT_AVAILABLE; }
        
        // "Category" display color
        UIColor * categoryColor = [UIColor colorWithWhite:25.0/255.0 alpha:1.0];
        
        // Update UI
        // Background
        self.view.backgroundColor = [categoryColor colorWithAlphaComponent:FEATURED_EVENT_BACKGROUND_COLOR_ALPHA];
        // Title bar
        self.titleBarView.backgroundColor = categoryColor;
        // Title text
        self.titleLabel.text = title;
        // Date & Time
        self.timeLabel.text = time;
        self.timeLabel.textColor = categoryColor;
        self.dateLabel.text = date;
        self.dateLabel.textColor = categoryColor;
        // Venue
        self.venueNameLabel.text = theVenue;
        self.venueNameLabel.textColor = categoryColor;    
        // Address
        self.addressFirstLineLabel.text = addressFirstLine;
        self.addressFirstLineLabel.textColor = categoryColor;        
        self.addressSecondLineLabel.text = addressSecondLine;
        self.addressSecondLineLabel.textColor = categoryColor;
        // Map Button
        self.mapButton.alpha = mapButtonActive ? 1.0 : FEATURED_EVENT_MAP_BUTTON_INACTIVE_ALPHA;
        self.mapButton.userInteractionEnabled = mapButtonActive;
        // Price
        self.priceLabel.text = price;
        // Phone number
        self.phoneNumberButton.userInteractionEnabled = (featuredEvent.phone != nil);
        [self.phoneNumberButton setTitle:phoneNumber forState:UIControlStateNormal];
        [self.phoneNumberButton sizeToFit];
        CGRect phoneNumberButtonFrame = self.phoneNumberButton.frame;
        phoneNumberButtonFrame.origin.x = self.detailsView.frame.size.width - FEV_PHONE_BUTTON_PADDING_RIGHT - phoneNumberButtonFrame.size.width;
        self.phoneNumberButton.frame = phoneNumberButtonFrame;
//        if (!(featuredEvent.phone)) {
//            self.phoneNumberButton.frame = CGRectMake(170,138,150,20);
//            self.phoneNumberButton.userInteractionEnabled = NO;
//        } else  {
//            self.phoneNumberButton.frame = CGRectMake(223,138,100,20);
//            self.phoneNumberButton.userInteractionEnabled = YES;
//        }
//        [self.phoneNumberButton setTitle:phoneNumber forState:UIControlStateNormal];
//        [self.phoneNumberButton setTitle:self.eventPhoneString forState:UIControlStateNormal];
        // Description
        self.eventDetailsLabel.text = theDescription;
        CGSize eventDetailsLabelSize = [self.eventDetailsLabel.text sizeWithFont:self.eventDetailsLabel.font constrainedToSize:CGSizeMake(self.eventDetailsLabel.bounds.size.width, 4600.0)];
        CGRect eventDetailsLabelFrame = self.eventDetailsLabel.frame;
        eventDetailsLabelFrame.size.height = eventDetailsLabelSize.height;
        self.eventDetailsLabel.frame = eventDetailsLabelFrame;
        CGRect eventDetailsContainerFrame = self.eventDetailsContainer.frame;
        eventDetailsContainerFrame.size.height = CGRectGetMaxY(self.eventDetailsLabel.frame) + FEV_DESCRIPTION_LABEL_PADDING_VERTICAL;
        self.eventDetailsContainer.frame = eventDetailsContainerFrame;
        NSLog(@"%@ %@", NSStringFromCGRect(self.eventDetailsLabel.frame), NSStringFromCGRect(self.eventDetailsContainer.frame));
        
        // Set contentSize for scroll view
        CGFloat endOfInfoY = CGRectGetMaxY(self.eventDetailsContainer.frame);
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, endOfInfoY)];
        
        // Invoke the NSOperation
        NSOperationQueue * queue = [[NSOperationQueue alloc] init];
        NSInvocationOperation * operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImageWithLocation:) object:featuredEvent.imageLocation];
        [queue addOperation:operation];
        [operation release];
        [queue release];
        
    }
}

- (void)loadImageWithLocation:(NSString *)imageLocation {
    NSLog(@"FeaturedEventViewController loadImageWithLocation:%@", imageLocation);
    
    UIImage * image = nil;
    
    NSString * imageLocationLocalWithoutSlashes = [imageLocation stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    // First, check to see if we already have the image cached locally.
    BOOL imageExistsLocally = [LocalImagesManager featuredEventImageExistsWithName:imageLocationLocalWithoutSlashes];

    if (imageExistsLocally) {
        NSLog(@"Image exists locally");
        // If we do have the image cached locally, then just load it up!
        image = [LocalImagesManager loadFeaturedEventImage:imageLocationLocalWithoutSlashes];
    } else {
        NSLog(@"Image does not exist locally");
        // If we do not already have the image cached locally, then try to pull it from the web.
        
        // Build URL
        NSString * urlplist = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
        NSDictionary * urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
        NSString * url = [urlDictionary valueForKey:@"base_url"];
        NSString * final_url_string = [[NSString alloc]initWithString:[url stringByAppendingString:imageLocation]];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:final_url_string]];
        image = [[[UIImage alloc] initWithData:imageData] autorelease];
        //NSLog(@"image is loaded, and it is %fx%f pixels", image.size.width, image.size.height);
        
        [imageData release];
        [final_url_string release];
        [urlDictionary release];

        if (image) {
            NSLog(@"image retrieved successfully, and now it will be saved");
            // If the image was retrieved successfully from the internet, then we should cache it locally.
            // Save new image
            [LocalImagesManager saveFeaturedEventImageData:imageData imageName:imageLocationLocalWithoutSlashes];
        } else {
            // If the image was NOT successfully retrieved online (after also not being available in our local cache), then we should probably fall back onto some sort of default featured event image.
            // ...
            // ... TO BE IMPLEMENTED LATER
            // ... TO BE IMPLEMENTED LATER
            // ... TO BE IMPLEMENTED LATER
            // ...
        }
    }
    
    self.imageFull = image;
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
    
}

- (void)displayImage:(UIImage *)image {
    self.imageView.image = image;
}

-(IBAction)phoneCall:(id)sender  {
	NSLog(@"phone call");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [self.coreDataModel getFeaturedEvent].phone]]];
}

- (void) shareButtonTouched {
    
    MFMailComposeViewController * emailViewController = [ActionsManagement makeEmailViewControllerForEvent:[self.coreDataModel getFeaturedEvent] withMailComposeDelegate:self usingWebDataTranslator:self.webDataTranslator];
    [self presentModalViewController:emailViewController animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void) letsGoButtonTouched {
    
    // Grab our event
    Event * featuredEvent = [self.coreDataModel getFeaturedEvent];
    
    // Send learned data to the web
    [self.webConnector sendLearnedDataAboutEvent:featuredEvent.uri withUserAction:@"G"];
        
    if ([self.facebookManager.fb isSessionValid]) {
        // Give choice of Facebook event or adding to calendar
        self.letsGoChoiceActionSheet = [[[UIActionSheet alloc] initWithTitle:@"What would you like to do with this event?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Create Facebook event", @"Add to Calendar", nil] autorelease];
        [self.letsGoChoiceActionSheet showFromRect:self.letsGoButton.frame inView:self.letsGoButton animated:YES];
    } else {
        // Add to calendar
        [ActionsManagement addEventToCalendar:featuredEvent usingWebDataTranslator:self.webDataTranslator];
        // Show confirmation alert
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", featuredEvent.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
//    // Can't really do this simple/horrible of a solution for the featured event page... BAD BAD BAD BAD. COME BACK TO THIS.
//    [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_going.png"] forState: UIControlStateNormal];
//    self.letsGoButton.enabled = NO;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.letsGoChoiceActionSheet) {
        
        Event * featuredEvent = [self.coreDataModel getFeaturedEvent];
        
        if (buttonIndex == 0) {
            
            ContactsSelectViewController * contactsSelectViewController = [[ContactsSelectViewController alloc] initWithNibName:@"ContactsSelectViewController" bundle:[NSBundle mainBundle]];
            contactsSelectViewController.contactsAll = [self.coreDataModel getAllFacebookContacts];
            contactsSelectViewController.delegate = self;
            [self presentModalViewController:contactsSelectViewController animated:YES];
            [contactsSelectViewController release];
            
        } else if (buttonIndex == 1) {
            
            // Add to calendar
            [ActionsManagement addEventToCalendar:featuredEvent usingWebDataTranslator:self.webDataTranslator];
            // Show confirmation alert
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", featuredEvent.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }
        
    }
    
}

- (void)contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts {
    if (!didCancel) {
        
        NSMutableDictionary * parameters = [ActionsManagement makeFacebookEventParametersFromEvent:[self.coreDataModel getFeaturedEvent] eventImage:self.imageFull];
        [self.facebookManager createFacebookEventWithParameters:parameters inviteContacts:selectedContacts];
        [self showWebActivityView];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void) facebookEventCreateSuccess:(NSNotification *)notification {
    if (self.view.window) {
        // Wait until after facebook invites...
    }
}
- (void) facebookEventCreateFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"Something went wrong while trying to create an event on Facebook. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebActivityView];
    }
}
- (void) facebookEventInviteSuccess:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Event Created" message:@"We successfully created your Facebook event, and invited your selected friends. Have fun at the event!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebActivityView];
    }
}
- (void) facebookEventInviteFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"We created your Facebook event no problem, but an error occurred while inviting your friends. You should probably check things over on Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
        [self hideWebActivityView];
    }
}


- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
}

///////////////
// MAP STUFF //
///////////////

- (void) mapButtonTouched {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    Event * featuredEvent = [self.coreDataModel getFeaturedEvent];
    self.mapViewController.locationLatitude = featuredEvent.latitude;
    self.mapViewController.locationLongitude = featuredEvent.longitude;
    self.mapViewController.locationName = featuredEvent.venue;
    self.mapViewController.locationAddress = featuredEvent.address;
    [self presentModalViewController:self.mapViewController animated:YES];
}

- (void)mapViewControllerDidPushBackButton:(MapViewController *)mapViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.mapViewController = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end
