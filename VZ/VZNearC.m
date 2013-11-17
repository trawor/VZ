//
//  VZNearC.m
//  VZ
//
//  Created by Travis on 13-11-2.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZNearC.h"

@interface VZNearC ()
@property (nonatomic, retain) NSArray *posts;
@end

@implementation VZNearC


- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

-(void)reloadPosts{
    MKCoordinateRegion  region= self.mapView.region;
    
    AVQuery *q= [VZPost query];
    [q whereKey:@"type" equalTo:@0];
    [q whereKeyExists:@"pics"];
    [q whereKey:@"geo" nearGeoPoint:[AVGeoPoint geoPointWithLatitude:region.center.latitude longitude:region.center.longitude] withinKilometers:50];
    
    __weak typeof(self) ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error description]);
        }else{
            ws.posts=objects;
            for (VZPost *post in objects) {
                
            }
        }
    }];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion  region=MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 50*1000,  50*1000);
    [mapView setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self reloadPosts];
}

@end
