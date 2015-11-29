//
//  SearchResultVC.m
//  ZXCook
//
//  Created by 张祥 on 15/8/16.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "SearchResultVC.h"
#import "SearchResultCell.h"
#import "SearchModel.h"
#import "MainViewController.h"
#import "NoProductView.h"

@interface SearchResultVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *searchDataAry;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL isDownRefresh;
@property (nonatomic, strong) NoProductView *noProductView;

@property (nonatomic, assign) BOOL sign;


@end

@implementation SearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //cell是在StoryBoard上拖出来的, 已经存在了, 不能再注册, 不然不显示
    //[self.collectionView registerClass:[SearchResultCell class] forCellWithReuseIdentifier:@"searchItems"];
    
    self.page = 1;
    
    [self getDataFromServer:self.searchContent page:self.page];
    
    [self addRefresh];
    
    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
    
}

- (void)dismiss {
    self.sign = YES;
    [SVProgressHUD dismiss];
}


#pragma mark - 懒加载

- (NSMutableArray *)searchDataAry {
    if (!_searchDataAry) {
        self.searchDataAry = [@[] mutableCopy];
    }
    return _searchDataAry;
}


- (NoProductView *)noProductView {
    if (!_noProductView) {
        self.noProductView = [[NoProductView alloc] initWithFrame:self.view.bounds];
    }
    return _noProductView;
}



#pragma mark - 加载刷新

- (void)addRefresh {
    
    
    __weak SearchResultVC *blockSelf = self;
   [self.collectionView addLegendHeaderWithRefreshingBlock:^{
       blockSelf.isDownRefresh = YES;
       
       [blockSelf getDataFromServer:self.searchContent page:1];
       
   }];
    
    
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        blockSelf.isDownRefresh = NO;
        
        self.page++;
        
        [blockSelf getDataFromServer:self.searchContent page:self.page];
        
        
    }];
    
    self.collectionView.footer.hidden = YES;
    
}

#pragma mark - 获取数据
- (void)getDataFromServer:(NSString *)name page:(int)page {
    
    
    if (self.isDownRefresh) {
        [self.searchDataAry removeAllObjects];
    }
    
    
    NSString *urlStr = @"http://admin.izhangchu.com/HandheldKitchen/api/home/tblAssort!getDataList.do";
    
    //创建可变请求, 设定一个网络请求超时时间
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.];
    
    //设置请求的方式
    [request setHTTPMethod:@"POST"];
    
    //参数网址
    NSString *parames = [NSString stringWithFormat:@"name=%@&page=%d&pageRecord=10&is_traditional=0", name, page];
    
    //将参数转成NSData(二进制数据)
    NSData *parameData = [parames dataUsingEncoding:NSUTF8StringEncoding];
    
    //把转成二进制后的参数放到request的HttpBody里面
    [request setHTTPBody:parameData];
    
    //发送网络连接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *dataAry = dic[@"data"];
            
            for (NSDictionary *dic in dataAry) {
                
                SearchModel *model = [SearchModel new];
                [model setValuesForKeysWithDictionary:dic];
                
                if ([model.type isEqualToString:@"1"]) {
                    model.nameID = dic[@"id"];
                    [self.searchDataAry addObject:model];
                }
            }
            
            
            [self.collectionView.footer endRefreshing];
            [self.collectionView.header endRefreshing];
            
            
            
            if (self.searchDataAry.count > 4) {
                self.collectionView.footer.hidden = NO;
            } else {
                
                self.collectionView.footer.hidden = YES;
            }
            
            
            if (!self.sign) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
            
            
            
            
            if (self.searchDataAry.count == 0) {
                self.noProductView.nameTitle = @"对不起, 搜索无结果, 请重新搜索···";
                [self.view addSubview:self.noProductView];
            }
            
            
            
            
            [self.collectionView reloadData];
        } else {
            
            //如果搜索无结果, 则添加占位图片
#warning mark - 靠, 突然发现一个神奇的东西, 尼玛有时候搜不到东西的时候data也为空, 也是有数据的(data有大小), 所以这里的else有时候是不走的, 坑爹呀
            
        }
        
    }];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchDataAry.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchItems" forIndexPath:indexPath];
    
    SearchModel *model = self.searchDataAry[indexPath.row];
    cell.model = model;
    
    return cell;
    
}


#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((kScreenWidth -40) / 2 , 150);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
#warning mark - 你看, 我这个就是直接从cell上拖线过去的, 没有在did方法里写执行线方法, 好奇葩哦😂
     if ([segue.identifier isEqualToString:@"searchToMain"]) {
         
         NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
         
         SearchModel *model = self.searchDataAry[indexPath.row];
         
         MainViewController *vc = (MainViewController *)segue.destinationViewController;
         vc.nameID = model.nameID;
         
         vc.name = model.name;
     }
     
     
     
 }


@end
