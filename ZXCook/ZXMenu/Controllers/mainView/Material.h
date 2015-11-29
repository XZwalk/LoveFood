//
//  Material.h
//  TwoTableView
//
//  Created by 张祥 on 15/8/13.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Material : NSObject


@property (nonatomic, copy) NSString *name;//调料名
@property (nonatomic, copy) NSString *imagePath;//调料的图片

@property (nonatomic, copy) NSString *seasoningContent;//调料的内容


@property (nonatomic, copy) NSString *rawImagePath;//原料的图片

@property (nonatomic, copy) NSString *rawContent;//原料内容




@end
