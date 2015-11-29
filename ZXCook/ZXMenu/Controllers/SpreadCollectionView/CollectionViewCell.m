//
//  CollectionViewCell.m
//  test
//
//  Created by 张祥 on 15/7/4.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "CollectionViewCell.h"
#import "UIViewAdditions.h"

@interface CollectionViewCell ()

@property (nonatomic, retain) UIView *myView;
@property (nonatomic, retain) UIView *myView1;

@end

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.titleLabel];
        
        //self.backgroundColor = [UIColor redColor];
        [self addAllViews];
        [self addPointingView];
    }
    
    return self;
    
}



- (void)addAllViews
{
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
     self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imgView.bottom - 30, self.frame.size.width, 30)];
    [self addSubview:self.imgView];
    [self.imgView addSubview:self.titleLabel];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
//    self.titleLabel.backgroundColor = [UIColor greenColor];
    
    self.imgView.alpha = .95;
    
    //这里的颜色不去掉的话会看到cell与cell之间有一条一条的分割线, 不知道是为什么, 应该是cell的背景色, 不知道为什么尺寸是cell的尺寸还是会露出来
//    self.titleLabel.backgroundColor = [UIColor redColor];
//    self.imgView.backgroundColor = [UIColor blueColor];
    
    
}


- (void)addPointingView
{
    
        self.myView = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame) - 2, self.titleLabel.frame.size.width, 2)];
//        
//        self.myView1 = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2  + 0.5 - 9, self.titleLabel.bottom - 4, 13, 15)];
    
        self.myView.backgroundColor = [UIColor orangeColor];
    
        
//        self.myView.transform = CGAffineTransformMakeRotation(M_PI_4);
//        self.myView1.transform = CGAffineTransformMakeRotation(M_PI_4);
    
//        self.myView1.backgroundColor = [UIColor colorWithRed:0.774 green:0.768 blue:0.931 alpha:1.000];
    
    

}


- (void)setIsHiddenedma:(BOOL)isHiddenedma
{
    
    _isHiddenedma = isHiddenedma;
    if (!_isHiddenedma) {
        [self addSubview:self.myView];
//        [self addSubview:self.myView1];

    }else{
        [self.myView removeFromSuperview];
//        [self.myView1 removeFromSuperview];

    }
}





@end
