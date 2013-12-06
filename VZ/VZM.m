//
//  VZM.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZM.h"

#import <AVOSCloud/AVJSONRequestOperation.h>
@implementation VZM
+(VZM*)shared{
    static VZM *_vzm_=Nil;
    if (_vzm_==Nil) {
        _vzm_=[VZM new];
    }
    
    return _vzm_;
}


- (id)init
{
    self = [super init];
    if (self) {
        [VZPost registerSubclass];
        [VZUser registerSubclass];
        
        AVHTTPClient *client=[[AVHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"vz.avosapps.com"]];
        self.client=client;
    }
    return self;
}
-(void)login:(AVSNSResultBlock)callback{
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2858658895" andAppSecret:@"9d97c1cce2893cbdcdc970f05bc55fe4" andRedirectURI:@"http://"];
    //[AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"31024382" andAppSecret:@"25c3e6b5763653d1e5b280884b45c51f" andRedirectURI:@"http://"];
    
    [AVOSCloudSNS loginWithCallback:callback toPlatform:AVOSCloudSNSSinaWeibo];
}

-(void)getCommentWithWbid:(NSString*)wbid callback:(AVArrayResultBlock)callback{
    if (![AVOSCloudSNS doesUserExpireOfPlatform:AVOSCloudSNSSinaWeibo]) {
        NSDictionary *dict= [AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo];
        NSString *token=[dict objectForKey:@"access_token"];
        
        NSString *url=[NSString stringWithFormat:@"https://api.weibo.com/2/comments/show.json?id=%@&access_token=%@",wbid,token];
        NSURLRequest *req=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        AVJSONRequestOperation *opt=[AVJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSArray *arr= JSON[@"comments"];
            if (arr) {
                NSArray *shuma=@[@"2043408047",@"1761596064",@"1882458640",@"1841288857",@"3787475667",@"3701452524"];
                
                NSMutableArray *a=[NSMutableArray array];
                
                for (NSDictionary *comment in arr) {
                    NSString *idstr=comment[@"user"][@"idstr"];
                    if ([shuma containsObject:idstr]) {
                        continue;
                    }
                    
                    [a addObject:comment];
                }
                
                [a sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"idstr" ascending:YES]]];
                callback(a,nil);
            }else{
                callback(Nil,Nil);
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            callback(Nil,error);
            NSLog(@"%@", [error description]);
        }];
        
        [self.client enqueueHTTPRequestOperation:opt];
    }else{
        callback(nil,[NSError errorWithDomain:@"vz" code:1 userInfo:nil]);
    }
    
    
}



@end




@implementation VZUser
@dynamic avatar;
+ (NSString *)parseClassName {
    return @"_User";
}

-(NSString*)wbid{
    return [self valueForKeyPath:@"authData.weibo.uid"];
}

-(void)findMyFriendOnWeibo:(AVArrayResultBlock)callback{
    NSString *uid=[self wbid];
    NSString *token=[[self objectForKey:@"authData"] valueForKeyPath:@"weibo.access_token"];
    
    NSString *url=[NSString stringWithFormat:@"https://api.weibo.com/2/friendships/friends/ids.json?uid=%@&access_token=%@",uid,token];
    NSURLRequest *req=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AVJSONRequestOperation *opt=[AVJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *arr= JSON[@"ids"];
        if (arr) {
            AVQuery *q=[VZUser query];
            [q whereKey:@"authData.weibo.uid" containedIn:arr];
            
            [q findObjectsInBackgroundWithBlock:callback];
        }else{
            callback(Nil,Nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        callback(Nil,error);
    }];
    
    [model.client enqueueHTTPRequestOperation:opt];
}



@end