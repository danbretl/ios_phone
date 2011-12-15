//
//  VenueViewController.m
//  kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VenueViewController.h"
#import "UIImageView+WebCache.h"
#import "URLBuilder.h"
#import "UIFont+Kwiqet.h"
#import "EventTableViewCell.h"

@interface VenueViewController()

@property (readonly, nonatomic) WebDataTranslator * webDataTranslator;

@property (retain, nonatomic) IBOutlet UIView * navBarContainer;
@property (retain, nonatomic) IBOutlet UIButton * backButton;
@property (retain, nonatomic) IBOutlet UIButton * logoButton;
@property (retain, nonatomic) IBOutlet UIButton * followButton;

@property (retain, nonatomic) IBOutlet UIView * mainContainer;
@property (retain, nonatomic) IBOutlet ElasticUILabel * nameBar;
@property (retain, nonatomic) IBOutlet UIImageView * imageView;
@property (retain, nonatomic) IBOutlet UIView * infoContainer;
@property (retain, nonatomic) IBOutlet UILabel * addressLabel;
@property (retain, nonatomic) IBOutlet UILabel * cityStateZipLabel;
@property (retain, nonatomic) IBOutlet UIButton * phoneNumberButton;
@property (retain, nonatomic) IBOutlet UIButton * mapButton;
@property (retain, nonatomic) IBOutlet UIView * descriptionContainer;
@property (retain, nonatomic) IBOutlet UILabel * descriptionLabel;

@property (retain, nonatomic) IBOutlet UITableView * eventsTableView;

- (IBAction)backButtonTouched:(UIButton *)button;
- (IBAction)logoButtonTouched:(UIButton *)button;
- (IBAction)followButtonTouched:(UIButton *)button;
- (IBAction)phoneNumberButtonTouched:(UIButton *)button;
- (IBAction)mapButtonTouched:(UIButton *)button;

- (void) updateImageFromVenue:(Place *)venue;
- (void) updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated;
- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation VenueViewController
@synthesize mainContainer;
@synthesize delegate;
@synthesize venue=venue_;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    // Main view
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_dark_gray.jpg"]];
    
    // Table header view
    self.eventsTableView.backgroundColor = [UIColor clearColor];
    self.eventsTableView.tableHeaderView = self.mainContainer;
    
    // Nav bar views
    self.navBarContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]];
    
    // Venue info views
    self.addressLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.cityStateZipLabel.font = [UIFont kwiqetFontOfType:RegularCondensed size:14];
    self.phoneNumberButton.titleLabel.font = [UIFont kwiqetFontOfType:BoldCondensed size:12];
    
    
    if (self.venue) {
        [self updateInfoViewsFromVenue:self.venue animated:NO];
        [self updateImageFromVenue:self.venue];
    }
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
    [self setMainContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [venue_ release];
    [webDataTranslator_ release];
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
    [mainContainer release];
    [super dealloc];
}

- (void)backButtonTouched:(UIButton *)button {
    [self.delegate venueViewControllerDidFinish:self];
}

- (void)logoButtonTouched:(UIButton *)button {
    [self.delegate venueViewControllerDidRequestStackCollapse:self];
}

- (void)followButtonTouched:(UIButton *)button {
    NSLog(@"followButtonTouched");
}

- (void)phoneNumberButtonTouched:(UIButton *)button {
    NSLog(@"phoneNumberButtonTouched");
}

- (void)mapButtonTouched:(UIButton *)button {
    NSLog(@"mapButtonTouched");
}

- (void) setVenue:(Place *)venue {
    if (venue_ != venue) {
        [venue_ release];
        venue_ = [venue retain];
        if (self.view.window) {
            [self updateInfoViewsFromVenue:self.venue animated:YES];
            [self updateImageFromVenue:self.venue];
        }
    }
}

- (WebDataTranslator *)webDataTranslator {
    if (webDataTranslator_ == nil) {
        webDataTranslator_ = [[WebDataTranslator alloc] init];
    }
    return webDataTranslator_;
}

- (void)updateInfoViewsFromVenue:(Place *)venue animated:(BOOL)animated {
    NSString * descriptionText = @"";
    if (!venue) {
        self.nameBar.text = @"";
        self.addressLabel.text = @"";
        self.cityStateZipLabel.text = @"";
        [self.phoneNumberButton setTitle:@"" forState:UIControlStateNormal];
        [self.phoneNumberButton setTitle:@"" forState:UIControlStateHighlighted];
        self.phoneNumberButton.enabled = venue.phone && venue.phone.length > 0;
        self.mapButton.enabled = venue.latitude && venue.longitude;
    } else {
        self.nameBar.text = venue.title;
        self.addressLabel.text = venue.address;
        self.cityStateZipLabel.text = [self.webDataTranslator addressSecondLineStringFromCity:venue.city state:venue.state zip:venue.zip];
        BOOL phoneNumberAvailable = venue.phone && venue.phone.length > 0;
        NSString * phoneString = phoneNumberAvailable ? venue.phone : @"Phone number not available";
        [self.phoneNumberButton setTitle:phoneString forState:UIControlStateNormal];
        [self.phoneNumberButton setTitle:phoneString forState:UIControlStateHighlighted];
        self.phoneNumberButton.enabled = phoneNumberAvailable;
        self.mapButton.enabled = venue.latitude && venue.longitude;
        descriptionText = venue.placeDescription;
    }
    void(^descriptionLabelSizeBlock)(NSString *) = ^(NSString * descriptionText){
        if (descriptionText && descriptionText.length > 0) {
            CGSize descriptionLabelSize = [descriptionText sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 3000) lineBreakMode:self.descriptionLabel.lineBreakMode];
            CGRect descriptionLabelFrame = self.descriptionLabel.frame;
            descriptionLabelFrame.size = descriptionLabelSize;
            self.descriptionLabel.frame = descriptionLabelFrame;
            CGRect descriptionContainerFrame = self.descriptionContainer.frame;
            descriptionContainerFrame.size.height = self.descriptionLabel.frame.size.height + 2 * self.descriptionLabel.frame.origin.y;
            self.descriptionContainer.frame = descriptionContainerFrame;
        } else {
            CGRect descriptionContainerFrame = self.descriptionContainer.frame;
            descriptionContainerFrame.size.height = 0;
            self.descriptionContainer.frame = descriptionContainerFrame;
        }
        CGRect mainContainerFrame = self.mainContainer.frame;
        mainContainerFrame.size.height = CGRectGetMaxY(self.descriptionContainer.frame);
        self.mainContainer.frame = mainContainerFrame;
        [self.eventsTableView beginUpdates];
        self.eventsTableView.tableHeaderView = self.mainContainer;
        [self.eventsTableView endUpdates];
//        UIEdgeInsets eventsTableViewInsets = self.eventsTableView.contentInset;
//        eventsTableViewInsets.top = CGRectGetMaxY(self.descriptionContainer.frame) - self.eventsTableView.frame.origin.y;
//        self.eventsTableView.contentInset = eventsTableViewInsets;
//        self.eventsTableView.scrollIndicatorInsets = eventsTableViewInsets;
    };
    self.descriptionLabel.text = descriptionText;
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            descriptionLabelSizeBlock(descriptionText);
        }];
    } else {
        self.descriptionLabel.text = descriptionText;
        descriptionLabelSizeBlock(descriptionText);
    }
}

// Venue image not yet available / implemented. Need to add an imageLocation attribute the Place object, and pull in that file location from the server.
- (void)updateImageFromVenue:(Place *)venue {
    self.imageView.image = [UIImage imageNamed:@"event_img_placeholder.png"];
//    [self.imageView setImageWithURL:[URLBuilder imageURLForImageLocation:self.event.imageLocation] placeholderImage:[UIImage imageNamed:@"event_img_placeholder.png"]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.eventsTableView) {
        CGRect nameBarFrame = self.nameBar.frame;
        if (self.eventsTableView.contentOffset.y >= 0) {
            nameBarFrame.origin.y = self.eventsTableView.contentOffset.y;
            CGFloat infoContainerOriginalOriginY = self.nameBar.frame.size.height + self.imageView.frame.size.height;
            CGRect infoContainerFrame = self.infoContainer.frame;
            CGFloat infoContainerAdjustedOriginY = infoContainerOriginalOriginY;
            if (self.eventsTableView.contentOffset.y + self.nameBar.frame.size.height >= infoContainerOriginalOriginY) {
                infoContainerAdjustedOriginY = nameBarFrame.origin.y + nameBarFrame.size.height;
            }
            infoContainerFrame.origin.y = infoContainerAdjustedOriginY;
            self.infoContainer.frame = infoContainerFrame;
        } else {
            nameBarFrame.origin.y = 0;
        }
        self.nameBar.frame = nameBarFrame;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * CellIdentifier = @"EventCellGeneral";
    
    EventTableViewCell * cell = (EventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(EventTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Fake Event %d", indexPath.row];
    cell.categoryColor = indexPath.row % 2 == 1 ? [UIColor yellowColor] : [UIColor greenColor];
    cell.locationLabel.text = @"Redundantly Displayed Venue Name";
    cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"January %d, 2012 | %d:0%d AM", indexPath.row, indexPath.row, indexPath.row];
    cell.priceOriginalLabel.text = [NSString stringWithFormat:@"$10%d.00", indexPath.row];
    
}

@end
