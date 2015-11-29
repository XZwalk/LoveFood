//
//  NoProductView.m
//  Class2509
//
//  Created by 张祥 on 15/7/19.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "NoProductView.h"
#import "UIViewAdditions.h"


@interface NoProductView ()
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UILabel *label;

@end
@implementation NoProductView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.944 green:0.947 blue:0.958 alpha:1.000];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 150) / 2, (200.00 / 667.00) * [UIScreen mainScreen].bounds.size.height, 150, 150)];
        
        self.imgView.image = [UIImage imageNamed:@"noresult"];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imgView.bottom, [UIScreen mainScreen].bounds.size.width, 40)];
        
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:14];
        
        
        [self addSubview:self.imgView];
        [self addSubview:self.label];
        
    }
    return self;
}


- (void)setNameTitle:(NSString *)nameTitle
{
    _nameTitle = nameTitle;
    self.label.text = _nameTitle;
    
}





@end
