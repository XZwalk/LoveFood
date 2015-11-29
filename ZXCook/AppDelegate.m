//
//  AppDelegate.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "GuidePageView.h"


@interface AppDelegate ()
@property (nonatomic, strong) GuidePageView *guide;

@property (nonatomic, strong) UITabBarController *tabBar;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#warning mark - 用StoryBoard写代码加引导页的方法
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.tabBar = [storyBoard instantiateViewControllerWithIdentifier:@"xiang"];

    self.window.rootViewController = self.tabBar;

    
    
    [self addGuidePage];
    return YES;
}



- (void)addGuidePage
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isRuned"] boolValue])
    {
        NSArray * ary = @[@"welcome1.png",
                          @"welcome2.png",
                          @"welcome3.png",
                          @"welcome4.png"];
        
        self.guide = [[GuidePageView alloc] initWithFrame:self.window.bounds
                                               namesArray:ary];
        [self.tabBar.view addSubview:self.guide];
        
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isRuned"];
        
        [self.guide.but addTarget:self action:@selector(beginExperience:) forControlEvents:UIControlEventTouchUpInside];
    }else
    {
        [self checkNetworkStatus];
    }
}



- (void)beginExperience:(UIButton *)sender
{
    [self.guide removeFromSuperview];
    [self checkNetworkStatus];
}



#pragma mark - UI方法
#pragma mark - 私有方法
#pragma mark 网络状态变化提示

-(void)alert:(NSString *)message{
    
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [alertView dismissWithClickedButtonIndex:0 animated:YES];
//        
//    });
 }

#pragma mark 网络状态监测
-(void)checkNetworkStatus{
    //创建一个用于测试的url
    NSURL *url=[NSURL URLWithString:@"http://www.apple.com"];
    AFHTTPRequestOperationManager *operationManager=[[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    
    //根据不同的网络状态改变去做相应处理
    [operationManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self alert:@"您当前网络为2G/3G/4G网络."];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self alert:@"您当前处于WiFi网络, 请放心使用"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self alert:@"无网络, 请检查网络连接."];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                break;
                
            default:
                [self alert:@"Unknown."];
                break;
        }
    }];
    
    //开始监控
    [operationManager.reachabilityManager startMonitoring];
}








- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xiangzi.ZXCook" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ZXCook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ZXCook.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
