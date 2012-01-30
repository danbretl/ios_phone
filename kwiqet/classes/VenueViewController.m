//
//  VenueViewController.m
//  Kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueViewController.h"
#import "URLBuilder.h"
#import "UIFont+Kwiqet.h"
#import "EventTableViewCell.h"
#import "EventLocationAnnotation.h"
#import <QuartzCore/QuartzCore.h>
#import "Event.h"
#import "EventResult.h"
#import "WebUtil.h"

double const VVC_ANIMATION_DURATION = 0.25;
NSInteger const VVC_MAXIMUM_NUMBER_OF_ROWS_FOR_UPCOMING_EVENTS = 5;

@interface VenueViewController()

@property (retain, nonatomic) EventsWebQuery * eventsWebQuery;
@property (retain, nonatomic) NSMutableArray * events;
@property (readonly, nonatomic) WebDataTranslator * webDataTranslator;
@property (readonly, nonatomic) WebConnector * webConnector;
@property (nonatomic) BOOL isGettingEvents;
@property (nonatomic) BOOL isGettingImage;
@property (nonatomic, readonly) BOOL isGettingWebData;
@property (nonatomic, readonly) BOOL isEventsTableVisible;
@property (nonatomic) UpcomingEventsHeaderViewMessageType appropriateMessageType;
@property (nonatomic) BOOL deletedFromEventCard;

@property (retain, nonatomic) NSIndexPath * eventsTableViewIndexPathOfSelectedRowPreserved;
@property (nonatomic) CGFloat scrollViewContentOffsetHeightLeftUntilEndPreserved;
@property (nonatomic) BOOL scrollViewContentOffsetInfoIsPreserved;

@property (retain, nonatomic) IBOutlet UIView * navBarContainer;
@property (retain, nonatomic) IBOutlet UIButton * backButton;
@property (retain, nonatomic) IBOutlet UIButton * logoButton;
@property (retain, nonatomic) IBOutlet UIButton * followButton;

@property (retain, nonatomic) IBOutlet UIScrollView * scrollView;
@property (retain, nonatomic) IBOutlet UIView * mainContainer;
@property (retain, nonatomic) NSArray * mainContainerChainOfDependentlyPositionedViews;
@property (retain, nonatomic) IBOutlet ElasticUILabel * nameBar;
@property (retain, nonatomic) IBOutlet UIImageView * imageView;
@property (retain, nonatomic) IBOutlet UIView * infoContainer;
@property (retain, nonatomic) IBOutlet UIView * infoContainerShadowView;
@property (retain, nonatomic) IBOutlet UIView * infoContainerBackgroundView;
@property (retain, nonatomic) IBOutlet UILabel * addressLabel;
@property (retain, nonatomic) IBOutlet UILabel * cityStateZipLabel;
@property (retain, nonatomic) IBOutlet UIButton * phoneNumberButton;
@property (retain, nonatomic) IBOutlet UIButton * mapButton;
@property (retain, nonatomic) IBOutlet MKMapView * mapView;
@property (retain, nonatomic) IBOutlet UIView * descriptionContainer;
@property (retain, nonatomic) IBOutlet UILabel * descriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton * descriptionReadMoreButton;
@property (retain, nonatomic) IBOutlet GradientView * descriptionReadMoreCoverView;

@property (retain, nonatomic) IBOutlet UpcomingEventsHeaderView * eventsHeaderView;
@property (retain, nonatomic) IBOutlet UIView * eventsHeaderViewShadow;
@property (retain, nonatomic) IBOutlet UITableView * eventsTableView;

@property (retain, nonatomic) WebActivityView * webActivityView;
@property (nonatomic, readonly) UIAlertView * connectionErrorStandardAlertView;

@property (nonatomic, retain) MapViewController * mapViewController;
@property (nonatomic, retain) EventViewController * eventViewController;

@property (retain) UISwipeGestureRecognizer * swipeToGoBack;

- (IBAction)backButtonTouched:(UIButton *)button;
- (IBAction)logoButtonTouched:(UIButton *)button;
- (IBAction)followButtonTouched:(UIButton *)button;
- (IBAction)phoneNumberButtonTouched:(UIButton *)button;
- (IBAction)mapButtonTouched:(UIButton *)button;
- (void)swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture;
- (IBAction)descriptionReadMoreButtonTouched:(id)sender;
- (void)eventsHeaderViewButtonTouched:(UIButton *)button;
- (void)showMoreUpcomingEventsButtonTouched:(UIButton *)button;
- (void) showWebLoadingViews;
- (void) hideWebLoadingViews;
- (void) updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) updateDescriptionTextFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) updateDescriptionContainerSizeToFitLabelAfterExpansion:(BOOL)shouldExpandLabel animated:(BOOL)animated;
- (void) setDescriptionReadMoreIsVisible:(BOOL)isVisible animated:(BOOL)animated;
- (void) updateMapViewToCenterOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void) updateImageFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated;
- (void) setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated;
- (void) updateMainContainerAndScrollViewSize;
- (void) updateViewOrigin:(UIView *)theView;
- (void) updateViewsOriginsDependentlyPositionedOnView:(UIView *)rootView;
- (void) updateViewOrigin:(UIView *)theView andUpdateDependentlyPositionedViews:(BOOL)shouldUpdateDependentlyPositionedViews;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) updateNetworkActivityIndicator;
- (void) updateUpcomingEventsAnimated:(BOOL)animated;
- (void) updateEventsWebQueryFromVenue:(Place *)venue;
- (BOOL) shouldShowMoreEventsButtonForEvents:(NSArray *)events;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsDisplayedInSection:(NSInteger)section;

@end

@implementation VenueViewController
@synthesize eventViewControllerSourceOfReferral=eventViewControllerSourceOfReferral_;
@synthesize isGettingEvents=isGettingEvents_;
@synthesize isGettingImage=isGettingImage_;
@synthesize scrollView=scrollView_;
@synthesize mainContainer=mainContainer_;
@synthesize mainContainerChainOfDependentlyPositionedViews=mainContainerChainOfDependentlyPositionedViews_;
@synthesize mapView=mapView_;
@synthesize eventsHeaderView=eventsHeaderView_;
@synthesize eventsHeaderViewShadow=eventsHeaderViewShadow_;
@synthesize descriptionReadMoreCoverView=descriptionReadMoreCoverView_;
@synthesize descriptionReadMoreButton=descriptionReadMoreButton_;
@synthesize infoContainerShadowView=infoContainerShadowView_;
@synthesize infoContainerBackgroundView=infoContainerBackgroundView_;
@synthesize delegate;
@synthesize userLocation=userLocation_;
@synthesize eventsWebQuery=eventsWebQuery_;
@synthesize events=events_;
@synthesize coreDataModel=coreDataModel_;
@synthesize venue=venue_;
@synthesize eventsTableViewIndexPathOfSelectedRowPreserved=eventsTableViewIndexPathOfSelectedRowPreserved_;
@synthesize scrollViewContentOffsetHeightLeftUntilEndPreserved=scrollViewContentOffsetHeightLeftUntilEndPreserved_;
@synthesize scrollViewContentOffsetInfoIsPreserved=scrollViewContentOffsetInfoIsPreserved_;
@synthesize navBarContainer=navBarContainer_;
@synthesize backButton=backButton_;
@synthesize logoButton=logoButton_;
@synthesize followButton=followButton_;
@synthesize eventsTableView=eventsTableView_;
@synthesize nameBar=nameBar_;
@synthesize imageView=imageView_;
@synthesize infoContainer=infoContainer_;
@synthesize addressLabel=addressLabel_;
@synthesize cityStateZipLabel=cityStateZipLabel_;
@synthesize phoneNumberButton=phoneNumberButton_;
@synthesize mapButton=mapButton_;
@synthesize descriptionContainer=descriptionContainer_;
@synthesize descriptionLabel=descriptionLabel_;
@synthesize mapViewController=mapViewController_;
@synthesize eventViewController=eventViewController_;
@synthesize swipeToGoBack=swipeToGoBack_;
@synthesize appropriateMessageType;
@synthesize webActivityView=webActivityView_;
@synthesize deletedFromEventCard=deletedFromEventCard_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appropriateMessageType = UpcomingEventsLoading;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Main view / scroll view
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dark_gray.jpg"]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.mainContainer];
    self.scrollView.contentSize = self.mainContainer.frame.size;
    
    // Main container positional dependencies
    self.mainContainerChainOfDependentlyPositionedViews = [NSArray arrayWithObjects:self.nameBar, self.imageView, self.infoContainer, self.descriptionContainer, self.eventsHeaderView, self.eventsTableView, nil];
        
    // Nav bar views
    self.navBarContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
    // Image view
    imageViewNormalHeight = self.imageView.frame.size.height;
    [self setImageViewIsVisible:NO animated:NO];
    
    // Venue info views
    // Background
    self.infoContainerBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_venue_location_info.png"]];
    // Shadow
    self.infoContainerShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoContainerShadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.infoContainerShadowView.layer.shadowOpacity = 0.55;
    self.infoContainerShadowView.layer.shouldRasterize = YES;
    // Subviews
    self.addressLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    // Description view
    self.descriptionLabel.font = [UIFont kwiqetFontOfType:LightNormal size:14];
    self.descriptionReadMoreButton.titleLabel.font = /*[UIFont kwiqetFontOfType:RegularNormal size:self.descriptionLabel.font.pointSize];*/self.descriptionLabel.font;
    self.descriptionReadMoreCoverView.colorEnd = self.descriptionContainer.backgroundColor;
    self.descriptionReadMoreCoverView.endX = 20;
    
    // Table header views
    [self.eventsHeaderView.button addTarget:self action:@selector(eventsHeaderViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.eventsHeaderViewShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    self.eventsHeaderViewShadow.layer.shadowOffset = CGSizeMake(0, 0);
    self.eventsHeaderViewShadow.layer.shadowOpacity = 0.55;
    self.eventsHeaderViewShadow.layer.shouldRasterize = YES;
    
    // Gesture recognizers
    swipeToGoBack_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack:)];
    self.swipeToGoBack.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeToGoBack.delegate = self;
    [self.mainContainer addGestureRecognizer:self.swipeToGoBack];
    
    // Web activity view
    CGFloat webActivityViewSize = 60.0;
    webActivityView_ = [[WebActivityView alloc] initWithSize:CGSizeMake(webActivityViewSize, webActivityViewSize) centeredInFrame:self.view.bounds];
    [self.view addSubview:self.webActivityView];
    [self.view bringSubviewToFront:self.webActivityView];
    
    // Update views from data
    if (self.venue) {
        [self updateInfoViewsFromVenue:self.venue animated:NO];
        [self updateDescriptionTextFromVenue:self.venue animated:NO];
        if (self.venue.coordinateAvailable) {
            [self updateMapViewToCenterOnCoordinate:self.venue.coordinate animated:NO];
        }
        [self updateImageFromVenue:self.venue animated:NO];
        [self updateUpcomingEventsAnimated:NO];
    }
    
    NSLog(@"self.eventsTableView.frame = %@", NSStringFromCGRect(self.eventsTableView.frame));
    
    BOOL debuggingFrames = NO;
    if (debuggingFrames) {
        self.addressLabel.backgroundColor = [UIColor redColor];
        self.cityStateZipLabel.backgroundColor = [UIColor orangeColor];
        self.phoneNumberButton.backgroundColor = [UIColor yellowColor];
        self.descriptionLabel.backgroundColor = [UIColor greenColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.eventsTableViewIndexPathOfSelectedRowPreserved != nil) {
        [self.eventsTableView selectRowAtIndexPath:self.eventsTableViewIndexPathOfSelectedRowPreserved animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    if (self.scrollViewContentOffsetInfoIsPreserved) {
        CGFloat contentOffsetY = self.scrollView.contentSize.height - self.scrollView.frame.size.height - self.scrollViewContentOffsetHeightLeftUntilEndPreserved;
        contentOffsetY = MAX(contentOffsetY, 0);
        [self.scrollView setContentOffset:CGPointMake(0, contentOffsetY)];
    }
    self.scrollViewContentOffsetInfoIsPreserved = NO;
//    if (self.venue && self.imageView.image == nil && !self.isGettingImage) {
//        [self updateImageFromVenue:self.venue animated:YES];
//    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.deletedFromEventCard) {
        NSLog(@"VenueViewController - The learned behavior of the delete was sent to the server, but the deletion is not going to be observed in this view controller.");
//        Event * eventToDelete = [self.events objectAtIndex:self.eventsTableViewIndexPathOfSelectedRowPreserved.row];
//        [self.coreDataModel deleteRegularEventForURI:eventToDelete.uri];
//        [self.events removeObjectAtIndex:self.eventsTableViewIndexPathOfSelectedRowPreserved.row];
//        [self.eventsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.eventsTableViewIndexPathOfSelectedRowPreserved] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.eventsTableView deselectRowAtIndexPath:self.eventsTableViewIndexPathOfSelectedRowPreserved animated:YES];
    self.eventsTableViewIndexPathOfSelectedRowPreserved = nil;
    self.deletedFromEventCard = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CGFloat scrollViewContentOffsetHeightLeftUntilEnd = self.scrollView.contentSize.height - (self.scrollView.contentOffset.y + self.scrollView.frame.size.height);
    self.scrollViewContentOffsetHeightLeftUntilEndPreserved = scrollViewContentOffsetHeightLeftUntilEnd;
    self.scrollViewContentOffsetInfoIsPreserved = YES;
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.nameBar invalidateTimerAndScrollTextToOriginAnimated:NO];
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setLogoButton:nil];
    [self setFollowButton:nil];
    [self setNameBar:nil];
    [self setNavBarContainer:nil];
    [self setImageView:nil];
    [self setInfoContainer:nil];
    [self setDescriptionContainer:nil];
    [self setAddressLabel:nil];
    [self setCityStateZipLabel:nil];
    [self setPhoneNumberButton:nil];
    [self setMapButton:nil];
    [self setDescriptionLabel:nil];
    [self setEventsTableView:nil];
    [self setScrollView:nil];
    [self setMainContainer:nil];
    [self setMainContainerChainOfDependentlyPositionedViews:nil];
    [self setMapView:nil];
    [self setEventsHeaderView:nil];
    [self setEventsHeaderViewShadow:nil];
    [self setSwipeToGoBack:nil];
    [self setDescriptionReadMoreCoverView:nil];
    [self setDescriptionReadMoreButton:nil];
    [self setInfoContainerBackgroundView:nil];
    [self setInfoContainerShadowView:nil];
    [self setWebActivityView:nil];
    [connectionErrorStandardAlertView_ release];
    connectionErrorStandardAlertView_ = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [venue_ release];
    [userLocation_ release];
    [eventsTableViewIndexPathOfSelectedRowPreserved_ release];
    [webDataTranslator_ release];
    [webConnector_ release];
    [backButton_ release];
    [logoButton_ release];
    [followButton_ release];
    [nameBar_ release];
    [navBarContainer_ release];
    [imageView_ release];
    [infoContainer_ release];
    [descriptionContainer_ release];
    [addressLabel_ release];
    [cityStateZipLabel_ release];
    [phoneNumberButton_ release];
    [mapButton_ release];
    [descriptionLabel_ release];
    [eventsTableView_ release];
    [scrollView_ release];
    [mainContainer_ release];
    [mainContainerChainOfDependentlyPositionedViews_ release];
    [mapView_ release];
    [mapViewController_ release];
    [eventViewController_ release];
    [eventsHeaderView_ release];
    [eventsHeaderViewShadow_ release];
    [swipeToGoBack_ release];
    [descriptionReadMoreCoverView_ release];
    [descriptionReadMoreButton_ release];
    [infoContainerBackgroundView_ release];
    [infoContainerShadowView_ release];
    [eventsWebQuery_ release];
    [events_ release];
    [coreDataModel_ release];
    [webActivityView_ release];
    [connectionErrorStandardAlertView_ release];
    [super dealloc];
}

- (void)backButtonTouched:(UIButton *)button {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
}

- (void)logoButtonTouched:(UIButton *)button {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:YES];
}

- (void)followButtonTouched:(UIButton *)button {
    NSLog(@"followButtonTouched");
}

- (void)phoneNumberButtonTouched:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.venue.phone]]];
}

- (void)showMoreUpcomingEventsButtonTouched:(UIButton *)button {
    NSLog(@"showMoreUpcomingEventsButtonTouched");
}

- (void)eventsHeaderViewButtonTouched:(UIButton *)button {
    [self updateEventsWebQueryFromVenue:self.venue];
}

- (void)mapButtonTouched:(UIButton *)button {
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    self.mapViewController.delegate = self;
    self.mapViewController.locationLatitude = self.venue.latitude;
    self.mapViewController.locationLongitude = self.venue.longitude;
    self.mapViewController.locationName = self.venue.title;
    self.mapViewController.locationAddress = self.venue.address;
    [self presentModalViewController:self.mapViewController animated:YES];
}

- (void)mapViewControllerDidPushBackButton:(MapViewController *)mapViewController {
    [self dismissModalViewControllerAnimated:YES];
    self.mapViewController = nil;
}

- (BOOL) eventsWebQueryIsExecutedSuccessfullyRecentlyEnough:(EventsWebQuery *)eventsWebQuery {
    return (eventsWebQuery != nil &&
            eventsWebQuery.datetimeQueryExecuted &&
            abs(eventsWebQuery.datetimeQueryExecuted.timeIntervalSinceNow) < 5 * 60 &&
            eventsWebQuery.eventResults.count > 0);
}

- (void) updateEventsWebQueryFromVenue:(Place *)venue {
    EventsWebQuery * webQueryForVenue = [self.coreDataModel getMostRecentEventsWebQueryForVenue:self.venue];
    if ([self eventsWebQueryIsExecutedSuccessfullyRecentlyEnough:webQueryForVenue]) {
        self.appropriateMessageType = UpcomingEventsLoaded;
        self.eventsWebQuery = webQueryForVenue;
        self.events = [self.eventsWebQuery.eventResultsEventsInOrder.mutableCopy autorelease];
    } else {
        self.appropriateMessageType = UpcomingEventsLoading;
        self.events = nil;
        self.isGettingEvents = YES;
        [self updateNetworkActivityIndicator];
        EventsWebQuery * eventsWebQuery = [NSEntityDescription insertNewObjectForEntityForName:@"EventsWebQuery" inManagedObjectContext:self.coreDataModel.managedObjectContext];
        self.eventsWebQuery = eventsWebQuery;
        self.eventsWebQuery.queryType = [NSNumber numberWithInt:VenueQuery];
        self.eventsWebQuery.datetimeQueryCreated = [NSDate date];
        self.eventsWebQuery.filterVenue = self.venue;
        [self.coreDataModel coreDataSave];
        [self.webConnector getEventsListForVenueURI:self.venue.uri];
    }
}

- (void) updateUpcomingEventsAnimated:(BOOL)animated {
    
    [self.eventsHeaderView setMessageToShowMessageType:self.appropriateMessageType animated:animated];
    
    BOOL showEventsTable = self.events && self.events.count > 0;
    NSUInteger eventsCount = self.events == nil ? 0 : [self tableView:self.eventsTableView numberOfRowsDisplayedInSection:0];
    
    void(^eventsTableHeightBlock)(int, BOOL) = ^(int eventsCount, BOOL shouldMaintainMaxY){
        CGRect eventsTableViewFrame = self.eventsTableView.frame;
        CGFloat eventsTableViewPreviousHeight = eventsTableViewFrame.size.height;
        eventsTableViewFrame.size.height = eventsCount * self.eventsTableView.rowHeight + [self tableView:self.eventsTableView heightForFooterInSection:0];
        if (shouldMaintainMaxY) {
            eventsTableViewFrame.origin.y -= eventsTableViewFrame.size.height - eventsTableViewPreviousHeight;
        }
        self.eventsTableView.frame = eventsTableViewFrame;
    };
    
    void(^eventsTableOriginBlock)(BOOL) = ^(BOOL showTable){
        CGRect eventsTableViewFrame = self.eventsTableView.frame;
        eventsTableViewFrame.origin.y = CGRectGetMaxY(self.eventsHeaderView.frame) - (showTable ? 0 : self.eventsTableView.frame.size.height);
        self.eventsTableView.frame = eventsTableViewFrame;
    };
    
    if (animated) {
        if (self.isEventsTableVisible) {
            if (showEventsTable) {
                [self.eventsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
                    eventsTableHeightBlock(eventsCount, NO);
                    [self updateMainContainerAndScrollViewSize];
                }];
            } else {
                eventsTableOriginBlock(showEventsTable);
                [self updateMainContainerAndScrollViewSize];
            }
        } else {
            eventsTableHeightBlock(eventsCount, YES);
            [self.eventsTableView reloadData];
            [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
                eventsTableOriginBlock(showEventsTable);
                [self updateMainContainerAndScrollViewSize];
            }];
        }
    } else {
        [self.eventsTableView reloadData];
        eventsTableHeightBlock(eventsCount, NO);
        eventsTableOriginBlock(showEventsTable);
        [self updateMainContainerAndScrollViewSize];
    }
    
}

//- (void) updateUpcomingEventsFromVenue:(Place *)venue animated:(BOOL)animated {
//    EventsWebQuery * webQuery = [self.coreDataModel getMostRecentEventsWebQueryForVenue:self.venue];
//    if (webQuery != nil && webQuery.datetimeQueryCreated != nil) {
//        if (webQuery.datetimeQueryExecuted && abs(webQuery.datetimeQueryExecuted.timeIntervalSinceNow) < 5 * 60) {
//            self.eventsWebQuery = webQuery;
//            // show/update the table
//        } else {
//            // wait for the 
//        }
//    } else {
//        // Make a new query
//        // Attempt the query
//    }
//}

- (void)webConnector:(WebConnector *)webConnector getEventsListSuccess:(ASIHTTPRequest *)request forVenueURI:(NSString *)venueURI {
    
    self.isGettingEvents = NO;
    [self updateNetworkActivityIndicator];
    
    self.eventsWebQuery.datetimeQueryExecuted = [NSDate date];
    
    NSError * error = nil;
    NSDictionary * dictionaryFromJSON = [request.responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    NSArray * eventSummaryDictionaries = [dictionaryFromJSON valueForKey:@"objects"];
    
    if (eventSummaryDictionaries && eventSummaryDictionaries.count > 0) {
        int order = 0;
        for (NSDictionary * eventSummaryDictionary in eventSummaryDictionaries) {
            Event * eventToUpdate = [self.coreDataModel getEventWithURI:[eventSummaryDictionary valueForKey:@"event"]];
            if (eventToUpdate == nil) {
                eventToUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            }
            [self.coreDataModel updateEvent:eventToUpdate usingEventSummaryDictionary:eventSummaryDictionary relativeToVenue:self.venue featuredOverride:nil fromSearchOverride:nil];
            EventResult * eventResult = [NSEntityDescription insertNewObjectForEntityForName:@"EventResult" inManagedObjectContext:self.coreDataModel.managedObjectContext];
            eventResult.order = [NSNumber numberWithInt:order];
            order++;
            eventResult.event = eventToUpdate;
            eventResult.query = self.eventsWebQuery;
        }
    }
    self.events = [self.eventsWebQuery.eventResultsEventsInOrder.mutableCopy autorelease];
    
    self.appropriateMessageType = self.events.count > 0 ? UpcomingEventsLoaded : UpcomingEventsNoEvents;
    
    if (self.view.window) {
        [self updateUpcomingEventsAnimated:YES];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventsListFailure:(ASIHTTPRequest *)request forVenueURI:(NSString *)venueURI {

    self.isGettingEvents = NO;
    [self updateNetworkActivityIndicator];
    
    self.eventsWebQuery.datetimeQueryExecuted = [NSDate date];
    self.events = nil;
    
    self.appropriateMessageType = UpcomingEventsConnectionError;
    
    if (self.view.window) {
        [self updateUpcomingEventsAnimated:YES];
    }
    
}

- (void) setVenue:(Place *)venue {
    if (venue_ != venue) {
        // Set the venue variable
        [venue_ release];
        venue_ = [venue retain];
        // Get and check out the associated web query
        [self updateEventsWebQueryFromVenue:self.venue]; // This also updates the property self.events, so we can use that later in this method if we want (which we do).
        if (self.view.window) {
            // Info & Description
            [self updateInfoViewsFromVenue:self.venue animated:YES];
            [self updateDescriptionTextFromVenue:self.venue animated:YES];
            if (self.venue.coordinateAvailable) {
                [self updateMapViewToCenterOnCoordinate:self.venue.coordinate animated:YES];
            }
            // Image
            [self updateImageFromVenue:self.venue animated:YES];
            // Upcoming events
            [self updateUpcomingEventsAnimated:YES];
        }
    }
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator_ == nil) {
        webDataTranslator_ = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator_;
}

- (WebConnector *) webConnector {
    if (webConnector_ == nil) {
        webConnector_ = [[WebConnector alloc] init];
        webConnector_.delegate = self;
    }
    return webConnector_;
}


- (void)updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated {
    
    void(^infoViewsWidthsBlock)(NSString *, NSString *, NSString *) = ^(NSString * addressText, NSString * cityStateZipText, NSString * phoneText){
        // Set up
        CGFloat mapViewMaxAllowableOriginX = 207; // HARD-CODED VALUE
        CGFloat mapViewPaddingLeft = 10; // HARD-CODED MAP VIEW PADDING VALUE
        CGFloat mapViewPaddingRight = 5; // HARD-CODED MAP VIEW PADDING VALUE
        CGFloat labelsRightmostAllowableX = mapViewMaxAllowableOriginX - mapViewPaddingLeft;
        CGFloat phoneTouchPaddingRight = mapViewPaddingLeft;
        // Calculating text sizes
        CGSize addressTextSize = [addressText sizeWithFont:self.addressLabel.font];
        CGSize cityStateZipTextSize = [cityStateZipText sizeWithFont:self.cityStateZipLabel.font];
        CGSize phoneTextSize = [phoneText sizeWithFont:self.phoneNumberButton.titleLabel.font];
        // Address lines
        CGRect addressLabelFrame = self.addressLabel.frame;
        CGRect cityStateZipLabelFrame = self.cityStateZipLabel.frame;
        addressLabelFrame.size.width = MIN(addressTextSize.width, labelsRightmostAllowableX - addressLabelFrame.origin.x);
        cityStateZipLabelFrame.size.width = MIN(cityStateZipTextSize.width, labelsRightmostAllowableX - cityStateZipLabelFrame.origin.x);
        self.addressLabel.frame = addressLabelFrame;
        self.cityStateZipLabel.frame = cityStateZipLabelFrame;
        // Phone
        CGRect phoneNumberButtonFrame = self.phoneNumberButton.frame;
        phoneNumberButtonFrame.size.width = MIN(phoneTextSize.width + self.phoneNumberButton.contentEdgeInsets.left, labelsRightmostAllowableX - phoneNumberButtonFrame.origin.x) + phoneTouchPaddingRight;
        self.phoneNumberButton.frame = phoneNumberButtonFrame;
        // Map view
        CGRect mapViewFrame = self.mapView.frame;
        mapViewFrame.origin.x = MAX(MAX(CGRectGetMaxX(addressLabelFrame), CGRectGetMaxX(cityStateZipLabelFrame)), CGRectGetMaxX(phoneNumberButtonFrame) - phoneTouchPaddingRight) + mapViewPaddingLeft;
        mapViewFrame.size.width = self.infoContainer.frame.size.width - mapViewPaddingRight - mapViewFrame.origin.x;
        self.mapView.frame = mapViewFrame;
    };
    
    NSString * nameText = @"";
    NSString * addressText = @"";
    NSString * cityStateZipText = @"";
    NSString * phoneText = @"";

    BOOL phoneAvailable = venue && venue.phone && venue.phone.length > 0;
    BOOL locationAvailable = venue && venue.latitude && venue.longitude;
    if (venue != nil) {
        nameText = venue.title;
        addressText = venue.address;
        cityStateZipText = [self.webDataTranslator addressSecondLineStringFromCity:venue.city state:venue.state zip:venue.zip];
        phoneText = phoneAvailable ? venue.phone : @"Phone number not available";
    }
    
    self.nameBar.text = nameText;
    self.addressLabel.text = addressText;
    self.cityStateZipLabel.text = cityStateZipText;
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateNormal];
    [self.phoneNumberButton setTitle:phoneText forState:UIControlStateHighlighted];
    self.phoneNumberButton.enabled = phoneAvailable;
    self.mapButton.enabled = locationAvailable;
    
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
        }];
    } else {
        infoViewsWidthsBlock(addressText, cityStateZipText, phoneText);
    }

}


- (void) updateDescriptionTextFromVenue:(Place *)venue animated:(BOOL)animated {
    
    NSString * descriptionText = @"";
    if (venue != nil) {
        descriptionText = venue.placeDescription;
    }
    self.descriptionLabel.text = descriptionText;
    
    CGFloat descriptionContainerCurrentHeight = self.descriptionContainer.frame.size.height;
    CGFloat descriptionContainerNeededHeight = 0;
    CGSize descriptionLabelTextSize = CGSizeMake(self.descriptionLabel.frame.size.width, 0);
    CGFloat descriptionLabelVerticalPadding = self.descriptionLabel.frame.origin.y;
    if (self.descriptionLabel.text.length > 0) {
        descriptionLabelTextSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
        descriptionContainerNeededHeight = descriptionLabelTextSize.height + 2 * descriptionLabelVerticalPadding;
    }
    
    void(^descriptionLabelHeightAdjustmentBlock)(CGFloat) = ^(CGFloat givenHeight){
        CGRect descriptionLabelFrame = self.descriptionLabel.frame;
        descriptionLabelFrame.size.height = givenHeight;
        self.descriptionLabel.frame = descriptionLabelFrame;
    };
    
    if (descriptionContainerNeededHeight <= descriptionContainerCurrentHeight) {
        
        [self updateDescriptionContainerSizeToFitLabelAfterExpansion:YES animated:animated];
        
    } else {
        
        NSLog(@"Description label text is longer than the description container can currently handle.");
        NSLog(@"Description label text needs container of %f pixels, description container is currently %f pixels.", descriptionContainerNeededHeight, descriptionContainerCurrentHeight);
        
        void(^roundedDescriptionLabelHeightAdjustmentBlock)(void) = ^{
            CGFloat lineHeight = self.descriptionLabel.font.lineHeight;
            CGFloat numberOfLinesThatFit = floorf((descriptionContainerCurrentHeight - 2 * descriptionLabelVerticalPadding) / lineHeight);
            NSLog(@"Line height is %f, and the number of lines that fit in the current container is %f.", lineHeight, numberOfLinesThatFit);
            descriptionLabelHeightAdjustmentBlock(numberOfLinesThatFit * lineHeight);
        };
        
        if (animated) {
            [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
                roundedDescriptionLabelHeightAdjustmentBlock();
            }];
        } else {
            roundedDescriptionLabelHeightAdjustmentBlock();
        }
        [self updateDescriptionContainerSizeToFitLabelAfterExpansion:NO animated:animated];
        
    }

}

- (void) updateDescriptionContainerSizeToFitLabelAfterExpansion:(BOOL)shouldExpandLabel animated:(BOOL)animated {
    
    void(^descriptionLabelExpandBlock)(void) = ^{
        NSLog(@"descriptionLabelExpandBlock");
        NSLog(@"%@", self.descriptionLabel.text);
        [self.descriptionLabel setNeedsDisplay];
        CGSize descriptionLabelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
        CGRect descriptionLabelFrame = self.descriptionLabel.frame;
        descriptionLabelFrame.size = descriptionLabelSize;
        self.descriptionLabel.frame = descriptionLabelFrame;
        NSLog(@"%@", NSStringFromCGRect(self.descriptionLabel.frame));
    };
    
    void(^descriptionContainerFitBlock)(void) = ^{
        NSLog(@"descriptionContainerFitBlock");
        CGFloat descriptionContainerHeight = 0;
        if (self.descriptionLabel.frame.size.height > 0) {
            CGFloat descriptionLabelVerticalPadding = self.descriptionLabel.frame.origin.y;
            descriptionContainerHeight = CGRectGetMaxY(self.descriptionLabel.frame) + descriptionLabelVerticalPadding;            
        }
        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
        descriptionContainerFrame.size.height = descriptionContainerHeight;
        self.descriptionContainer.frame = descriptionContainerFrame;
        NSLog(@"%@", NSStringFromCGRect(self.descriptionContainer.frame));
    };
    
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            if (shouldExpandLabel) { descriptionLabelExpandBlock(); }
            descriptionContainerFitBlock();
            [self updateViewsOriginsDependentlyPositionedOnView:self.infoContainer];
        }];
    } else {
        if (shouldExpandLabel) { descriptionLabelExpandBlock(); }
        descriptionContainerFitBlock();
        [self updateViewsOriginsDependentlyPositionedOnView:self.infoContainer];
    }
    [self setDescriptionReadMoreIsVisible:!shouldExpandLabel animated:animated];
    
}

- (void) setDescriptionReadMoreIsVisible:(BOOL)isVisible animated:(BOOL)animated {
    CGFloat alpha = isVisible ? 1.0 : 0.0;
    void(^alphaBlock)(CGFloat) = ^(CGFloat alpha){
        self.descriptionReadMoreButton.alpha = alpha;
        self.descriptionReadMoreCoverView.alpha = alpha;
    };
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            alphaBlock(alpha);
            self.descriptionReadMoreButton.userInteractionEnabled = isVisible;
        }];
    } else {
        alphaBlock(alpha);
        self.descriptionReadMoreButton.userInteractionEnabled = isVisible;        
    }
}

- (void) updateMapViewToCenterOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(coordinate.latitude + .00055, coordinate.longitude), 200, 200) animated:animated];
    EventLocationAnnotation * venueLocationAnnotation = [[EventLocationAnnotation alloc] initWithName:@"" address:@"" coordinate:coordinate];
    [self.mapView addAnnotation:venueLocationAnnotation];
    [venueLocationAnnotation release];
}

- (void) updateNetworkActivityIndicator {
    NSLog(@"updateNetworkActivityIndicator start");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = self.isGettingWebData || self.webConnector.connectionInProgress;
    NSLog(@"updateNetworkActivityIndicator end");
}

// Venue image not yet available / implemented. Need to add an imageLocation attribute the Place object, and pull in that file location from the server. UPDATE: Done!
- (void) updateImageFromVenue:(Place *)venue animated:(BOOL)animated {
    NSLog(@"updateImageFromVenue:");
//    self.imageView.image = [UIImage imageNamed:@"event_img_placeholder.png"];
//    [self.imageView setImageWithURL:[URLBuilder imageURLForImageLocation:self.venue.imageLocation] placeholderImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
    if (self.venue.imageLocation) {
        NSURL * imageURL = [URLBuilder imageURLForImageLocation:self.venue.imageLocation];
        SDWebImageManager * webImageManager = [SDWebImageManager sharedManager];
        UIImage * cachedImage = [webImageManager imageWithURL:imageURL];
        if (cachedImage) {
            [self showImageViewWithImage:cachedImage animated:animated];
        } else {
            self.isGettingImage = YES;
            [self updateNetworkActivityIndicator];
            [webImageManager downloadWithURL:imageURL delegate:self];
        }
    }
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    NSLog(@"webImageManager:didFinishWithImage:");
    self.isGettingImage = NO;
    [self updateNetworkActivityIndicator];
    [self showImageViewWithImage:image animated:(self.view.window != nil)];
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    NSLog(@"webImageManager:didFailWithError:");
    // Do nothing, really... Just chill, sans image in the venue card. Maybe ensure that the image view is hidden.
    self.isGettingImage = NO;
    [self updateNetworkActivityIndicator];
    [self setImageViewIsVisible:NO animated:(self.view.window != nil)];
}

- (void) showImageViewWithImage:(UIImage *)image animated:(BOOL)animated {
    NSLog(@"showImageViewWithImage:");
    self.imageView.image = image;
    [self setImageViewIsVisible:YES animated:animated];
}

- (void)setImageViewIsVisible:(BOOL)visible animated:(BOOL)animated {
    NSLog(@"setImageViewIsVisible:%d", visible);
    void(^imageViewSizeBlock)(BOOL)=^(BOOL makeVisible){
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.size.height = makeVisible ? imageViewNormalHeight : 0;
        self.imageView.frame = imageViewFrame;
    };
    if (animated) {
        [UIView animateWithDuration:VVC_ANIMATION_DURATION animations:^{
            imageViewSizeBlock(visible);
            [self updateViewsOriginsDependentlyPositionedOnView:self.imageView];
        }];
    } else {
        imageViewSizeBlock(visible);
        [self updateViewsOriginsDependentlyPositionedOnView:self.imageView];
    }
}

- (void) updateViewOrigin:(UIView *)theView {
    if (theView == self.nameBar) {
        CGRect nameBarFrame = self.nameBar.frame;
        nameBarFrame.origin.y = MAX(0, self.scrollView.contentOffset.y);
        self.nameBar.frame = nameBarFrame;
    } else if (theView == self.imageView) {
        // No action necessary
    } else if (theView == self.infoContainer) {
        CGRect infoContainerFrame = self.infoContainer.frame;
        infoContainerFrame.origin.y = MAX(CGRectGetMaxY(self.nameBar.frame), CGRectGetMaxY(self.imageView.frame));
        self.infoContainer.frame = infoContainerFrame;
    } else if (theView == self.descriptionContainer) {
        CGRect descriptionContainerFrame = self.descriptionContainer.frame;
        descriptionContainerFrame.origin.y = CGRectGetMaxY(self.imageView.frame) + self.infoContainer.frame.size.height;
        self.descriptionContainer.frame = descriptionContainerFrame;
    } else if (theView == self.eventsHeaderView) {
        CGRect eventsHeaderViewFrame = self.eventsHeaderView.frame;
        eventsHeaderViewFrame.origin.y = MAX(CGRectGetMaxY(self.descriptionContainer.frame), CGRectGetMaxY(self.infoContainer.frame));
        self.eventsHeaderView.frame = eventsHeaderViewFrame;
        CGRect eventsHeaderViewShadowFrame = self.eventsHeaderViewShadow.frame;
        eventsHeaderViewShadowFrame.origin.y = self.eventsHeaderView.frame.origin.y + 1;
        self.eventsHeaderViewShadow.frame = eventsHeaderViewShadowFrame;
    } else if (theView == self.eventsTableView) {
        CGRect eventsTableViewFrame = self.eventsTableView.frame;
        eventsTableViewFrame.origin.y = CGRectGetMaxY(self.descriptionContainer.frame) + self.eventsHeaderView.frame.size.height;
        self.eventsTableView.frame = eventsTableViewFrame;
    } else {
        NSLog(@"ERROR in VenueViewController updateViewOrigin - unrecognized / unsupported view %@", theView);
    }
}

- (void) updateMainContainerAndScrollViewSize {
    CGRect mainContainerFrame = self.mainContainer.frame;
    mainContainerFrame.size.height = CGRectGetMaxY(self.eventsTableView.frame);
    self.mainContainer.frame = mainContainerFrame;
    self.scrollView.contentSize = self.mainContainer.frame.size;
    // The following results in more realistic / tactile / physical behavior, but perhaps more annoying behavior as well. (It makes it so that if the content of the scroll view is smaller than the size of the scroll view itself, you can only scroll that content if you actually touch it with your finger, rather than touch anywhere on the screen.) Leaving it out for now...
    /*
    self.scrollView.clipsToBounds = NO;
    CGFloat fullPossibleScrollViewHeight = self.view.frame.size.height - self.navBarContainer.frame.size.height;
    CGRect scrollViewFrame = self.scrollView.frame;
    if (self.scrollView.contentSize.height < fullPossibleScrollViewHeight) {
        scrollViewFrame.size = self.scrollView.contentSize;
    } else {
        scrollViewFrame.size = CGSizeMake(self.scrollView.frame.size.width, fullPossibleScrollViewHeight);
    }
    self.scrollView.frame = scrollViewFrame;
     */
}

- (void) updateViewOrigin:(UIView *)theView andUpdateDependentlyPositionedViews:(BOOL)shouldUpdateDependentlyPositionedViews {
    
    [self updateViewOrigin:theView];
    if (shouldUpdateDependentlyPositionedViews) {
        [self updateViewsOriginsDependentlyPositionedOnView:theView];
    }
    
}

- (void)updateViewsOriginsDependentlyPositionedOnView:(UIView *)rootView {
    NSUInteger index = [self.mainContainerChainOfDependentlyPositionedViews indexOfObject:rootView];
    if (index == self.mainContainerChainOfDependentlyPositionedViews.count - 1) {
        [self updateMainContainerAndScrollViewSize];
    } else {
        UIView * nextView = [self.mainContainerChainOfDependentlyPositionedViews objectAtIndex:(index + 1)];
        [self updateViewOrigin:nextView andUpdateDependentlyPositionedViews:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self updateViewOrigin:self.nameBar andUpdateDependentlyPositionedViews:NO];
        [self updateViewOrigin:self.infoContainer andUpdateDependentlyPositionedViews:NO];
        [self updateViewOrigin:self.eventsHeaderView andUpdateDependentlyPositionedViews:NO];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton * showMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showMoreButton addTarget:self action:@selector(showMoreUpcomingEventsButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    showMoreButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:18];
    [showMoreButton setTitle:@"More Upcoming Events" forState:UIControlStateNormal];
    [showMoreButton setTitle:@"More Upcoming Events" forState:UIControlStateHighlighted];
    [showMoreButton setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [showMoreButton setTitleColor:[UIColor colorWithWhite:53.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    showMoreButton.backgroundColor = [UIColor colorWithWhite:241.0/255.0 alpha:1.0];
    return showMoreButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self shouldShowMoreEventsButtonForEvents:self.events] ? 40 : 0;
}

- (BOOL) shouldShowMoreEventsButtonForEvents:(NSArray *)events {
    return events.count > VVC_MAXIMUM_NUMBER_OF_ROWS_FOR_UPCOMING_EVENTS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
//    return MIN(VVC_MAXIMUM_NUMBER_OF_ROWS_FOR_UPCOMING_EVENTS, self.events.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsDisplayedInSection:(NSInteger)section {
    return MIN(VVC_MAXIMUM_NUMBER_OF_ROWS_FOR_UPCOMING_EVENTS, [self tableView:tableView numberOfRowsInSection:section]);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"VenueViewController cellForRowAtIndexPath:%@", indexPath);
    
    static NSString * CellIdentifier = @"EventCellGeneral";
    
    EventTableViewCell * cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.shouldShowVenue = NO;
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event * event = (Event *)[self.events objectAtIndex:indexPath.row];
    
    // Title
    cell.titleLabel.text = event.title;
    // Category color & icon
    Category * concreteParentCategory = event.concreteParentCategory;
    cell.categoryColor = [WebUtil colorFromHexString:concreteParentCategory.colorHex];
    cell.categoryIcon = [UIImage imageNamed:[concreteParentCategory.iconThumb stringByReplacingOccurrencesOfString:@".png" withString:@"_big.png"]];
    cell.categoryIconHorizontalOffset = concreteParentCategory.iconBigHorizontalOffset.floatValue;
    // Event summary
    EventSummary * eventSummary = [event eventSummaryRelativeToVenue:self.venue];
    // Date & Time
    NSString * dateToDisplay = [self.webDataTranslator eventsListDateRangeStringFromEventDateEarliest:eventSummary.startDateEarliest eventDateLatest:eventSummary.startDateLatest eventDateCount:eventSummary.startDateCount relativeDates:YES dataUnavailableString:nil];
    NSString * timeToDisplay = [self.webDataTranslator eventsListTimeRangeStringFromEventTimeEarliest:eventSummary.startTimeEarliest eventTimeLatest:eventSummary.startTimeLatest eventTimeCount:eventSummary.startTimeCount dataUnavailableString:nil];
    NSString * divider = eventSummary.startDateEarliest && eventSummary.startTimeEarliest ? @" | " : @"";
    NSString * finalDatetimeString = [NSString stringWithFormat:@"%@%@%@", dateToDisplay, divider, timeToDisplay];
    cell.dateAndTimeLabel.text = finalDatetimeString;
    // Price
    NSString * priceRange = [self.webDataTranslator priceRangeStringFromMinPrice:eventSummary.priceMinimum maxPrice:eventSummary.priceMaximum separatorString:nil dataUnavailableString:nil];
    cell.priceOriginalLabel.text = priceRange;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event * event = (Event *)[self.events objectAtIndex:indexPath.row];
    
    BOOL movingBackwards = self.eventViewControllerSourceOfReferral != nil && self.eventViewControllerSourceOfReferral.event == event;
    
    if (!movingBackwards) {
        
        self.eventsTableViewIndexPathOfSelectedRowPreserved = indexPath;
        
        self.eventViewController = [[[EventViewController alloc] initWithNibName:@"EventViewController" bundle:[NSBundle mainBundle]] autorelease];
        self.eventViewController.coreDataModel = self.coreDataModel;
        self.eventViewController.delegate = self;
        self.eventViewController.userLocation = self.userLocation;
        self.eventViewController.venueViewControllerSourceOfReferral = self;
        
    }

    [self.webConnector sendLearnedDataAboutEvent:event.uri withUserAction:@"V"]; // Attempt to send the learning to our server.
    
    if (!movingBackwards) {
        [self.webConnector getEventWithURI:event.uri]; // Attempt to get the full event info
        [self showWebLoadingViews];
    } else {
        [self.delegate viewController:self didFinishByRequestingJumpBackToViewController:self.eventViewControllerSourceOfReferral];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataSuccess:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    if ([userAction isEqualToString:@"V"] && self.eventViewController) {
        
        NSLog(@"VenueViewController successfully sent 'view' learning to server for event with URI %@.", eventURI);
        
    }
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector sendLearnedDataFailure:(ASIHTTPRequest *)request aboutEvent:(NSString *)eventURI userAction:(NSString *)userAction {
    
    // Display an internet connection error message
    if ([userAction isEqualToString:@"V"] && self.eventViewController) {
        
        NSLog(@"EventsViewController failed to send 'view' learning to server for event with URI %@. We should be remembering this, and trying to send the learning again later! This is crucial!", eventURI);
        
    }
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventSuccess:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
    NSString * responseString = [request responseString];
    NSError *error = nil;
    NSDictionary * eventDictionary = [responseString yajl_JSONWithOptions:YAJLParserOptionsAllowComments error:&error];
    
    Event * event = [self.events objectAtIndex:self.eventsTableViewIndexPathOfSelectedRowPreserved.row];
    
    [self.coreDataModel updateEvent:event usingEventDictionary:eventDictionary featuredOverride:nil fromSearchOverride:nil];
    
    self.eventViewController.event = event;
    [self.navigationController pushViewController:self.eventViewController animated:YES];
    self.deletedFromEventCard = NO;
    
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)webConnector:(WebConnector *)webConnector getEventFailure:(ASIHTTPRequest *)request forEventURI:(NSString *)eventURI {
    
    [self.connectionErrorStandardAlertView show];
    if (!self.webConnector.connectionInProgress) {
        [self hideWebLoadingViews];
    }
    
}

- (void)viewController:(UIViewController *)viewController didFinishByRequestingStackCollapse:(BOOL)didRequestStackCollapse {
    if (didRequestStackCollapse) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }   
}

- (void)viewController:(UIViewController *)viewController didFinishByRequestingJumpBackToViewController:(UIViewController *)viewControllerToJumpTo {
        [self.navigationController popToViewController:viewControllerToJumpTo animated:YES]; // No safety checks... Trusting.
}

- (void) eventViewController:(EventViewController *)eventViewController didFinishByRequestingEventDeletionForEventURI:(NSString *)eventURI {
    self.deletedFromEventCard = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    if (gestureRecognizer == self.swipeToGoBack) {
        if ([touch.view isDescendantOfView:self.nameBar]) {
            shouldReceive = NO;
        }
    }
    return shouldReceive;
}

- (void)swipedToGoBack:(UISwipeGestureRecognizer *)swipeGesture {
    [self.delegate viewController:self didFinishByRequestingStackCollapse:NO];
}

- (IBAction)descriptionReadMoreButtonTouched:(UIButton *)button {
    [self updateDescriptionContainerSizeToFitLabelAfterExpansion:YES animated:YES];
}

- (BOOL)isGettingWebData {
    return self.isGettingEvents || self.isGettingImage;
}

- (BOOL)isEventsTableVisible {
    return self.eventsTableView.frame.origin.y > CGRectGetMaxY(self.eventsHeaderView.frame) && self.eventsTableView.frame.size.height > 0;
}

-(void) showWebLoadingViews  {
    // ACTIVITY VIEWS
    [self.view bringSubviewToFront:self.webActivityView];
    [self.webActivityView showAnimated:YES];
    [self updateNetworkActivityIndicator];
    // USER INTERACTION
    self.scrollView.userInteractionEnabled = NO;
    self.followButton.userInteractionEnabled = NO;
}

-(void)hideWebLoadingViews  {
    // ACTIVITY VIEWS
    [self.webActivityView hideAnimated:NO];
    [self updateNetworkActivityIndicator];
    // USER INTERACTION
    self.scrollView.userInteractionEnabled = YES;
    self.followButton.userInteractionEnabled = YES;
}

- (UIAlertView *)connectionErrorStandardAlertView {
    if (connectionErrorStandardAlertView_ == nil) {
        connectionErrorStandardAlertView_ = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:WEB_CONNECTION_ERROR_MESSAGE_STANDARD delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return connectionErrorStandardAlertView_;
}

@end
