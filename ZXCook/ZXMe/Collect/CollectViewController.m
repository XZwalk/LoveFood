//
//  CollectViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "CollectViewController.h"
#import "CollectCell.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "MenuCook.h"

@interface CollectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) NSMutableArray *dataAry;

@property (nonatomic, strong) UIButton *but;

@property (nonatomic, strong) NSMutableArray *touchAry;

@property (nonatomic, assign) BOOL isDeleteStyle;


@end

@implementation CollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];

    [self getDataFromLocal];
    
#warning mark - 为什么控件拖不上去
    
    //因为控件拖不上去, 就用代码写了
   
    
    self.title = @"我的收藏";
    
    self.isDeleteStyle = NO;
}

#pragma mark - 懒加载

- (NSMutableArray *)dataAry {
    if (!_dataAry) {
        self.dataAry = [@[] mutableCopy];
    }
    return _dataAry;
}


- (NSMutableArray *)touchAry {
    if (!_touchAry) {
        self.touchAry = [@[] mutableCopy];
    }
    return _touchAry;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectItem" forIndexPath:indexPath];
    
    if (self.dataAry.count > 0) {
        MenuCook *model = self.dataAry[indexPath.row];

        cell.model = model;
    }
    
    //取到我们在那边创建的but
    self.but = [cell valueForKey:@"but"];
    
    
#warning mark - 🐂牛逼的一句代码, 至少我这么觉得
    self.but.tag = indexPath.row;
    
    [self.but addTarget:self action:@selector(butAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;
    
    cell.isDeleteButtonHide = !self.isDeleteStyle;
    
    return cell;
}


#pragma mark - 获取数据

- (void)getDataFromLocal {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuCook" inManagedObjectContext:self.context];
    
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:request error:&error];
    if (fetchedObjects.count == 0) {
        
    }else
    {
        //如果拿到的数组中有数据, 就把查询到的数据加到数据源中
        [self.dataAry setArray:fetchedObjects];
        
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction:)];
        
        //刷新列表
        [self.collectionView reloadData];
    }
}



#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kScreenWidth - 40) / 2, 160);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//编辑按钮
- (void) rightBarAction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"编辑"]) {
        
        sender.title = @"完成";
        self.isDeleteStyle = YES;
        
    } else {
        
        sender.title = @"编辑";
        self.isDeleteStyle = NO;
    }
    
    [self.collectionView reloadData];
}



//点击删除按钮
- (void)butAction:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self.touchAry addObject:indexPath];
    
    MenuCook *model = self.dataAry[indexPath.row];
    
    [self.context deleteObject:model];
    
    NSError *error = nil;
    
    [self.context save:&error];
    
    if (!error) {
        [self.dataAry removeObject:model];
        
        [self.collectionView reloadData];

    } else {
        NSLog(@"%@", [error localizedDescription]);
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //当处于编辑状态时点击啥也不干
    if (self.isDeleteStyle) {
        
        //不能直接从cell往控制器上拖线, 因为当处于编辑状态时我不让它有点击状态, 也就是不让它跳转, 所以直接从控制器拖线到控制器, 能掌控它的跳转, 说不定直接拖线也行, 重写选中的这个方法应该会从这里走, 我母牛试
       
        //不是的时候跳转
    } else {
        [self performSegueWithIdentifier:@"collectToMain" sender:nil];

    }
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"collectToMain"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        MenuCook *model = self.dataAry[indexPath.row];
        
        MainViewController *vc = (MainViewController *)segue.destinationViewController;
        vc.nameID = model.nameID;
        vc.name = model.name;
    }
    
}


@end
