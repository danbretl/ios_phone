//
//  ContactCell.m
//  Kwiqet
//
//  Created by Dan Bretl on 7/12/11.
//  Copyright 2011 Abextra Technologies. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

@synthesize pictureImageView;
@synthesize nameLabel;
@synthesize picture;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView * backgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FBcellbar.png"]];
        self.backgroundView = backgroundViewWithImage;
        [backgroundViewWithImage release];
        UIImageView * selectedBackgroundViewWithImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FBcellbar_selected.png"]];
        self.selectedBackgroundView = selectedBackgroundViewWithImage;
        [selectedBackgroundViewWithImage release];
        
        pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 44, 44)];
        self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.pictureImageView];
        self.picture = nil;
        
        CGFloat nameLabelOriginX = 60;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabelOriginX, 16, self.contentView.bounds.size.width - nameLabelOriginX, 30)];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-MdCn" size:24];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.highlightedTextColor = self.nameLabel.textColor;
        [self.contentView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)setPicture:(UIImage *)thePicture {
    if (thePicture == nil) {
        thePicture = [UIImage imageNamed:@"fbPicturePlaceholder.png"];
    }
    if (picture != thePicture) {
        [picture release];
        picture = [thePicture retain];
    }
    self.pictureImageView.image = self.picture;
}

- (void)dealloc
{
    [pictureImageView release];
    [nameLabel release];
    [picture release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
