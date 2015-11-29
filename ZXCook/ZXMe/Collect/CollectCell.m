//
//  CollectCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "CollectCell.h"

@interface CollectCell ()


@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, strong) UIButton *but;


@end

@implementation CollectCell




- (void)setModel:(MenuCook *)model {
    _model = model;
    
    self.contentImageView.image = [UIImage imageWithData:_model.imageData];
    
    self.contentLabel.text = _model.name;
    
}


- (UIButton *)but {
    if (!_but) {
        self.but = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.but.frame = CGRectMake(self.frame.size.width - 30, 0, 30, 30);
        
        self.but.backgroundColor = [UIColor blueColor];
        
        
        self.but.layer.masksToBounds = YES;
        self.but.layer.cornerRadius = 15;
        
        [self.but setBackgroundImage:[UIImage imageNamed:@"delete.jpg"] forState:UIControlStateNormal];
    }
    
    return _but;
}



- (void)setIsDeleteButtonHide:(BOOL)isDeleteButtonHide {
    _isDeleteButtonHide = isDeleteButtonHide;
    
    if (!_isDeleteButtonHide) {
        [self addSubview:self.but];
    } else {
        [self.but removeFromSuperview];
    }
    
}

@end
