//
//  MeToBooksTableViewCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MeToBooksTableViewCell.h"


@interface MeToBooksTableViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;


@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *httpLabel;

@end

@implementation MeToBooksTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MeToBooks *)model {
    _model = model;
    
    
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:_model.publishingImage]];
    
    self.contentLabel.text = _model.publishingName;
    
    self.httpLabel.text = _model.publishingUrl;
}






@end
