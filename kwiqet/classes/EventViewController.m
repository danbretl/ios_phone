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

#define CGFLOAT_MAX_TEXT_SIZE 10000

@interface EventViewController()
@property (retain) UIView * navigationBar;
@property (retain) UIButton * backButton;
@property (retain) UIButton * logoButton;
@property (retain) UIView * actionBar;
@property (retain) UIButton * letsGoButton;
@property (retain) UIButton * shareButton;
@property (retain) UIButton * deleteButton;
@property (retain) ElasticUILabel * titleBar;
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
@property (retain) UILabel * detailsLabel;
@property (nonatomic, retain) WebActivityView * webActivityView;

- (void) backButtonPushed;
- (void) logoButtonPushed;

@end

@implementation EventViewController
@synthesize event;
@synthesize navigationBar, backButton, logoButton;
@synthesize actionBar, letsGoButton, shareButton, deleteButton;
@synthesize titleBar;
@synthesize scrollView;
@synthesize imageView, breadcrumbsBar, breadcrumbsLabel;
@synthesize eventInfoDividerView;
@synthesize monthLabel, dayNumberLabel, dayNameLabel;
@synthesize priceLabel, timeLabel;
@synthesize venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton;
@synthesize detailsLabel;
@synthesize webActivityView;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;

- (void)dealloc {
    [event release];
    [navigationBar release];
    [backButton release];
    [logoButton release];
    [actionBar release];
    [letsGoButton release];
    [shareButton release];
    [deleteButton release];
    [titleBar release];
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
    [detailsLabel release];
    [webActivityView release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release]; // ---?
    [webDataTranslator release];
    [super dealloc];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation bar
    navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar_blank.png"]];
    [self.view addSubview:self.navigationBar];
    {
        // Back button
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(10, 6, 74, 32);
        [self.backButton setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState: UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonPushed) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationBar addSubview:self.backButton];
        
        // Logo button
        self.logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.logoButton.frame = CGRectMake(135, 3, 53, 38);
        [self.logoButton setBackgroundImage:[UIImage imageNamed:@"btn_logo.png"] forState: UIControlStateNormal];
        [self.logoButton addTarget:self action:@selector(logoButtonPushed) forControlEvents:UIControlEventTouchUpInside];
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
        [self.letsGoButton addTarget:self action:@selector(bookedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.letsGoButton];
        
        // Share button
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.shareButton.frame = actionButtonFrameBlock(110);
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"btn_share.png"] forState: UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.shareButton];
        
        // Delete button
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.frame = actionButtonFrameBlock(215);
        [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState: UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(deleteEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionBar addSubview:self.deleteButton];
    }
    
    // Title bar
    titleBar = [[ElasticUILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.actionBar.frame), self.view.bounds.size.width, 32)];
    [self.view addSubview:self.titleBar];
    [self.view bringSubviewToFront:self.titleBar];
    
    // Scroll view
    CGFloat scrollViewOriginY = CGRectGetMaxY(self.titleBar.frame);
	scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, scrollViewOriginY, self.view.bounds.size.width, self.view.bounds.size.height - scrollViewOriginY)];
    [self.view addSubview:self.scrollView];
    {
        // Image view
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 180)];
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
        self.eventInfoDividerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"eventcard.png"]];
        [self.scrollView addSubview:self.eventInfoDividerView];
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
            
            // Price label
            CGFloat priceLabelOriginX = 80;
            priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelOriginX, 5, self.eventInfoDividerView.bounds.size.width - priceLabelOriginX, 15)];
            self.priceLabel.backgroundColor = [UIColor clearColor];
            self.priceLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
            [self.eventInfoDividerView addSubview:self.priceLabel];
            
            // Time label
            CGFloat timeLabelOriginX = priceLabelOriginX;
            timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabelOriginX, 37, self.eventInfoDividerView.bounds.size.width - timeLabelOriginX, 20)];
            self.timeLabel.backgroundColor = [UIColor clearColor];
            self.timeLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:16];
            [self.eventInfoDividerView addSubview:self.timeLabel];
            
            // Location box
            //CGSize locationBoxSize = CGSizeMake(self.eventInfoDividerView.bounds.size.width, self.eventInfoDividerView.bounds.size.height - dateBoxSize.height);
            {
                                
                // Venue label
                venueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,75,317,30)];
                self.venueLabel.backgroundColor = [UIColor clearColor];
                self.venueLabel.font= [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:22];
                [self.eventInfoDividerView addSubview:self.venueLabel];
                
                // Address label
                addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,91,200,25)];
                self.addressLabel.backgroundColor = [UIColor clearColor];
                self.addressLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                [self.eventInfoDividerView addSubview:self.addressLabel];
                
                // City State Zip label
                cityStateZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,106,200,25)];
                self.cityStateZipLabel.backgroundColor = [UIColor clearColor];
                self.cityStateZipLabel.font= [UIFont fontWithName:@"HelveticaNeue" size:14];
                [self.eventInfoDividerView addSubview:self.cityStateZipLabel];
                
                // Phone number button
                self.phoneNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.phoneNumberButton.frame = CGRectMake(10, 130, 150, 20);
                [self.phoneNumberButton setTitleColor:[UIColor colorWithRed:0.2549 green:0.41568 blue:0.70196 alpha:1.0] forState:UIControlStateNormal];
                [self.phoneNumberButton addTarget:self action:@selector(phoneCall:) forControlEvents:UIControlEventTouchUpInside];
                self.phoneNumberButton.backgroundColor = [UIColor clearColor];
                self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:12];
                self.phoneNumberButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [self.eventInfoDividerView addSubview:self.phoneNumberButton];
                
                // Map button
                self.mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.mapButton.frame = CGRectMake(240,105,64,20);
                [self.mapButton setBackgroundImage:[UIImage imageNamed:@"btn_map.png"] forState: UIControlStateNormal];
                [self.mapButton addTarget:self action:@selector(makeMapView:) forControlEvents:UIControlEventTouchUpInside];
                [self.eventInfoDividerView addSubview:self.mapButton];
                self.mapButton.enabled = NO;
            }
            
            // Details text view
            CGFloat detailsLabelHorizontalPadding = 5;
            detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailsLabelHorizontalPadding, CGRectGetMaxY(self.eventInfoDividerView.frame), self.scrollView.bounds.size.width - 2 * detailsLabelHorizontalPadding, 0.0)];
            self.detailsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
            self.detailsLabel.backgroundColor = [UIColor clearColor];
            self.detailsLabel.numberOfLines = 0;
            [self.scrollView addSubview:self.detailsLabel];
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
        [self.webActivityView showAnimated:NO];
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
    self.view.backgroundColor = [concreteParentCategoryColor colorWithAlphaComponent:0.15];
    
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
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.detailsLabel.frame))];
    
    // Breadcrumbs
    NSMutableString * breadcrumbsString = [self.event.concreteParentCategory.title mutableCopy];
    NSArray * orderedConcreteCategoryBreadcrumbs = [self.event.concreteCategoryBreadcrumbs sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]]];
    for (CategoryBreadcrumb * breadcrumb in orderedConcreteCategoryBreadcrumbs) {
        [breadcrumbsString appendFormat:@", %@", breadcrumb.category.title];
    }
    self.breadcrumbsLabel.text = breadcrumbsString;
    
	// If the image view is not already set, then attempt to load an image for this event.
    if (self.imageView.image == nil) {
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
    if (imageLocation == nil) {
        imageLocation = self.event.concreteParentCategory.thumbnail;
    }
    NSString * imageURL = [url stringByAppendingString:imageLocation];
	NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    UIImage * image = [UIImage imageWithData:imageData];
	[self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
}

- (void)displayImage:(UIImage *)image {
    //NSLog(@"image is %f by %f", image.size.width, image.size.height);
	[self.imageView setImage:image];
}

///send learned data to ML with tag G
- (IBAction)bookedButtonClicked:(id)sender  {
    
    [self showWebLoadingViews];
    
    // Add event to the device's iCal
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEvent * newEvent = [EKEvent eventWithEventStore:eventStore];
    
    newEvent.title = self.event.title;
    newEvent.startDate = self.event.startDatetime;
    NSLog(@"%@", newEvent.startDate);
    newEvent.allDay = ![self.event.startTimeValid boolValue];
    if ([self.event.endDateValid boolValue]) {
        newEvent.endDate = self.event.endDatetime;
    } else {
        newEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:newEvent.startDate];
    }
    newEvent.location = self.event.venue;
    NSMutableString * iCalEventNotes = [NSMutableString string];
    NSString * addressLineFirst = self.event.address;
    NSString * addressLineSecond = [self.webDataTranslator addressSecondLineStringFromCity:self.event.city state:self.event.state zip:self.event.zip];
    if (addressLineFirst) { 
        [iCalEventNotes appendFormat:@"%@\n", addressLineFirst]; 
    }
    if (addressLineSecond) {
        [iCalEventNotes appendFormat:@"%@\n", addressLineSecond];
    }
    if (addressLineFirst || addressLineSecond) {
        [iCalEventNotes appendString:@"\n"];
    }
    if (self.event.details) {
        [iCalEventNotes appendString:self.event.details];
    }
    newEvent.notes = iCalEventNotes;
    
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError * err;
    [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&err];
    if (err != nil) { NSLog(@"error"); }
    [eventStore release];
    
    // Send learned data to the web
    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"G"];
    
    // Change appearance of "Let's Go" button
    [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_going.png"] forState: UIControlStateNormal];
    self.letsGoButton.enabled = NO;
    
	// Show alert
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", self.event.title] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    // Wait for response from server

}

-(IBAction)shareButtonClicked:(id)sender  {
    
    [self makeAndShowEmailViewController];
    
}

- (void) makeAndShowEmailViewController {
    NSLog(@"Email"); // Email
    
    NSString * EVENT_TITLE_NOT_AVAILABLE = @"Title not available";
    NSString * EVENT_TIME_NOT_AVAILABLE = @"Time not available";
    NSString * EVENT_DATE_NOT_AVAILABLE = @"Date not available";
    NSString * EVENT_COST_NOT_AVAILABLE = @"Price not available";
    NSString * EVENT_DESCRIPTION_NOT_AVAILABLE = @"Description not available";
    
    NSString * emailTitle = self.event.title ? self.event.title : EVENT_TITLE_NOT_AVAILABLE;
    NSString * emailLocation = self.event.venue ? [NSString stringWithFormat:@"    Location: %@<br>", self.event.venue] : @"";
    NSString * emailAddressFirst = self.event.address ? self.event.address : @"";
    NSString * emailAddressSecond = [self.webDataTranslator addressSecondLineStringFromCity:self.event.city state:self.event.state zip:self.event.zip];
    if (self.event.address && emailAddressSecond) { emailAddressFirst = [emailAddressFirst stringByAppendingString:@", "]; }
    if (!emailAddressSecond) { emailAddressSecond = @""; }
    NSString * emailAddressFull = ([emailAddressFirst isEqualToString:@""] && [emailAddressSecond isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"    Address: %@%@<br>", emailAddressFirst, emailAddressSecond];
    NSString * emailTime = [self.webDataTranslator timeSpanStringFromStartDatetime:self.event.startTimeDatetime endDatetime:self.event.endTimeDatetime dataUnavailableString:EVENT_TIME_NOT_AVAILABLE];
    NSString * emailDate = [self.webDataTranslator dateSpanStringFromStartDatetime:self.event.startDateDatetime endDatetime:self.event.endDateDatetime relativeDates:YES dataUnavailableString:EVENT_DATE_NOT_AVAILABLE];
    NSString * emailPrice = [self.webDataTranslator priceRangeStringFromMinPrice:self.event.priceMinimum maxPrice:self.event.priceMaximum dataUnavailableString:EVENT_COST_NOT_AVAILABLE];
    NSString * emailDescription = self.event.details ? self.event.details : EVENT_DESCRIPTION_NOT_AVAILABLE;
    emailDescription = ![emailDescription isEqualToString:EVENT_DESCRIPTION_NOT_AVAILABLE] ? [NSString stringWithFormat:@"<br><br>%@", emailDescription] : @"";
    
    NSString * emailMap = @"";
    if (self.event.latitude && self.event.longitude) {
        NSString * mapSearchQuery = [[[NSString stringWithFormat:@"%@ %@ %@", (self.event.venue ? self.event.venue : @""), emailAddressFirst, emailAddressSecond] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%f,%f", mapSearchQuery, [self.event.latitude floatValue], [self.event.longitude floatValue]];
        emailMap = [NSString stringWithFormat:@"    <a href='%@'>Click here for map</a><br>", urlString];
    }
    
    //create message body with event title and description
    NSString *mailString = [[NSString alloc] initWithFormat:@"Hey! I found this event on Kwiqet. We should go!<br><br>    <b>%@</b><br><br>%@%@%@    Time: %@<br>    Date: %@<br>    Price: %@%@", emailTitle, emailLocation, emailAddressFull, emailMap, emailTime, emailDate, emailPrice, emailDescription];
    
    //call mail app to front as modal window
    MFMailComposeViewController * controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"You're Invited via Kwiqet"];
    [controller setMessageBody:mailString isHTML:YES];
    if (controller) [self presentModalViewController:controller animated:YES];
    [controller release];
    [mailString release];
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
-(IBAction)deleteEvent:(id)sender  {

    [self.webConnector sendLearnedDataAboutEvent:self.event.uri withUserAction:@"X"];
    [self showWebLoadingViews];
    // Wait for response from server
    
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
-(IBAction)phoneCall:(id)sender  {
	NSLog(@"phone call");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.event.phone]]];
}

-(IBAction)makeMapView:(id)sender  {
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

- (void) backButtonPushed  {
    [self viewControllerIsFinished];
}

- (void) logoButtonPushed {
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