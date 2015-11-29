//
//  ZXGMainCollectionVC.m
//  ZXCook
//
//  Created by 张祥 on 15/8/14.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXGMainCollectionVC.h"
#import "ZXGMainMdoel.h"
#import "ZXGMainCell.h"
#import "ClassifyCollectionViewController.h"



@interface ZXGMainCollectionVC ()<UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *mainDataAry;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL sign;

@end

@implementation ZXGMainCollectionVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden =NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self getDataFromServer];
    
    
    //如果我直接拖, 访问不到它的layout属性, 自定义程度太差
    //所以以后还是少用UICollectionViewController等, 直接用UIViewController
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    
    //用storyBoard拖的cell不用注册
    //自己创建的cell要注册, 不管是通过纯代码创建的还是通过xib
    //其实我们通过xib创建的所有控件和我们手工纯代码创建的所有控件一样使用, 只不过一个是alloc代码的, 一个是用nib初始化的
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZXGMainCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"goodItems"];
    
    //页面不够一屏也可以滑动
    self.collectionView.alwaysBounceVertical = YES;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.view addSubview:self.collectionView];
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1.000 green:0.762 blue:0.124 alpha:1.000];
    
    
    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
    
}

- (void)dismiss {
    self.sign = YES;
    [SVProgressHUD dismiss];
}


#pragma mark - 懒加载

- (NSMutableArray *)mainDataAry {
    if (!_mainDataAry) {
        self.mainDataAry = [@[] mutableCopy];
    }
    return _mainDataAry;
}



#pragma mark - 获取数据

- (void)getDataFromServer {
    
    NSString *urlStr = @"http://121.40.54.242:80/HandheldKitchen/api/found/tblBoutique!getTblBoutiqueTypeList.do?is_traditional=0&page=1&pageRecord=12&phonetype=1";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        if (data) {
            
        
    
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        
            NSArray *dataAry = dic[@"data"];
            
            for (NSDictionary *dic in dataAry) {
                ZXGMainMdoel *model = [ZXGMainMdoel new];
                
                [model setValuesForKeysWithDictionary:dic];
                
                model.nameId = dic[@"id"];
                [self.mainDataAry addObject:model];
            }
            
            
            if (!self.sign) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
            
            
            [self.collectionView reloadData];
        }
        
    }];
    
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
    return self.mainDataAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZXGMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodItems" forIndexPath:indexPath];
    
    ZXGMainMdoel *model = self.mainDataAry[indexPath.row];
    
    cell.model = model;
    return cell;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /*                    对于cell的拖线有两步
     
     第一步: 在StoryBoard上拖线, 从cell拖或者从ViewController拖都行
     
     第二步: 从一个ViewController拖线到另一个ViewController, 这时候这里面就需要加上如下代码(因为你是从一个视图控制器拖线到另一个视图控制器, 所以这个命令需要你给它规定)
    */
    
    [self performSegueWithIdentifier:@"goodToMain" sender:nil];
}





#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 40)/ 3, 100);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


 #pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqualToString:@"goodToMain"]) {
         
         //第一种: 创建第二个控制器的方法是纯手工代码
         
         //第二种: 创建第二个控制器的方法是没拖线的
         //这里的bundle可以给空, 因为就一个程序包, 当然也可以给[UIBundle mainBUndle].
         //UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         //ClassifyCollectionViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"other"];
         
         //第三种: 创建第二个控制器的方法是已经拖过线的
         ClassifyCollectionViewController *vc = (ClassifyCollectionViewController *)segue.destinationViewController;
         
         //其实这里不用那么麻烦, 直接把indexPath通过sender传过来就好了, 但是为了练习在不用传值的情况下找到indexPath, 你懂的
         NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
         
         ZXGMainMdoel *model = self.mainDataAry[indexPath.row];
         vc.nameID = model.nameId;
         
         vc.name = model.name;
         
     }
     
 }






@end
