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

- (void) backButtonPushed;
- (void) logoButtonPushed;

@end

@implementation EventViewController
@synthesize navigationBar, backButton, logoButton;
@synthesize actionBar, letsGoButton, shareButton, deleteButton;
@synthesize titleBar;
@synthesize scrollView;
@synthesize imageView, breadcrumbsLabel;
@synthesize eventInfoDividerView;
@synthesize monthLabel, dayNumberLabel, dayNameLabel;
@synthesize priceLabel, timeLabel;
@synthesize venueLabel, addressLabel, cityStateZipLabel, phoneNumberButton, mapButton;
@synthesize detailsLabel;

@synthesize eventDictionary,eventStartDatetime,eventEndDatetime,phoneString,categoryColor,eventDetailID,eventTime,costString;
@synthesize delegate;
@synthesize coreDataModel;
@synthesize mapViewController;

- (void)dealloc {
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
    
    [costString release];
    [eventTime release];
    [eventDetailID release];
    [categoryColor release];
	[phoneString release];
	[eventStartDatetime release];
    [eventEndDatetime release];
	[eventDictionary release];
    [connectionErrorOnUserActionRequestAlertView release];
    [mapViewController release];
    [webConnector release];
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
        [self.scrollView addSubview:self.imageView];
        // Image view gesture recognizer
        UISwipeGestureRecognizer * swipeToGoBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack:)];
        [self.imageView addGestureRecognizer:swipeToGoBack];
        self.imageView.userInteractionEnabled = YES;
        [swipeToGoBack release];
        
        // Breadcrumbs label
        CGFloat breadcrumbsLabelHeight = 32.0;
        float breadcrumbsLabelBackgroundColorWhite = 53.0/255.0;
        float breadcrumbsLabelBackgroundAlpha = 0.9;
        breadcrumbsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bounds.size.height - breadcrumbsLabelHeight, self.imageView.bounds.size.width, breadcrumbsLabelHeight)];
        self.breadcrumbsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.breadcrumbsLabel.backgroundColor = [UIColor colorWithWhite:breadcrumbsLabelBackgroundColorWhite alpha:breadcrumbsLabelBackgroundAlpha];
        self.breadcrumbsLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.breadcrumbsLabel.textColor = [UIColor whiteColor];
        [self.imageView addSubview:self.breadcrumbsLabel];
        
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
                self.phoneNumberButton.frame = CGRectMake(6, 130, 150, 20);
                [self.phoneNumberButton setTitle:self.phoneString forState:UIControlStateNormal];
                [self.phoneNumberButton setTitleColor:[UIColor colorWithRed:0.2549 green:0.41568 blue:0.70196 alpha:1.0] forState:UIControlStateNormal];
                [self.phoneNumberButton addTarget:self action:@selector(phoneCall:) forControlEvents:UIControlEventTouchUpInside];
                self.phoneNumberButton.backgroundColor = [UIColor clearColor];
                self.phoneNumberButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-BdCn" size:12];
                self.phoneNumberButton.titleLabel.textAlignment = UITextAlignmentLeft;
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
    
    [self eventRequestWithID:self.eventDetailID];
}

#pragma request for event details
-(void)eventRequestWithID:(NSString*)eventID {
    URLBuilder *urlBuilder = [[URLBuilder alloc]init];
    NSURL *url = [urlBuilder buildCardURLWithID:eventID];
    NSLog(@"EventViewController eventRequestWithID - url is %@", url);
    ASIHTTPRequest * myRequest = [ASIHTTPRequest requestWithURL:url];
    [myRequest setTimeOutSeconds:5];
    [myRequest setDelegate:self];
    [myRequest setRequestMethod:@"GET"];
    [myRequest setDidFinishSelector:@selector(uploadFinished:)];
    [myRequest setDidFailSelector:@selector(uploadFailed:)];
    [myRequest startAsynchronous];
    [urlBuilder release];
}

- (void)uploadFinished:(ASIHTTPRequest *)request  {
	[self buildArrayFromRequest:[request responseString]];
}

- (void)uploadFailed:(ASIHTTPRequest *)request  {
	NSString *statusMessage = [request responseStatusMessage];
	NSLog(@"%@",statusMessage);
	NSError *error = [request error];
	NSLog(@"%@",error);
	//[self serverError];
}

-(void)buildArrayFromRequest:(NSString*)string  {
	//take JSON and unpack it	
	NSString *JSONString = string;
	NSError *error = nil;
    
    self.eventDictionary = [JSONString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    
    //create view
    [self makeSubViews];
}

-(void)makeSubViews  {
    
    NSString *titleText = [WebUtil stringOrNil:[self.eventDictionary objectForKey:@"title"]];
    //make check for date and time
    NSString * Startdate = [WebUtil stringOrNil:[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"start_date"]];
    if (Startdate.length == 0) {
        Startdate = @"Date not available";
    }
    NSString *StartTime = [WebUtil stringOrNil:[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"start_time"]];
    
    NSString *EndTime = [WebUtil stringOrNil:[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"end_time"]];
    if ([EndTime isEqual:[NSNull null]]) {
        EndTime = @"";
    }    
    NSString *descriptionText = [WebUtil stringOrNil:[self.eventDictionary objectForKey:@"description"]];
    //check if descritption is empty
    if (descriptionText.length == 0 ) {
        descriptionText = @"Description not available";
    }
    
    NSString *venueString = [WebUtil stringOrNil:[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"title"]];
    if (venueString.length == 0) {
        venueString = @"-";
    }
    NSString *address = [WebUtil stringOrNil:[[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"point"]valueForKey:@"address"]];
    if (address.length == 0) {
        address = @"Address not available";
    }
    NSString *cityString = [WebUtil stringOrNil:[[[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"point"]valueForKey:@"city"]valueForKey:@"city"]];
    if (cityString.length == 0) {
        cityString = @"City not available";
    }
    NSString *stateString = [WebUtil stringOrNil:[[[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"point"]valueForKey:@"city"]valueForKey:@"state"]];
    if (stateString.length == 0) {
        stateString = @"State not available";
    }
    NSString *zipCodeString = [WebUtil stringOrNil:[[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"point"]valueForKey:@"zip"]];
    if (zipCodeString.length == 0) {
        zipCodeString = @"00000";
    }
    NSString *fullAddress = [NSString stringWithFormat:@"%@, %@ %@",cityString,stateString,zipCodeString];
    
    self.phoneString = [WebUtil stringOrNil:[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"phone"]];
    if (self.phoneString.length == 0) {
        self.phoneString = @"Phone number not available";
    }
    NSArray *price = [[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"prices"];
    NSString * costStringSetup;
    
    if ([price count] == 0) {
        costStringSetup = @"No price available";
    } else if ([price count] == 1) {
        NSString * priceValue = [[price objectAtIndex:0] valueForKey:@"quantity"];
        if ([priceValue intValue] == 0) {
            priceValue = @"Free";
            costStringSetup = priceValue;
        } else {
            costStringSetup = [NSString stringWithFormat:@"$%@", priceValue];
        }
    } else {
        // NOTE THAT WE ARE ASSUMING PRICES ARE INTs (OR THAT WE DON'T CARE WE ARE CHANGING THEM TO INTs) HERE
        int minPrice = 100000;
        int maxPrice = -100000;
        for (int i=0; i < [price count]; i++) {
            NSString * priceValue = [[price objectAtIndex:i] valueForKey:@"quantity"];
            int priceValueInt = [priceValue intValue];
            minPrice = MIN(minPrice, priceValueInt);
            maxPrice = MAX(maxPrice, priceValueInt);
        }
        costStringSetup = [NSString stringWithFormat:@"$%d - $%d", minPrice, maxPrice];
    }
    self.costString = costStringSetup;
    
    UIColor * categoryUIColor = [WebUtil colorFromHexString:self.categoryColor];
    
    self.view.backgroundColor = [categoryUIColor colorWithAlphaComponent:0.15];
    
    titleBar.color = categoryUIColor;
    titleBar.text = titleText;

    // Startdate contains the Event Start dat e. 
    // / Startdate is split to get month date and Day Values..
    Startdate=[Startdate stringByAppendingString:@" "];
    Startdate=[Startdate stringByAppendingString:StartTime];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];            //@"yyyy-MM-dd HH:mm:ss"];
    if ([Startdate 
         isEqualToString:@"Date not available"]) {
        Startdate=@"0000-00-00";
    }
    self.eventStartDatetime = [dateFormat dateFromString:Startdate];  
    // Convert date object to desired output format
    [dateFormat setDateFormat:@"MMM"];
    
    NSString *Month = [dateFormat stringFromDate:self.eventStartDatetime];  
    NSString *CapMonth = [Month uppercaseString];
    
    self.monthLabel.text=CapMonth;

    [dateFormat setDateFormat:@"d"];
    
    NSString *DayNum = [dateFormat stringFromDate:self.eventStartDatetime];  
    
    self.dayNumberLabel.text = DayNum;
    self.dayNumberLabel.textColor  = categoryUIColor;
    
    [dateFormat setDateFormat:@"EEE"];
    
    NSString * Day = [dateFormat stringFromDate:self.eventStartDatetime];  
    NSString * CapDay=[Day uppercaseString];
    self.dayNameLabel.text=CapDay;
    
    //set time in proper position
    [dateFormat setDateFormat:@"h:mm a"];
    
    NSString *beginTime = [dateFormat stringFromDate:self.eventStartDatetime];
    
    if (EndTime.length == 0) {
        self.eventTime = [NSString stringWithFormat:@"%@",beginTime];
    }
    else {
        NSString *EndDateTimeString=[@"2011-02-16" stringByAppendingString:@" "];
        EndDateTimeString=[EndDateTimeString stringByAppendingString:EndTime];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.eventEndDatetime = [dateFormat dateFromString:EndDateTimeString];
        [dateFormat setDateFormat:@"h:mm a"];
        EndTime = [dateFormat stringFromDate:self.eventEndDatetime];
        
        self.eventTime = [NSString stringWithFormat:@"%@ - %@",beginTime,EndTime];
    }
    
    //make price
    NSString *myPriceTag = @"Price: ";
    myPriceTag = [myPriceTag stringByAppendingString:self.costString];
    self.priceLabel.text = myPriceTag;
    
    
    // HACK OVERRIDE TO AVOID DEALING WITH MESS ABOVE FOR A WHILE LONGER - THIS HACK ISN'T COVERING IT. THERE SEEMS TO BE A PROBLEM SERVERSIDE THAT SOME TIMES ARE NOT COMING IN RIGHT. MAYBE IT'S JUST A RANDOM SCRAPE PROBLEM SOMETIMES - I.E. THAT TIMES ARE JUST NOT RETRIEVED CORRECTLY SOMETIMES.
    NSString * originalStartTimeString = [[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"start_time"];
    NSString * originalEndTimeString = [[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]objectForKey:@"end_time"];
    NSLog(@"originalstart - %@ originalend - %@", originalStartTimeString, originalEndTimeString);
    if ((!originalStartTimeString || [originalStartTimeString isEqual:[NSNull null]] || [originalStartTimeString length] == 0 || [originalStartTimeString isEqualToString:@"00:00:00"]) &&
        (!originalEndTimeString || [originalEndTimeString isEqual:[NSNull null]] || [originalEndTimeString length] == 0 || [originalEndTimeString isEqualToString:@"00:00:00"])) {
        self.timeLabel.text = @"Time not available";
    } else {
        self.timeLabel.text = self.eventTime;
    }
    
    self.venueLabel.text = venueString;
    self.addressLabel.text = address;
    self.cityStateZipLabel.text = fullAddress;
    if ([self.phoneString isEqualToString:@"Phone number not available"]) {
        self.phoneNumberButton.frame = CGRectMake(3,130,150,20);
    } else  {
        self.phoneNumberButton.frame = CGRectMake(6,130,80,20);
    }
    [self.phoneNumberButton setTitle:self.phoneString forState:UIControlStateNormal];
        
    self.detailsLabel.text = descriptionText;
    //set contentSize for scroll view
    CGSize detailsLabelSize = [self.detailsLabel.text sizeWithFont:self.detailsLabel.font constrainedToSize:CGSizeMake(self.detailsLabel.bounds.size.width, 10000)];
    CGRect newFrame = self.detailsLabel.frame;
    newFrame.size.height = detailsLabelSize.height;
    self.detailsLabel.frame = newFrame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(self.detailsLabel.frame))];
    NSLog(@"%@ %@", NSStringFromCGSize(self.scrollView.contentSize), NSStringFromCGRect(self.detailsLabel.frame));
    
	//invoke the NSOperation
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
										initWithTarget:self
										selector:@selector(loadImage) 
										object:nil];
    
	[queue addOperation:operation];
    [operation release];
	[queue release];
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
    NSString *urlplist = [[NSBundle mainBundle]
						  pathForResource:@"urls" ofType:@"plist"];
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithContentsOfFile:urlplist];
    NSString *url = [urlDictionary valueForKey:@"base_url"];
    NSString *imageLocation = [self.eventDictionary valueForKey:@"image"];
    if ([imageLocation isEqual:[NSNull null]] || imageLocation.length == 0) {
        imageLocation = [self.eventDictionary valueForKey:@"thumbnail_detail"];
    }
    NSString *final_url_string = [[NSString alloc]initWithString:[url stringByAppendingString:imageLocation]];
	NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:final_url_string]];
	UIImage* image = [[[UIImage alloc] initWithData:imageData] autorelease];
	[imageData release];
    [final_url_string release];
	[self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
    
    [urlDictionary release];
}

- (void)displayImage:(UIImage *)image {
    NSLog(@"image is %f by %f", image.size.width, image.size.height);
	[self.imageView setImage:image]; //UIImageView
    //breadcrumbs
    [self breadcrumbs];
}

-(void)breadcrumbs  {
    Category * concreteParentCategory = [self.coreDataModel getCategoryWithURI:[self.eventDictionary valueForKey:@"concrete_parent_category"]];
    NSString * breadcrumbsString = [NSString stringWithFormat:@"   %@",concreteParentCategory.title];
    NSArray * breadArray = [[NSArray alloc]initWithArray:[self.eventDictionary valueForKey:@"concrete_category_breadcrumbs"]];
    for (int i = [breadArray count] - 1; i >= 0; i = i - 1) {
        Category * nextCategory = [self.coreDataModel getCategoryWithURI:[breadArray objectAtIndex:i]];
        breadcrumbsString = [breadcrumbsString stringByAppendingFormat:@", %@", nextCategory.title];
    }
    self.breadcrumbsLabel.text = breadcrumbsString;
    [breadArray release];
}

///send learned data to ML with tag G
- (IBAction)bookedButtonClicked:(id)sender  {

    // Add event to the device's iCal
    EKEventStore * eventStore = [[EKEventStore alloc] init];
    EKEvent * newEvent = [EKEvent eventWithEventStore:eventStore];
    
    NSDictionary * betterEventDictionary = [self tempSolutionWellFormattedDataFromDictionary:self.eventDictionary];
        
    newEvent.title = [betterEventDictionary objectForKey:@"title"]; 
    newEvent.startDate = [betterEventDictionary objectForKey:@"startDatetime"];
    newEvent.allDay = ![[betterEventDictionary valueForKey:@"startTimeValid"] boolValue];
    if ([[betterEventDictionary valueForKey:@"endDateValid"] boolValue]) {
        newEvent.endDate = [betterEventDictionary valueForKey:@"endDatetime"];
    } else {
        newEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:newEvent.startDate];
    }
    newEvent.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:newEvent.startDate];
    NSLog(@"%@ to %@", newEvent.startDate, newEvent.endDate);
    newEvent.location = [betterEventDictionary valueForKey:@"venue"];
    
    NSMutableString * iCalEventNotes = [NSMutableString string];
    NSString * addressLineFirst = [betterEventDictionary valueForKey:@"address"];
    NSString * addressLineSecond = [self.webDataTranslator addressSecondLineStringFromCity:[betterEventDictionary valueForKey:@"city"] state:[betterEventDictionary valueForKey:@"state"] zip:[betterEventDictionary valueForKey:@"zip"]];
    if (addressLineFirst) { 
        [iCalEventNotes appendFormat:@"%@\n", addressLineFirst]; 
    }
    if (addressLineSecond) {
        [iCalEventNotes appendFormat:@"%@\n", addressLineSecond];
    }
    if (addressLineFirst || addressLineSecond) {
        [iCalEventNotes appendString:@"\n"];
    }
    if ([betterEventDictionary valueForKey:@"details"]) {
        [iCalEventNotes appendString:[betterEventDictionary valueForKey:@"details"]];
    }
    newEvent.notes = iCalEventNotes;
    
    [newEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError * err;
    [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&err];
    if (err != nil) { NSLog(@"error"); NSLog(@"%@", [err userInfo]);}
    [eventStore release];
        
    // Show alert
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Event added to Calendar!" message:[NSString stringWithFormat:@"The event \"%@\" has been added to your calendar.", [betterEventDictionary valueForKey:@"title"]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self.letsGoButton setBackgroundImage:[UIImage imageNamed:@"btn_going.png"] forState: UIControlStateNormal];
    self.letsGoButton.enabled = NO;

    [self.webConnector sendLearnedDataAboutEvent:[self.eventDictionary objectForKey:@"resource_uri"] withUserAction:@"G"];
    
    // Wait for response from server

}

-(IBAction)shareButtonClicked:(id)sender  {
    
    NSDictionary * betterEventDictionary = [self tempSolutionWellFormattedDataFromDictionary:self.eventDictionary];
    
    NSString * emailTitle = [betterEventDictionary valueForKey:@"title"] ? [betterEventDictionary valueForKey:@"title"] : @"Title not available";
    
    NSString * emailLocation = [betterEventDictionary valueForKey:@"venue"] ? [NSString stringWithFormat:@"    Location: %@<br>", [betterEventDictionary valueForKey:@"venue"]] : @"";
    
    NSString * emailAddressFirst = [betterEventDictionary valueForKey:@"address"] ? [betterEventDictionary valueForKey:@"address"] : @"";
    NSString * emailAddressSecond = [self.webDataTranslator addressSecondLineStringFromCity:[betterEventDictionary valueForKey:@"city"] state:[betterEventDictionary valueForKey:@"state"] zip:[betterEventDictionary valueForKey:@"zip"]];
    if ([betterEventDictionary valueForKey:@"address"] && emailAddressSecond) { emailAddressFirst = [emailAddressFirst stringByAppendingString:@", "]; }
    if (!emailAddressSecond) { emailAddressSecond = @""; }
    NSString * emailAddressFull = ([emailAddressFirst isEqualToString:@""] && [emailAddressSecond isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"    Address: %@%@<br>", emailAddressFirst, emailAddressSecond];
    
    NSDate * startTimeDatetime = [[betterEventDictionary valueForKey:@"startTimeValid"] boolValue] ? [betterEventDictionary valueForKey:@"startDatetime"] : nil;
    NSDate * endTimeDatetime = [[betterEventDictionary valueForKey:@"endTimeValid"] boolValue] ? [betterEventDictionary valueForKey:@"endDatetime"] : nil;
    NSDate * startDateDatetime = [[betterEventDictionary valueForKey:@"startDateValid"] boolValue] ? [betterEventDictionary valueForKey:@"startDatetime"] : nil;
    NSDate * endDateDatetime = [[betterEventDictionary valueForKey:@"endDateValid"] boolValue] ? [betterEventDictionary valueForKey:@"endDatetime"] : nil;
    
    NSString * emailTime = [self.webDataTranslator timeSpanStringFromStartDatetime:startTimeDatetime endDatetime:endTimeDatetime dataUnavailableString:@""];
    emailTime = !([emailTime isEqualToString:@""] || [emailTime isEqualToString:@"12:00 AM"]) ? [NSString stringWithFormat:@"    Time: %@<br>", emailTime] : @"";
    
    NSString * emailDate = [self.webDataTranslator dateSpanStringFromStartDatetime:startDateDatetime endDatetime:endDateDatetime relativeDates:YES dataUnavailableString:@""];
    emailDate = ![emailDate isEqualToString:@""] ? [NSString stringWithFormat:@"    Date: %@<br>", emailDate] : @"";
    
    NSString * emailPrice = [self.webDataTranslator priceRangeStringFromMinPrice:[betterEventDictionary valueForKey:@"priceMinimum"] maxPrice:[betterEventDictionary valueForKey:@"priceMaximum"] dataUnavailableString:@""];
    emailPrice = ![emailPrice isEqualToString:@""] ? [NSString stringWithFormat:@"    Price: %@<br>", emailPrice] : @"";
    
    NSString * emailDescription = [betterEventDictionary valueForKey:@"details"] ? [betterEventDictionary valueForKey:@"details"] : @"";
    emailDescription = ![emailDescription isEqualToString:@""] ? [NSString stringWithFormat:@"<br>%@", emailDescription] : @"";
    
    NSString * emailMap = @"";
    if ([betterEventDictionary valueForKey:@"latitude"] && [betterEventDictionary valueForKey:@"longitude"]) {
        NSString * mapSearchQuery = [[[NSString stringWithFormat:@"%@ %@ %@", ([betterEventDictionary valueForKey:@"venue"] ? [betterEventDictionary valueForKey:@"venue"] : @""), emailAddressFirst, emailAddressSecond] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&ll=%f,%f", mapSearchQuery, [[betterEventDictionary valueForKey:@"latitude"] floatValue], [[betterEventDictionary valueForKey:@"longitude"] floatValue]];
        emailMap = [NSString stringWithFormat:@"    <a href='%@'>Click here for map</a><br>", urlString];
    }
    
    //create message body with event title and description
    NSString *mailString = [[NSString alloc] initWithFormat:@"Hey! I found this event on Kwiqet. We should go!<br><br>    <b>%@</b><br><br>%@%@%@%@%@%@%@", emailTitle, emailLocation, emailAddressFull, emailMap, emailTime, emailDate, emailPrice, emailDescription];
    
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

//add event to calendar
-(IBAction)addCalendar:(id)sender {
	EKEventStore *eventDB = [[EKEventStore alloc] init];
	EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];
	
	myEvent.title     = [self.eventDictionary objectForKey:@"title"];
	myEvent.startDate = [[NSDate alloc] init]; //eventStartDate; 
	myEvent.endDate   = [[NSDate alloc] initWithTimeInterval:600 sinceDate:myEvent.startDate];

	//myEvent.allDay = YES;
	
	[myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
	
	NSError *err;
	[eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
	if (err == noErr) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Event Created"
							  message:nil
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[eventDB release];
}
//delete event from core data and revert back to table
-(IBAction)deleteEvent:(id)sender  {

    [self.webConnector sendLearnedDataAboutEvent:[self.eventDictionary objectForKey:@"resource_uri"] withUserAction:@"X"];
    
    // Wait for response from server
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
            
    if ([userAction isEqualToString:@"G"]) {
        
        // Currently, we delete the event if the user "went". THIS IS CONFUSING. We are changing this functionality.
        //deletedEventDueToGoingToEvent = YES;
        //[self.coreDataModel deleteRegularEventForURI:[self.eventDictionary objectForKey:@"resource_uri"]]; // This makes me uneasy deleting it here... But, we're not dealing with this right now.
        
    } else if ([userAction isEqualToString:@"X"]) {
        NSString * eventURI = [self.eventDictionary objectForKey:@"resource_uri"];
        [self.coreDataModel deleteRegularEventForURI:eventURI];
        // We're done here, let our delegate know that we are finished, and that we ended by deleting the event.
        [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:YES eventURI:eventURI];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"G"]) {
        [self.connectionErrorOnUserActionRequestAlertView show];
    } else if ([userAction isEqualToString:@"X"]) {
        [self.connectionErrorOnUserActionRequestAlertView show];
    }
    
}

// make Phone number clickable..
-(IBAction)phoneCall:(id)sender  {
	NSLog(@"phone call");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.phoneString]]];
}

-(IBAction)makeMapView:(id)sender  {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    self.mapViewController.locationLatitude = [[[[[self.eventDictionary valueForKey:@"occurrences"] objectAtIndex:0] valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"latitude"];
    self.mapViewController.locationLongitude = [[[[[self.eventDictionary valueForKey:@"occurrences"] objectAtIndex:0] valueForKey:@"place"] valueForKey:@"point"] valueForKey:@"longitude"];
    self.mapViewController.locationName = [[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"title"];
    self.mapViewController.locationAddress = [[[[[self.eventDictionary valueForKey:@"occurrences"]objectAtIndex:0]valueForKey:@"place"]valueForKey:@"point"]valueForKey:@"address"];
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
    NSString * eventURI = [self.eventDictionary objectForKey:@"resource_uri"];
    [self.delegate cardPageViewControllerDidFinish:self withEventDeletion:deletedEventDueToGoingToEvent eventURI:eventURI];
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
