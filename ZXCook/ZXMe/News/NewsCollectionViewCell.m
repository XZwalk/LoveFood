//
//  NewsCollectionViewCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "NewsCollectionViewCell.h"

@interface NewsCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;


@property (weak, nonatomic) IBOutlet UILabel *subLabel;



@property (weak, nonatomic) IBOutlet UILabel *weekLabel;


@property (weak, nonatomic) IBOutlet UILabel *dateLabel;



@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;



@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end


@implementation NewsCollectionViewCell

- (void)setModel:(MeToNewsModel *)model {
    
    _model = model;
    
    self.mainLabel.text = _model.title;
    self.subLabel.text = _model.subtitle;
    
    
    NSString *weekStr = [_model.sendTime substringToIndex:2];
    
    NSString *dateStr = [_model.sendTime substringFromIndex:2];
    
    
    self.weekLabel.text = weekStr;
    
    self.dateLabel.text = dateStr;
    
    
    [self.imageVIew sd_setImageWithURL:[NSURL URLWithString:_model.imagePathThumbnails]];
    
    
    self.contentLabel.text = _model.pushContent;
    
    
}






@end
