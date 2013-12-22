//
//  VZM.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZM.h"
#import <AVOSCloudSNS/AVUser+SNS.h>
#import <AVOSCloud/AVJSONRequestOperation.h>

@implementation VZTheme
+(void)changeTheme:(VZThemeType)theme{
    model.theme=theme;
    [[NSUserDefaults standardUserDefaults] setInteger:theme forKey:@"Theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(UIColor *)textColor{
    switch(model.theme){
        case VZThemeTypeLight:
            return [UIColor lightTextColor];
        case VZThemeTypeModern:
            return [UIColor whiteColor];
    }
    return nil;
}
+(UIColor *)bgColor{
    switch(model.theme){
        case VZThemeTypeLight:
            return [UIColor lightTextColor];
        case VZThemeTypeModern:
            return [UIColor clearColor];
    }
    return nil;
}

+(UIImage*)bgImage{
    switch(model.theme){
        case VZThemeTypeLight:
            return [UIImage imageNamed:@"bg"];
        case VZThemeTypeModern:
            return [UIImage imageNamed:@"bg2"];
    }
    return nil;
}

@end

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
        
        self.theme=[[NSUserDefaults standardUserDefaults] integerForKey:@"Theme"];
        
        AVHTTPClient *client=[[AVHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"vz.avosapps.com"]];
        self.client=client;
    }
    return self;
}
-(void)login:(AVUserResultBlock)callback{
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2858658895" andAppSecret:@"9d97c1cce2893cbdcdc970f05bc55fe4" andRedirectURI:@"http://vz.avosapps.com/oauth?type=weibo"];
    //[AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"31024382" andAppSecret:@"25c3e6b5763653d1e5b280884b45c51f" andRedirectURI:@"http://"];
    
    [AVOSCloudSNS loginWithCallback:^(NSDictionary* object, NSError *error) {
        if (error==nil && object) {
            [VZUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
                BOOL needSave=NO;
                if (![user objectForKey:@"avatar"]) {
                    [user setObject:object[@"avatar"] forKey:@"avatar"];
                    needSave=YES;
                }
                
                if (![user objectForKey:@"name"]) {
                    [user setObject:object[@"username"] forKey:@"name"];
                    needSave=YES;
                }
                if (needSave) {
                    [user save];
                }
                
                callback(user,error);
            }];
        }
        
    } toPlatform:AVOSCloudSNSSinaWeibo];
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

-(void)commentToWbid:(NSString*)wbid toCommentId:(NSString*)cid withText:(NSString*)text callback:(AVSNSResultBlock)callback{
    if (![AVOSCloudSNS doesUserExpireOfPlatform:AVOSCloudSNSSinaWeibo]) {
        NSDictionary *dict= [AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo];
        NSString *token=[dict objectForKey:@"access_token"];
        
        NSString *url=[NSString stringWithFormat:@"https://api.weibo.com/2/comments/%@.json",cid?@"reply":@"create"];
        
        NSMutableDictionary *param=[NSMutableDictionary dictionary];
        [param setObject:token forKey:@"access_token"];
        [param setObject:wbid forKey:@"id"];
        [param setObject:text forKey:@"comment"];
        if (cid) {
            [param setObject:cid forKey:@"cid"];
        }
        NSURLRequest *req=[self.client requestWithMethod:@"POST" path:url parameters:param];
        
        AVJSONRequestOperation *opt=[AVJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            callback(JSON,nil);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            callback(JSON,error);
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
    NSString *uid=nil;
    [self validateValue:&uid forKeyPath:@"authData.weibo.uid" error:nil];
    
    return uid;
}

-(void)findMyFriendOnWeibo:(AVArrayResultBlock)callback{
    NSString *uid=[self wbid];
    
    if (uid && ![AVOSCloudSNS doesUserExpireOfPlatform:AVOSCloudSNSSinaWeibo]) {
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
    }else{
        callback(Nil,[NSError errorWithDomain:@"vz" code:1 userInfo:nil]);
    }
}

-(void)watch:(BOOL)flat post:(VZPost*)post callback:(AVBooleanResultBlock)callback{
    if (flat) {
        [post.watchUsers addObject:post];
    }else{
        [post.watchUsers removeObject:self];
    }
    
    [post saveInBackgroundWithBlock:callback];
}

@end