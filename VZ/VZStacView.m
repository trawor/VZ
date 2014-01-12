//
//  VZStacView.m
//  VZ
//
//  Created by Travis on 13-11-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZStacView.h"

#define WHRate 0.6
#define TRIGGER_DLT 0.4
@interface VZStacView ()
{
    int count;
    float imageH;
    
    CGRect imgFrame;
    float scrollY;
    
}
@end

@implementation VZStacView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.initFrame=frame;
        
        float w=frame.size.width-8;
        
        imageH=w*WHRate;
        imgFrame=CGRectMake(4, frame.size.height-imageH, w, imageH);
        
        UIPinchGestureRecognizer *pg=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [self addGestureRecognizer:pg];
        
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

-(void)close{
    [self setOpen:NO];
}

-(void)addImage:(UIImage*)img{
    if (self.open) {
        return;
    }
    UIImageView *imgv=[[UIImageView alloc] initWithImage:img];
    imgv.contentMode=UIViewContentModeScaleAspectFill;
    imgv.clipsToBounds=YES;
    imgv.frame=imgFrame;
    
    imgv.tag=count;
    imgv.alpha=0.2;
    count++;
    
    [UIView beginAnimations:@"add" context:nil];
    [UIView setAnimationDuration:0.2];
    [self insertSubview:imgv atIndex:count];
    [self scroll:0];
    [UIView commitAnimations];
}

-(void)scroll:(float)y{
    
    if (self.open) {
        return;
    }
    
    float dlt=-y/self.initFrame.size.height;
    
    if (dlt>=TRIGGER_DLT) {
        self.open=YES;
        return;
    }
    dlt=MAX(0.02, dlt);
    [self layoutWithDelta:dlt];
}


-(void)layoutWithDelta:(float)dlt{
    CGRect f=self.frame;
    
    float gapH=imageH*dlt/5.0;
    
    for (UIImageView *imgv in self.subviews) {
        float scale=1.0-(count-imgv.tag-1)*(TRIGGER_DLT-dlt)*0.2;
        imgv.transform=CGAffineTransformScale(CGAffineTransformIdentity,scale, scale);
        
        float y=f.size.height-imageH*(1.0-scale*0.5)-(count-imgv.tag)*gapH;
        imgv.center=CGPointMake(self.initFrame.size.width/2, y);
        imgv.alpha=scale;
        
        //NSLog(@"Img:%d scale:%.02f y:%.02f",imgv.tag,scale,y);
    }
}

-(void)setOpen:(BOOL)open{
    _open=open;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (open) {
            float h=44;
            
            for (UIImageView *imgv in self.subviews) {
                CGSize size=imgv.image.size;
                
                imgv.transform=CGAffineTransformIdentity;
                imgv.alpha=1;
                
                
                float r=size.width/imgFrame.size.width;
                
                
                
                CGRect f=imgFrame;
                f.origin.y=h;
                f.size.height=size.height/r;
                
                imgv.frame=f;
                imgv.contentMode=UIViewContentModeScaleToFill;
                
                h+=f.size.height+4;
            }
            
            CGRect f=self.initFrame;
            f.size.height=h;
            self.frame=f;
            
        }else{
            
            
                for (UIImageView *imgv in self.subviews) {
                    imgv.transform=CGAffineTransformIdentity;
                    imgv.frame=imgFrame;
                    imgv.contentMode=UIViewContentModeScaleAspectFill;
                }
                [self scroll:0];
            self.frame=self.initFrame;
        }
        [self.delegate stacViewOpenChanged:self];
    } completion:^(BOOL finished) {
        
    }];
    
}

@end
