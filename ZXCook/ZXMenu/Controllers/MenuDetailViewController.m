//
//  MenuDetailViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MenuDetailViewController.h"
#import "MenuDetailView.h"
#import "MainViewController.h"



@interface MenuDetailViewController ()

@property (weak, nonatomic) IBOutlet MenuDetailView *useImageView;

@property (nonatomic, strong) UISearchBar *searchBar;



@end

@implementation MenuDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    
    self.searchBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    if (self.rect1.origin.x < (kScreenWidth - 30) / 2) {
        
        self.useImageView.frame = CGRectMake(0, 0, 0, kScreenHeight);
    } else {
        self.useImageView.frame = CGRectMake(kScreenWidth, 0, 0, kScreenHeight);
    }
    
    self.useImageView.menu = self.menu;
    
    [UIView animateWithDuration:1 animations:^{
        
        self.useImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }];
    
    self.useImageView.image = self.useImage;
    [self.view addSubview:self.useImageView];
    
    //导航栏的返回按钮只保留那个箭头,去掉后边的文字,在网上查了一些资料,最简单且没有副作用的方法
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    //打开图片视图的用户交互
    self.useImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    
    [self.useImageView addGestureRecognizer:tap];
    
    for (UIView *view in self.navigationController.view.subviews)
    {
        if ([view isKindOfClass:[UISearchBar class]])
        {
            self.searchBar = (UISearchBar *)view;
        }
    }
}


- (void)tapAction {
    
    MainViewController *vc = [MainViewController new];
    vc.nameID = self.menu.vegetable_id;
    vc.name = self.menu.name;
    [self.navigationController pushViewController:vc animated:YES];
    
}






- (void)dealloc
{
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
