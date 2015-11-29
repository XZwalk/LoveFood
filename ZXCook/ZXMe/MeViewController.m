//
//  MeViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/16.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MeViewController.h"
#import "MeTableViewCell.h"


@interface MeViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

    
    self.tabBarController.tabBar.hidden = NO;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 4;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"me";
    
    MeTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    
    NSArray *imageAry = @[@"news", @"green_book", @"garbage", @"star", @"i_swear"];
    
    NSArray *titleAry = @[@"消息列表", @"新书推荐", @"清除缓存", @"我的收藏", @"关于我们"];
    
    if (indexPath.section == 0) {
        [cell setValue:[UIImage imageNamed:imageAry[0]] forKeyPath:@"contentImageView.image"];

    } else {
        [cell setValue:[UIImage imageNamed:imageAry[indexPath.row + 1]] forKeyPath:@"contentImageView.image"];

    }
    
    
    if (indexPath.section == 0) {
        [cell setValue:titleAry[indexPath.row] forKeyPath:@"contentLabel.text"];
    } else {
        [cell setValue:titleAry[indexPath.row + 1] forKeyPath:@"contentLabel.text"];
        
    }
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"meToNews" sender:nil];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"meToBooks" sender:nil];
        } else if (indexPath.row == 1) {
            //该方法是根据一个路径, 计算该路径下的所有文件的大小, 并展示大小
            [self folderSizeAtPath:[self getPath]];
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"meToCollect" sender:nil];
        } else {
            
            [self performSegueWithIdentifier:@"meToAbout" sender:nil];
        }
        
    }
    
    
}

#pragma mark - 缓存清理

- (CGFloat)folderSizeAtPath:(NSString *)path
{
    //初始化一个文件管理类对象
    NSFileManager * fileManager = [NSFileManager defaultManager];
    CGFloat folderSize;
    
    //如果文件夹存在
    if ([fileManager fileExistsAtPath:path]) {
        //得到路径下的所有子路径
        NSArray * childerFiles = [fileManager subpathsAtPath:path];
        
        //遍历得到的每个路径下的文件, fileName就是一个已经拼接好的子路径
        for (NSString * fileName in childerFiles) {
            //可以剔除不计算大小的文件类型
            //字符串以什么结尾
            if ([fileName hasSuffix:@".mp4"] || [fileName hasSuffix:@".sqlite"]) {
                //NSLog(@"不计算");
            }else
            {
                //将子路径和主路径拼接起来组成完成的文件路径
                NSString * absolutePath = [path stringByAppendingPathComponent:fileName];
                //将主路径下所有的文件的大小加起来
                folderSize += [self filePathSize:absolutePath];
            }
        }
        
        //将计算好的缓存大小放到alertView上展示
        [self showCacheFileSizeToDelete:folderSize];
        //返回文件大小
        return folderSize;
    }

    //如果不存在返回0
    return 0;
    
}

//根据一个文件路径计算文件的大小
- (CGFloat)filePathSize:(NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //如果文件路径存在
    if ([fileManager fileExistsAtPath:path]) {
        //计算得到的是字节
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        //转换成兆单位
        return  size / 1024.0 / 1024.0;
        
    }
    //不存在直接返回0
    return 0;
}

//展示缓存大小
- (void)showCacheFileSizeToDelete:(CGFloat)fileSize
{
    if (fileSize < 0.01) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的手机很干净, 不需要清理" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show ];
        
        return;
    }
    NSString * string = [NSString stringWithFormat:@"缓存大小为:%.2fM,是否删除",fileSize];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"删除" otherButtonTitles:@"取消", nil];
    [alertView show ];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self clearCache:[self getPath]];
    }
    
    //取消cell的选中状态
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}



- (NSString *)getPath
{
    //得到缓存文件夹的路径
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSLog(@"%@", path);
    return path;
    
}

//删除缓存
- (void)clearCache:(NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString * fileName in childerFiles) {
            //如有需要,加入条件,过滤不想删除的文件
            if ([fileName hasSuffix:@".mp4"] || [fileName hasSuffix:@".sqlite"]) {
                //NSLog(@"不删除");
            }else{
                //拼接好文件路径
                NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
                //删除路径下的文件
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
        
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    self.tabBarController.tabBar.hidden = YES;
    
    
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    //meTONews
    
    //meToBooks
    if ([segue.identifier isEqualToString:@"meToNews"]) {
        
        
    } else if ([segue.identifier isEqualToString:@"meToBooks"]) {
        
        
    } else if ([segue.identifier isEqualToString:@"meToCollect"]) {
        
        
    } else if ([segue.identifier isEqualToString:@"meToAbout"]) {
        
        
    }
    
}


@end
