//
//  VZM.h
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZPost.h"

#import <AVOSCloud/AVOSCloud.h>

#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloudSNS/AVUser+SNS.h>

#import <AVOSCloud/AVHTTPClient.h>

@interface VZM : NSObject

@property(nonatomic,assign) BOOL showPostsWithPicsOnly;
@property(nonatomic,assign) BOOL showAroundOnly;

@property(nonatomic,retain) AVHTTPClient *client;

+(VZM*)shared;

-(void)login:(AVSNSResultBlock)callback;
-(void)getCommentWithWbid:(NSString*)wbid callback:(AVArrayResultBlock)callback;
@end

#define model [VZM shared]


@interface VZUser : AVUser<AVSubclassing>

@property(nonatomic,copy) NSString *avatar;
//@property(nonatomic,readonly) NSString *wbid;
-(NSString*)wbid;

-(void)findMyFriendOnWeibo:(AVArrayResultBlock)callback;

@end