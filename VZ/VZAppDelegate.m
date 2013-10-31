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


@interface VZAppDelegate()
{
    
}
@end

@implementation VZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    model;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //self.window.backgroundColor = [UIColor lightGrayColor];
    
    
    [AVOSCloud setApplicationId:@"1tglhmgzoq6apby1rmhx3fc5kg2ie0bums7085d3cqhpunlo"
                      clientKey:@"4es7zmmqsx0xarkp7svkwady8eaipwdz83c2mccoi0z15358"];

    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIStoryboard *board=[UIStoryboard storyboardWithName:@"iPhone" bundle:Nil];
    
    VZMenuC *menuC=[board instantiateViewControllerWithIdentifier:@"menuC"];
    
    
    UINavigationController *nav=[board instantiateInitialViewController];
    nav.view.backgroundColor=[UIColor clearColor];
    
    
    MMDrawerController * menu = [[MMDrawerController alloc]initWithCenterViewController:nav
                                             leftDrawerViewController:menuC];
    
    menu.maximumLeftDrawerWidth=64;
    menu.centerHiddenInteractionMode=MMDrawerOpenCenterInteractionModeFull;
    
    self.window.rootViewController=menu;
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
    [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
