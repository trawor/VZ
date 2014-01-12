//
//  VZStatusListC.m
//  VZ
//
//  Created by Travis on 14-1-5.
//  Copyright (c) 2014年 Plumn LLC. All rights reserved.
//

#import "VZStatusListC.h"
#import "VZM.h"
#import "VZNavView.h"
#import "VZWebViewC.h"
#import <AVOSCloud/AVStatus.h>

@interface VZStatusListC (){
    BOOL dragStart;
    BOOL updateRefreshView;
}
@property (nonatomic,strong) NSArray *statuses;
@property (nonatomic,retain) VZProgressView *refreshView;
@end

@implementation VZStatusListC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[VZTheme bgImage]];
    
    self.navigationItem.titleView=self.refreshView=[VZProgressView new];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleTap:)];
    [self.navigationItem.titleView addGestureRecognizer:tap];
    
    [self showRefresh];
    [self loadNew];
    
    
}
-(void)onTitleTap:(UITapGestureRecognizer*)tap{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 10, 1) animated:YES];
}

-(void)hideRefreshView{
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake([VZNavView height], 0, 0, 0)];
    } completion:^(BOOL finished) {
        self.refreshView.infinite=NO;
        self.refreshView.progress=1;
        updateRefreshView=NO;
    }];
    
}

-(void)showRefresh{
    if (updateRefreshView) {
        return;
    }
    
    updateRefreshView=YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
    
    self.refreshView.infinite=YES;
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
        [self.refreshView setProgress:(1.0-(-y-REFRESH_HEIGHT)*1.0f/REFRESH_TRIGGER) animated:NO];
    }
}


-(void)loadNew{
    __weak typeof(self) ws=self;
    [AVStatus getStatusesWithType:kAVStatusTypeTimeline skip:0 limit:100 andCallback:^(NSArray *objects, NSError *error) {
        
        AVStatus *status=[[AVStatus alloc] init];
        [status setData:@{
                          @"text":@"hello link",
                          @"content":@"http://baidu.com",
                          }];
        
        AVStatus *status3=[[AVStatus alloc] init];
        [status3 setData:@{
                          @"text":@"hello store",
                          @"content":@"http://itunes.apple.com/us/app/iq-test-sale/id297141027?mt=8&uo=6",
                          }];
        
        AVStatus *status2=[[AVStatus alloc] init];
        [status2 setData:@{
                          @"text":@"hello post",
                          @"content":@"post://52342342343",
                          }];
        
        objects=@[status,status2,status3];
        
        ws.statuses=objects;
        [ws.tableView reloadData];
        [ws hideRefreshView];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    AVStatus *status=[self.statuses objectAtIndex:indexPath.row];
    NSDictionary *data=status.data;
    
    cell.textLabel.text=data[@"text"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AVStatus *status=[self.statuses objectAtIndex:indexPath.row];
    NSDictionary *data=status.data;
    NSString *content= data[@"content"];
    
    NSArray *cpt=[content componentsSeparatedByString:@"://"];
    
    NSString *scheme=cpt[0];
    
    if ([scheme hasPrefix:@"post"]) {
        VZPost *post=[VZPost objectWithoutDataWithObjectId:cpt[1]];
        [post fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            
        }];
    }else if([scheme hasPrefix:@"http"]){
        VZWebViewC *webc=[[VZWebViewC alloc] init];
        
        [webc loadURL:content];
        
        [self.navigationController pushViewController:webc animated:YES];
    }
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
