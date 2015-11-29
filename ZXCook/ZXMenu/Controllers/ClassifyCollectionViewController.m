//
//  ClassifyItemCollectionViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ClassifyCollectionViewController.h"
#import "NetworkHelper.h"
#import "ClassifyModel.h"
#import "ClassifyItemCollectionViewCell.h"
#import "mainViewController.h"
#import "SpreadCollectionController.h"


@interface ClassifyCollectionViewController ()<NetworkHelperDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *dataAry;
@property (nonatomic, assign) BOOL isDown;

@end

@implementation ClassifyCollectionViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //http://121.40.54.242/HandheldKitchen/api/home/tblAssort!getVegetable.do?id=23&page=1&pageRecord=10&is_traditional=0&phonetype=1
    
    self.page = 1;

    [self getDataFromServer:self.nameID page:self.page];
    
    //block内不能用self, 循环引用
    __weak ClassifyCollectionViewController *blockSelf = self;
    
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        blockSelf.isDown = YES;
        [blockSelf getDataFromServer:blockSelf.nameID page:blockSelf.page];
        
    }];
    
    
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        blockSelf.isDown = NO;
        blockSelf.page++;
        [blockSelf getDataFromServer:blockSelf.nameID page:blockSelf.page];
    }];
    
    //开始没数据的时候将加载更多隐藏
    self.collectionView.footer.hidden = YES;
    
    self.title = self.name;
    
}



#pragma mark - 懒加载

- (NSMutableArray *)dataAry {
    if (!_dataAry) {
        self.dataAry = [@[] mutableCopy];
        
    }
    return _dataAry;
}




#pragma mark - 获取数据
- (void)getDataFromServer:(NSString *)nameID page:(int)page {
    
    NetworkHelper *helper = [NetworkHelper new];
    
    helper.delegate = self;
    NSLog(@"%d", page);
    
    
    NSArray *controllerAry = self.navigationController.viewControllers;
    //SpreadCollectionController
    //ZXGMainCollectionVC
    NSString *urlStr = nil;
    
    if ([controllerAry[controllerAry.count - 2] isKindOfClass:[SpreadCollectionController class]]) {
         urlStr = [NSString stringWithFormat:@"http://121.40.54.242/HandheldKitchen/api/home/tblAssort!getVegetable.do?id=%@&page=%d&pageRecord=10&is_traditional=0&phonetype=1", self.nameID, self.page];
    }
    else {
        urlStr = [NSString stringWithFormat:@"http://121.41.88.194:80/HandheldKitchen/api/found/tblBoutique!getTblBoutiqueVegetableList.do?is_traditional=0&page=%d&pageRecord=10&phonetype=0&user_id=0&typeId=%@", self.page, self.nameID];
        
    }
    
    
    
   
    
    [helper getDataWithUrlString:urlStr];
}



//当数据成功获取后使用此方法回调
- (void)networkDataIsSuccessful:(NSData *)data
{
    if (self.isDown) {
        [self.dataAry removeAllObjects];
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *ary = dic[@"data"];
    
    for (NSDictionary *dic in ary) {
        
        ClassifyModel *model = [ClassifyModel new];
        
        model.nameID = dic[@"id"];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataAry addObject:model];
        
    }
    
    [self.collectionView reloadData];
    
    //当数据小于一页的时候隐藏, 根据数组中的元素个数来判断
    if (self.dataAry.count < 2) {
        self.collectionView.footer.hidden = YES;
    } else {
        //多余一页的时候加载出来
        self.collectionView.footer.hidden = NO;
    }
    
    
    //这两句代码一定要写, 代表此次刷新结束, 不然一直会停留在上次刷新状态, 不会进行下次刷新
    [self.collectionView.header endRefreshing];
    [self.collectionView.footer endRefreshing];
}


//当数据获取失败后使用此方法回调
- (void)networkDataIsFail:(NSError *)error
{
    
    
    
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
    return self.dataAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ClassifyItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ClassifyItem" forIndexPath:indexPath];

    
    
    ClassifyModel *model = self.dataAry[indexPath.row];
    
    
    
    NSArray *controllerAry = self.navigationController.viewControllers;
    
    if ([controllerAry[controllerAry.count - 2] isKindOfClass:[SpreadCollectionController class]]) {
        cell.model = model;

    } else {
        
        cell.classifyName.textColor = [UIColor darkGrayColor];
        cell.classifyName.font = [UIFont systemFontOfSize:14];
        cell.classifyName.textAlignment = NSTextAlignmentCenter;
        
        
        
        [cell.classifyImage sd_setImageWithURL:[NSURL URLWithString:model.imagePathLandscape]];
        cell.classifyName.text = model.name;
    }

    
    
    
    
    
    
    
    
    return cell;
}



#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 30)/ 2, 150);
}



#pragma mark <UICollectionViewDelegate>

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
     
     if ([segue.identifier isEqualToString:@"mainView"] ) {
         
         NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
         
         ClassifyModel *model = self.dataAry[indexPath.row];
         
         MainViewController *seconVC = (MainViewController *)segue.destinationViewController;
         
         
         
         NSArray *controllerAry = self.navigationController.viewControllers;
         
         if ([controllerAry[controllerAry.count - 2] isKindOfClass:[SpreadCollectionController class]]) {
             seconVC.nameID = [model nameID];
             
             seconVC.name = model.name;
         } else {
             seconVC.nameID = model.vegetable_id;
             
             seconVC.moveArray = @[model.materialVideoPath, model.productionProcessPath];
             
             
             seconVC.name = model.name;
             
         }
         
     }
     
 }


@end
