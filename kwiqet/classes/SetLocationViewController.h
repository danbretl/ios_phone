//
//  SetLocationViewController.h
//  Kwiqet
//
//  Created by Dan Bretl on 10/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BSForwardGeocoder.h"
#import "BSKmlResult.h"
#import "WebActivityView.h"
#import "CoreDataModel.h"

@protocol SetLocationViewControllerDelegate;

@interface SetLocationViewController : UIViewController <UITextFieldDelegate, BSForwardGeocoderDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKReverseGeocoderDelegate, UIAlertViewDelegate> {
    
    IBOutlet UIView * headerBar_;
    IBOutlet UIButton * cancelButton_;
    IBOutlet UITextField * locationTextField_;
//    IBOutlet UIButton * currentLocationButton_;
    
    IBOutlet UIView * locationsContainer_;
    IBOutlet UITableView * locationsTableView_;
    IBOutlet UIImageView * locationsWindowImageView_;
    
    UIAlertView * locationManagerTimerAlertView_;    
    WebActivityView * webActivityView_;
    
    id<SetLocationViewControllerDelegate> delegate_;
    
    CLLocationManager * locationManager_;
    NSTimer * locationManagerTimer_;
    BSForwardGeocoder * forwardGeocoder_;
    MKReverseGeocoder * reverseGeocoder_;
    NSArray * matchedLocations_; // Array of BSKmlResult objects
    BOOL matchLocationsRequestMade_;
    NSArray * recentLocations_; // Array of UserLocation objects
    CLLocation * currentLocation_;
    NSString * currentLocationAddress_;

    NSDateFormatter * recentLocationsDateFormatter_;
    NSDateFormatter * recentLocationsTimeFormatter_;
    
    CoreDataModel * coreDataModel_;
    
}

@property (assign) id<SetLocationViewControllerDelegate> delegate;
@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) CoreDataModel * coreDataModel;

@end

@protocol SetLocationViewControllerDelegate <NSObject>
- (void) setLocationViewController:(SetLocationViewController *)setLocationViewController didSelectUserLocation:(UserLocation *)location;
- (void) setLocationViewControllerDidCancel:(SetLocationViewController *)setLocationViewController;
@end
