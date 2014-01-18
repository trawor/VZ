//
//  VZNearC.m
//  VZ
//
//  Created by Travis on 13-11-2.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZNearC.h"
#import <AVOSCloud/AVImageRequestOperation.h>
#import <AVOSCloud/AVJSONRequestOperation.h>
#import "VZProgressView.h"
#import "VZPostViewC.h"

@interface VZNearC (){
    BOOL gotUserLocation;
    BOOL loading;
}

@property (nonatomic,retain) VZProgressView *refreshView;
@property (nonatomic,assign) CLLocationCoordinate2D lastCoor;
@end

@implementation VZNearC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [AVAnalytics beginLogPageView:@"地图页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"地图页面"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView.userTrackingMode=MKUserTrackingModeNone;
    
    self.refreshView=[[VZProgressView alloc] initWithWidth:44];
    [self.refreshView setProgress:1 animated:NO];
    self.refreshView.infinite=YES;
    self.navigationItem.titleView=self.refreshView;
}

-(void)reloadPosts{
    if (loading) {
        return;
    }
    loading=YES;
    if (!self.refreshView.infinite) {
        self.refreshView.infinite=YES;
    }
    
    MKCoordinateRegion  region= self.mapView.region;
    
    AVQuery *q= [VZPost query];
    [q whereKey:@"type" containedIn:@[@0,@2]];
    [q whereKeyExists:@"pics"];
    [q setLimit:60];
    
    float kilo=region.span.latitudeDelta*111.0*0.5;
    
    [q whereKey:@"geo" nearGeoPoint:[AVGeoPoint geoPointWithLatitude:region.center.latitude longitude:region.center.longitude] withinKilometers:kilo];
    
    __weak typeof(self) ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
        }else{
            if (objects.count) {
                for (VZPost *post in objects) {
                    NSUInteger index = [self.mapView.annotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation> otherAnnotation, NSUInteger idx, BOOL *stop) {
                        return [post coordinate].latitude==[otherAnnotation coordinate].latitude && [post coordinate].longitude==[otherAnnotation coordinate].longitude ;
                    }];
                    if (index == NSNotFound)
                    {
                        [ws.mapView addAnnotation:post];
                    }
                    
                }
            }
           
        }
        ws.refreshView.infinite=NO;
        [ws.refreshView setProgress:1 animated:NO];
        loading=NO;
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
        
        annotationView.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        annotationView.opaque = NO;
        annotationView.animatesDrop = YES;
        
    }
    

    
    
    VZPost *post=(id)annotation;
    if ([post isKindOfClass:[VZPost class]]) {
        
        int type=[[post objectForKey:@"type"] intValue];
        if (type==0) {
            annotationView.pinColor=MKPinAnnotationColorPurple;
            annotationView.rightCalloutAccessoryView.tintColor=[UIColor purpleColor];
        }else if (type==1){
            annotationView.pinColor=MKPinAnnotationColorRed;
            annotationView.rightCalloutAccessoryView.tintColor=[UIColor redColor];
        }else if (type==2){
            annotationView.pinColor=MKPinAnnotationColorGreen;
            annotationView.rightCalloutAccessoryView.tintColor=[UIColor greenColor];
        }
        
        
        NSDictionary *user=[post objectForKey:@"user"];
        NSString *url=user[@"avatar_large"];
        if(url==nil){
            url=user[@"avatar"];
            url=[url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
        }
        
        float h=32;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, h, h)];
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head"]];
        
        imageView.clipsToBounds=YES;
        imageView.layer.cornerRadius=h*0.5;
        
        annotationView.leftCalloutAccessoryView = imageView;
    }else{
        return nil;
    }
    result = annotationView;
    return result;
}

-(void)onGetLocation:(CLLocationCoordinate2D)location exact:(BOOL)exact{
    if (CLLocationCoordinate2DIsValid(self.lastCoor)) {
        CLLocationDistance dis=ABS([[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude]
                                      distanceFromLocation:
                                      [[CLLocation alloc] initWithLatitude:self.lastCoor.latitude longitude:self.lastCoor.longitude]
                                      ]);
        if (dis<5000) {
            return;
        }
    }
    
    
    self.lastCoor=location;
    gotUserLocation=YES;
    
    float kilo=10;
    if (exact==NO) {
        kilo=50;
    }
    
    MKCoordinateRegion  region=MKCoordinateRegionMakeWithDistance(location, kilo*1000,  kilo*1000);
    [self.mapView setRegion:region animated:YES];
    
    [self reloadPosts];
}

-(void)onLocationFail{
    gotUserLocation=YES;
    
    [self reloadPosts];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (gotUserLocation) {
        return;
    }
    [self onGetLocation:userLocation.location.coordinate exact:YES];
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    if (gotUserLocation) {
        return;
    }

    __weak typeof(self) ws=self;
    
    AVJSONRequestOperation *opt=[AVJSONRequestOperation
                                 JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:
                                                                  [NSURL URLWithString:@"http://api.map.baidu.com/location/ip?ak=08fadd5a7e397b10f4599c325ee55b9c&coor=bd09ll"]]
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                     
                                     NSDictionary *point=JSON[@"content"][@"point"];
                                     if (point) {
                                         [ws onGetLocation:CLLocationCoordinate2DMake([point[@"y"] floatValue], [point[@"x"] floatValue])
                                          exact:NO];
                                     }else{
                                         [ws onLocationFail];
                                     }
                                 }
                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                     [ws onLocationFail];
                                 }];
    
    [model.client enqueueHTTPRequestOperation:opt];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (!animated) {
        [self reloadPosts];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    VZPost *post=(id)view.annotation;
    
    if ([post isKindOfClass:[VZPost class]]) {
        VZPostViewC *pc=[self.storyboard instantiateViewControllerWithIdentifier:@"PostViewC"];
        pc.post=post;
        
        [self.navigationController pushViewController:pc animated:YES];
    }

}

-(void)didReceiveMemoryWarning{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

@end
