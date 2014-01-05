//
//  VZPostListC.m
//  VZ
//
//  Created by Travis on 13-10-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostListC.h"

#import "VZPost.h"
#import "VZPostCell.h"
#import <UIViewController+MMDrawerController.h>
#import <MMDrawerController.h>
#import "VZNavView.h"
#import <AVOSCloud/AVGlobal.h>

#define  QUERY_LIMIT 30
#define  ORDER_BY @"createdAt"

@interface VZPostListC (){
    BOOL updateRefreshView;
    BOOL dragStart;
    
    BOOL isAddNew;
}
@property (nonatomic,retain) NSMutableArray *posts;
@property (nonatomic,copy) NSString *newid;
@property (nonatomic,copy) NSString *lastid;
@property (nonatomic)UIButton *moreBtn;

@property (nonatomic,retain) VZProgressView *refreshView;

@end

@implementation VZPostListC


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)onSwipe:(UISwipeGestureRecognizer*)swipe{
    
    //[self menu:Nil];return;
    
//    if (swipe.direction==UISwipeGestureRecognizerDirectionRight) {
//        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//    }else {
//        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
//    }
    
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newid=[[NSUserDefaults standardUserDefaults] objectForKey:@"CacheCourse"];
    
    UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    
    swipe.direction=UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipe];
    
    swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    
    swipe.direction=UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipe];
    

    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[VZTheme bgImage]];
    
    self.posts=[NSMutableArray array];
    
    [self.refreshControl addTarget:self action:@selector(loadNew) forControlEvents:UIControlEventValueChanged];
    
    UIView *btmV=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.borderWidth=1;
    btn.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.8].CGColor;
    btn.clipsToBounds=YES;
    btn.layer.cornerRadius=4;
    btn.frame=CGRectMake(20, 10, 280, 40);
    btn.titleLabel.font=[UIFont systemFontOfSize:14];
    
    [btn setTitle:@"更 多" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    btn.hidden=YES;
    self.moreBtn=btn;
    
    [btmV addSubview:btn];
    self.tableView.tableFooterView=btmV;
    
    [self.tableView setContentInset:UIEdgeInsetsMake([VZNavView height], 0, 0, 0)];
    
    
    self.navigationItem.titleView=[VZNavView shared].refreshView;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleTap:)];
    [self.navigationItem.titleView addGestureRecognizer:tap];
    
    [self showRefresh];
    [self loadNew];
    
}

-(void)onTitleTap:(UITapGestureRecognizer*)tap{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 1) animated:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"showPostsWithPicsOnly"]) {
        [self.posts removeAllObjects];
        [self loadNew];
    }
}



-(void)onGetNewPosts:(NSArray*)objects isMore:(BOOL)isMore{
    if (objects.count) {
        NSMutableArray *newObjs=[NSMutableArray array];
        NSArray *ids= [self.posts valueForKeyPath:@"objectId"];
        for (AVObject *post in objects) {
            NSString *pid=post.objectId;
            if (![ids containsObject:pid]) {
                [newObjs addObject:post];
            }
        }
        
        objects=[newObjs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:ORDER_BY ascending:NO]]];
        
        
        int offset=0;
        if (isMore) {
            offset=self.posts.count;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:self.newid forKey:@"CacheCourse"];
            self.newid=objects[0][ORDER_BY];
        }
        
        NSIndexSet *iset=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(offset, objects.count)];
        
        [self.posts insertObjects:objects atIndexes:iset];
        if(objects.count>=QUERY_LIMIT){
            self.lastid=[[self.posts lastObject][ORDER_BY] copy];
            self.moreBtn.hidden=NO;
        }else{
            self.lastid=nil;
            self.moreBtn.hidden=YES;
        }
        
        [self.tableView reloadData];
        
    }
    
}


-(AVQuery*)getQuery{
    
    AVQuery *q=[VZPost query];
    q.cachePolicy=kPFCachePolicyCacheElseNetwork;
    [q orderByDescending:ORDER_BY];
    [q setMaxCacheAge:60*10];
    [q setLimit:QUERY_LIMIT];
    [q whereKeyExists:@"pics"];
    [q whereKey:@"type" equalTo:@(0)];
    return q;
}

-(void)loadNew{
    AVQuery *q=[self getQuery];
    if (self.newid) {
        [q whereKey:ORDER_BY greaterThan:self.newid];
    }
    
    __weak VZPostListC* ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"出错了" andMessage:[error localizedDescription]];
            
            [alertView addButtonWithTitle:@"重试"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [ws loadNew];
                                  }];
            
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [ws.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            
            [alertView show];
        }else{
            [ws onGetNewPosts:objects isMore:NO];
        }
        
        [self hideRefreshView];
    }];
}

-(IBAction)loadMore:(id)sender{
    if (!self.lastid) {return;};
    
    AVQuery *q=[self getQuery];
    
    [q whereKey:ORDER_BY lessThan:self.lastid];
    
    self.lastid=nil;
    
    __weak VZPostListC* ws=self;
    [ws.moreBtn setTitle:@"" forState:UIControlStateNormal];
    
    UIActivityIndicatorView *av=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    av.center=ws.moreBtn.center;
    [av startAnimating];
    [ws.moreBtn.superview addSubview:av];
    ws.moreBtn.userInteractionEnabled=NO;
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"出错了" andMessage:[error localizedDescription]];
            
            [alertView addButtonWithTitle:@"重试"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [ws loadNew];
                                  }];
            
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alert) {
                                      [ws.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            
            [alertView show];
        }else{
            [ws onGetNewPosts:objects isMore:YES];
            
            [av removeFromSuperview];
            [ws.moreBtn setTitle:@"更 多" forState:UIControlStateNormal];
        }
        
        ws.moreBtn.userInteractionEnabled=YES;
    }];
}


-(void)hideRefreshView{

    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake([VZNavView height], 0, 0, 0)];
    } completion:^(BOOL finished) {
        [VZNavView shared].refreshView.infinite=NO;
        [VZNavView shared].refreshView.progress=1;
        updateRefreshView=NO;
    }];
    
}

-(void)showRefresh{
    if (updateRefreshView) {
        return;
    }
    
    updateRefreshView=YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake([VZNavView height]+REFRESH_TRIGGER, 0, 0, 0)];
    }];

    [VZNavView shared].refreshView.infinite=YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    dragStart=YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    float y=scrollView.contentOffset.y;
    
    if (!updateRefreshView && y<=-REFRESH_TRIGGER-REFRESH_HEIGHT) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-y, 0, 0, 0)];
        
        [self showRefresh];
        [self loadNew];
        
        dragStart=NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float y=scrollView.contentOffset.y;
    
    if (dragStart && !updateRefreshView && y<0) {
        [[VZNavView shared].refreshView setProgress:(1.0-(-y-REFRESH_HEIGHT)*1.0f/REFRESH_TRIGGER) animated:NO];
    }
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PostCell0";
    VZPostCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.table=tableView;
    
    
    VZPost *post=self.posts[indexPath.row];
    cell.post=post;
    cell.textLb.text= post.text;
    
    
    NSDictionary *user=[post objectForKey:@"user"];
    NSString *url=user[@"avatar"];
    
    if (url) {
        url=[url stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
    }
    
    [cell.userAvatar setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head"]];
    
    
    AVGeoPoint *geo=[post objectForKey:@"geo"];
    
    if (geo) {
        cell.geoIcon.hidden=NO;
    }else{
        cell.geoIcon.hidden=YES;
    }
    
    NSString *price=[post objectForKey:@"price"];
    if (price) {
        cell.priceLb.hidden=NO;
        cell.priceLb.text=[NSString stringWithFormat:@"¥ %@",price];
    }else {
        cell.priceLb.hidden=YES;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(VZPostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if (cell.canAnimate) {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.8];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
        scaleAnimation.duration = .5f;
        
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [cell.layer addAnimation:scaleAnimation forKey:@"scale"];
        
        cell.canAnimate=NO;
    }
    
    [cell loadPhoto];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(VZPostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.canAnimate=YES;
    [cell stopLoadPhoto];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VZPost *post=self.posts[indexPath.row];
    VZPostViewC *pc=[self.storyboard instantiateViewControllerWithIdentifier:@"PostViewC"];
    pc.post=post;
    
//    self.mm_drawerController.rightDrawerViewController=pc;
//    
//    [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    
    [self.navigationController pushViewController:pc animated:YES];
}
@end
