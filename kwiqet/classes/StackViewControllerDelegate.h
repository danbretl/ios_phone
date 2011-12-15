//
//  StackViewControllerDelegate.h
//  kwiqet
//
//  Created by Dan Bretl on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventViewController;
@class VenueViewController;

@protocol StackViewControllerDelegate <NSObject>
@required
- (void) viewController:(UIViewController *)viewController didFinishByRequestingStackCollapse:(BOOL)didRequestStackCollapse;
- (void) eventViewController:(EventViewController *)eventViewController didFinishByRequestingEventDeletionForEventURI:(NSString *)eventURI;
@end
