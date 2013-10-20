//
//  VZMenuC.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZMenuC.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import <UIView+REFrostedViewController.h>
#import <REFrostedViewController.h>

@interface VZMenuC ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@end

@implementation VZMenuC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    self.avatar.center=CGPointMake(self.view.bounds.size.width/2, self.avatar.center.y);
    
	self.avatar.clipsToBounds=YES;
    self.avatar.layer.cornerRadius=48;
    [self.avatar setImageWithURL:[NSURL URLWithString:@"http://tp3.sinaimg.cn/1642587442/180/1281861902/1"] placeholderImage:[UIImage imageNamed:@"head"]];
    
    self.avatar.layer.borderWidth =3.0;
    
    self.avatar.layer.borderColor=[UIColor grayColor].CGColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    model.showPostsWithPicsOnly=(indexPath.row==1);
    
    REFrostedViewController *ref=self.frostedViewController;
    [ref hideMenuViewController];
}

@end
