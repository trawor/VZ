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


@interface VZAppDelegate()
{
    
}
@end

@implementation VZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:1] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor:[UIColor whiteColor]
                                                           }];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor:[UIColor whiteColor]
                                                           } forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
   
    if (is7orLater()) {
        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"arrow"]];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"arrow"]];
        
        [UIBarButtonItem.appearance setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -64) forBarMetrics:UIBarMetricsDefault];
        
        self.window.tintColor = [UIColor whiteColor];
        
    }else{
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"arrow"] stretchableImageWithLeftCapWidth:16 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    
    
    model;
    
    self.window.backgroundColor=[UIColor blackColor];
    
    UIImageView *bg=[[UIImageView alloc] initWithImage:[VZTheme bgImage]];
    bg.alpha=0.8;
    [self.window addSubview:bg];
    
    [AVOSCloud setApplicationId:@"1tglhmgzoq6apby1rmhx3fc5kg2ie0bums7085d3cqhpunlo"
                      clientKey:@"4es7zmmqsx0xarkp7svkwady8eaipwdz83c2mccoi0z15358"];

    [AVOSCloud setLastModifyEnabled:YES];
    [AVAnalytics setCrashReportEnabled:YES];
    
    
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
    menu.shouldStretchDrawer=YES;
    menu.maximumLeftDrawerWidth=64;
    
    menu.maximumRightDrawerWidth=64;
    
    self.window.rootViewController=menu;
    menu.view.backgroundColor=[UIColor clearColor];
    [self.window makeKeyAndVisible];


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
    if (![channels containsObject:@"update"]) {// 设置默认的推送
        [channels addObject:@"update"];
        currentInstallation.channels=channels;
        [currentInstallation saveInBackground];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [AVAnalytics event:@"开启推送失败" label:[error description]];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:nil];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [AVOSCloudSNS handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    application.applicationIconBadgeNumber=0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    application.applicationIconBadgeNumber=0;
}

@end
