//
//  VZPostListC.m
//  VZ
//
//  Created by Travis on 13-10-19.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZPostListC.h"
#import "UIViewController+REFrostedViewController.h"
#import <REFrostedViewController.h>
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.posts=[NSMutableArray array];
    
    [self.refreshControl addTarget:self action:@selector(loadNew) forControlEvents:UIControlEventValueChanged];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 200, 44);
    btn.titleLabel.font=[UIFont systemFontOfSize:13];
    
    [btn setTitle:@"更多" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    btn.hidden=YES;
    self.moreBtn=btn;
    
    self.tableView.tableFooterView=btn;
    
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

- (IBAction)menu:(id)sender {
    REFrostedViewController *ref=self.frostedViewController;
    [ref presentMenuViewController];
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
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
        
        NSArray *ids= [self.posts valueForKeyPath:@"objectId"];
        NSLog(@"%@",[ids description]);
    }
    self.moreBtn.hidden=objects.count<QUERY_LIMIT;
}



-(AVQuery*)getQuery{
    AVQuery *q=[AVQuery queryWithClassName:@"Post"];
    [q orderByDescending:@"wbid"];
    
    [q setLimit:QUERY_LIMIT];
    
    if (model.showPostsWithPicsOnly) {
        [q whereKeyExists:@"pics"];
    }
    //[q whereKey:@"type" equalTo:@(0)];
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
    static NSString *CellIdentifier = @"PostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines=3;
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    cell.imageView.contentMode=UIViewContentModeCenter;
    
    AVObject *post=self.posts[indexPath.row];
    
    cell.textLabel.text=[post objectForKey:@"text"];
    
    NSArray *pics=[post objectForKey:@"pics"];
    if (pics) {
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:pics[0]] placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]];
        
//        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pics[0]]]
//                              placeholderImage:[UIImage imageNamed:@"AppIcon57x57"]
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            [wc setNeedsLayout];
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            
//        }];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
