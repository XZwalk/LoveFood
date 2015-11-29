//
//  NetworkHelper.m
//  TuDou_QiuBai
//
//  Created by 张祥 on 15/6/26.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "NetworkHelper.h"

@interface NetworkHelper ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>


//此私有属性, 用于保存从服务器获取到的数据
@property (nonatomic, retain)NSMutableData *data;

@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, assign) BOOL sign;//标记方法是否执行


@end


@implementation NetworkHelper




- (void)getDataWithUrlString:(NSString *)urlString
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.connection = [NSURLConnection  connectionWithRequest:request delegate:self];

    [self.connection start];
    
    //开启系统状态栏小菊花
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isProgress"] boolValue]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isProgress"];
        
    } else {
         [SVProgressHUD show];
    }
    
    
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
}

- (void)dismiss {
    //此方法执行的时候将值设为YES
    self.sign = YES;
    [SVProgressHUD dismiss];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    
    
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}




- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    //如果取消方法没执行则执行此方法
    //也就是说, 如果3秒钟加载成功则执行成功方法, 3秒钟没加载成功则执行取消方法
    if (!self.sign) {
        
        
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isSuccess"] boolValue]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isSuccess"];

        } else {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }
        
    }
 
    
    if (_delegate && [_delegate respondsToSelector:@selector(networkDataIsSuccessful:)]) {
        [_delegate networkDataIsSuccessful:self.data];
    }
}

    



//当一个网络连接请求错误后, 执行此方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
    
    //如果代理存在, 而且能响应方法
    if (_delegate && [_delegate respondsToSelector:@selector(networkDataIsFail:)])
    {
        [_delegate networkDataIsFail:error];
    }
}



- (NSMutableData *)data
{
    if (!_data)
    {
        self.data = [NSMutableData data];
    }
    return _data;
}


- (void)connectionCancel
{
    [self.connection cancel];
    
}


@end
