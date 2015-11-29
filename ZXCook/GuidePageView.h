//
//  GuidePageView.h
//  ProgramGuidePage
//
//  Created by 介岳西 on 15/6/13.
//  Copyright (c) 2015年 介岳西. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuidePageView : UIView

@property (nonatomic, retain) UIButton *but;


- (id)initWithFrame:(CGRect)frame
         namesArray:(NSArray *)items;

@end
