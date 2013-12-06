//
//  VZPostCell.m
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostCell.h"
#import <AVOSCloud/AVImageRequestOperation.h>

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

@interface UIImageView ()
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AVImageRequestOperation *af_imageRequestOperation;
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
        
        AVImageRequestOperation *requestOperation = [[AVImageRequestOperation alloc] initWithRequest:urlRequest];
        
        
        VZProgressView *pv=[[VZProgressView alloc] initWithWidth:self.frame.size.width/2];
        pv.bgLineColor=[UIColor colorWithWhite:1 alpha:0.4];
        pv.fgLineColor=[UIColor whiteColor];
        
        [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float progress=totalBytesRead*1.0/totalBytesExpectedToRead;
            pv.progress=progress;
        }];
        [self addSubview:pv];
        
        [requestOperation setCompletionBlockWithSuccess:^(AVHTTPRequestOperation *operation, id responseObject) {
            if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]]) {
                self.image = responseObject;
                [pv removeFromSuperview];
                self.af_imageRequestOperation = nil;
            }
            
            [[[self class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AVHTTPRequestOperation *operation, NSError *error) {
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
        
        [self.photo setProgressImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[UIImage imageNamed:nil]];
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
    [self.photo cancelImageRequestOperation];
}

-(void)awakeFromNib{
//    self.textLabel.numberOfLines=3;
//    self.textLabel.font=[UIFont systemFontOfSize:14];
    
    //self.container.clipsToBounds=YES;
    //self.container.layer.cornerRadius=5;
    
//    self.priceLb.layer.borderColor=[UIColor whiteColor].CGColor;
//    self.priceLb.layer.borderWidth=1;
//    self.priceLb.backgroundColor=[UIColor colorWithWhite:0 alpha:0.3];
    self.priceLb.layer.cornerRadius=4;
    
    self.userAvatar.clipsToBounds=YES;
    //self.userAvatar.layer.cornerRadius=20;
    
    self.userAvatar.layer.borderWidth =1;
    
    self.userAvatar.layer.borderColor=[UIColor whiteColor].CGColor;
 
    self.photo.backgroundColor=[UIColor clearColor];
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
    
}

@end
