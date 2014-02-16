//
//  VZSearchBar.h
//  VZ
//
//  Created by Travis on 14-2-13.
//  Copyright (c) 2014年 Plumn LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VZSearchBar;
@protocol VZSearchBar <NSObject,UITextFieldDelegate>

-(void)onSearchBarClose:(VZSearchBar*)searchBar;

@end

@interface VZSearchBar : UITextField
-(void)tiny;
@end
