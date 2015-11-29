//
//  ZXNReusableView.m
//  ZXCook
//
//  Created by 张祥 on 15/8/15.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXNReusableView.h"


@interface ZXNReusableView ()

@property (weak, nonatomic) IBOutlet UIImageView *titileImageView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end


@implementation ZXNReusableView

- (void)setModel:(ZXNDetailModel *)model {
    _model = model;
    
    [self.titileImageView sd_setImageWithURL:[NSURL URLWithString:_model.imageFilename]];
    
    self.contentLabel.text = _model.content;
    
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;

}




@end
