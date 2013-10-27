//
//  VZPost.h
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface VZPost : AVObject<AVSubclassing>

@property(nonatomic,copy) NSString *text;

//@property(nonatomic,retain) NSDictionary *user;

@end
