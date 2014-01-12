//
//  VZWebViewC.m
//  VZ
//
//  Created by Travis on 14-1-7.
//  Copyright (c) 2014年 Plumn LLC. All rights reserved.
//

#import "VZWebViewC.h"
#import "VZProgressView.h"


@interface VZWebViewC ()<SKStoreProductViewControllerDelegate>
@property(nonatomic,strong) VZProgressView *refreshView;
@end

@implementation VZWebViewC


- (id)init
{
    self = [super init];
    if (self) {
        self.webView=[[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.webView];
        
        self.webView.delegate=self;
        
        self.webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.titleView=self.refreshView=[VZProgressView new];
    self.refreshView.progress=1;
    
}


-(void)loadURL:(NSString*)url{
    NSURLRequest *req=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:req];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url=request.URL;
    if ([url.host hasPrefix:@"itunes.apple.com"]) {
        NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:@"id([0-9]{8,})" options:0 error:nil];
        NSTextCheckingResult *result= [re firstMatchInString:url.path options:NSMatchingReportCompletion range:NSMakeRange(0, url.path.length)];
        
        if (result) {
            NSString *storeId=[url.path substringWithRange:[result rangeAtIndex:1]];
            if (storeId) {
                __weak typeof(self) ws=self;
                
                SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
                // Configure View Controller
                [storeProductViewController setDelegate:(id)self];
                [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : storeId}
                 
                                                      completionBlock:^(BOOL result, NSError *error) {
                                                          if (error) {
                                                              NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                                                              
                                                              SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"出错了" andMessage:[error localizedDescription]];
                                                              
                                                              [alertView addButtonWithTitle:@"确定"
                                                                                       type:SIAlertViewButtonTypeCancel
                                                                                    handler:^(SIAlertView *alert) {
                                                                                        
                                                                                    }];
                                                              
                                                              alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                              
                                                              [alertView show];
                                                              
                                                          } else {
                                                              // Present Store Product View Controller             
                                                              [self presentViewController:storeProductViewController animated:YES completion:nil];        
                                                          }
                                                          
                                                          ws.refreshView.infinite=NO;
                                                      }];
                
                self.refreshView.infinite=YES;
                return NO;
            }
        }
        
    }
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.refreshView.infinite=YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.refreshView.infinite=NO;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.refreshView.infinite=NO;
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"出错了" andMessage:[error localizedDescription]];
    
    [alertView addButtonWithTitle:@"确定"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    
    [alertView show];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
