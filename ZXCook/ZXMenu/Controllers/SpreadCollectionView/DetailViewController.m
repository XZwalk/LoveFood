//
//  SecondViewController.m
//  SpreadCollectionView
//
//  Created by 张祥 on 15/7/24.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailCollectionViewCell.h"
#import "DetailModel.h"
#import "ClassifyCollectionViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //生成一个布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.minView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    [self.view addSubview:self.minView];
    
    self.minView.delegate = self;
    self.minView.dataSource = self;
    self.minView.backgroundColor = [UIColor colorWithWhite:0.333 alpha:0.200];
    
    //注册cell
    [self.minView  registerClass:[DetailCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataAry.count;
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    DetailModel *detail = self.dataAry[indexPath.row];
    
    cell.titleLabel.text = detail.name;
    
    
    cell.layer.masksToBounds = YES;
    
    cell.layer.cornerRadius = 10;
    
    
    return cell;
}




#pragma mark - UICollectionViewDelegate 选中执行

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    //选中执行的方法
    DetailModel *model = self.dataAry[indexPath.row];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ClassifyCollectionViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"other"];
    
    vc.nameID = model.nameID;
    vc.name = model.name;
    [self.navigationController pushViewController:vc animated:YES];
    
}





#pragma mark - UICollectionViewDelegateFlowLayout - 动态布局
//动态设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(kScreenWidth  / kDetail_Item_Number - 30, kItem_Height);
}


//动态设置每个分区的缩进量
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


//动态设置每个分区的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//动态设置不同区的列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

@end
