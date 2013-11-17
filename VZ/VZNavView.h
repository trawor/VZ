//
//  VZNavView.h
//  VZ
//
//  Created by Travis on 13-11-16.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZProgressView.h"
@interface VZNavView : UIView
@property (nonatomic,retain) VZProgressView *refreshView;
@property(nonatomic,retain)UIButton *arrowBtn;

+(VZNavView*)shared;
+(float)height;

-(void)arrowDown;
-(void)arrowLeft;
-(void)showClose:(BOOL)flag;
@end

