//
//  VZCommentCell.m
//  VZ
//
//  Created by Travis on 13-11-17.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZCommentCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation VZCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    self.avatarView.layer.cornerRadius=20;
    self.avatarView.clipsToBounds=YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSString *text=self.textLb.text;
    if (text.length>0) {
        CGSize size= [text sizeWithFont:self.textLb.font constrainedToSize:CGSizeMake(220, 500)];
        CGRect f=self.textLb.frame;
        f.size=size;
        
        
        CGRect f2=self.textBg.frame;
        
        //float x1=self.frame.size.width-f2.origin.x-f2.size.width;
        float w=f2.size.width;
        
        f2.size=CGSizeMake(size.width+30, MAX(size.height+25, 39));
        
        if ([self.reuseIdentifier isEqualToString:@"CommentCell2"]) {
            f.origin.x-=f2.size.width-w;
            f2.origin.x-=f2.size.width-w;
        }
        
        self.textLb.frame=f;
        self.textBg.frame=f2;
    }
}

@end
