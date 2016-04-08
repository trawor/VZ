//
//  VZPostCell.m
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostCell.h"
#import <AVOSCloud/AVOSCloud.h>

#define avatarFrame CGRectMake(8,17,50,50)


@implementation UIImageView(Progress)

-(void)setProgressImageWithUrl:(NSString*)url placeholderImage:(UIImage*)placeholderImage{
    //[self cancelImageRequestOperation];
    [[self viewWithTag:1000] removeFromSuperview];
    
    AVFile* file=[AVFile fileWithURL:url];
    BOOL hasData=[file isDataAvailable];
    if(hasData){
        NSData* data=[file getData];
        UIImage* image=[UIImage imageWithData:data];
        self.image=image;
    }else{
        self.image=placeholderImage;
        
        VZProgressView *pv=[[VZProgressView alloc] initWithWidth:self.frame.size.width/2];
        pv.bgLineColor=[UIColor colorWithWhite:1 alpha:0.4];
        pv.fgLineColor=[UIColor whiteColor];
        pv.tag=1000;
        [self addSubview:pv];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error){
               [pv removeFromSuperview];
            }else{
                UIImage* image=[UIImage imageWithData:data];
                self.image=image;
                [pv removeFromSuperview];
                
            }
        } progressBlock:^(NSInteger percentDone) {
            pv.progress=percentDone;
        }];
    }
}
@end

@interface VZPostCell()

@property(weak,nonatomic) NSMutableDictionary *oldFrame;

@end

@implementation VZPostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

-(void)loadPhoto{
    NSArray *pics=[self.post objectForKey:@"pics"];
    if (pics) {
        NSString *url=pics[0];
        url=[url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        
        [self.photo setProgressImageWithUrl:url placeholderImage:[UIImage imageNamed:nil]];
    }
    
    int c=pics.count;
    if (c>1) {
        self.pageControl.hidden=NO;
        [self.pageControl setNumberOfPages:pics.count];
        
    }else{
        self.pageControl.hidden=YES;
    }
    
}
-(void)stopLoadPhoto{
    //[self.photo cancelImageRequestOperation];
}

-(void)awakeFromNib{
//    self.textLabel.numberOfLines=3;
//    self.textLabel.font=[UIFont systemFontOfSize:14];
    
    //self.container.clipsToBounds=YES;
    //self.container.layer.cornerRadius=5;
    
//    self.priceLb.layer.borderColor=[UIColor whiteColor].CGColor;
//    self.priceLb.layer.borderWidth=1;
//    self.priceLb.backgroundColor=[UIColor colorWithWhite:0 alpha:0.3];
    self.textLb.textColor=[VZTheme textColor];
    
    self.priceLb.layer.cornerRadius=4;
    
    self.userAvatar.clipsToBounds=YES;
    
    self.userAvatar.layer.borderWidth =1;
    
    self.userAvatar.layer.borderColor=[UIColor whiteColor].CGColor;
 
    self.photo.backgroundColor=[UIColor clearColor];
    self.userAvatar.layer.cornerRadius=20;
}

-(void)prepareForReuse{
    [self reset];
}


-(void)reset{
    if (self.oldFrame) {
        self.userAvatar.frame=avatarFrame;
        self.userAvatar.layer.cornerRadius=25;
        
        
        self.oldFrame=nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

@end
