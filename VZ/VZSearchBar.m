//
//  VZSearchBar.m
//  VZ
//
//  Created by Travis on 14-2-13.
//  Copyright (c) 2014年 Plumn LLC. All rights reserved.
//

#import "VZSearchBar.h"

#define SB_LEFT_MG 10

@interface VZSearchBar ()
@property(nonatomic,assign)CGRect origFram;
@property(nonatomic,assign)BOOL addAnimated;
@end

@implementation VZSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.origFram=frame;
        self.frame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.height);
//        self.layer.borderWidth=1;
//        self.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.7].CGColor;
        self.layer.cornerRadius=frame.size.height/2;
        
        self.backgroundColor=[UIColor colorWithWhite:0.7 alpha:0.6];
        //self.backgroundColor=[UIColor clearColor];
        self.textColor=[UIColor colorWithWhite:1 alpha:0.7];
        self.font=[UIFont systemFontOfSize:14];
        
        self.keyboardAppearance=UIKeyboardAppearanceAlert;
        self.autocorrectionType=UITextAutocorrectionTypeNo;
        self.returnKeyType=UIReturnKeySearch;
    }
    return self;
}

-(void)tiny{
    float w=[self.text sizeWithFont:self.font forWidth:self.origFram.size.width lineBreakMode:0].width+SB_LEFT_MG*2+13;
    
    CGRect f=self.frame;
    f.size.width=w;
    
    UIImageView *cls=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchClose"]];
    cls.frame=CGRectMake(w-20, (f.size.height-16)/2, 16, 16);
    [self addSubview:cls];
    
    self.frame=f;
    self.backgroundColor=[UIColor colorWithWhite:0.7 alpha:0.6];
    self.layer.borderWidth=0;
    //self.textColor=[UIColor colorWithRed:0 green:0 blue:0.7 alpha:1];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self addGestureRecognizer:tap];
}

-(void)onTap{
    [self.delegate performSelector:@selector(onSearchBarClose:) withObject:self];
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview && self.addAnimated==NO) {
        self.addAnimated=YES;
        [UIView animateWithDuration:0.15 animations:^{
            self.frame=self.origFram;
        }];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    int leftMargin = SB_LEFT_MG;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin, bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int leftMargin = SB_LEFT_MG;
    CGRect inset = CGRectMake(bounds.origin.x + leftMargin, bounds.origin.y, bounds.size.width - leftMargin, bounds.size.height);
    return inset;
}


@end
