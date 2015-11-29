//
//  RootViewController.m
//  Lesson_collectionView
//
//  Created by 张祥 on 15/7/1.
//  Copyright (c) 2015年 张祥. All rights reserved.
//



/*
 之前的大bug是由于我写了一个cell的isHidden属性, 但是这个属性和系统重名, UIView有一个isHidden属性, 导致刷新之后, cell在重用的时候出问题, 也就是布局错乱,  以至于不响应方法
 */


#import "SpreadCollectionController.h"
#import "FooterView.h"
#import "CollectionViewCell.h"
#import "DetailViewController.h"
#import "UIViewAdditions.h"
#import "MainModel.h"
#import "DetailModel.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"

@interface SpreadCollectionController ()

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *indexPathAry;
@property (nonatomic, retain) NSMutableArray *sectionAry;
@property (nonatomic, retain) NSMutableArray *listAry;
@property (nonatomic, retain) NSMutableArray *detailAry;
@property (nonatomic, retain) DetailViewController *secondVC;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, retain) NSIndexPath *index;
@property (nonatomic, assign) BOOL sign;//标记取消方法是否执行


@end


@implementation SpreadCollectionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //生成一个布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //生成集合视图
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
    
    [self.view addSubview:self.collectionView];
    
    //指定代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //获取数据(本地plist文件)
    [self getDataFromServe];
    
    //注册cell
    [self.collectionView  registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    //注册页脚
    [self.collectionView registerClass:[FooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    
    //创建小视图控制器, 并作为本视图控制器的子视图控制器
    //把着两句代码写到这里就会只走一次, 不会说创建很多视图控制器
    self.secondVC = [DetailViewController new];
    [self addChildViewController:self.secondVC];
    
    
    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
    
    
    self.title = @"分类";
    
}

- (void)dismiss {
    //标记方法执行
    self.sign = YES;
    [SVProgressHUD dismiss];
}




#pragma mark - 懒加载

- (NSMutableArray *)indexPathAry
{
    if (!_indexPathAry) {
        self.indexPathAry = [NSMutableArray arrayWithCapacity:1];
    }
    return _indexPathAry;
}

- (NSMutableArray *)sectionAry
{
    
    if (!_sectionAry) {
        self.sectionAry = [NSMutableArray arrayWithCapacity:1];
    }
    return _sectionAry;
}

- (NSMutableArray *)listAry
{
    if (!_listAry) {
        self.listAry = [NSMutableArray arrayWithCapacity:1];
    }
    return _listAry;
}


- (NSMutableArray *)detailAry
{
    if (!_detailAry) {
        self.detailAry = [NSMutableArray arrayWithCapacity:1];
    }
    return _detailAry;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //如果数组中有元素的时候走下面方法
    if (self.listAry.count > 0) {
        
        //找到最后一个分区
        if (section == self.listAry.count / kItem_Number) {
            
            //如果能被每行的个数整除
            if (self.listAry.count % kItem_Number == 0) {
                //返回每行的个数
                return kItem_Number;
            }
            
            //不然返回元素个数对每行个数的取余数
            return self.listAry.count % kItem_Number;
        }
        
        //        NSLog(@"%ld####%ld", self.listAry.count / kItem_Number, self.listAry.count % kItem_Number);
        
        //其他情况返回正常的个数
        return kItem_Number;
    }
    
    //这个没啥用, 代码只有第一次, 数据未加载出来的时候走这个
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //这里要知道如果返回数是8, 分区下标就是0 ~~ 7
    
    //如果能整除, 就返回正常结果
    if (self.listAry.count % kItem_Number == 0) {
        return self.listAry.count / kItem_Number;
    }
    
    //如果不能整除就在结果上加1, 例如25个数据, 每行3个, 则需要25 / 3 + 1行
    return self.listAry.count / kItem_Number + 1;
    
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //正常情况下把所有的色块全部隐藏
    cell.isHiddenedma = YES;
    
    
    //当选中的时候让色块出现
    if (indexPath == self.index)
    {
        if (self.isSelected) {
            cell.isHiddenedma = NO;
        }
    }
    
    
    //indexPath.row + indexPath.section * kItem_Number
    //indexPath.section * kItem_Number, 当前分区数*每行的个数
    //因为每个分区的indexPath.row 都是从0开始的, 所以要把之前分区的item全部加上
    
    if (self.listAry.count > 0) {
        
        MainModel *main = self.listAry[indexPath.row + indexPath.section * kItem_Number];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:main.imagePath]];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", main.name];
    }
    
    
    return cell;
    
}

#warning mark - 返回区头视图的时候一定返回区头视图的尺寸, 系统默认区头视图的尺寸是(0, 0)
//这里要知道, 区头高度默认是0, 如果这里返回了区头视图, 但是未设置区头高度, 则无显示, 除非不是代码写的而是👐托出来的
//针对每个分区的页眉和页脚, 返回对应的视图对象, 重用的
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
    
    //将第二个视图控制器添加到区尾上
    [footerView addSubview:self.secondVC.view];
    
    //对多余的视图进行裁剪
    footerView.clipsToBounds = YES;
    
    return footerView;
}




#pragma mark - 获取列表数据

- (void)getDataFromServe
{
    NSString *urlStr = @"http://121.41.88.115:80/HandheldKitchen/api/home/tblAssort!getFirstgrade.do";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //这两句不写请求不到数据
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSArray *dataAry = responseObject[@"data"];
            
            for (NSDictionary *dic1 in dataAry) {
                
                MainModel *main = [[MainModel alloc] init];
                
                [main setValuesForKeysWithDictionary:dic1];
                
                NSArray *deleteAry = @[@"对症食疗", @"食材大全", @"家电佳肴", @"厨娘私房菜"];
                
#warning mark - 破Xcode, 不给提示, 让老子以为不能这么写呢, 肯定是可以这样判断的, 不过写成上面的方式是不是更清晰一点呢😊
                /*
                 
                 if ([main.name isEqualToString:@"对症食疗"] || [main.name isEqualToString:@"食材大全"] || [main.name isEqualToString:@"家电佳肴"] || [main.name isEqualToString:@"厨娘私房菜"]) {
                 
                 } else {
                 [self.listAry addObject:main];
                 
                 }
                 */
                
                if ([deleteAry containsObject:main.name]) {
                    
                    //剔除这四种奇葩另类的数据(木牛做, 当然要踢呀)
                    
                } else {
                    
                    [self.listAry addObject:main];
                    
                }
                
            }
            
        }
        
        //如果取消方法没执行, 则执行成功方法
        if (!self.sign) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }
        
        
        [self.collectionView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}






#pragma mark - UICollectionViewDelegate 选中执行

- (void)JudgeSelected:(NSIndexPath *)indexPath
{
    
    //始终保持数组中只有一个元素或则无元素
    if (self.sectionAry.count > 1)
    {
        [self.sectionAry removeObjectAtIndex:0];
    }
    
    //如果这此点击的元素存在于数组中则状态置为NO,并将此元素移除数组
    /*
     这里之所以置为NO的时候把元素移除是因为, 如果不移除, 下次点击的时候代码走到这里里面还是有一个元素, 而且是上次的元素, 不会走else的代码
     */
    if ([self.sectionAry containsObject:indexPath])
    {
        self.isSelected = NO;
        [self.sectionAry removeObject:indexPath];
    }else{
        //当数组为空的时候或者点击的非上次元素的时候走这里
        self.isSelected = YES;
        [self.sectionAry addObject:indexPath];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.index = indexPath;
    //NSLog(@"%ld, %ld", indexPath.section, indexPath.row);
    
    //掉用方法来判断选中状态和选中的分区
    [self JudgeSelected:indexPath];
    
    [self.detailAry removeAllObjects];
    
    MainModel *main = self.listAry[indexPath.row + indexPath.section * kItem_Number];
    
    for (NSDictionary *dic in main.secondgrade) {
        
        DetailModel *detail = [[DetailModel alloc] init];
        
        [detail setValuesForKeysWithDictionary:dic];
        
        detail.nameID = dic[@"id"];
        
        [self.detailAry addObject:detail];
    }
    
    self.secondVC.dataAry = self.detailAry;
    
    [self.collectionView reloadData];
    
    //刷新子视图控制器
    [self.secondVC.minView reloadData];
}



#pragma mark - UICollectionViewDelegateFlowLayout - 动态布局

//动态设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth  / kItem_Number - 0.5, kScreenWidth  / kItem_Number - 0.5);
}


//动态设置每个分区的缩进量
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


//动态设置每个分区的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0;
}


//动态设置不同区的列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//动态设置区尾的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    
    if (self.sectionAry.count == 0 || self.isSelected == NO) {
        [self.secondVC.view removeFromSuperview];
        return CGSizeMake(0, 0);
    }
    
    if (section == [[self.sectionAry lastObject] section]) {
        if (self.detailAry.count % kDetail_Item_Number == 0) {
            //能被整除就直接返回
            return CGSizeMake([UIScreen mainScreen].bounds.size.width, (self.detailAry.count / kDetail_Item_Number) * (kItem_Height + 10) + 20);
        }else{
            //不能被整除就加1
            return CGSizeMake([UIScreen mainScreen].bounds.size.width, (self.detailAry.count / kDetail_Item_Number + 1) * (kItem_Height + 10) + 20);
        }
    }else{
        return CGSizeMake(0, 0);
    }
    
}


@end
