//
//  ZXNDetailViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/15.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXNDetailViewController.h"
#import "ZXNListModel.h"
#import "ZXNDetailModel.h"
#import "ZXNDetailCell.h"
#import "ZXNReusableView.h"
#import "MainViewController.h"


@interface ZXNDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *bigDataAry;
@property (nonatomic, strong) NSMutableArray *littleDataAry;

@property (nonatomic, assign) CGFloat height;

//占位视图, 你懂得👌
@property (nonatomic, strong) UIView *placeholderView;

@property (nonatomic, assign) BOOL sign;


@end

@implementation ZXNDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    self.height = 60;
    
    [self getDataFromServer:self.nameID];
    
    //添加占位图
    [self.view addSubview:self.placeholderView];

    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
    
}


- (void)dismiss {
    self.sign = YES;
    [SVProgressHUD dismiss];
}

#pragma mark - 懒加载

- (NSMutableArray *)bigDataAry {
    if (!_bigDataAry) {
        self.bigDataAry = [@[] mutableCopy];
    }
    return _bigDataAry;
}

- (NSMutableArray *)littleDataAry {
    if (!_littleDataAry) {
        self.littleDataAry = [@[] mutableCopy];
    }
    return _littleDataAry;
}


- (UIView *)placeholderView {
    if (!_placeholderView) {
        self.placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.placeholderView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.949 alpha:1.000];
    }
    return _placeholderView;
}

#pragma mark - 展开收回按钮

- (IBAction)changeHeight:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"展开"]) {
        
        [sender setTitle:@"收起" forState:UIControlStateNormal];
        
        ZXNDetailModel *model = self.bigDataAry[0];
        
        CGRect rect = [model.content boundingRectWithSize:CGSizeMake(kScreenWidth - 10, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
        
        self.height = rect.size.height;
        
    } else {
        [sender setTitle:@"展开" forState:UIControlStateNormal];
        self.height = 60;
        
    }
    
    [self.collectionView reloadData];
 }



#pragma mark - 获取数据
- (void)getDataFromServer:(NSString *)nameID {
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://121.41.117.95:80/HandheldKitchen/api/found/tblFresh!getTblFreshDelicacyList.do?freshId=%@&is_traditional=0&phonetype=1", nameID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *dataAry = dic[@"data"];
            
            ZXNDetailModel *detailModel = [ZXNDetailModel new];
            
            [detailModel setValuesForKeysWithDictionary:dataAry[0]];
            
            [self.bigDataAry addObject:detailModel];
            
            for (NSDictionary *dic in dataAry[0][@"vegetable"]) {
                ZXNListModel *listModel = [ZXNListModel new];
                
                [listModel setValuesForKeysWithDictionary:dic];
                
                [self.littleDataAry addObject:listModel];
            }
            //数据加载出来了, 移除占位图
            [self.placeholderView removeFromSuperview];
            
            if (!self.sign) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
            
            [self.collectionView reloadData];
        }
    }];
    
}





#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.littleDataAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZXNDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"zxNewDetail" forIndexPath:indexPath];
    
    if (self.littleDataAry.count > 0) {
        ZXNListModel *model = self.littleDataAry[indexPath.row];
        
        cell.model = model;
        
    }
    return cell;
    
}


//拖的区头和区尾跟cell一样, 也要实现方法, 从重用池取即可
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    ZXNReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"zxNewHeader" forIndexPath:indexPath];
    
    if (self.bigDataAry.count > 0) {
        ZXNDetailModel *model = self.bigDataAry[0];
        view.model = model;
    }
    
    return view;
}



#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 50) / 2, 120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 15, 0, 15);
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    //250正常
    //我相当于是改变区头的高度, 然后图片是固定死的, 显示文字的label加了约束, 完了就欧了
    return CGSizeMake(kScreenWidth - 10, 190 + self.height);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //freshToMain
    
    //突然发现一个问题, collectionView的cell的线直接拖过去的话直接就响应了, 不用再在did选中的方法里加上执行线的方法了
    //但是tableView的cell就不行是什么鬼, 有空了得试试, 警告走起
#warning mark - cell的拖线要不要执行线方法
    
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    
    ZXNListModel *model = self.littleDataAry[indexPath.row];
    
    MainViewController *vc = (MainViewController *)segue.destinationViewController;
    vc.nameID = model.vegetable_id;
    
    vc.name = model.name;
    
}


@end
