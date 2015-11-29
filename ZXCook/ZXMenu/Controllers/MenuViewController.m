//
//  MenuViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MenuViewController.h"
#import "NetworkHelper.h"
#import "MenuCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "MenuDetailViewController.h"
#import "Menu.h"
#import "SpreadCollectionController.h"
#import "SDCycleScrollView.h"
#import "MainViewController.h"


@interface MenuViewController ()<NetworkHelperDelegate, UICollectionViewDelegateFlowLayout, SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *dataAry;

@property (nonatomic, assign) BOOL isDownRefresh;

@property (nonatomic, assign) int page;

@property (nonatomic, strong) UIToolbar *bar;
@property (nonatomic, assign) CGFloat lastContentOffset;


@end

@implementation MenuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden =NO;
    self.searchBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSearchbarToNavigationItem];
    
    self.page = 1;
    [self getData:self.page];
    [self addRefresh];
    
    
    [self addSuspendButton];
}

#pragma mark - 懒加载
- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        self.imageArray = [@[] mutableCopy];
    }
    return _imageArray;
}

- (NSMutableArray *)dataAry {
    
    if (!_dataAry) {
        self.dataAry = [@[] mutableCopy];
    }
    return _dataAry;
}

- (void)addRefresh {
    
    __weak MenuViewController *blockSelf = self;
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        blockSelf.isDownRefresh = YES;
        
        [blockSelf getData:1];
        
    }];
    
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        blockSelf.isDownRefresh = NO;
        
        blockSelf.page++;
        
        [blockSelf getData:blockSelf.page];
    }];
    
    self.collectionView.footer.hidden = YES;
}




#pragma mark - 得到数据
- (void)getData:(int)page {
    
    
    NSString *url = [NSString stringWithFormat:@"http://121.40.54.242:80/HandheldKitchen/api/more/tblcalendaralertinfo!homePageInfo.do?phonetype=2&page=%d&pageRecord=10&is_traditional=0", page];
    
    NetworkHelper *helper = [NetworkHelper new];
    [helper getDataWithUrlString:url];
    
    helper.delegate = self;
    
    
}


#pragma mark - NetworkHelperDelegate

//当数据成功获取后使用此方法回调
- (void)networkDataIsSuccessful:(NSData *)data {
    
    if (self.isDownRefresh) {
        [self.dataAry removeAllObjects];
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *ary = dic[@"data"];
    for (NSDictionary *dic in ary) {
        [self.imageArray addObject:dic[@"imagePathLandscape"]];
        
        Menu *menu = [[Menu alloc] init];
        
        
        [menu setValuesForKeysWithDictionary:dic];
        
        [self.dataAry addObject:menu];
        
    }
    
    if (self.dataAry.count > 9) {
        self.collectionView.footer.hidden = NO;
    } else {
        self.collectionView.footer.hidden = YES;
    }
    
    [self.collectionView.header endRefreshing];
    [self.collectionView.footer endRefreshing];
    
    //一定记得拿到数据之后刷新数据
    [self.collectionView reloadData];
    
}


//当数据获取失败后使用此方法回调
- (void)networkDataIsFail:(NSError *)error {
    
    
    
    
    
}

#pragma mark - 加载搜索框

- (void)addSearchbarToNavigationItem {
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(70, 20, kScreenWidth - 140, 40)];
    
    //self.navigationController.view指的就是navigationController管理的view, 它的frame指的就是整个屏幕的大小
    //这里加到view上显示不出来
    [self.navigationController.view addSubview:self.searchBar];
    self.searchBar.barTintColor = [UIColor orangeColor];
    [self.searchBar setBackgroundImage:[[UIImage alloc] init]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
    self.searchBar.placeholder = @"搜索关键字";
    
    //self.searchBar.delegate = self;
#warning mark - 响应者链
    //这里不能将searchBar的交互关掉, 不然我加在view上的轻拍手势就不响应了
    //也就是它阻断了响应者链(View的userInteractionEnabled 的属性是NO, 则其上所有子视图都不再查询, 响应链到此终止)
    //self.searchBar.userInteractionEnabled = NO;
    
    //触摸事件的处理流程  1:检测触摸事件     2:处理触摸事件
    
    
    UIView *view = [[UIView alloc] initWithFrame:self.searchBar.bounds];
    
    [self.searchBar addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modalToNextPage)];
    
    [view addGestureRecognizer:tap];
}

- (void)modalToNextPage {
    
    //因为模态出来的页面不带导航栏, 所以拖的时候拖一个导航控制器
    [self performSegueWithIdentifier:@"search" sender:nil];
    
}


#warning mark - 点击编辑框不让键盘弹出的方法

//想要点击的时候不弹出键盘, 不能把键盘的收回方法下载下面这个方法里, 这个方法的返回值就是代表搜索框是否响应编辑
//此方法需要返回一个BOOL值, 只要你返回YES, 不管上面写什么代码键盘都会弹出来, 除非关闭用户交互
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}


//想要不弹出键盘需要把键盘的收回方法写在已经开始编辑的方法里, 这个方法无返回值
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    //这样的话键盘是弹不出来了, 但是返回的时候光标还在, 所以我决定, 在上面覆盖一层透明view加一个手势跳过去
    //if ([self.searchBar canResignFirstResponder]) {
    //[self.searchBar resignFirstResponder];
    //}
    
    //因为模态出来的页面不带导航栏, 所以拖的时候拖一个导航控制器
    //[self performSegueWithIdentifier:@"search" sender:nil];
    
    //貌似更改模态的跳转模式之后程序会崩溃一次, 再运行一次就欧了
    //跳转的最后一种动画, Partial Curl ,类似于翻页的那种, 好看是好看, 但它自带了返回手势, 所以这种模式一般最好别用, 谁用谁崩溃
}



- (IBAction)classifyDisplay:(UIBarButtonItem *)sender {
    
    //<#(UIOffset)#>水平线, 垂直线
    
    
    self.tabBarController.tabBar.hidden = YES;
    
    self.searchBar.hidden = YES;
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    SpreadCollectionController *vc = [SpreadCollectionController new];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count - 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"menuCell" forIndexPath:indexPath];
    
    NSString *imgStr = self.imageArray[indexPath.row + 4];
    [cell.bigImage sd_setImageWithURL:[NSURL URLWithString:imgStr]];
    
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;
    
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"menuHeader" forIndexPath:indexPath];
        
        
        if (self.dataAry.count > 0) {
            NSMutableArray *imgAry = [@[] mutableCopy];
            NSMutableArray *titleAry = [@[] mutableCopy];
            for (int i = 0; i < 4; i++)
            {
                [imgAry addObject:[self.dataAry[i] imagePathThumbnails]];
                [titleAry addObject:[self.dataAry[i] name]];
            }
            
            //网络加载 --- 创建带标题的图片轮播器
            SDCycleScrollView *cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 170) imageURLStringsGroup:nil]; // 模拟网络延时情景
            cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
            cycleScrollView2.delegate = self;
            cycleScrollView2.titlesGroup = titleAry;  //标题数组
            cycleScrollView2.dotColor = [UIColor yellowColor]; // 自定义分页控件小圆标颜色
            cycleScrollView2.placeholderImage = [UIImage imageNamed:@"placeholder"];
            [view addSubview:cycleScrollView2];
            
            //             --- 模拟加载延迟
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                cycleScrollView2.imageURLStringsGroup = imgAry;  //图片网址数组
            });
        }
        
        return view;
    }
    
    return nil;
    
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    
    //scrollViewToMain
    [self performSegueWithIdentifier:@"scrollViewToMain" sender:@(index)];
    
    
}



#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((kScreenWidth - 30) / 2, 200);
}


//动态设置分区缩进
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(10, 10, 0, 10);
    
}


//动态设置列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10;
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    return CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
//}

#pragma mark - 悬浮按钮

- (void)addSuspendButton
{
    
    if (!self.bar) {
        
        self.bar = [[UIToolbar alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - 89, 30, 30)];
        [self.view addSubview:self.bar];
        self.bar.backgroundColor = [UIColor blackColor];
        
        //圆角效果, 这个必须打开, 不然无法修改
        self.bar.layer.masksToBounds = YES;
        
        //按钮宽的一半
        self.bar.layer.cornerRadius = 15;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToTop)];
        [self.bar addGestureRecognizer:tap];
        self.bar.alpha = 0.5;
        [self.bar setBackgroundImage:[UIImage imageNamed:@"bar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
    }
    
}




- (void)backToTop
{
    
    //加一个动画, 不然效果太突兀了
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         self.collectionView.contentOffset = CGPointMake(0, -64);
                         
                     } completion:^(BOOL finished) {
                         
                         [self.bar removeFromSuperview];
                         self.bar  = nil;
                         
                     }];
    
}



#pragma mark - UIScrollViewDelegate
/*
 @interface UITableView : UIScrollView
 因为tabView继承于scrollView, 所以当给tabView指定代理的时候也就是给scrollView指定了代理
 
 遵守协议, 然后直接用代理方法就好
 */

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.lastContentOffset = scrollView.contentOffset.y;
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"%.f", scrollView.contentOffset.y);
    if (self.lastContentOffset < scrollView.contentOffset.y) {//向下减速
        
        [self addSuspendButton];
        
    }else if (scrollView.contentOffset.y == - 64){//当滑到屏幕顶部的时候
        
        [self.bar removeFromSuperview];
        self.bar = nil;
    }
}




/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */





#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"search"]) {
        
        //导航控制器管理的第一个页面没办法加返回按钮, 系统自带的那种
        //UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
        //returnButtonItem.title = @"返回";
        //self.navigationItem.backBarButtonItem = returnButtonItem;
        
        
        
    } else if ([segue.identifier isEqualToString:@"scrollViewToMain"]) {
        
        NSInteger index = [sender integerValue];
        Menu *model = self.dataAry[index];
        MainViewController *vc = (MainViewController *)segue.destinationViewController;
        vc.nameID = model.vegetable_id;
        
        vc.name = model.name;
        
    } else {

        //找到storyBoard中控制器的方法
        //1. 先找到那个storyBoard
        //UIStoryboard *storyBoard = [UIStoryboard  storyboardWithName:@"Main" bundle:nil];
        
        //2. 找到storyBoard中相应的控制器
        //MenuDetailViewController *menuDetailVC = [storyBoard instantiateViewControllerWithIdentifier:@"menuDetail"];
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems]firstObject];
        
        MenuCollectionViewCell *cell = (MenuCollectionViewCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([segue.identifier isEqualToString:@"menuDetail"]) {
            
            MenuDetailViewController *secondVC = (MenuDetailViewController *)segue.destinationViewController;
            secondVC.rect1 = cell.frame;
            secondVC.useImage = cell.bigImage.image;
            
            secondVC.menu = self.dataAry[indexPath.row + 4];
            
        }
        
    }
    
}



@end

