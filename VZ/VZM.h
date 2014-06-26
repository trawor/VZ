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

BOOL is7orLater();

typedef enum{
    VZThemeTypeModern =0,
    VZThemeTypeLight
} VZThemeType;

@interface VZTheme: NSObject
+(void)changeTheme:(VZThemeType)theme;
+(UIColor *)textColor;
+(UIColor *)bgColor;
+(UIImage*)bgImage;
@end


@interface VZM : NSObject

@property(nonatomic,assign) BOOL showAroundOnly;

@property(nonatomic,assign) BOOL showPostsWithPicsOnly;
@property(nonatomic,assign) VZThemeType theme;

@property(nonatomic,retain) AVHTTPClient *client;

+(VZM*)shared;

+(NSString*)storeIdOfURL:(NSString*)url;

-(void)login:(AVUserResultBlock)callback;
-(void)logout;

-(void)getCommentWithWbid:(NSString*)wbid callback:(AVArrayResultBlock)callback;
-(void)commentToWbid:(NSString*)wbid toCommentId:(NSString*)cid withText:(NSString*)text callback:(AVSNSResultBlock)callback;

-(void)uploadImage:(UIImage*)image callback:(AVSNSResultBlock)callback;
@end

#define model [VZM shared]


@interface VZUser : AVUser<AVSubclassing>

@property(nonatomic,copy) NSString *avatar;
@property(nonatomic,readonly) NSString *wbid;
-(NSString*)wbid;


/**
 *  查找来自微博的好友
 *
 *  @param callback 回调返回好友ID数字
 */
-(void)findMyFriendOnWeibo:(AVArrayResultBlock)callback;

-(void)watch:(BOOL)flat post:(VZPost*)post callback:(AVBooleanResultBlock)callback;
@end
