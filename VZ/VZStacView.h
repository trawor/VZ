//
//  VZStacView.h
//  VZ
//
//  Created by Travis on 13-11-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZStacView : UIView
@property(nonatomic,assign)CGRect initFrame;
@property(nonatomic,assign) BOOL open;
-(void)addImage:(UIImage*)img;

-(void)scroll:(float)y;

@end
