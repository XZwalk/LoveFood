//
//  ZXNTableViewCell.m
//  ZXCook
//
//  Created by 张祥 on 15/8/15.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "ZXNTableViewCell.h"




@interface ZXNTableViewCell ()

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *contentLabel;


@property (strong, nonatomic) UIImageView *freshImageView;

@end


@implementation ZXNTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, kScreenWidth / 2 - 20, 30)];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), 60)];
        
        self.freshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 10, 5, kScreenWidth / 2 - 25, 100)];
        
        
        //self.freshImageView.backgroundColor = [UIColor redColor];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.freshImageView];
        
        
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.contentLabel.textColor = [UIColor darkGrayColor];
        
        self.titleLabel.numberOfLines = 0;
        self.contentLabel.numberOfLines = 0;
        
        
        //这样按字符切割的不会导致半个字的出现
        self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        
        
        
        
        
        

    }
    
    return self;
}
    
    

//cell的init方法在刚进入生成cell的地方就会走, 所以在init方法里给cell赋后来得到的值是没用的


//借助cell的属性的setter方法, 正好, cell的init方法也走完了, cell的对象有了. 给cell的属性赋值, 走到这里, 给cell上的空间一一赋值, prefect

- (void)setModel:(ZXNewModel *)model {
    _model = model;
    
    
    self.titleLabel.text = _model.name;
    self.contentLabel.text = _model.content;
    
    [self.freshImageView sd_setImageWithURL:[NSURL URLWithString:model.titleImageFile]];

    
    
}
    
    


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
