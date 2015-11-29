//
//  AppDelegate.h
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;//被管理对象上下文, 临时数据库, 我们对数据库模型的操作都在临时数据库中进行, 不会影响到我们的真实数据库, 要想改变真实地文件, 必须进行保存操作.
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;//数据模型管理器, (被管理对象模型)
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;//持久化存储连接器(也叫持久化存储助理), coreData的核心类





- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

