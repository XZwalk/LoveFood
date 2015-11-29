//
//  ClassifyItemCollectionViewCell.h
//  ZXCook
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassifyModel.h"

@interface ClassifyItemCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *classifyImage;


@property (weak, nonatomic) IBOutlet UILabel *classifyName;

@property (nonatomic, strong) ClassifyModel *model;


@end
