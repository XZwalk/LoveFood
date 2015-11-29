//
//  MenuDetailViewController.h
//  ZXCook
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Menu.h"


@interface MenuDetailViewController : UIViewController

@property (nonatomic, strong) UIImage *useImage;
@property (nonatomic, assign) CGRect rect1;
@property (nonatomic, strong) Menu *menu;


@end
