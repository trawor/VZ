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

#define  QUERY_LIMIT 30

@interface VZPostListC ()
@property (nonatomic,retain) NSMutableArray *posts;
@property (nonatomic,copy) NSString *newid;
@property (nonatomic,copy) NSString *lastid;
@property (nonatomic)UIButton *moreBtn;
@end

@implementation VZPostListC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)dealloc
{
    [model removeObserver:self forKeyPath:@"showPostsWithPicsOnly"];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    
//    top.backgroundColor=[UIColor colorWithRed:0.10 green:0.22 blue:0.33 alpha:.3];
//    [self.view.superview insertSubview:top aboveSubview:self.view];
//    
//}



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
    
   
    
    //self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    //self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg2"]];
    
    self.posts=[NSMutableArray array];
    
    [self.refreshControl addTarget:self action:@selector(loadNew) forControlEvents:UIControlEventValueChanged];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 200, 44);
    btn.titleLabel.font=[UIFont systemFontOfSize:13];
    
    [btn setTitle:@"更多" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    //btn.hidden=YES;
    self.moreBtn=btn;
    
    self.tableView.tableFooterView=btn;
    
    [self.refreshControl beginRefreshing];
    [self loadNew];
    
    
    [model addObserver:self forKeyPath:@"showPostsWithPicsOnly" options:NSKeyValueObservingOptionNew context:nil];
    
    //[self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"showPostsWithPicsOnly"]) {
        [self.posts removeAllObjects];
        [self loadNew];
    }
}



-(void)onGetNewPosts:(NSArray*)objects{
    if (objects.count) {
//        NSArray *ids= [self.posts valueForKeyPath:@"objectId"];
//        for (AVObject *post in objects) {
//            NSString *pid=post.objectId;
//            if (![ids containsObject:pid]) {
//                [self.posts addObject:post];
//            }
//        }
        [self.posts addObjectsFromArray:objects];
        [self.posts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"wbid" ascending:NO]]];
        [self.tableView reloadData];
        self.newid=self.posts[0][@"wbid"];
        self.lastid=[self.posts lastObject][@"wbid"];
        
        //NSArray *ids= [self.posts valueForKeyPath:@"objectId"];
        //NSLog(@"%@",[ids description]);
    }
    //self.moreBtn.hidden=objects.count<QUERY_LIMIT;
}



-(AVQuery*)getQuery{
    //AVQuery *q=[AVQuery queryWithClassName:@"Post"];
    
    AVQuery *q=[VZPost query];
    
    [q orderByDescending:@"wbid"];
    
    [q setLimit:QUERY_LIMIT];
    [q whereKeyExists:@"pics"];
   
//    if (model.showPostsWithPicsOnly) {
//        
//    }
    [q whereKey:@"type" equalTo:@(0)];
    return q;
}

-(void)loadNew{
    AVQuery *q=[self getQuery];
    if (self.newid) {
        [q whereKey:@"wbid" greaterThan:self.newid];
    }
    
    __weak VZPostListC* ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [ws onGetNewPosts:objects];
        
        [ws.refreshControl endRefreshing];
        
    }];
}

-(IBAction)loadMore:(id)sender{
    if (!self.lastid) {return;};
    
    AVQuery *q=[self getQuery];
    
    [q whereKey:@"wbid" lessThan:self.lastid];
    
    __weak VZPostListC* ws=self;
    
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [ws onGetNewPosts:objects];
    
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //NSString *CellIdentifier = [NSString stringWithFormat:@"PostCell%d",indexPath.row%2];
    
    static NSString *CellIdentifier = @"PostCell0";
    VZPostCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.table=tableView;
    
    
    VZPost *post=self.posts[indexPath.row];
    
    cell.textLb.text= post.text;
    
    NSArray *pics=[post objectForKey:@"pics"];
    if (pics) {
        NSString *url=pics[0];
        url=[url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        
        [cell.photo setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]];
    }
    
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
        cell.infoLb.hidden=NO;
        cell.infoLb.text=[NSString stringWithFormat:@"¥ %@",price];
    }else {
        cell.infoLb.hidden=YES;
    }
    
    return cell;
}

//This function is where all the magic happens
-(void)tableView:(UITableView *)tableView willDisplayCell:(VZPostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.8];
    
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    scaleAnimation.duration = .5f;
    
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [cell.layer addAnimation:scaleAnimation forKey:@"scale"];

    
    
//    //1. Setup the CATransform3D structure
//    CATransform3D rotation;
//    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    rotation.m34 = 1.0/ -600;
//    
//    
//    //2. Define the initial state (Before the animation)
//    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//    
//    cell.layer.transform = rotation;
//    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    
//    
//    //3. Define the final state (After the animation) and commit the animation
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.8];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
    
    


}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}
@end
