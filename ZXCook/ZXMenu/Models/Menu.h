//
//  Menu.h
//  ZXCook
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property (nonatomic, copy) NSString *englishName;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *vegetable_id;

@property (nonatomic, copy) NSString *imagePathThumbnails;//缓存图

@property (nonatomic, copy) NSString *imagePathPortrait;//


@end
