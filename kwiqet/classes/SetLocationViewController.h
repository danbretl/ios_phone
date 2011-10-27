//
//  SetLocationViewController.h
//  kwiqet
//
//  Created by Dan Bretl on 10/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "WebActivityView.h"

@protocol SetLocationViewControllerDelegate;

@interface SetLocationViewController : UIViewController <UITextFieldDelegate, BSForwardGeocoderDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {
    
    IBOutlet UIView * headerBar_;
    IBOutlet UIButton * cancelButton_;
    IBOutlet UITextField * locationTextField_;
//    IBOutlet UIButton * currentLocationButton_;
    
    IBOutlet UIView * locationsContainer_;
    IBOutlet UITableView * locationsTableView_;
    IBOutlet UIImageView * locationsWindowImageView_;
    
    WebActivityView * webActivityView_;
    
    id<SetLocationViewControllerDelegate> delegate_;
    
    CLLocationManager * locationManager_;
    BSForwardGeocoder * forwardGeocoder_;
    NSArray * matchedLocations_; // Array of BSKmlResult objects
    
}

@property (assign) id<SetLocationViewControllerDelegate> delegate;
@property (nonatomic, retain) CLLocationManager * locationManager;

@end

@protocol SetLocationViewControllerDelegate <NSObject>
- (void) setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectCurrentLocation:(CLLocation *)location;
- (void) setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectLocation:(BSKmlResult *)location;
- (void) setLocationViewControllerDidCancel:(SetLocationViewController *)setLocationViewController;
@end