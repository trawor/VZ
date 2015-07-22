//
//  VZMenuC.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZMenuC.h"
#import <QuartzCore/QuartzCore.h>
#import <AVOSCloud/AVImageRequestOperation.h>
#import "VZNavView.h"
#import <UIViewController+MMDrawerController.h>
#import <SIAlertView/SIAlertView.h>
#import <AVOSCloudSNS/AVUser+SNS.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "VZNearC.h"

#import "VZStatusListC.h"

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}


@interface VZMenuC ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (nonatomic) UITapGestureRecognizer *loginTap;
@end

@implementation VZMenuC

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)onLogin:(VZUser*)user{
    [self.avatar setImageWithURL:[NSURL URLWithString:[user objectForKey:@"avatar"]]
                placeholderImage:[UIImage imageNamed:@"head"]];
}

-(void)onLogout{
    [model logout];
    
    self.avatar.image=[UIImage imageNamed:@"head"];
}

-(void)login{
    if ([VZUser currentUser]==nil) {
        [model login:^(id object, NSError *error) {
            if (error) {
                NSLog(@"login error %@",[error description]);
            }else if(object){
                [self onLogin:object];
            }
        }];
    }else{
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"注销" andMessage:@"确定要注销吗？"];
        
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  [self onLogout];
                              }];
        
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        
        [alertView show];
        
    }
    
}

- (void)dealloc
{
    NSLog(@"menu release?");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"左菜单"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"左菜单"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView.frame=CGRectMake(0, 0, 10, 0);
    
    //self.loginTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
    //[self.avatar addGestureRecognizer:self.loginTap];
    
    [self onLogin:[VZUser currentUser]];
    
}

//-(void)viewWillAppear:(BOOL)animated{
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationRight];
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UINavigationController *nav=(id)self.mm_drawerController.centerViewController;
    
    if (indexPath.section==1) {
        [nav setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"SettingC"]] animated:NO];
    }else if(indexPath.section==0){
        switch (indexPath.row) {
            case 0:
                [self login];
                return;
                break;
            
            case 1:
            {
                UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"PostListC"];
                [nav setViewControllers:@[vc] animated:NO];
            }
                break;
                
            case 2:
            {
                VZNearC *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"NearC"];
                [nav setViewControllers:@[vc] animated:NO];
                break;
            }
              
            case 3:
            {
                VZStatusListC *vc=[[VZStatusListC alloc] initWithStyle:UITableViewStylePlain];
                [nav setViewControllers:@[vc] animated:NO];
            }
            default:
                break;
        }
    }
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}


@end
