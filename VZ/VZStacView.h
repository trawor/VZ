//
//  VZStacView.h
//  VZ
//
//  Created by Travis on 13-11-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZStacView;
@protocol VZStacViewDelegate <NSObject>

-(void)stacViewOpenChanged:(VZStacView*)stacView;

@end

@interface VZStacView : UIView
@property(nonatomic,assign)CGRect initFrame;
@property(nonatomic,assign) BOOL open;
@property(nonatomic,assign) id<VZStacViewDelegate> delegate;
@property(nonatomic,assign) int totalCountToShow;

-(void)addImage:(UIImage*)img;

-(void)scroll:(float)y;

@end
