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


@interface VZMenuC (){
    
}
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (nonatomic) UITapGestureRecognizer *loginTap;

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
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)onLogin:(VZUser*)user{
    if (user) {
        [self.avatar setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"head"]];
        
        //[self.userNameLb setText:[user objectForKey:@"username"]];
    }
}
-(void)onLogout{
    self.avatar.image=[UIImage imageNamed:@"head"];
    self.userNameLb.text=@"";
}

-(void)login{
    AVOSCloudSNSType type=AVOSCloudSNSSinaWeibo;
    
    [AVOSCloudSNS setupPlatform:type withAppKey:@"1714255746" andAppSecret:@"298c4b365c60fb9de5b2c4fa6c69d874" andRedirectURI:@"http://"];
    
    __weak VZMenuC *ws=self;
    [AVOSCloudSNS loginWithCallback:^(NSDictionary *object, NSError *error) {
        if (error) {
            if (error.code==AVOSCloudSNSErrorUserCancel && [error.domain isEqualToString:AVOSCloudSNSErrorDomain]) {
                
            }else{
                
            }
        }else if(object){
            [VZUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
                VZUser *auser=(id)user;
                if (auser.avatar==nil) {
                    auser.avatar=object[@"avatar"];
                    auser.username=object[@"username"];
                    [auser saveInBackground];
                }
                [ws onLogin:auser];
            }];
        }
    } toPlatform:type];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    [self.avatar addGestureRecognizer:self.loginTap];
    
    //self.view.backgroundColor=[UIColor clearColor];
//    self.avatar.center=CGPointMake(self.view.bounds.size.width/2, self.avatar.center.y);
//    
//	self.avatar.clipsToBounds=YES;
//    self.avatar.layer.cornerRadius=48;
//    
//    //self.avatar.layer.borderWidth =3.0;
//    
//    self.avatar.layer.borderColor=[UIColor grayColor].CGColor;
//    
    [self onLogin:(id)[VZUser currentUser]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    model.showPostsWithPicsOnly=(indexPath.row==1);
//    
//    
//    
//    REFrostedViewController *ref=self.frostedViewController;
//    [ref hideMenuViewController];
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

@end
