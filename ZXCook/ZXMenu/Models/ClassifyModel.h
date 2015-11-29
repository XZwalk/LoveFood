//
//  ClassifyModel.h
//  ZXCook
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassifyModel : NSObject

@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nameID;

@property (nonatomic, copy) NSString *imagePathLandscape;//从精品汇过去的
@property (nonatomic, copy) NSString *vegetable_id;//从精品汇过去的
@property (nonatomic, copy) NSString *materialVideoPath;//A视频
@property (nonatomic, copy) NSString *productionProcessPath;//B视频


@end
