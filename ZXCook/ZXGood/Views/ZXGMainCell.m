//
//  ZXGMainCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/14.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXGMainCell.h"


@interface ZXGMainCell ()
@property (weak, nonatomic) IBOutlet UIImageView *useImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ZXGMainCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setModel:(ZXGMainMdoel *)model {
    _model = model;
    [self.useImageView sd_setImageWithURL:[NSURL URLWithString:_model.imageFilename]];
    
    
    NSArray *strAry = [_model.name componentsSeparatedByString:@"100"];
    
    self.titleLabel.text = strAry[0];
    
}




@end
