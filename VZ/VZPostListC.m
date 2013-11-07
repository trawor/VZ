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

#import <AVOSCloud/AVGlobal.h>

#define  REFRESH_HEIGHT 20
#define  REFRESH_TRIGGER 50

#define  QUERY_LIMIT 30
#define  ORDER_BY @"createdAt"

@interface VZPostListC (){
    BOOL updateRefreshView;
    BOOL showRefreshView;
    
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
    
    if (swipe.direction==UISwipeGestureRecognizerDirectionRight) {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
    
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    
    swipe.direction=UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipe];
    
    swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    
    swipe.direction=UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipe];
    

    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    
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
    
    
    
    int topH=300;
    
    UIView *topV= [[UIView alloc] initWithFrame:CGRectMake(0, -topH, self.view.frame.size.width, topH)];
    topV.backgroundColor=[UIColor colorWithWhite:0 alpha:0.4];
    
    
    self.refreshView=[[VZProgressView alloc] initWithWidth:REFRESH_HEIGHT*2];
    self.refreshView.autoCenter=NO;
    self.refreshView.center=CGPointMake(self.view.frame.size.width/2, topH-REFRESH_HEIGHT);
    [topV addSubview:self.refreshView];
    [self.view addSubview:topV];
    
    
    
    [self showRefresh];
    [self loadNew];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"showPostsWithPicsOnly"]) {
        [self.posts removeAllObjects];
        [self loadNew];
    }
}



-(void)onGetNewPosts:(NSArray*)objects isMore:(BOOL)isMore{
    if (objects.count) {
//        NSArray *ids= [self.posts valueForKeyPath:@"objectId"];
//        for (AVObject *post in objects) {
//            NSString *pid=post.objectId;
//            if (![ids containsObject:pid]) {
//                [self.posts addObject:post];
//            }
//        }
        
        objects=[objects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:ORDER_BY ascending:NO]]];
        
        
        int offset=0;
        if (isMore) {
            offset=self.posts.count;
        }else{
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
    
    [q orderByDescending:ORDER_BY];
    
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
        
        [ws onGetNewPosts:objects isMore:NO];
        
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
        
        [ws onGetNewPosts:objects isMore:YES];
        
        [av removeFromSuperview];
        [ws.moreBtn setTitle:@"更 多" forState:UIControlStateNormal];
        ws.moreBtn.userInteractionEnabled=YES;
    }];
}


-(void)hideRefreshView{
    if (updateRefreshView) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView setContentInset:UIEdgeInsetsZero];
        } completion:^(BOOL finished) {
            self.refreshView.infinite=NO;
            updateRefreshView=NO;
        }];
        
    }
}

-(void)showRefresh{
    if (updateRefreshView) {
        return;
    }
    
    updateRefreshView=YES;
    self.refreshView.infinite=YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(REFRESH_HEIGHT+REFRESH_TRIGGER, 0, 0, 0)];
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    float y=scrollView.contentOffset.y;
    if (!updateRefreshView && y<-REFRESH_HEIGHT-REFRESH_TRIGGER) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-y, 0, 0, 0)];
        
        [self showRefresh];
        [self loadNew];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float y=scrollView.contentOffset.y;
    if (!updateRefreshView && y<0) {
        [self.refreshView setProgress:(-y-REFRESH_TRIGGER)*1.0/REFRESH_HEIGHT animated:NO];
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
    VZPostViewC *pc=[[VZPostViewC alloc] init];
    pc.post=post;
    
    //[self.navigationController pushViewController:pc animated:YES];
}
@end
