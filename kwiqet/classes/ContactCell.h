//
//  ContactCell.h
//  kwiqet
//
//  Created by Dan Bretl on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContactCell : UITableViewCell {
    
    UIImageView * pictureImageView;
    UILabel * nameLabel;
    
    UIImage * picture;
    
}

@property (readonly) UIImageView * pictureImageView;
@property (nonatomic, retain) UIImage * picture;
@property (retain) UILabel * nameLabel;

@end
