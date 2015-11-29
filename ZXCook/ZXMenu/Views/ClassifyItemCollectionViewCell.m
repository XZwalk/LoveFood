//
//  ClassifyItemCollectionViewCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ClassifyItemCollectionViewCell.h"

@implementation ClassifyItemCollectionViewCell




- (void)setModel:(ClassifyModel *)model {
    
    _model = model;
    
    
    
    self.classifyName.textAlignment = NSTextAlignmentCenter;
    self.classifyName.font = [UIFont systemFontOfSize:14];
    self.classifyName.textColor = [UIColor darkGrayColor];
    
    [self.classifyImage sd_setImageWithURL:[NSURL URLWithString:model.imagePath]];
    
    self.classifyName.text = model.name;
    
    
}




@end
