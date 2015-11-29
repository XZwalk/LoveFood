//
//  MeToNewsModel.h
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeToNewsModel : NSObject
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *subtitle;//子标题
@property (nonatomic, copy) NSString *pushContent;//内容
@property (nonatomic, copy) NSString *imagePathThumbnails;//图片
@property (nonatomic, copy) NSString *vegetableId;//id
@property (nonatomic, copy) NSString *sendTime;//推送时间

@property (nonatomic, assign) CGFloat height;


@end
