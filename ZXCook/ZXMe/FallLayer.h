//
//  FallLayer.h
//  ZXwalk
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FallLayer : CAEmitterLayer

@property(nonatomic,assign)CGFloat delayHideTime;

- (id)initWithImageName:(NSString *)imageName;

- (id)initWithImageNameArray:(NSArray *)imageNameArray;

-(void)initializeValue;

-(CAEmitterCell *)createSubLayerContainer;

-(CAEmitterCell *)createSubLayer:(UIImage *)image;

@end
