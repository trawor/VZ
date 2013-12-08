//
//  VZPost.h
//  VZ
//
//  Created by Travis on 13-10-26.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>
#import <MapKit/MapKit.h>
@interface VZPost : AVObject<AVSubclassing,MKAnnotation>

@property(nonatomic,copy) NSString *text;
@property(nonatomic,retain) AVGeoPoint *geo;
@property(nonatomic,retain) AVRelation *watchUsers;

//@property(nonatomic,retain) NSDictionary *user;

@end
