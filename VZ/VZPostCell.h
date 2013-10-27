//
//  VZPostCell.h
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VZM.h"

@interface VZPostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *geoIcon;
@property (weak, nonatomic) IBOutlet UILabel *textLb;
@property (weak, nonatomic) IBOutlet UILabel *infoLb;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;

@property (weak, nonatomic) IBOutlet UIView *container;


@property (weak, nonatomic) VZPost *post;
@property (weak, nonatomic) UITableView *table;

@end


@interface VZPostRightCell : VZPostCell

@end