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

#define gap 5

@interface VZPostViewC ()
@property (nonatomic,retain) VZProgressView *refreshView;
@property (nonatomic,retain) NSArray *comments;
@property (nonatomic,retain) UIView *container;

@end

@implementation VZPostViewC
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)loadPics{
    NSArray *pics=[self.post objectForKey:@"pics"];
    
    if (pics.count>0) {
        
        float w=self.view.frame.size.width-gap*2;
        float h=w/16*9;
        
        UIView *picContiner= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, h)];
        
        int c=MIN(pics.count, 5);
        
        UIImageView *lastV=nil;
        
        for (int i=0; i<c; i++) {
            float y=(c-i-1)*gap;
            UIImageView *imgv=[[UIImageView alloc] initWithFrame:CGRectMake(gap+i*gap, y, w-i*gap*2, h-y)];
            imgv.contentMode=UIViewContentModeScaleAspectFill;
            imgv.alpha=(c-i)*0.6/c+0.4;
            imgv.clipsToBounds=YES;
            if (lastV) {
                [picContiner insertSubview:imgv belowSubview:lastV];
            }else{
                [picContiner addSubview:imgv];
            }
            
            lastV=imgv;
            
            NSString *url=pics[i];
            url=[url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
            
            [imgv setImageWithURL:[NSURL URLWithString:url]
                 placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]];
        }
        
        self.tableView.tableHeaderView=picContiner;
        self.container=picContiner;
    }else{
        self.tableView.tableHeaderView=nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.tableView registerClass:[VZCommentCell class] forCellReuseIdentifier:@"CommentCell"];
    
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    self.refreshView=[[VZProgressView alloc] initWithWidth:44];
    self.refreshView.infinite=YES;
    
    
    self.navigationItem.titleView=self.refreshView;
    
	self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    //self.view.backgroundColor=[UIColor clearColor];
    [self loadPics];
    
    NSDictionary *comment=@{@"user":self.post[@"user"],@"text":self.post.text};
    self.comments=@[comment];
    [self.tableView reloadData];
    
    
    __weak typeof(self) ws=self;
    [model getCommentWithWbid:[self.post objectForKey:@"wbid"] callback:^(NSArray *objects, NSError *error) {
        if (objects.count) {
            NSMutableArray *arr=[NSMutableArray arrayWithObject:ws.comments[0]];
            [arr addObjectsFromArray:objects];
            ws.comments=arr;
            [ws.tableView reloadData];
        }
        ws.refreshView.infinite=NO;
        ws.refreshView.progress=1;
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
