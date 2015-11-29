//
//  SearchResultCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/16.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "SearchResultCell.h"

@interface SearchResultCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation SearchResultCell





- (void)setModel:(SearchModel *)model {
    _model = model;
    
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:model.imagePath]];
    
    self.contentLabel.text = model.name;
}



@end
