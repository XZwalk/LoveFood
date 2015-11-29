//
//  CollectCell.h
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCook.h"



@interface CollectCell : UICollectionViewCell

@property (nonatomic, strong) MenuCook *model;

@property (nonatomic, assign) BOOL isDeleteButtonHide;


@end
