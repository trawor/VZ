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

#import "AVOSCloudSNS.h"

@interface VZMenuC ()
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

-(void)onLogin:(NSDictionary*)user{
    if (user) {
        [self.avatar setImageWithURL:[NSURL URLWithString:[user objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"head"]];
        
        [self.userNameLb setText:[user objectForKey:@"username"]];
        
        [self.avatar removeGestureRecognizer:self.loginTap];
        self.loginTap=nil;
    }
}
-(void)onLogout{
    self.avatar.image=[UIImage imageNamed:@"head"];
    self.userNameLb.text=@"";
    
    self.loginTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    [self.avatar addGestureRecognizer:self.loginTap];
}

-(void)login{
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"1714255746" andAppSecret:@"298c4b365c60fb9de5b2c4fa6c69d874" andRedirectURI:@"http://"];
    
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        [self onLogin:object];
        if (error) {
            NSLog([error description]);
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    self.avatar.center=CGPointMake(self.view.bounds.size.width/2, self.avatar.center.y);
    
	self.avatar.clipsToBounds=YES;
    self.avatar.layer.cornerRadius=48;
    
    self.avatar.layer.borderWidth =3.0;
    
    self.avatar.layer.borderColor=[UIColor grayColor].CGColor;
    
    if ([AVOSCloudSNS doesUserExpireOfPlatform:AVOSCloudSNSSinaWeibo]) {
        [self onLogout];
    }else{
        NSDictionary *user=[AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo];
        [self onLogin:user];
    }
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
    
    if (indexPath.section==1) {
        if (indexPath.row==0) {
            [AVOSCloudSNS logout:AVOSCloudSNSSinaWeibo];
            [self onLogout];
        }
    }
}

@end
