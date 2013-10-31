//
//  VZPostCell.m
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostCell.h"
#import <UIImageView+AFNetworking.h>

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

@interface UIImageView ()
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
+ (AFImageCache *)af_sharedImageCache;
+(NSOperationQueue*)af_sharedImageRequestOperationQueue;
@end

#define avatarFrame CGRectMake(8,17,50,50)


@implementation UIImageView(Progress)

- (void)setProgressImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage

{
    [self cancelImageRequestOperation];
    
    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        self.image = cachedImage;
        self.af_imageRequestOperation = nil;
        self.image = cachedImage;
    } else {
        self.image = placeholderImage;
        
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        
        
        VZProgressView *pv=[[VZProgressView alloc] initWithWidth:self.frame.size.width/2];
        pv.bgLineColor=[UIColor darkGrayColor];
        pv.fgLineColor=[UIColor whiteColor];
        
        [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float progress=totalBytesRead*1.0/totalBytesExpectedToRead;
            pv.progress=progress;
        }];
        [self addSubview:pv];
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]]) {
                self.image = responseObject;
                [pv removeFromSuperview];
                self.af_imageRequestOperation = nil;
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [pv removeFromSuperview];
        }];
        
        self.af_imageRequestOperation = requestOperation;
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
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
        
        [self.photo setProgressImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]];
    }
}
-(void)stopLoadPhoto{
    [self.photo cancelImageRequestOperation];
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