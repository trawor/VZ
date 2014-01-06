//
//  VZPostActionC.h
//  VZ
//
//  Created by Travis on 13-12-8.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VZPostViewC;
@interface VZPostActionC : UITableViewController
@property(nonatomic,assign) BOOL isAuthor;
@property(weak) VZPostViewC *delegate;
@end
