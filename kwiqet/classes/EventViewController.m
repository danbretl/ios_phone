//
//  CardPageViewController.m
//  Abextra
//
//  Created by John Nichols on 2/2/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "EventViewController.h"
#import <EventKit/EventKit.h>
#import "EventLocationAnnotation.h"
#import <EventKit/EventKit.h>
#import "URLBuilder.h"
#import "WebUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionsManagement.h"

#define CGFLOAT_MAX_TEXT_SIZE 10000

@interface EventViewController()
@property (retain) UIView * backgroundColorView;
@property (retain) UIView * navigationBar;
@property (retain) UIButton * backButton;
@property (retain) UIButton * logoButton;
@property (retain) UIView * actionBar;
@property (retain) UIButton * letsGoButton;
@property (retain) UIButton * shareButton;
@property (retain) UIButton * deleteButton;
@property (retain) ElasticUILabel * titleBar;
@property (retain) UIView * titleBarBorderCheatView;
@property (retain) UIScrollView * scrollView;
@property (retain) UIImageView * imageView;
@property (retain) UIView * breadcrumbsBar;
@property (retain) UILabel * breadcrumbsLabel;
@property (retain) UIView * eventInfoDividerView;
@property (retain) UILabel * monthLabel;
@property (retain) UILabel * dayNumberLabel;
@property (retain) UILabel * dayNameLabel;
@property (retain) UILabel * priceLabel;
@property (retain) UILabel * timeLabel;
@property (retain) UILabel * venueLabel;
@property (retain) UILabel * addressLabel;
@property (retain) UILabel * cityStateZipLabel;
@property (retain) UIButton * phoneNumberButton;
@property (retain) UIButton * mapButton;
@property (retain) UIView * detailsContainer;
@property (retain) UIView * detailsContainerShadowCheat;
@property (retain) UIView * detailsBackgroundColorView;
@property (retain) UILabel * detailsLabel;
@property (nonatomic, retain) WebActivityView * webActivityView;
@property (retain) UIActionSheet * letsGoChoiceActionSheet;

@property (retain) MapViewController * mapViewController;
@property (nonatomic, readonly) WebConnector * webConnector;
@property (nonatomic, readonly) WebDataTranslator * webDataTranslator;
@property (nonatomic, readonly) UIAlertView * connectionErrorOnUserActionRequestAlertView;
- (void)displayImage:(UIImage *)image;

- (void) backButtonTouched;
- (void) logoButtonTouched;
- (void) letsGoButtonTouched;
- (void) shareButtonTouched;
- (void) deleteButtonTouched;
- (void) phoneButtonTouched;
- (void) mapButtonTouched;

@end

@implementation EventViewController
@synthesize event;
@synthesize backgroundColorView;
@synthesize navigationBar, backButton, logoButton;
@synthesize actionBar, letsGoButton, shareButton, deleteButton;
@synthesize titleBar, titleBarBorderCheatView;
@synthesize scrollView;
@synthesize imageView, breadcrumbsBar, breadcrumbsLabel;
@synthesize eventInfoDividerView;
@synthesize monthLabel, dayNumberLabel, dayNameLabel;
@synthesize priceLabel, timeLabel;
@synthesize venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton;
@synthesize detailsContainer, detailsContainerShadowCheat, detailsBackgroundColorView, detailsLabel;
@synthesize webActivityView;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;
@synthesize letsGoChoiceActionSheet;
@synthesize facebookManager;

- (void)dealloc {
    [event release];
    [backgroundColorView release];
    [navigationBar release];
    [backButton release];
    [logoButton release];
    [actionBar release];
    [letsGoButton release];
    [shareButton release];
    [deleteButton release];
    [titleBar release];
    [titleBarBorderCheatView release];
    [scrollView release];
    [imageView release];
    [breadcrumbsBar release];
    [breadcrumbsLabel release];
    [eventInfoDividerView release];
    [monthLabel release];
    [dayNumberLabel release];
    [dayNameLabel release];
    [priceLabel release];
    [timeLabel release];
    [venueLabel release];
    [addressLabel release];
    [cityStateZipLabel release];
    [phoneNumberButton release];
    [mapButton release];
    [detailsContainer release];
    [detailsContainerShadowCheat release];
    [detailsBackgroundColorView release];
    [detailsLabel release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release]; // ---?
    [webDataTranslator release];
    [letsGoChoiceActionSheet release];
    [facebookManager release];
    [super dealloc];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cardbg.png"]];
    backgroundColorView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColorView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backgroundColorView];
    [self.view sendSubviewToBack:self.backgroundColorView];
    
    // Navigation bar
    navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    [self.view addSubview:self.navigationBar];
    {
        // Back button
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(10, 6, 74, 32);
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState: UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:self.backButton];
        
        // Logo button
        self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.logoButton.frame = CGRectMake(135, 3, 53, 38);
        [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo.png"] forState: UIControlStateNormal];
        [self.logoButton addTarget:self action:@selector(logoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:self.logoButton];
    }
    
    // Action bar
    actionBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.bounds.size.width, 36)];
    self.actionBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"actbar.png"]];
    [self.view addSubview:self.actionBar];
    {
        // Action buttons
        CGRect (^actionButtonFrameBlock) (CGFloat) = ^(CGFloat originX){
            return CGRectMake(originX, 5, 100, 25);
        };
        
        // Let's Go button
        self.letsGoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.letsGoButton.frame = actionButtonFrameBlock(5);
        [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_letsgo.png"] forState: UIControlStateNormal];
        [self.letsGoButton addTarget:self action:@selector(letsGoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.letsGoButton];
        
        // Share button
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareButton.frame = actionButtonFrameBlock(110);
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"btn_share.png"] forState: UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.shareButton];
        
        // Delete button
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.frame = actionButtonFrameBlock(215);
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState: UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.deleteButton];
    }
    UIView * shadowCheatViewTwo = [[UIView alloc] initWithFrame:self.actionBar.frame];
    CGRect fooFrame = shadowCheatViewTwo.frame;
    fooFrame.size.height -= 1;
    shadowCheatViewTwo.frame = fooFrame;
    shadowCheatViewTwo.layer.shadowColor = [[UIColor blackColor] CGColor];
    shadowCheatViewTwo.layer.shadowOffset = CGSizeMake(0, 0);
    shadowCheatViewTwo.layer.shadowOpacity = .55;
    shadowCheatViewTwo.layer.shouldRasterize = YES;
    shadowCheatViewTwo.backgroundColor = [UIColor blackColor];
    [self.view addSubview:shadowCheatViewTwo];
    [self.view sendSubviewToBack:shadowCheatViewTwo];
    [shadowCheatViewTwo release];
    
    // Scroll view
    CGFloat scrollViewOriginY = CGRectGetMaxY(self.actionBar.frame);
	scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, scrollViewOriginY, self.view.bounds.size.width, self.view.bounds.size.height - scrollViewOriginY)];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    {
        // Title bar
        titleBar = [[ElasticUILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 32)];
        [self.scrollView addSubview:self.titleBar];
        [self.scrollView bringSubviewToFront:self.titleBar];
        // Title bar shadow
        UIView * shadowCheatViewOne = [[UIView alloc] initWithFrame:self.titleBar.frame];
        CGRect fooFrame = shadowCheatViewOne.frame;
        fooFrame.origin.y += 1;
        shadowCheatViewOne.frame = fooFrame;
        shadowCheatViewOne.layer.shadowColor = [[UIColor blackColor] CGColor];
        shadowCheatViewOne.layer.shadowOffset = CGSizeMake(0, 0);
        shadowCheatViewOne.layer.shadowOpacity = 0.55;
        shadowCheatViewOne.layer.shouldRasterize = YES;
        shadowCheatViewOne.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:shadowCheatViewOne];
        [self.scrollView sendSubviewToBack:shadowCheatViewOne];
        [shadowCheatViewOne release];
        // Title bar bottom border
        titleBarBorderCheatView = [[UIView alloc] initWithFrame:self.titleBar.frame];
        self.titleBarBorderCheatView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleBarBorderCheatView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HR.png"]];
        self.titleBarBorderCheatView.opaque = NO;
        self.titleBarBorderCheatView.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.titleBarBorderCheatView];
        [self.scrollView bringSubviewToFront:self.titleBarBorderCheatView];
        
        // Image view
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleBar.frame), self.scrollView.bounds.size.width, 180)];
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.scrollView addSubview:self.imageView];
        // Image view gesture recognizer
        UISwipeGestureRecognizer * swipeToGoBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack:)];
        [self.imageView addGestureRecognizer:swipeToGoBack];
        self.imageView.userInteractionEnabled = YES;
        [swipeToGoBack release];
        
        // Breadcrumbs bar
        CGFloat breadcrumbsBarHeight = 32.0;
        float breadcrumbsBarBackgroundColorWhite = 53.0/255.0;
        float breadcrumbsBarBackgroundAlpha = 0.9;
        CGFloat breadcrumbsLabelHorizontalPadding = 8.0;
        breadcrumbsBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.imageView.bounds.size.height - breadcrumbsBarHeight, self.imageView.bounds.size.width, breadcrumbsBarHeight)];
        self.breadcrumbsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.breadcrumbsBar.backgroundColor = [UIColor colorWithWhite:breadcrumbsBarBackgroundColorWhite alpha:breadcrumbsBarBackgroundAlpha];
        [self.imageView addSubview:self.breadcrumbsBar];
        // Breadcrumbs label
        breadcrumbsLabel = [[UILabel alloc] initWithFrame:CGRectMake(breadcrumbsLabelHorizontalPadding, 0, self.breadcrumbsBar.bounds.size.width - 2 * breadcrumbsLabelHorizontalPadding, self.breadcrumbsBar.bounds.size.height)];
        self.breadcrumbsLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.breadcrumbsLabel.textColor = [UIColor whiteColor];
        self.breadcrumbsLabel.backgroundColor = [UIColor clearColor];
        [self.breadcrumbsBar addSubview:self.breadcrumbsLabel];
        
        // Event info divider view
        eventInfoDividerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.scrollView.bounds.size.width, 164)];
        self.eventInfoDividerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_card.png"]];
        [self.scrollView addSubview:self.eventInfoDividerView];
        [self.scrollView bringSubviewToFront:self.eventInfoDividerView];
        {
            // Date box
            CGSize dateBoxSize = CGSizeMake(69, 65);
            {
                // Month label
                monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, dateBoxSize.width, 18)];
                self.monthLabel.backgroundColor = [UIColor clearColor];
                self.monthLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:12];
                self.monthLabel.textAlignment = UITextAlignmentCenter;
                [self.eventInfoDividerView addSubview:self.monthLabel];
                
                // Day number label
                dayNumberLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.monthLabel.frame), dateBoxSize.width, 42)];
                self.dayNumberLabel.backgroundColor = [UIColor clearColor];
                self.dayNumberLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:33];
                self.dayNumberLabel.textAlignment = UITextAlignmentCenter;
                [self.eventInfoDividerView addSubview:self.dayNumberLabel];
                
                // Day name label
                dayNameLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 46, dateBoxSize.width, 20)];
                self.dayNameLabel.backgroundColor = [UIColor clearColor];
                self.dayNameLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:12];
                self.dayNameLabel.textAlignment = UITextAlignmentCenter;
                [self.eventInfoDividerView addSubview:self.dayNameLabel];
            }
            
            // Time label
            CGFloat timeLabelOriginX = 80;
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelOriginX, 9, self.eventInfoDividerView.bounds.size.width - timeLabelOriginX, 20)];
            self.timeLabel.backgroundColor = [UIColor clearColor];
            self.timeLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:16];
            [self.eventInfoDividerView addSubview:self.timeLabel];
            
            // Price label
            CGFloat priceLabelOriginX = timeLabelOriginX;
            priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelOriginX, 43, self.eventInfoDividerView.bounds.size.width - priceLabelOriginX, 15)];
            self.priceLabel.backgroundColor = [UIColor clearColor];
            self.priceLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
            [self.eventInfoDividerView addSubview:self.priceLabel];
                        
            // Location box
            //CGSize locationBoxSize = CGSizeMake(self.eventInfoDividerView.bounds.size.width, self.eventInfoDividerView.bounds.size.height - dateBoxSize.height);
            {
                                
                // Venue label
                venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,80,317,30)];
                self.venueLabel.backgroundColor = [UIColor clearColor];
                self.venueLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:22];
                [self.eventInfoDividerView addSubview:self.venueLabel];
                
                // Address label
                addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,96,200,25)];
                self.addressLabel.backgroundColor = [UIColor clearColor];
                self.addressLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                [self.eventInfoDividerView addSubview:self.addressLabel];
                
                // City State Zip label
                cityStateZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,111,200,25)];
                self.cityStateZipLabel.backgroundColor = [UIColor clearColor];
                self.cityStateZipLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                [self.eventInfoDividerView addSubview:self.cityStateZipLabel];
                
                // Phone number button
                self.phoneNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.phoneNumberButton.frame = CGRectMake(10, 135, 150, 20);
                [self.phoneNumberButton setTitleColor:[UIColor colorWithRed:0.2549 green:0.41568 blue:0.70196 alpha:1.0] forState:UIControlStateNormal];
                [self.phoneNumberButton addTarget:self action:@selector(phoneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                self.phoneNumberButton.backgroundColor = [UIColor clearColor];
                self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:12];
                self.phoneNumberButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [self.eventInfoDividerView addSubview:self.phoneNumberButton];
                
                // Map button
                self.mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.mapButton.frame = CGRectMake(240,110,64,20);
                [self.mapButton setBackgroundImage:[UIImage imageNamed:@"btn_map.png"] forState: UIControlStateNormal];
                [self.mapButton addTarget:self action:@selector(mapButtonTouched) forControlEvents:UIControlEventTouchUpInside];
                [self.eventInfoDividerView addSubview:self.mapButton];
                self.mapButton.enabled = NO;
            }
            
            // Details container
            detailsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.eventInfoDividerView.frame), self.scrollView.bounds.size.width, 0.0)];
            self.detailsContainer.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:self.detailsContainer];
            [self.scrollView sendSubviewToBack:self.detailsContainer];
            // Details shadow
            detailsContainerShadowCheat = [[UIView alloc] initWithFrame:self.detailsContainer.frame];
            self.detailsContainerShadowCheat.layer.shadowColor = [[UIColor blackColor] CGColor];
            self.detailsContainerShadowCheat.layer.shadowOffset = CGSizeMake(0, 0);
            self.detailsContainerShadowCheat.layer.shadowOpacity = .55;
            self.detailsContainerShadowCheat.layer.shouldRasterize = YES;
            self.detailsContainerShadowCheat.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:self.detailsContainerShadowCheat];
            [self.scrollView sendSubviewToBack:self.detailsContainerShadowCheat];
            // Details background color view
            detailsBackgroundColorView = [[UIView alloc] initWithFrame:self.detailsContainer.bounds];
            self.detailsBackgroundColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.detailsBackgroundColorView.backgroundColor = [UIColor whiteColor];
            self.detailsBackgroundColorView.opaque = YES;
            [self.detailsContainer addSubview:self.detailsBackgroundColorView];
            // Details text view
            CGFloat detailsLabelHorizontalPadding = 10;
            CGFloat detailsLabelVerticalPadding = 10;
            detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailsLabelHorizontalPadding, detailsLabelVerticalPadding, self.detailsContainer.bounds.size.width - 2 * detailsLabelHorizontalPadding, 0)];
            //self.detailsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
            self.detailsLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:18];
            self.detailsLabel.backgroundColor = [UIColor clearColor];
            self.detailsLabel.numberOfLines = 0;
            [self.detailsContainer addSubview:self.detailsLabel];
            [self.detailsContainer bringSubviewToFront:self.detailsLabel];
        }
        
    }
    
    CGFloat webActivityViewSize = 60.0;
    webActivityView = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.frame];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    if (self.event) {
        [self updateViewsFromData];
    }
}

-(void) showWebLoadingViews  {
    if (self.view.window) {
        // ACTIVITY VIEWS
        [self.view bringSubviewToFront:self.webActivityView];
        [self.webActivityView showAnimated:YES];
        // USER INTERACTION
        self.view.userInteractionEnabled = NO;
    }
}

-(void)hideWebLoadingViews  {
    
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    // USER INTERACTION
    self.view.userInteractionEnabled = YES;
    
}

- (void)setEvent:(Event *)theEvent {
    if (event != theEvent) {
        [event release];
        event = [theEvent retain];
        [self.webConnector getEventWithURI:self.event.uri];
        [self showWebLoadingViews];
    }
}

- (void)webConnector:(WebConnector *)webConnector getEventSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * eventDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    [self.coreDataModel updateEvent:self.event usingEventDictionary:eventDictionary featuredOverride:nil fromSearchOverride:nil];
    [self updateViewsFromData];
    [self hideWebLoadingViews];
}

- (void)webConnector:(WebConnector *)webConnector getEventFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
	NSString * statusMessage = [request responseStatusMessage];
	NSLog(@"%@", statusMessage);
	NSError *error = [request error];
	NSLog(@"%@", error);
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self viewControllerIsFinished];
    [self hideWebLoadingViews];
}

-(void) updateViewsFromData {
    
    NSString * EVENT_TIME_NOT_AVAILABLE = @"Time not available";
    NSString * EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
    NSString * EVENT_ADDRESS_NOT_AVAILABLE = @"Address not available";
    NSString * EVENT_PHONE_NOT_AVAILABLE = @"Phone number not available";
    
    // Concrete parent category color
    UIColor * concreteParentCategoryColor = self.event.concreteParentCategory.colorHex ? [WebUtil colorFromHexString:self.event.concreteParentCategory.colorHex] : [UIColor blackColor];
    
    // Background
//    self.view.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
    self.backgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.05];
//    self.detailsBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.10];
    self.detailsBackgroundColorView.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
//    self.detailsLabel.backgroundColor = concreteParentCategoryColor;
//    self.detailsLabel.textColor = [UIColor whiteColor];
    
    // Title
    self.titleBar.text = self.event.title;
    self.titleBar.color = concreteParentCategoryColor;
    
    // Date & Time
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    // Month
    [dateFormatter setDateFormat:@"MMM"];
    NSString * month = [dateFormatter stringFromDate:self.event.startDateDatetime];
    self.monthLabel.text = [month uppercaseString];
    // Day number
    [dateFormatter setDateFormat:@"d"];
    NSString * dayNumber = [dateFormatter stringFromDate:self.event.startDateDatetime];
    self.dayNumberLabel.text = dayNumber;
    self.dayNumberLabel.textColor = concreteParentCategoryColor;
    // Day name
    [dateFormatter setDateFormat:@"EEE"];
    NSString * dayName = [dateFormatter stringFromDate:self.event.startDateDatetime];
    self.dayNameLabel.text = [dayName uppercaseString];
    // Time
    NSString * time = [self.webDataTranslator timeSpanStringFromStartDatetime:self.event.startTimeDatetime endDatetime:self.event.endTimeDatetime dataUnavailableString:EVENT_TIME_NOT_AVAILABLE];
    self.timeLabel.text = time;
    
    NSString * price = [self.webDataTranslator priceRangeStringFromMinPrice:self.event.priceMinimum maxPrice:self.event.priceMaximum dataUnavailableString:nil];
    self.priceLabel.text = [NSString stringWithFormat:@"Price: %@", price];
    
    // Location & Address
    NSString * addressFirstLine = self.event.address;
    NSString * addressSecondLine = [self.webDataTranslator addressSecondLineStringFromCity:self.event.city state:self.event.state zip:self.event.zip];
    BOOL someLocationInfo = addressFirstLine || addressSecondLine;
    if (!addressFirstLine) { addressFirstLine = EVENT_ADDRESS_NOT_AVAILABLE; }
    self.addressLabel.text = addressFirstLine;
    self.cityStateZipLabel.text = addressSecondLine;
    
    // Venue
    NSString * venue = self.event.venue;
    if (!venue) { 
        if (someLocationInfo) {
            venue = @"Location:";
        } else {
            venue = @"Location not available";
        }
    }
    self.venueLabel.text = venue;
    
    // Map button
    self.mapButton.enabled = self.event.latitude && self.event.longitude;
    
    // Phone
    NSString * phone = self.event.phone ? self.event.phone : EVENT_PHONE_NOT_AVAILABLE;
    [self.phoneNumberButton setTitle:phone forState:UIControlStateNormal];
    
    // Description
    NSString * descriptionString = self.event.details ? self.event.details : EVENT_DESCRIPTION_NOT_AVAILABLE;
    self.detailsLabel.text = descriptionString;
    //set contentSize for scroll view
    CGSize detailsLabelSize = [self.detailsLabel.text sizeWithFont:self.detailsLabel.font constrainedToSize:CGSizeMake(self.detailsLabel.bounds.size.width, 10000)];
    CGRect detailsLabelFrame = self.detailsLabel.frame;
    detailsLabelFrame.size.height = detailsLabelSize.height;
    self.detailsLabel.frame = detailsLabelFrame;
    NSLog(@"%@", NSStringFromCGRect(self.detailsLabel.frame));
    CGRect detailsContainerFrame = self.detailsContainer.frame;
    detailsContainerFrame.size.height = CGRectGetMaxY(self.detailsLabel.frame) + self.detailsLabel.frame.origin.y - 6; // TEMPORARY HACK, INFERRING THAT THE ORIGIN Y OF THE DETAILS LABEL IS EQUAL TO THE VERTICAL PADDING WE SHOULD GIVE UNDER THAT LABEL. // EVEN WORSE TEMPORARY HACK, HARDCODING AN OFFSET BECAUSE PUTTING EQUAL PADDING AFTER AS BEFORE DOES NOT LOOK EVEN.
    self.detailsContainer.frame = detailsContainerFrame;
    self.detailsContainerShadowCheat.frame = self.detailsContainer.frame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.detailsContainer.frame))];
    NSLog(@"%@", NSStringFromCGSize(self.scrollView.contentSize));
    
    // Breadcrumbs
    NSMutableString * breadcrumbsString = [self.event.concreteParentCategory.title mutableCopy];
    NSArray * orderedConcreteCategoryBreadcrumbs = [self.event.concreteCategoryBreadcrumbs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]]];
    for (CategoryBreadcrumb * breadcrumb in orderedConcreteCategoryBreadcrumbs) {
        [breadcrumbsString appendFormat:@", %@", breadcrumb.category.title];
    }
    self.breadcrumbsLabel.text = breadcrumbsString;
    
    
//    if (!self.imageView.image) {
//        [self displayImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
//    }
	// If an image has not already been successfully loaded and set, then attempt to load and set an image for this event.
//    if (!loadedImage) {
    if(!self.imageView.image) {
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
                                            initWithTarget:self
                                            selector:@selector(loadImage) 
                                            object:nil];
        
        [queue addOperation:operation];
        [operation release];
        [queue release];
    }
    
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

- (NSDictionary *) tempSolutionWellFormattedDataFromDictionary:(NSDictionary *)rawEventDictionary {
    
    NSDictionary * firstOccurrenceDictionary = [[rawEventDictionary valueForKey:@"occurrences"] objectAtIndex:0];
    
    NSString * uri = [WebUtil stringOrNil:[rawEventDictionary objectForKey:@"resource_uri"]];
    NSString * titleText = [WebUtil stringOrNil:[rawEventDictionary objectForKey:@"title"]];
    NSString * descriptionText = [WebUtil stringOrNil:[rawEventDictionary objectForKey:@"description"]];
    
    NSString * startDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_date"]];
    NSLog(@"startDate:%@", startDate);
    NSString * endDate = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_date"]];
    NSLog(@"endDate:%@", endDate);
    NSString * startTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"start_time"]];
    NSLog(@"startTime:%@", startTime);
    NSString * endTime = [WebUtil stringOrNil:[firstOccurrenceDictionary objectForKey:@"end_time"]];
    NSLog(@"endTime:%@", endTime);
    
    // Date and time
    NSDictionary * startAndEndDatetimesDictionary = [self.webDataTranslator datetimesSummaryFromStartTime:startTime endTime:endTime startDate:startDate endDate:endDate];
    NSDate * startDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_START_DATETIME_KEY];
    NSDate * endDatetime = (NSDate *)[startAndEndDatetimesDictionary objectForKey:WDT_END_DATETIME_KEY];
    NSNumber * startDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_DATE_VALID_KEY];
    NSNumber * startTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_START_TIME_VALID_KEY];
    NSNumber * endDateValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_DATE_VALID_KEY];
    NSNumber * endTimeValid = [startAndEndDatetimesDictionary valueForKey:WDT_END_TIME_VALID_KEY];
    NSLog(@"%@", startAndEndDatetimesDictionary);
    
    // Price
    NSArray * priceArray = [firstOccurrenceDictionary objectForKey:@"prices"];
    NSDictionary * pricesMinMaxDictionary = [self.webDataTranslator pricesSummaryFromPriceArray:priceArray];
    NSNumber * priceMinimum = [pricesMinMaxDictionary objectForKey:@"minimum"];
    NSNumber * priceMaximum = [pricesMinMaxDictionary objectForKey:@"maximum"];
    
    // Address first line
    NSString * addressLineFirst = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"address"]];
    
    // Address second line
    NSString * cityString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"city"]];
    NSString * stateString = [WebUtil stringOrNil:[[[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"point"] valueForKey:@"city"] valueForKey:@"state"]];
    NSString * zipCodeString = [WebUtil stringOrNil:[[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"zip"]];
    
    // Latitude & Longitude
    NSNumber * latitudeValue  = [WebUtil numberOrNil:[[[[[rawEventDictionary valueForKey:@"occurrences"] objectAtIndex:0]valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"latitude"]];
    NSNumber * longitudeValue = [WebUtil numberOrNil:[[[[[rawEventDictionary valueForKey:@"occurrences"] objectAtIndex:0] valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"longitude"]];
    
    // Phone Number
    NSString * eventPhoneString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"] valueForKey:@"phone"]];
    
    // Venue
    NSString * venueString = [WebUtil stringOrNil:[[firstOccurrenceDictionary valueForKey:@"place"]valueForKey:@"title"]];
    
    // Image location
    NSString * imageLocation = [WebUtil stringOrNil:[rawEventDictionary valueForKey:@"image"]];
    if (!imageLocation) {
        imageLocation = [WebUtil stringOrNil:[rawEventDictionary valueForKey:@"thumbnail_detail"]];
    }
    
    // Concrete parent category
    NSString * concreteParentCategoryURI = [WebUtil stringOrNil:[rawEventDictionary objectForKey:@"resource_uri"]];
    
    NSMutableDictionary * wellFormattedDataDictionary = [NSMutableDictionary dictionary];
    if (uri) { [wellFormattedDataDictionary setValue:uri forKey:@"uri"]; }
    if (concreteParentCategoryURI) { [wellFormattedDataDictionary setValue:concreteParentCategoryURI forKey:@"concreteParentCategoryURI"]; }
    if (titleText) { [wellFormattedDataDictionary setValue:titleText forKey:@"title"]; }
    if (startDatetime) { [wellFormattedDataDictionary setValue:startDatetime forKey:@"startDatetime"]; }
    if (endDatetime) { [wellFormattedDataDictionary setValue:endDatetime forKey:@"endDatetime"]; }
    if (startDateValid) { [wellFormattedDataDictionary setValue:startDateValid forKey:@"startDateValid"]; }
    if (startTimeValid) { [wellFormattedDataDictionary setValue:startTimeValid forKey:@"startTimeValid"]; }
    if (endDateValid) { [wellFormattedDataDictionary setValue:endDateValid forKey:@"endDateValid"]; }
    if (endTimeValid) { [wellFormattedDataDictionary setValue:endTimeValid forKey:@"endTimeValid"]; }
    if (venueString) { [wellFormattedDataDictionary setValue:venueString forKey:@"venue"]; }
    if (addressLineFirst) { [wellFormattedDataDictionary setValue:addressLineFirst forKey:@"address"]; }
    if (cityString) { [wellFormattedDataDictionary setValue:cityString forKey:@"city"]; }
    if (stateString) { [wellFormattedDataDictionary setValue:stateString forKey:@"state"]; }
    if (zipCodeString) { [wellFormattedDataDictionary setValue:zipCodeString forKey:@"zip"]; }
    if (latitudeValue) { [wellFormattedDataDictionary setValue:latitudeValue forKey:@"latitude"]; }
    if (longitudeValue) { [wellFormattedDataDictionary setValue:longitudeValue forKey:@"longitude"]; }
    if (priceMinimum) { [wellFormattedDataDictionary setValue:priceMinimum forKey:@"priceMinimum"]; }
    if (priceMaximum) { [wellFormattedDataDictionary setValue:priceMaximum forKey:@"priceMaximum"]; }
    if (eventPhoneString) { [wellFormattedDataDictionary setValue:eventPhoneString forKey:@"phone"]; }
    if (descriptionText) { [wellFormattedDataDictionary setValue:descriptionText forKey:@"details"]; }
    if (imageLocation) { [wellFormattedDataDictionary setValue:imageLocation forKey:@"imageLocation"]; }
    
    NSLog(@"%@", wellFormattedDataDictionary);
    
    return wellFormattedDataDictionary;
}

- (void) swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"foo");
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self viewControllerIsFinished];
    }
}

//methods for asychronous loading of imageView.  takes url from dictionary
- (void)loadImage {
    //build url
    NSString *urlplist = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    NSDictionary * urlDictionary = [NSDictionary dictionaryWithContentsOfFile:urlplist];
    NSString * url = [urlDictionary valueForKey:@"base_url"];
    NSString * imageLocation = self.event.imageLocation;
    UIImage * image = nil;
    // Check if image location is nil - if it is, default to the concrete parent category image
    NSLog(@"%@", self.event.concreteParentCategory);
    if (imageLocation == nil) {
        NSLog(@"Using concrete parent category thumbnail");
        imageLocation = self.event.concreteParentCategory.thumbnail;
    }
    // If there is no image, then use a placeholder image.
    if (imageLocation == nil) {
        NSLog(@"ERROR in EventViewController loadImage - can't find image location. Event is %@ (imageLoc = %@), Category is %@ (imageLoc = %@)", self.event.title, self.event.imageLocation, self.event.concreteParentCategory.title, self.event.concreteParentCategory.thumbnail);
        image = [UIImage imageNamed:@"event_img_placeholder.png"];
    } else {
        NSString * imageURL = [url stringByAppendingString:imageLocation];
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        image = [UIImage imageWithData:imageData];
        //    loadedImage = YES;
    }
    NSLog(@"EventViewController loadImage with imageLocation=%@", imageLocation); // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	[self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
}

- (void)displayImage:(UIImage *)image {
    //NSLog(@"image is %f by %f", image.size.width, image.size.height);
	[self.imageView setImage:image];
    [self.scrollView bringSubviewToFront:self.titleBar];
    [self.scrollView bringSubviewToFront:self.titleBarBorderCheatView];
}

-(void)shareButtonTouched {
    
    MFMailComposeViewController * emailViewController = [ActionsManagement makeEmailViewControllerForEvent:self.event withMailComposeDelegate:self usingWebDataTranslator:self.webDataTranslator];
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

//delete event from core data and revert back to table
-(void)deleteButtonTouched {
    
    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"X"];
    [self showWebLoadingViews];
    // Wait for response from server
    
}

///send learned data to ML with tag G
- (void)letsGoButtonTouched {
    
    // Send learned data to the web
    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"G"];
    
    if ([self.facebookManager.fb isSessionValid]) {
        // Give choice of Facebook event or adding to calendar
        self.letsGoChoiceActionSheet = [[[UIActionSheet alloc] initWithTitle:@"What would you like to do with this event?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Create Facebook event", @"Add to Calendar", nil] autorelease];
        [self.letsGoChoiceActionSheet showFromRect:self.letsGoButton.frame inView:self.letsGoButton animated:YES];
    } else {
        // Add to calendar
        [ActionsManagement addEventToCalendar:self.event usingWebDataTranslator:self.webDataTranslator];
        // Show confirmation alert
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
//    // Change appearance of "Let's Go" button
//    [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_going.png"] forState: UIControlStateNormal];
//    self.letsGoButton.enabled = NO;

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.letsGoChoiceActionSheet) {
                
        if (buttonIndex == 0) {
            
            ContactsSelectViewController * contactsSelectViewController = [[ContactsSelectViewController alloc] initWithNibName:@"ContactsSelectViewController" bundle:[NSBundle mainBundle]];
            contactsSelectViewController.contactsAll = [self.coreDataModel getAllFacebookContacts];
            contactsSelectViewController.delegate = self;
            [self presentModalViewController:contactsSelectViewController animated:YES];
            [contactsSelectViewController release];
            
        } else if (buttonIndex == 1) {
            
            // Add to calendar
            [ActionsManagement addEventToCalendar:self.event usingWebDataTranslator:self.webDataTranslator];
            // Show confirmation alert
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }
        
    }
    
}

- (void)contactsSelectViewController:(ContactsSelectViewController *)contactsSelectViewController didFinishWithCancel:(BOOL)didCancel selectedContacts:(NSArray *)selectedContacts {
    if (!didCancel) {
        NSMutableDictionary * parameters = [ActionsManagement makeFacebookEventParametersFromEvent:self.event eventImage:self.imageView.image];
        [self.facebookManager createFacebookEventWithParameters:parameters inviteContacts:selectedContacts];
        [self showWebLoadingViews];
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
        [self hideWebLoadingViews];
    }
}
- (void) facebookEventInviteSuccess:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Event Created" message:@"We successfully created your Facebook event, and invited your selected friends. Have fun at the event!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self hideWebLoadingViews];
    }
}
- (void) facebookEventInviteFailure:(NSNotification *)notification {
    if (self.view.window) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Error" message:@"We created your Facebook event no problem, but an error occurred while inviting your friends. You should probably check things over on Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];    
        [self hideWebLoadingViews];
    }
}




- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
            
    if ([userAction isEqualToString:@"G"]) {
        
        // Currently, we delete the event if the user "went". THIS IS CONFUSING. We are changing this functionality.
        //deletedEventDueToGoingToEvent = YES;
        //[self.coreDataModel deleteRegularEventForURI:[self.eventDictionary objectForKey:@"resource_uri"]]; // This makes me uneasy deleting it here... But, we're not dealing with this right now.
        
    } else if ([userAction isEqualToString:@"X"]) {
        
        // We're done here, let our delegate know that we are finished, and that we ended by requesting to delete the event. Leave the actual event object deletion up to the delegate though.
        [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:YES eventURI:self.event.uri];
        
    }
    
    [self hideWebLoadingViews];
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"G"]) {
        //[self.connectionErrorOnUserActionRequestAlertView show]; // I'm taking this alert view out for now. We should definitely be saving this lost learning in some sort of cache and sending it up to the server at another time, but even though we are not doing that yet, there is still no reason to display an annoying popup to the user.
    } else if ([userAction isEqualToString:@"X"]) {
        [self.connectionErrorOnUserActionRequestAlertView show];
    }
    
    [self hideWebLoadingViews];
    
}

// make Phone number clickable..
-(void)phoneButtonTouched {
	NSLog(@"phone call");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.event.phone]]];
}

-(void)mapButtonTouched {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    self.mapViewController.locationLatitude = self.event.latitude;
    self.mapViewController.locationLongitude = self.event.longitude;
    self.mapViewController.locationName = self.event.venue;
    self.mapViewController.locationAddress = self.event.address;
    [self presentModalViewController:self.mapViewController animated:YES];
}

- (void)mapViewControllerDidPushBackButton:(MapViewController *)mapViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.mapViewController = nil;
}

- (void) backButtonTouched  {
    [self viewControllerIsFinished];
}

- (void) logoButtonTouched {
    [self viewControllerIsFinished];
}

- (void) viewControllerIsFinished {
    [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:deletedEventDueToGoingToEvent eventURI:self.event.uri];
}

- (UIAlertView *)connectionErrorOnUserActionRequestAlertView {
    if (connectionErrorOnUserActionRequestAlertView == nil) {
        connectionErrorOnUserActionRequestAlertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Sorry, due to a connection error, we could not complete your request. Please check your settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorOnUserActionRequestAlertView;
}

//// Such a crazy heavyweight solution for just one pixel... Oh well!
//- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {
//    if (theScrollView == self.scrollView) {
//        self.titleBarBorderCheatView.hidden = !(self.scrollView.contentOffset.y >= 0);
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView {

    if (theScrollView == self.scrollView) {
        CGRect titleBarFrame = self.titleBar.frame;
        titleBarFrame.origin.y = MAX(0, self.scrollView.contentOffset.y);
        self.titleBar.frame = titleBarFrame;
        self.titleBarBorderCheatView.frame = self.titleBar.frame;
    }
    
}

#pragma mark memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end