//
//  MenuDetailView.m
//  ZXCook
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MenuDetailView.h"


@interface MenuDetailView ()
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

@end


@implementation MenuDetailView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self addAllViews];
        
    }
    
    return self;
}


- (void)addAllViews {
    
 
    self.label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 200, 50)];//汉字
    self.label2 = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.label1.frame) - 20, 200, 20)];//拼音
    
    self.label1.textColor = [UIColor whiteColor];
    self.label2.textColor = [UIColor whiteColor];
    self.label2.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:self.label1];
    [self addSubview:self.label2];
    
}


//给控件赋值走model的set方法
- (void)setMenu:(Menu *)menu {
    _menu = menu;
    
    self.label1.text = self.menu.name;
    
    self.label2.text = self.menu.englishName;

    
}



@end
