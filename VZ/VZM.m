//
//  VZM.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZM.h"

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
        
    }
    return self;
}

@end
