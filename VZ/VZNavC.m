//
//  VZNavC.m
//  VZ
//
//  Created by Travis on 13-11-30.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZNavC.h"
#import <UIViewController+MMDrawerController.h>

@interface VZNavC ()<UINavigationControllerDelegate>
@property(nonatomic,strong)UIBarButtonItem *menuItem;
@end

@implementation VZNavC

- (void)viewDidLoad
{
    UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dots"] style:UIBarButtonItemStylePlain target:self action:@selector(menu:)];
    
    self.menuItem=btn;
    
    UIViewController *vc= self.viewControllers[0];
    vc.navigationItem.leftBarButtonItem=self.menuItem;
}

-(void)menu:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    [super setViewControllers:viewControllers animated:animated];
    UIViewController *vc= viewControllers[0];
    vc.navigationItem.leftBarButtonItem=self.menuItem;
}

@end
