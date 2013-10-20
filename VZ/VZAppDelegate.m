//
//  VZAppDelegate.m
//  VZ
//
//  Created by Travis on 13-10-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>

#import "REFrostedViewController.h"
#import "VZMenuC.h"

@implementation VZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [AVOSCloud setApplicationId:@"1tglhmgzoq6apby1rmhx3fc5kg2ie0bums7085d3cqhpunlo"
                      clientKey:@"4es7zmmqsx0xarkp7svkwady8eaipwdz83c2mccoi0z15358"];

    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [AVAnalytics setCrashReportEnabled:YES andIgnore:YES];
    
    
    UIStoryboard *board=[UIStoryboard storyboardWithName:@"iPhone" bundle:Nil];
    
    
    REFrostedViewController *menu=[[REFrostedViewController alloc] initWithContentViewController:[board instantiateInitialViewController]
                                              menuViewController:[board instantiateViewControllerWithIdentifier:@"menuC"]];
    menu.limitMenuViewSize=YES;
    menu.minimumMenuViewSize=CGSizeMake(220, self.window.bounds.size.height);

    
    self.window.rootViewController=menu;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
