//
//  NetworkHelper.h
//  TuDou_QiuBai
//
//  Created by 张祥 on 15/6/26.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <Foundation/Foundation.h>


//数据获取处理类定得一个协议
@protocol NetworkHelperDelegate <NSObject>


//当数据成功获取后使用此方法回调
- (void)networkDataIsSuccessful:(NSData *)data;


//当数据获取失败后使用此方法回调
- (void)networkDataIsFail:(NSError *)error;



@end




@interface NetworkHelper : NSObject


@property (nonatomic, retain)id<NetworkHelperDelegate> delegate;


//通过调用此方法(需传入获取数据的地址), 来开始获取数据
- (void)getDataWithUrlString:(NSString *)urlString;


/**
 *取消网络请求
 */
- (void)connectionCancel;


@end
