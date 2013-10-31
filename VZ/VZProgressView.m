//
//  VZProgressView.m
//  VZ
//
//  Created by Travis on 13-10-31.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface VZProgressView(){
 
}
@property(nonatomic,retain) CAShapeLayer *shapeLayer;
@property(nonatomic,retain) CAShapeLayer *bgLayer;

@end

@implementation VZProgressView

- (id)initWithWidth:(float)width
{
    float height=width*0.5;
    CGRect frame=CGRectMake(0, 0, width, height);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        
        self.autoCenter=YES;
        
        self.shapeLayer=[CAShapeLayer layer];
        self.shapeLayer.lineCap=kCALineCapRound;
        self.shapeLayer.strokeEnd=0;
        
        self.bgLayer=[CAShapeLayer layer];
        self.bgLayer.lineCap=kCALineCapRound;
        
        
        [self.layer addSublayer:self.bgLayer];
        [self.layer addSublayer:self.shapeLayer];
        
        self.lineWidth=1;
        self.dashBgLine=YES;
        self.fgLineColor=[UIColor redColor];
        self.bgLineColor=[UIColor darkGrayColor];
        
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addLineToPoint:CGPointMake(width/4, height)];
        [bezierPath addLineToPoint:CGPointMake(width/2, 0)];
        [bezierPath addLineToPoint:CGPointMake(width,0)];
        [bezierPath addLineToPoint:CGPointMake(width/2, height)];
        [bezierPath addLineToPoint:CGPointMake(width, height)];
        self.path=bezierPath;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithWidth:frame.size.width];
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (self.autoCenter) {
        CGSize s=newSuperview.bounds.size;
        self.center=CGPointMake(s.width/2, s.height/2);
    } 
}

-(void)setDashBgLine:(BOOL)dashBgLine{
    if (dashBgLine) {
        self.bgLayer.lineDashPattern=@[@(2),@(2),@(2),@(2)];
    }else{
        self.bgLayer.lineDashPattern=nil;
    }
}

-(void)setLineWidth:(float)lineWidth{
    self.shapeLayer.lineWidth=lineWidth;
    self.bgLayer.lineWidth=lineWidth;
}

-(void)setPath:(UIBezierPath *)path{
    self.shapeLayer.path=path.CGPath;
    self.bgLayer.path=path.CGPath;
}

-(void)setFgLineColor:(UIColor *)fgLineColor{
    self.shapeLayer.strokeColor = [fgLineColor CGColor];
}

-(void)setBgLineColor:(UIColor *)bgLineColor{
    self.bgLayer.strokeColor = [bgLineColor CGColor];
}

-(void)setProgress:(float)progress{
    [self setProgress:progress animated:YES];
}

-(void)setProgress:(float)p animated:(BOOL)animated{
    if (animated) {
        [self.shapeLayer removeAllAnimations];
        [CATransaction begin];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = (p-_progress)*0.25;
        animation.fromValue = [NSNumber numberWithFloat:_progress];
        animation.toValue = [NSNumber numberWithFloat:p];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion=NO;
        animation.autoreverses = NO;
        [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
        [CATransaction commit];
        
    }else{
        self.shapeLayer.strokeEnd=p;
    }
    _progress=p;
}
@end
