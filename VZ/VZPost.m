//
//  VZPost.m
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPost.h"


@implementation VZPost
@dynamic text,geo;

+ (NSString *)parseClassName {
    return @"Post";
}

-(CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(self.geo.latitude, self.geo.longitude);
}

-(NSString*)title{
    return self.text;
}

-(NSString*)subtitle{
    int i=[[self objectForKey:@"type"] intValue];
    
    switch (i) {
        case 0:
            return @"出售";
            break;
        case 1:
            return @"求购";
            
        case 2:
            return @"交易完成";
    }
    
    return nil;
}

@end
