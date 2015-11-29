//
//  ZXNTableViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/15.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXNViewController.h"
#import "ZXNewModel.h"
#import "ZXNTableViewCell.h"
#import "ZXNDetailViewController.h"


@interface ZXNViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataAry;
@property (nonatomic, assign) BOOL isDownRefresh;

@property (nonatomic, assign) int page;

//占位视图数据未加载出来之前的视图, 可以在上面放图片, 好看(*^__^*) 嘻嘻……
@property (nonatomic, strong) UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIToolbar *bar;
@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, assign) BOOL sign;



@end

@implementation ZXNViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden =NO;

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //用tableViewController之后, 数据未加载之前就会有很多cell出现, 而且我在上面盖一层view也盖不住, cell的线还是会漏出来. 丑到爆
    //以后打死都不用tableView和collectionView的controller了, 直接用viewController, 自定义程度高,还不会出现上述奇葩问题
    //你说麻烦不, 都拖好弄好了, 还得让老子删了重高, 幸亏cell上的控件是代码写的, 不然😢都没地儿😢
    
    
    self.page = 1;
    
    [self getDataFromServer:1];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self addRefresh];
    
    [self.tableView registerClass:[ZXNTableViewCell class] forCellReuseIdentifier:@"zxNew"];
    
    [self.view addSubview:self.placeholderView];

    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];
    
   
    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
}

- (void)dismiss {
    self.sign = YES;
    [SVProgressHUD dismiss];
}


#pragma mark - 懒加载

- (NSMutableArray *)dataAry {
    if (!_dataAry) {
        self.dataAry = [@[] mutableCopy];
    }
    return _dataAry;
}



- (UIView *)placeholderView {
    if (!_placeholderView) {
        self.placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.placeholderView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.949 alpha:1.000];
    }
    return _placeholderView;
}


#pragma mark - 刷新加载

- (void)addRefresh {
    
    
    
    __weak ZXNViewController *blockSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        
        blockSelf.isDownRefresh = YES;
        
        
        [blockSelf getDataFromServer:1];
        
        
    }];
    
    
    
    
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        blockSelf.isDownRefresh = NO;
        blockSelf.page++;
        [blockSelf getDataFromServer:blockSelf.page];
    }];
    
    self.tableView.footer.hidden = YES;
    
}



#pragma mark - 获取数据
- (void)getDataFromServer:(int)page {
    
    if (self.isDownRefresh) {
        [self.dataAry removeAllObjects];
    }
    
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://121.41.117.95:80/HandheldKitchen/api/found/tblFresh!getTblFreshList.do?is_traditional=0&page=%d&pageRecord=10&phonetype=1", page];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *dataAry = dic[@"data"];
            
            for (NSDictionary *dic in dataAry) {
                ZXNewModel *model = [ZXNewModel new];
                [model setValuesForKeysWithDictionary:dic];
                [self.dataAry addObject:model];
            }
            
            
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            
            
            if (self.dataAry.count > 5) {
                self.tableView.footer.hidden = NO;
            } else {
                self.tableView.footer.hidden = YES;
            }
            
            [self.placeholderView removeFromSuperview];
            
            if (!self.sign) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
                
                [self.tableView reloadData];

            }
        }
    }];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataAry.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //下面注掉的代码是通过用代码创建cell使用的
    
//    static NSString *str = @"zxNew";
//    
//    if (!cell) {
//        cell = [[ZXNTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
//    }
    
    
    
    //因为我这个cell是在StoryBoard上拖出来的, 所以不恩呢过使用上述代码
    
    //如果我cell以及cell上的控件是拖出来的则直接就会显示, 若我cell是拖出来的, 但它上面的控件都是我代码创建的, 则需要注册, 注册之后才会显示
    //因为如果控件是拖出来的, 相当于创建控件的代码系统帮你写好了, 运行的时候会自动走, 所以不需要注册, 这时候走initcoder方法
    //但是如果是自己手写的代码需要调用才会走, 所以需要注册, 这时候才会走cell的init方法
    
    
    ZXNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zxNew" forIndexPath:indexPath];


    if (self.dataAry.count > 0) {
        ZXNewModel *model = self.dataAry[indexPath.row];
        cell.model = model;
    }
    
    
    
    
    
  
    
    
    //这就是装逼的后果, 代码走到这的时候cell的init方法已经走完了, 也就是说我后面给cell赋值的图片字符串是无用的
    //人家总结出来的, 就不要质疑了, 整天瞎玩, 人家说给cell的model赋值, 重写setter方法是有一定的道理的
//    if (model) {
//        [cell setValue:model.name forKeyPath:@"titleLabel.text"];
//        [cell setValue:model.content forKeyPath:@"contentLabel.text"];
//        cell.imageStr = model.titleImageFile;
//    }
    
 
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"newToDetail" sender:indexPath];
    
    
}






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
                         self.tableView.contentOffset = CGPointMake(0, -64);
                         
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
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"newToDetail"]) {
        
        ZXNDetailViewController *vc = (ZXNDetailViewController *)segue.destinationViewController;
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        vc.nameID = [self.dataAry[indexPath.row] freshId];
        
        
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
        
        vc.title = [self.dataAry[indexPath.row] name];
        
    }
    
}


@end
