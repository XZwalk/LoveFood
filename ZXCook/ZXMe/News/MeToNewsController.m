//
//  MeToNewsTableViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MeToNewsController.h"
#import "NewsCollectionViewCell.h"
#import "MeToNewsModel.h"

@interface MeToNewsController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) NSMutableArray *dataAry;

@property (nonatomic, assign) BOOL sign;

@end

@implementation MeToNewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.collectionView.dataSource = self;
    self.collectionView.delegate =self;
    
    [self getDataFormServer];
    
    [SVProgressHUD show];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
    
    
    

    self.title = @"LOVE FOOD, LOVE Ta";

    
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



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataAry.count;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NewsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"meToNewsItems" forIndexPath:indexPath];
    
    
    if (self.dataAry.count > 0) {
        MeToNewsModel *model = self.dataAry[indexPath.row];
        
        cell.model = model;
        
    }
    
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;

    return cell;
}




#pragma mark - 获取数据
- (void)getDataFormServer {
    
    NSString *urlStr = @"http://121.40.54.242:80/HandheldKitchen/api/push/tblPushInfo!getPushInfoList.do?is_traditional=0";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *dataAry = dic[@"data"];
        
            
            for (NSDictionary *dic in dataAry) {
                MeToNewsModel *model = [MeToNewsModel new];
                [model setValuesForKeysWithDictionary:dic];
                
                CGRect rect = [model.pushContent boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
                
                model.height = rect.size.height;
                [self.dataAry addObject:model];
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


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MeToNewsModel *model = nil;
    if (self.dataAry.count > 0) {
        
        
        
        model = self.dataAry[indexPath.row];
    }
   
    
    return CGSizeMake(kScreenWidth - 20, model.height + 300);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 0, 10);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
