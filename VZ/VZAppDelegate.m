//
//  VZAppDelegate.m
//  VZ
//
//  Created by Travis on 13-10-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>

#import "VZMenuC.h"
#import "VZM.h"

#import <MMDrawerController/MMDrawerController.h>
#import "VZNavView.h"


@interface MMDrawerController (){
    
}
-(UIView*)childControllerContainerView;
@end
@interface VZAppDelegate()
{
    
}
@end

@implementation VZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber=0;
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor:[UIColor whiteColor]
                                                           }];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor:[UIColor whiteColor]
                                                           } forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
   
    
    
    model;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor whiteColor];
    //self.window.backgroundColor=[UIColor blackColor];
    
    UIImageView *bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    bg.alpha=0.8;
    [self.window addSubview:bg];
    
    [AVOSCloud setApplicationId:@"1tglhmgzoq6apby1rmhx3fc5kg2ie0bums7085d3cqhpunlo"
                      clientKey:@"4es7zmmqsx0xarkp7svkwady8eaipwdz83c2mccoi0z15358"];

    
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIStoryboard *board=[UIStoryboard storyboardWithName:@"iPhone" bundle:Nil];
    
    VZMenuC *menuC=[board instantiateViewControllerWithIdentifier:@"menuC"];
    
    
    UINavigationController *nav=[board instantiateInitialViewController];
    
    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        nav.interactivePopGestureRecognizer.enabled=YES;
    }
    
    MMDrawerController * menu = [[MMDrawerController alloc]initWithCenterViewController:nav
                                             leftDrawerViewController:menuC];
    
    
    menu.openDrawerGestureModeMask=MMOpenDrawerGestureModeNone;
    menu.closeDrawerGestureModeMask=MMCloseDrawerGestureModeTapCenterView;
    menu.shouldStretchDrawer=NO;
    menu.maximumLeftDrawerWidth=64;
    
    menu.maximumRightDrawerWidth=64;
    
    self.window.rootViewController=menu;
    menu.view.backgroundColor=[UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    
//    [menu setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//        
//        switch (drawerSide) {
//            case MMDrawerSideLeft:
//                [[VZNavView shared].arrowBtn setTransform:CGAffineTransformMakeRotation(-M_PI /2*percentVisible)];
//                break;
//            
//                
//            case MMDrawerSideRight:
//                if (percentVisible==1.0) {
//                    [[VZNavView shared] showClose:YES];
//                }else if (percentVisible==0.0) {
//                    [[VZNavView shared] showClose:NO];
//                    //drawerController.rightDrawerViewController=nil;
//                }
//                break;
//            default:
//                break;
//        }
//        
////        if (percentVisible==1.0) {
////            switch (drawerSide) {
////                case MMDrawerSideRight:
////                    [[VZNavView shared] showClose:YES];
////                    break;
////                
////                case MMDrawerSideLeft:
////                    [[VZNavView shared] arrowDown];
////                    break;
////                default:
////                    break;
////            }
////        }else if (percentVisible==0.0) {
////            switch (drawerSide) {
////                case MMDrawerSideRight:
////                    [[VZNavView shared] showClose:NO];
////                    break;
////                case MMDrawerSideLeft:
////                    [[VZNavView shared] arrowLeft];
////                    break;
////                default:
////                    break;
////            }
////        }
//        
//    }];
//    
 
#if !TARGET_IPHONE_SIMULATOR
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
#endif
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    NSMutableArray *channels=[NSMutableArray arrayWithArray:currentInstallation.channels];
    if (![channels containsObject:@"update"]) {
        [channels addObject:@"update"];
        currentInstallation.channels=channels;
        [currentInstallation saveInBackground];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [AVAnalytics event:@"开启推送失败" label:[error description]];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //[AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    [AVPush handlePush:userInfo];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [AVOSCloudSNS handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
