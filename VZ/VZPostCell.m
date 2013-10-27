//
//  VZPostCell.m
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostCell.h"

#define avatarFrame CGRectMake(8,17,50,50)

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

-(void)awakeFromNib{
//    self.textLabel.numberOfLines=3;
//    self.textLabel.font=[UIFont systemFontOfSize:14];
    
    self.container.clipsToBounds=YES;
    self.container.layer.cornerRadius=5;
    
   
    self.userAvatar.clipsToBounds=YES;
    self.userAvatar.layer.cornerRadius=25;
    
    self.userAvatar.layer.borderWidth =1;
    
    self.userAvatar.layer.borderColor=[UIColor whiteColor].CGColor;
 
    
    //self.photo.layer.cornerRadius=10;
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
    
//    if (!selected && self.oldFrame==nil) {
//        return;
//    }
//    [UIView animateWithDuration:0.25 animations:^{
//        if (selected) {
//            
//                NSMutableDictionary *d=[NSMutableDictionary dictionary];
//                [d setObject:[NSValue valueWithCGRect:self.userAvatar.frame] forKey:@"avatar"];
//                
//                [d setObject:[NSValue valueWithCGRect:self.textLb.frame] forKey:@"textLb"];
//                
//                [d setObject:[NSValue valueWithCGRect:self.photo.frame] forKey:@"photo"];
//                
//                self.oldFrame=d;
//                
//                self.userAvatar.frame=CGRectMake((self.frame.size.width-90)/2, 0, 90, 90);
//                self.userAvatar.layer.cornerRadius=45;
//                
//                
//                CGRect f=self.container.frame;
//                [d setObject:[NSValue valueWithCGRect:f] forKey:@"container"];
//                
//                f.origin.y+=50;
//                self.container.frame=f;
//            
//            
//            
//            
//        }else {
//            [self reset];
//            
//        }
//
//    }];
//    
//    NSIndexPath *indexPath = [self.table indexPathForCell: self];
//    
//    if (indexPath) {
//        [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
}

@end


@implementation VZPostRightCell



@end