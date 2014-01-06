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
+(instancetype)new{
    VZProgressView *v=[[self alloc] initWithWidth:44];
    v.progress=1;
    return v;
}
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
        self.shapeLayer.fillColor=[UIColor clearColor].CGColor;
        
        self.bgLayer=[CAShapeLayer layer];
        self.bgLayer.lineCap=kCALineCapRound;
        self.bgLayer.fillColor=[UIColor clearColor].CGColor;
        
        [self.layer addSublayer:self.bgLayer];
        [self.layer addSublayer:self.shapeLayer];
        
        self.lineWidth=1;
        self.dashBgLine=YES;
        self.fgLineColor=[UIColor whiteColor];
        self.bgLineColor=[UIColor lightGrayColor];
        
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
    _progress=p;
    self.shapeLayer.strokeEnd=p;return;
    if (animated) {
        [self.shapeLayer removeAllAnimations];
        [CATransaction begin];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = (p-_progress)*0.25;
        animation.fromValue = [NSNumber numberWithFloat:self.shapeLayer.strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:p];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion=NO;
        animation.autoreverses = NO;
        [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
        [CATransaction commit];
        
    }else{
        self.shapeLayer.strokeEnd=p;
    }
    
}

-(void)setInfinite:(BOOL)infinite{
    if (infinite) {
        [self.shapeLayer removeAllAnimations];
        
        float dur=2;
        
        [CATransaction begin];
        
        CAAnimationGroup *group=[CAAnimationGroup animation];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration =dur;
        animation.fromValue = [NSNumber numberWithFloat:0];
        animation.toValue = [NSNumber numberWithFloat:1];
        
        
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation2.beginTime=dur;
        animation2.duration =dur;
        animation2.fromValue = [NSNumber numberWithFloat:0];
        animation2.toValue = [NSNumber numberWithFloat:1];
        
        group.duration =dur*2.0;
        group.fillMode = kCAFillModeForwards;
        group.autoreverses = YES;
        group.repeatCount=65530;
        group.animations=@[animation,animation2];
        
        [self.shapeLayer addAnimation:group forKey:@"stroke"];
        
        [CATransaction commit];
    }else{
        [self.shapeLayer removeAllAnimations];
        [self setProgress:_progress animated:NO];
    }
}

@end
