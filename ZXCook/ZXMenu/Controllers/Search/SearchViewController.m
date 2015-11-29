//
//  SearchViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/16.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultVC.h"


@interface SearchViewController ()<UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView2;

@property (nonatomic, strong) NSMutableArray *hotAry;


@property (nonatomic, strong) NSMutableArray *searchHistory;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //去掉黑色边框线
    [self.searchBar setBackgroundImage:[[UIImage alloc] init]];
    
    //设置黑色边框
    self.searchBar.layer.borderWidth = .3;

    //设置圆角
    self.searchBar.layer.cornerRadius = 10;
    
    
    self.searchBar.delegate = self;
    
    
    self.collectionView1.dataSource = self;
    self.collectionView1.delegate = self;
    
    
    self.collectionView2.dataSource = self;
    self.collectionView2.delegate = self;
    
    //打开非满屏滑动模式
    self.collectionView2.alwaysBounceVertical = YES;
    
    //加载热门搜索记录
    [self getNetHistory];
    
    //从本地plist文件中加载数据
    [self getPlistData];
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    
    tap.delegate = self;
    
    [self.view addGestureRecognizer:tap];
    
    
}

//导航栏返回按钮
- (IBAction)backToFirstPage:(UIBarButtonItem *)sender {
    
    
    if ([self.searchBar canResignFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    
    //搜索控件的子视图的第0个元素的子视图
    for (id obj in [searchBar.subviews[0] subviews]) {
        if ([obj isKindOfClass:[UIButton class]]) {
            
            //强转类型, 将id类型转为UIButton类型
            UIButton *cancleButton = (UIButton *)obj;
            //设置文字
            [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
            //设置文字颜色(颜色貌似改变不了)
            //[cancleButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }
    }
    return YES;
}

//搜索框取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([searchBar canResignFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    
    [searchBar setShowsCancelButton:NO animated:YES];
}


//点击键盘上的搜索按钮时触发此方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //如果搜索内容不为空
    if (searchBar.text.length != 0) {
        
        //往数组中添加数据
        //先判断搜索的内容是否已在数组中, 若存在则不加入
        if (![self.searchHistory containsObject:self.searchBar.text]) {
            [self.searchHistory addObject:self.searchBar.text];
        }
        
        [self.collectionView2 reloadData];
        
        if ([searchBar canResignFirstResponder]) {
            [searchBar resignFirstResponder];
        }
        
        [self performSegueWithIdentifier:@"searchResult" sender:searchBar.text];
        
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"输入内容不能为空"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}


/*
 每次进来先把plist文件里面的数据读出来存到数组中, 当点击搜索的时候把元素添加到数组中, 然后在页面被销毁的时候更新plist文件
 
 不能每次点击搜索的时候都更新一下plist文件, 这样每次都要重新创建对内存耗费较高, 故在页面即将消失的时候更新一下即可, 即被销毁的时候
 */


//将数据更新到plist文件中
- (void)updataSearchHistoryList
{
    
    //有一个很简单的数组去重方法, 看数组是否包含某个元素, 不需要一个个遍历比较
    NSString *dou = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@", dou);
    
    NSUserDefaults *user = [[NSUserDefaults alloc] initWithSuiteName:@"SearchHistoryList"];
    
    //将数组存入到本地plist文件中
    [user setObject:self.searchHistory forKey:@"array"];
    
    //立即执行存入操作, 这句不写的话, 当程序异常时数据可能丢失
    [user synchronize];
}


//当页面消失的时候更新数据到plist文件, 减小压力
//但是这里有一个bug, 如果我在当前页面搜索之后程序崩溃了(重新运行Xcode), 则历史数据就存不下来了
- (void)dealloc
{
    [self updataSearchHistoryList];
}


#pragma mark - 懒加载
- (NSMutableArray *)hotAry {
    if (!_hotAry) {
        self.hotAry = [@[] mutableCopy];
    }
    return _hotAry;
}

- (NSMutableArray *)searchHistory {
    if (!_searchHistory) {
        self.searchHistory = [@[] mutableCopy];
    }
    return _searchHistory;
}

#pragma mark - 获取数据
- (void)getNetHistory {
    
    NSString *url = @"http://121.40.54.242:80/HandheldKitchen/api/home/tblAssort!getWordcode.do";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *dataAry = dic[@"data"];
            
            for (NSDictionary *dic in dataAry) {
                [self.hotAry addObject:dic[@"name"]];
            }
            
            [self.collectionView1 reloadData];
            
        }
    }];
    
}


//从本地plist加载数据
- (void)getPlistData
{
    //plist文件的路径
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    
    //将文件名拼接到文件路径上
    NSString *plistPath = [[libraryPath stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:@"SearchHistoryList.plist"];
    
    //将文件初始化成OC对象
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    //取出对象
    NSArray *ary = dic[@"array"];
    
    for (NSString *str in ary) {
        //添加对象到数组
        //这里添加对象的时候不能在创建一个新的数组, 必须用这个, 因为后来往数组中添加元素时还要与原来的值比较, 所以里面必须存放plist里面的所有搜索数据
        [self.searchHistory addObject:str];
    }
    
    //刷新数据
    [self.collectionView2 reloadData];
    
}


#pragma mark - 清除历史记录

- (IBAction)cleanButtonAction:(UIButton *)sender {
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *plistPath = [[libraryPath stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:@"SearchHistoryList.plist"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    //删除plist文件
    if ([manager fileExistsAtPath:plistPath])
    {
        [manager removeItemAtPath:plistPath error:nil];
    }
    
    //清空数组
    [self.searchHistory removeAllObjects];
    
    
    //刷新数据
    [self.collectionView2 reloadData];
    
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 2000) {
        return self.hotAry.count;
    }
    return self.searchHistory.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 2000) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchOne" forIndexPath:indexPath];
        
        NSString *model = self.hotAry[indexPath.row];
        
        [cell setValue:model forKeyPath:@"label.text"];
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 10;
        
        cell.layer.borderWidth = .5;
        cell.layer.borderColor=[UIColor orangeColor].CGColor;
        
        return cell;
        
    } else {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchTwo" forIndexPath:indexPath];
        
        NSString *model = self.searchHistory[indexPath.row];
        
        [cell setValue:model forKeyPath:@"label.text"];
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 10;
        
        cell.layer.borderWidth = .5;
        cell.layer.borderColor=[UIColor orangeColor].CGColor;
        
        return cell;
    }
}



#pragma mark - UICollectionViewFlowLayout(自定义布局)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 2000) {
        return CGSizeMake((kScreenWidth - 50) / 4, 35);

    } else {
        return CGSizeMake((kScreenWidth - 40) / 3, 35);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//选中cell执行
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView.tag == 2000) {
        
        NSString *str = self.hotAry[indexPath.row];
        
        [self performSegueWithIdentifier:@"searchResult" sender:str];
    } else {
        
        NSString *str = self.searchHistory[indexPath.row];
        
        [self performSegueWithIdentifier:@"searchResult" sender:str];
    }
}


- (void)tapAction {
    
    if ([self.searchBar canResignFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view.superview class]));
    
#warning mark - tap手势和collectionViewCell的点击
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"SearchTwoCell"] || [NSStringFromClass([touch.view.superview class]) isEqualToString:@"SearchOneCell"]) {
    
//    if (touch.view == self.collectionView1) {
        return NO;
    }
    return  YES;
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchResult"]) {
        
        //去掉返回按钮右边的字体
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
        
        SearchResultVC *vc = (SearchResultVC *)segue.destinationViewController;
        
        vc.title = [NSString stringWithFormat:@"%@-搜索结果", sender];
        
        //更改导航栏字体的颜色, push之前和之后均可
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];        
        
        vc.searchContent = sender;
        
    }
    
    
    
}

@end
