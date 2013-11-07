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

#import <UIViewController+MMDrawerController.h>

#import <AVOSCloudSNS/AVUser+SNS.h>

@interface VZMenuC ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (nonatomic) UITapGestureRecognizer *loginTap;
@end

@implementation VZMenuC

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)onLogin:(id)user{
    [self.avatar setImageWithURL:[NSURL URLWithString:[user objectForKey:@"avatar"]]
                placeholderImage:[UIImage imageNamed:@"head"]];
}

-(void)onLogout{
    self.avatar.image=[UIImage imageNamed:@"head"];
}

-(void)login{
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2858658895" andAppSecret:@"9d97c1cce2893cbdcdc970f05bc55fe4" andRedirectURI:@"http://"];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (error) {
            NSLog(@"login error %@",[error description]);
        }else if(object){
            [self onLogin:object];
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    [self.avatar addGestureRecognizer:self.loginTap];
    
    [self onLogin:(id)[AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo]];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

@end
