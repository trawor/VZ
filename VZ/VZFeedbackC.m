//
//  VZFeedbackC.m
//  VZ
//
//  Created by Travis on 14-1-18.
//  Copyright (c) 2014年 Plumn LLC. All rights reserved.
//

#import "VZFeedbackC.h"
#import <SIAlertView/SIAlertView.h>
@interface AVAnalyticsUtils : NSObject

+(NSMutableDictionary *)deviceInfo;

@end

@interface VZFeedbackC ()
@property(nonatomic,weak) IBOutlet UITextView *textView;
@end

@implementation VZFeedbackC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)send:(id)a{
    if (self.textView.text.length<6) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"提示" andMessage:@"请您再多说几句吧"];
        
        [alertView addButtonWithTitle:@"确定"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        
        [alertView show];
    }else{
        [self.textView resignFirstResponder];
        self.view.userInteractionEnabled=NO;
        
        AVObject *fb=[AVObject objectWithClassName:@"Feedback"];
        if ([VZUser currentUser]) {
            [fb setObject:[VZUser currentUser] forKey:@"from"];
        }
        
        [fb setObject:[AVAnalyticsUtils deviceInfo] forKey:@"deviceInfo"];
        
        [fb setObject:self.textView.text forKey:@"text"];
        
        __weak typeof(self) ws=self;
        [fb saveEventually:^(BOOL succeeded, NSError *error) {
            ws.view.userInteractionEnabled=YES;
            
            NSString *title=succeeded?@"发送成功":@"发送失败";
            
            NSString *msg=succeeded?@"谢谢您的反馈,这对我们非常重要.":[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
            
            if (succeeded) {
                [alertView addButtonWithTitle:@"确定"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          [ws.navigationController popToRootViewControllerAnimated:YES];
                                      }];
            }else{
                [alertView addButtonWithTitle:@"重试"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          [ws send:Nil];
                                      }];
                [alertView addButtonWithTitle:@"取消"
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alert) {
                                          [ws.navigationController popToRootViewControllerAnimated:YES];
                                      }];

            }
            
            
            
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            
            [alertView show];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
    [AVAnalytics beginLogPageView:@"意见反馈"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AVAnalytics endLogPageView:@"意见反馈"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[VZTheme bgImage]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
