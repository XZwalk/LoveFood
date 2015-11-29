//
//  ZXNDetailCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/15.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXNDetailCell.h"


@interface ZXNDetailCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation ZXNDetailCell







- (void)setModel:(ZXNListModel *)model {
    _model = model;
    
    
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:_model.imagePathThumbnails]];
    
    self.contentLabel.text = model.name;
    
}





@end
