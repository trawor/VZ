//
//  VZSettingsC.m
//  VZ
//
//  Created by Travis on 13-11-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZSettingsC.h"
#import "VZM.h"
@interface VZSettingsC ()

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
}

-(void)clearCache{

}


@end
