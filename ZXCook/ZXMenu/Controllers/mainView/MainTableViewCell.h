//
//  TableViewCell.h
//  TwoTableView
//
//  Created by 张祥 on 15/8/13.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *makeAry;
@property (nonatomic, copy) NSArray *materialAry;
@property (nonatomic, strong) NSArray *aboutAry;
@property (nonatomic, copy) NSDictionary *fitAndGramDic;
@property (nonatomic, assign) CGFloat height;

+ (CGFloat)getSuitHeight;
@end
