//
//  VZPostViewC.m
//  VZ
//
//  Created by Travis on 13-11-1.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostViewC.h"
#import <UIImageView+AFNetworking.h>
#import <UIViewController+MMDrawerController.h>

#import "VZCommentCell.h"

#import "VZNavView.h"

#import "VZStacView.h"

#import "VZMenuC.h"

#define gap 5

@interface VZPostViewC ()<VZStacViewDelegate,UITextFieldDelegate>
@property (nonatomic,retain) VZProgressView *refreshView;
@property (nonatomic,retain) NSArray *comments;
@property (nonatomic,retain) VZStacView *stac;

@property (nonatomic,retain) UIView *bottomView;
@property (nonatomic,retain) UITextField *inputView;
@property (nonatomic,retain) UIImageView *userView;

@end

@implementation VZPostViewC
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return NO;
}

-(void)stacViewOpenChanged:(VZStacView *)stacView{
    if (stacView.open==NO) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 0) animated:YES];
    }
    self.tableView.tableHeaderView=stacView;
}

-(void)loadPics{
    NSArray *pics=[self.post objectForKey:@"pics"];
    
    if (pics.count>0) {
        
        float h=240;
        
        if (self.stac) {
            [self.stac removeFromSuperview];
        }
        
        VZStacView *sv=[[VZStacView alloc]
                        initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, h)];
        sv.delegate=self;
        for (int i=pics.count-1; i>=0; i--) {
            
            NSString *url=pics[i];
            url=[url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
            AFImageRequestOperation *opt=[AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] success:^(UIImage *image) {
                [sv addImage:image];
            }];
            
            [model.client enqueueHTTPRequestOperation:opt];
        }
        
        self.stac=sv;
        self.tableView.tableHeaderView=sv;
        
    }else{
        self.tableView.tableHeaderView=nil;
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float y=scrollView.contentOffset.y;
    
    [self.stac scroll:y];
}

-(void)onBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    UIView *bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
    //bottomView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.7];
    
    UIImageView *userV=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    userV.layer.cornerRadius=20;
    userV.clipsToBounds=YES;
    [bottomView addSubview:userV];
    self.userView=userV;
    
    UIImageView *ivBg=[[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 260, 40)];
    ivBg.image=[[UIImage imageNamed:@"chatBg"] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
    
    [bottomView addSubview:ivBg];
    
    UITextField *tf=[[UITextField alloc] initWithFrame:CGRectMake(65, 25, 230, 40)];
    tf.font=[UIFont systemFontOfSize:14];
    tf.textColor=[UIColor darkTextColor];
    tf.returnKeyType=UIReturnKeySend;
    tf.keyboardAppearance=UIKeyboardAppearanceAlert;
    
    NSArray *cms=@[@"能便宜吗?",@"出了吗?",@"小刀一下吧"];
    int rdm=arc4random()%cms.count;
    tf.placeholder=cms[rdm];
    
    [bottomView addSubview:tf];
    tf.delegate=self;
    self.bottomView=bottomView;
    
    self.refreshView=[[VZProgressView alloc] initWithWidth:44];
    
    self.navigationItem.titleView=self.refreshView;
    
    UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    self.navigationItem.leftBarButtonItem=btn;
    
    UIBarButtonItem *btn2=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dots"] style:UIBarButtonItemStylePlain target:self action:@selector(menu:)];
    self.navigationItem.rightBarButtonItem=btn2;
    
	self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    
    [self loadPics];
    
    NSDictionary *comment=@{@"user":self.post[@"user"],@"text":self.post.text};
    self.comments=@[comment];
    [self.tableView reloadData];
    
    [self loadComments];
}

-(void)sendComment{
    NSString *s= self.inputView.text;
    if (s.length==0) {
        s=self.inputView.placeholder;
    }
    
    //TODO: send it
}

-(void)loadComments{
    self.refreshView.infinite=YES;
    [self.userView setImageWithURL:[NSURL URLWithString:[[AVOSCloudSNS userInfo:AVOSCloudSNSSinaWeibo] objectForKey:@"avatar"]]
                  placeholderImage:[UIImage imageNamed:@"head"]];
    
    __weak typeof(self) ws=self;
    [model getCommentWithWbid:[self.post objectForKey:@"wbid"] callback:^(NSArray *objects, NSError *error) {
        
        if (error) {
            if ([error.domain isEqualToString:@"vz"] && error.code==1) {
                UIView *btmV=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
                
                UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
                btn.layer.borderWidth=1;
                btn.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.8].CGColor;
                btn.clipsToBounds=YES;
                btn.layer.cornerRadius=4;
                btn.frame=CGRectMake(60, 10, 200, 40);
                btn.titleLabel.font=[UIFont systemFontOfSize:14];
                
                [btn setTitle:@"登录微博, 查看评论" forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
                [btn addTarget:ws action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
                [btmV addSubview:btn];
                ws.tableView.tableFooterView=btmV;
            }else{
                ws.tableView.tableFooterView=self.bottomView;
            }
        }else {
            ws.tableView.tableFooterView=self.bottomView;
            if (objects.count){
                NSMutableArray *arr=[NSMutableArray arrayWithObject:ws.comments[0]];
                [arr addObjectsFromArray:objects];
                ws.comments=arr;
                [ws.tableView reloadData];
            }
        }
        ws.refreshView.infinite=NO;
        ws.refreshView.progress=1;
    }];
}

-(void)menu:(UIBarButtonItem*)btn{
    
    if (self.mm_drawerController.openSide==MMDrawerSideRight) {
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            self.mm_drawerController.rightDrawerViewController=nil;
        }];
        
    }else{
        self.mm_drawerController.rightDrawerViewController=[UIViewController new];
        
        [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

-(void)login{
    __weak typeof(self) ws=self;
    [model login:^(id object, NSError *error) {
        if (error) {
            NSLog(@"login error %@",[error description]);
        }else if(object){
            [ws loadComments];
            
            [self.mm_drawerController.leftDrawerViewController performSelector:@selector(onLogin:) withObject:object];
        }
    }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section==0) {
//        UIView *toolView=[[UIView alloc] initWithFrame:CGRectMake(0, 5, 320, 40)];
//        
//        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
//        btn.layer.borderWidth=1;
//        btn.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.8].CGColor;
//        btn.clipsToBounds=YES;
//        btn.layer.cornerRadius=4;
//        btn.frame=CGRectMake(10, 0, 60, 40);
//        btn.titleLabel.font=[UIFont systemFontOfSize:14];
//        
//        [btn setTitle:@"收藏" forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
//        
//        [toolView addSubview:btn];
//        
//        
//        return toolView;
//        
//    }
//    
//    return nil;
//}
//
//-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 50;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *comment=self.comments[indexPath.row];
    NSString *text= comment[@"text"];
    
    CGSize size= [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(220, 500)];
    
    return MAX(size.height+35, 50);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *comment=self.comments[indexPath.row];
    NSDictionary *user=[comment objectForKey:@"user"];
    
    NSString *CellIdentifier = @"CommentCell";
    
    NSString *idstr=user[@"idstr"];
    if (idstr==nil ||
        [idstr isEqualToString:self.post[@"user"][@"id"]]) {
        CellIdentifier = @"CommentCell2";
    }
    
    
    VZCommentCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[VZCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    
    cell.textLb.text= comment[@"text"];
    
    
    NSString *url=user[@"avatar_large"];
    if(url==nil){
        url=user[@"avatar"];
        url=[url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
    }
    
    [cell.avatarView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head"]];
    
    
    
    return cell;
}



@end
