//
//  VZM.h
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZM : NSObject

@property(nonatomic,assign) BOOL showPostsWithPicsOnly;
@property(nonatomic,assign) BOOL showAroundOnly;

+(VZM*)shared;

@end

#define model [VZM shared]