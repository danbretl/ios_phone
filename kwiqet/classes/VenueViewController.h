//
//  VenueViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElasticUILabel.h"

@protocol VenueViewControllerDelegate;

@interface VenueViewController : UIViewController {
    
    UIView * navBarContainer_;
    UIButton * backButton_;
    UIButton * logoButton_;
    UIButton * followButton_;
    
    UITableView * eventsTableView_;
    
    ElasticUILabel * nameBar_;
    
    UIImageView * imageView_;
    
    UIView * infoContainer_;
    UILabel * addressLabel_;
    UILabel * cityStateZipLabel_;
    UIButton * phoneNumberButton_;
    UIButton * mapButton_;
    
    UIView * descriptionContainer_;
    UILabel * descriptionLabel_;
    
    id<VenueViewControllerDelegate> delegate;
    
}

@property (assign) id<VenueViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView * navBarContainer;
@property (retain, nonatomic) IBOutlet UIButton * backButton;
@property (retain, nonatomic) IBOutlet UIButton * logoButton;
@property (retain, nonatomic) IBOutlet UIButton * followButton;

@property (retain, nonatomic) IBOutlet UITableView * eventsTableView;

@property (retain, nonatomic) IBOutlet ElasticUILabel * nameBar;

@property (retain, nonatomic) IBOutlet UIImageView * imageView;

@property (retain, nonatomic) IBOutlet UIView * infoContainer;
@property (retain, nonatomic) IBOutlet UILabel * addressLabel;
@property (retain, nonatomic) IBOutlet UILabel * cityStateZipLabel;
@property (retain, nonatomic) IBOutlet UIButton * phoneNumberButton;
@property (retain, nonatomic) IBOutlet UIButton * mapButton;

@property (retain, nonatomic) IBOutlet UIView * descriptionContainer;
@property (retain, nonatomic) IBOutlet UILabel * descriptionLabel;

@end

@protocol VenueViewControllerDelegate <NSObject>
@required
- (void) venueViewControllerDidFinish:(VenueViewController *)venueViewController;
- (void) venueViewControllerDidRequestStackCollapse:(VenueViewController *)venueViewController;
@end