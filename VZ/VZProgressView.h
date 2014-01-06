//
//  VZProgressView.h
//  VZ
//
//  Created by Travis on 13-10-31.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZProgressView : UIView
@property(nonatomic,assign) BOOL autoCenter;

@property(nonatomic,retain) UIBezierPath *path;
@property(nonatomic,retain) UIColor *bgLineColor;
@property(nonatomic,retain) UIColor *fgLineColor;

@property(nonatomic,assign) BOOL infinite;
@property(nonatomic,assign) BOOL dashBgLine;
@property(nonatomic,assign) float progress;
@property(nonatomic,assign) float lineWidth;


- (id)initWithWidth:(float)width;

-(void)setProgress:(float)p animated:(BOOL)animated;

@end
