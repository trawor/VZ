//
//  VZNearC.m
//  VZ
//
//  Created by Travis on 13-11-2.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZNearC.h"
#import <UIImageView+AFNetworking.h>
@interface VZNearC (){
    BOOL gotUserLocation;
}
@property (nonatomic, retain) NSArray *posts;

@end

@implementation VZNearC


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView.userTrackingMode=MKUserTrackingModeNone;
}

-(void)reloadPosts{
    MKCoordinateRegion  region= self.mapView.region;
    
    AVQuery *q= [VZPost query];
    //[q whereKey:@"type" equalTo:@0];
    [q whereKeyExists:@"pics"];
    [q setLimit:30];
    
    float kilo=region.span.latitudeDelta*111.0;
    
    [q whereKey:@"geo" nearGeoPoint:[AVGeoPoint geoPointWithLatitude:region.center.latitude longitude:region.center.longitude] withinKilometers:kilo];
    
    __weak typeof(self) ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"%@",[error description]);
        }else{
            if (objects.count) {
                NSLog(@"get %d Post ",objects.count);
                ws.posts=objects;
                for (VZPost *post in objects) {
                    [ws.mapView addAnnotation:post];
                }
            }
           
        }
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView * result = nil;
    
    
    
    NSString * pinReusableIdentifier = @"PostCell";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
    if(annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReusableIdentifier];
        
        [annotationView setCanShowCallout:YES];
    }
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    annotationView.rightCalloutAccessoryView = button;
    
    annotationView.opaque = NO;
    annotationView.animatesDrop = YES;
    
    
    VZPost *post=(id)annotation;
    if ([post isKindOfClass:[VZPost class]]) {
        
        int type=[[post objectForKey:@"type"] intValue];
        if (type==0) {
            annotationView.pinColor=MKPinAnnotationColorGreen;
        }else if (type==1){
            annotationView.pinColor=MKPinAnnotationColorPurple;
        }else if (type==2){
            annotationView.pinColor=MKPinAnnotationColorRed;
        }
        
        NSDictionary *user=[post objectForKey:@"user"];
        NSString *url=user[@"avatar_large"];
        if(url==nil){
            url=user[@"avatar"];
            url=[url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
        }
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head"]];
        annotationView.leftCalloutAccessoryView = imageView;
    }else{
        return nil;
    }
    result = annotationView;
    return result;
    
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (gotUserLocation) {
        return;
    }
    gotUserLocation=YES;
    MKCoordinateRegion  region=MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5*1000,  5*1000);
    [mapView setRegion:region animated:YES];
    
    [self reloadPosts];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (!animated) {
        
    }
}


@end
