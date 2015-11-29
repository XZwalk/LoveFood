//
//  Movie.h
//  TwoTableView
//
//  Created by 张祥 on 15/8/13.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, copy) NSString *fittingRestriction;//原料内容

@property (nonatomic, copy) NSString *method;//调料内容
@property (nonatomic, copy) NSString *materialVideoPath;//A视频

@property (nonatomic, copy) NSString *productionProcessPath;//B视频
@property (nonatomic, copy) NSString *imagePathThumbnails;//视频缓存缩略图

@property (nonatomic, copy) NSString *vegetable_id;//id

@property (nonatomic, copy) NSString *name;//名字


@end
