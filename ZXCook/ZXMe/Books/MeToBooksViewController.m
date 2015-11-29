//
//  MeToBooksViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MeToBooksViewController.h"
#import "MeToBooks.h"
#import "MeToBooksTableViewCell.h"

@interface MeToBooksViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;

@property (nonatomic, strong) NSMutableArray *dataAry;

@property (nonatomic, assign) BOOL sign;

@end

@implementation MeToBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;

    [self getDataFromServer];
    
    self.title = @"新书推荐";
    
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


#pragma mark - 获取数据
- (void)getDataFromServer {
    
    NSString *urlStr = @"http://121.40.54.242:80/HandheldKitchen/api/more/tblnewbook!getPublishing.do?is_traditional=0";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *dataAry = dic[@"data"];
            
            for (NSDictionary *dic in dataAry) {
                MeToBooks *model = [MeToBooks new];
                [model setValuesForKeysWithDictionary:dic];
                
                [self.dataAry addObject:model];
            }
            
            if (!self.sign) {
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
            
            [self.tableVIew reloadData];
            
        }
    }];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeToBooksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meToBookCell"];
    
    if (self.dataAry.count > 0) {
        MeToBooks *model = self.dataAry[indexPath.row];
        
        cell.model = model;
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
