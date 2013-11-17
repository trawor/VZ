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
        
        float w=self.view.frame.size.width-10;
        float h=w/16*9;
        
        UIView *picContiner= [[UIView alloc] initWithFrame:CGRectMake(5, 49, w, h)];
        
        
        
        int gap=5;
        
        int c=MIN(pics.count, 5);
        
        UIImageView *lastV=nil;
        
        for (int i=0; i<c; i++) {
            float y=(c-i-1)*gap;
            UIImageView *imgv=[[UIImageView alloc] initWithFrame:CGRectMake(i*gap, y, w-i*gap*2, h-y)];
            imgv.contentMode=UIViewContentModeScaleAspectFill;
            imgv.alpha=(c-i)*0.6/c+0.4;
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
    //self.view.backgroundColor=[UIColor clearColor];
    [self loadPics];
    
    
    
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
