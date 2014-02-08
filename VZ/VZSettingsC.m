//
//  VZSettingsC.m
//  VZ
//
//  Created by Travis on 13-11-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZSettingsC.h"
#import "VZM.h"
#import <StoreKit/SKStoreProductViewController.h>
#import <SIAlertView/SIAlertView.h>

#import "VZWebViewC.h"

@interface VZSettingsC ()
@property (weak, nonatomic) IBOutlet UILabel *weiboName;
@property (weak, nonatomic) IBOutlet UITextView *footer;

@end

@implementation VZSettingsC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"设置页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"设置页面"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[VZTheme bgImage]];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAvos)];
    [self.footer addGestureRecognizer:tap];
    
    [self reloadWeibo];
}
-(void)openAvos{
    VZWebViewC *wc= [[VZWebViewC alloc] init];
    [wc loadURL:@"http://cn.avoscloud.com?src=vzapp"];
    
    [self.navigationController pushViewController:wc animated:YES];
    
    [AVAnalytics event:@"打开AVOSCloud"];
}
-(void)reloadWeibo{
    NSString *name= [AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo][@"username"];
    self.weiboName.text=name?[@"@" stringByAppendingString:name]:@"未绑定";
}

-(void)clearCache{

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            
        {
             __weak typeof(self) ws=self;
            if ([VZUser currentUser]==nil) {
                [model login:^(id object, NSError *error) {
                    if (error) {
                        NSLog(@"login error %@",[error description]);
                    }else if(object){
                        [ws reloadWeibo];
                    }
                }];
            }else{
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"注销" andMessage:@"确定要注销吗？"];
                
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alert) {
                                          [model logout];
                                          [ws reloadWeibo];
                                      }];
                
                [alertView addButtonWithTitle:@"取消"
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alert) {
                                          
                                      }];
                
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                
                [alertView show];
                
            }
        }
            break;
            
        case 1:
        {
            
            [self.navigationController
             pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackC"]
             animated:YES];
        }
            break;
            
            
        case 2:
        {
            
            NSString *url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",@"768074220"];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            return;
            
            __weak typeof(self) ws=self;
            
            SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
            // Configure View Controller
            [storeProductViewController setDelegate:(id)self];
            [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @"768074220"}
             
                                                  completionBlock:^(BOOL result, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                                                          
                                                          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"出错了" andMessage:[error localizedDescription]];
                                                          
                                                          [alertView addButtonWithTitle:@"确定"
                                                                                   type:SIAlertViewButtonTypeCancel
                                                                                handler:^(SIAlertView *alert) {
                                                                                    [ws dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                          
                                                          alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                          
                                                          [alertView show];
                                                          
                                                          
                                                      }
                                                  }];
            [self presentViewController:storeProductViewController animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
