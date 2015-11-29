//
//  FallLayer.m
//  ZXwalk
//
//  Created by 张祥 on 15/8/11.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "FallLayer.h"

@interface FallLayer ()

//用来保存外面传进来的图片数组
@property(nonatomic,strong)NSArray *imageNameArray;

@end


@implementation FallLayer

//因为开放了一个用一个图片初始化的借口, 这里直接调用用数组初始化的方法, 省去步骤
- (id)initWithImageName:(NSString *)imageName{
    return [self initWithImageNameArray:[NSArray arrayWithObject:imageName]];
}


//外界调用这个初始化方法, 传进来一个图片数组
- (id)initWithImageNameArray:(NSArray *)imageNameArray{
    self = [super init];
    if (self) {
        //将外界传来的图片数组保存起来
        self.imageNameArray = imageNameArray;
        [self initializeValue];
    }
    return self;
}

//直接init的初始化方法, 封装严谨
- (id)init
{
    self = [super init];
    if (self) {
        [self initializeValue];
    }
    return self;
}

//初始化方法
-(void)initializeValue{
    // Configure the particle emitter to the top edge of the screen
    
    
    //CAEmitterLayer看上去像是许多CAEmitterCell的容器
    
    
    //创建容器
    CAEmitterLayer *parentLayer = self;
    parentLayer.emitterPosition = CGPointMake(320 / 2.0, -30);
    parentLayer.emitterSize	= CGSizeMake(320 * 2.0, 0);;
    
    // Spawn points for the flakes are within on the outline of the line
    parentLayer.emitterMode	= kCAEmitterLayerOutline;
    parentLayer.emitterShape = kCAEmitterLayerLine;
    
    parentLayer.shadowOpacity = 1.0;
    parentLayer.shadowRadius = 0.0;
    parentLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    parentLayer.shadowColor = [[UIColor whiteColor] CGColor];
    parentLayer.seed = (arc4random()%100)+1;
    
    // 创建粒子
    CAEmitterCell *containerLayer = [self createSubLayerContainer];
    containerLayer.name = @"containerLayer";
    NSMutableArray *subLayerArray = [NSMutableArray array];
    NSArray *contentArray = [self getContentsByArray:self.imageNameArray];
    //用图片创建一个粒子数组
    for (UIImage *image in contentArray) {
        [subLayerArray addObject:[self createSubLayer:image]];
    }
    
    
    //如果粒子存在
    if (containerLayer) {
        // 给粒子添加粒子, (就好比数组的数组一样)
        // 粒子也有emitterCells属性, 也就是说每个粒子也是一个小容器
        containerLayer.emitterCells = subLayerArray;
        // 将粒子添加入容器
        parentLayer.emitterCells = [NSArray arrayWithObject:containerLayer];
    }else{
        //如果粒子不存在, 直接将粒子添加进容器就好, 不给粒子添加粒子
        parentLayer.emitterCells = subLayerArray;
    }
}

//设置让粒子消失
-(void)setDelayHideTime:(CGFloat)delayHideTime{
    _delayHideTime = delayHideTime;
    [self performSelector:@selector(stopFall) withObject:nil afterDelay:1];
}

//让粒子消失的方法
-(void)stopFall{
    
    // 要知道这里是给containerLayer的出生率赋值, 当它不存在的时候给它赋值肯定是回崩溃的
    // 所以像上面一样加一个判断就好了, 但是我比较懒, 不想再加属性了, 就把判断加到了外面, 就是不让它走stopFall的方法, 也就是不给delayHideTime赋值
    //所以, 判断加在给delayHideTime赋值的地方
    [self setValue:[NSNumber numberWithInt:0] forKeyPath:@"emitterCells.containerLayer.birthRate"];
}

//创建粒子
-(CAEmitterCell*)createSubLayerContainer{
    CAEmitterCell *containerLayer = [CAEmitterCell emitterCell];
    containerLayer.birthRate = 10.0;
    containerLayer.velocity	= 0;
    containerLayer.lifetime	= 0.35;
    return containerLayer;
}

//用图片创建粒子
-(CAEmitterCell *)createSubLayer:(UIImage *)image{
    CAEmitterCell *cellLayer = [CAEmitterCell emitterCell];
    
    cellLayer.birthRate	= 5.0;
    cellLayer.lifetime = 120.0;
    
    cellLayer.velocity = -100;				// falling down slowly
    cellLayer.velocityRange = 0;
    cellLayer.yAcceleration = 2;
    cellLayer.emissionRange = 0.5 * M_PI;		// some variation in angle
    cellLayer.spinRange	= 0.25 * M_PI;		// slow spin
    
    cellLayer.contents = (id)[image CGImage];
    cellLayer.color	= [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor];
    
    return cellLayer;
}

//返回一个图片数组, 即是用字符串初始化成图片对象以后放到数组中
-(NSArray *)getContentsByArray:(NSArray *)imageNameArray{
    NSMutableArray *retArray = [NSMutableArray array];
    
    for (NSString *imageName in imageNameArray) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [retArray addObject:image];
        }
    }
    return retArray;
}
@end
