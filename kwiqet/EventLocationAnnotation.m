//
//  EventLocationAnnotation.m
//  Abextra
//
//  Created by John Nichols on 4/5/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "EventLocationAnnotation.h"

@implementation EventLocationAnnotation
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    NSString * returnTitle = nil;
    if (_name) { 
        returnTitle = _name; 
    } else {
        returnTitle = _address;
    }
    return returnTitle;
}

- (NSString *)subtitle {
    NSString * returnTitle = nil;
    if (_name) { 
        returnTitle = _address; 
    }
    return returnTitle;
}

- (void)dealloc
{
    [_name release];
    _name = nil;
    [_address release];
    _address = nil;    
    [super dealloc];
}
@end
