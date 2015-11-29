//
//  GuidePageView.m
//  ProgramGuidePage
//
//  Created by 介岳西 on 15/6/13.
//  Copyright (c) 2015年 介岳西. All rights reserved.
//


#define kKEY_WINDOW [[UIApplication sharedApplication] keyWindow]

#import "GuidePageView.h"

@interface GuidePageView ()

@property (nonatomic, retain) UIScrollView * grideScroll;

@end



@implementation GuidePageView



- (id)initWithFrame:(CGRect)frame
     namesArray:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = [[UIScreen mainScreen] bounds];
        [kKEY_WINDOW addSubview:self];
        
        self.grideScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.grideScroll.contentSize = CGSizeMake(kKEY_WINDOW.frame.size.width * items.count, kKEY_WINDOW.frame.size.height);
        self.grideScroll.pagingEnabled = YES;
        [self addSubview:self.grideScroll];
        self.grideScroll.showsHorizontalScrollIndicator = NO;
        //self.grideScroll.backgroundColor = [UIColor redColor];
        
        [self loadImagesWithArray:items];
    }
    return self;
}



- (void)loadImagesWithArray:(NSArray *)items
{
    for (int i = 0; i < items.count; i++)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kKEY_WINDOW.frame.size.width, 0, kKEY_WINDOW.frame.size.width, kKEY_WINDOW.frame.size.height)];
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:[items objectAtIndex:i]];
        [self.grideScroll addSubview:imageView];
        
        if (i == items.count - 1) {
            self.but = [UIButton buttonWithType:UIButtonTypeSystem];
            self.but.frame = CGRectMake(100,
                                   kKEY_WINDOW.frame.size.height - 90,
                                   kKEY_WINDOW.frame.size.width - 200,
                                   40);
            self.but.backgroundColor = [UIColor colorWithRed:1.000 green:0.717 blue:0.931 alpha:1.000];
            [self.but setTitle:@"开启美食之旅" forState:UIControlStateNormal];
            [self.but setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.but.titleLabel.font = [UIFont systemFontOfSize:17];
            [imageView addSubview:self.but];
        }
    }
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
