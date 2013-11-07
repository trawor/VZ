//
//  VZPostViewC.m
//  VZ
//
//  Created by Travis on 13-11-1.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostViewC.h"
#import <UIImageView+AFNetworking.h>
#import <UIViewController+MMDrawerController.h>
@interface VZPostViewC ()

@end

@implementation VZPostViewC
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)loadPics{
    NSArray *pics=[self.post objectForKey:@"pics"];
    
    if (pics.count>0) {
        
        float w=self.view.frame.size.width-80;
        float h=w/4*3;
        
        UIView *picContiner= [[UIView alloc] initWithFrame:CGRectMake(40, 40, w, h)];
        
        
        
        int gap=3;
        
        int c=MIN(pics.count, 5);
        
        UIImageView *lastV=nil;
        
        for (int i=0; i<c; i++) {
            float y=(c-i-1)*gap;
            UIImageView *imgv=[[UIImageView alloc] initWithFrame:CGRectMake(i*gap*0.5, y, w-i*gap, h-y)];
            imgv.contentMode=UIViewContentModeScaleAspectFill;
            imgv.alpha=(c-i)*0.3/c+0.7;
            imgv.clipsToBounds=YES;
            if (lastV) {
                [picContiner insertSubview:imgv belowSubview:lastV];
            }else{
                [picContiner addSubview:imgv];
            }
            
            lastV=imgv;
            
            NSString *url=pics[i];
            url=[url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
            
            [imgv setImageWithURL:[NSURL URLWithString:url]
                 placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]];
        }
        
        [self.view addSubview:picContiner];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg2"]];
    [self loadPics];
    
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 20, 40, 40);
    [btn setTitle:@"<" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(self.view.frame.size.width-40, 20, 40, 40);
    [btn setTitle:@">" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)close:(UIButton*)btn{
//    [btn removeFromSuperview];
//    
//    MMDrawerController *dc=self.mm_drawerController;
//    
//    [dc closeDrawerAnimated:YES completion:^(BOOL finished) {
//        dc.rightDrawerViewController=nil;
//    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
