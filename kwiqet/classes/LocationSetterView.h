//
//  LocationSetterView.h
//  kwiqet
//
//  Created by Dan Bretl on 10/18/11.
//  Copyright (c) 2011 Abextra Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationSetterView : UIView {
    
    UIView * headerBar_;
    UIButton * cancelButton_;
    UILabel * headerLabel_;
    UIButton * doneButton_;
    
    UITextField * locationTextField_;
    UIButton * currentLocationButton_;
    
}

@end
