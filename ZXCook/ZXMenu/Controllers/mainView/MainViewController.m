//
//  RootViewController.m
//  TwoTableView
//
//  Created by 张祥 on 15/8/12.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MainViewController.h"
#import "MainTableViewCell.h"
#import "NetworkHelper.h"
#import "MakeSteps.h"
#import "Material.h"
#import "Movie.h"
#import "About.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+WebCache.h"
#import "Fitting.h"
#import "Gram.h"
#import "BigMaterial.h"
#import "HYSegmentedControl.h"
#import "AppDelegate.h"
#import "MenuCook.h"
#import "MyOwnNotification.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//图片的高度
#define kImageHeight 150

//图片标题label的高度
#define kLabelHeight 60

//最后一页label的高度
#define kLastLabel 50

//图片上label的高度
#define kLittleLabelHeight 30

//图片之间的间距
#define kSpace 20

//最后一页图片之间的间距
#define kLittleSpace 10

//定义全局变量, 标记播放次数, 以便完成自动播放
static int playTime = 1;

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate, NetworkHelperDelegate, UIScrollViewDelegate, HYSegmentedControlDelegate, MyOwnNotificationDelegate>
@property (nonatomic, strong) UITableView *mainTableView;
//制作步骤
@property (nonatomic, strong) NSMutableArray *makeModelAry;
//材料
@property (nonatomic, strong) NSMutableArray *materialAry;
//视频
@property (nonatomic, strong) NSMutableArray *movieAry;
//相关
@property (nonatomic, strong) NSMutableArray *aboutAry;
@property (nonatomic, strong) NSMutableDictionary *suitAndGramDic;
@property (nonatomic, strong) UIScrollView *scroView;
@property (nonatomic, strong) UIView *lineView;
//cell的高度
@property (nonatomic, assign) CGFloat height;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器
@property (nonatomic, strong) UIImageView *playerView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *sectionHeaderView;
@property (nonatomic, strong) HYSegmentedControl *segment;
@property (nonatomic, strong) UIImage *thumImage;
@property (nonatomic, strong) NSManagedObjectContext *context;//被管理对象上下文

@property (nonatomic, strong) UISearchBar *searchBar;


@end

@implementation MainViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden =YES;
    
    for (UIView *view in self.navigationController.view.subviews) {
        if ([view isKindOfClass:[UISearchBar class]]) {
            self.searchBar = (UISearchBar *)view;
            
            self.searchBar.hidden = YES;
        }
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    //注意: 别忘添加, 不然无显示
    [self.view addSubview:self.mainTableView];
    
    [self addTableViewHeaderView];
    [self getDataFromServer];
    [self getMaterialData];
    [self getMovieData];
    [self getAboutData];
    [self getSuitableData];
    
    //添加通知
    [self addNotification];
    

    self.title = self.name;
    
    //取到Appdelegate里面的属性, 也即是临时数据库
    self.context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    
}




- (void)addTableViewHeaderView {
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.mainTableView.tableHeaderView = self.headerView;
    
}



#pragma mark -  *******************视频播放

- (void)addMoviePlayer {
    _moviePlayer = nil;
    
    //得到播放网址
    NSURL *url = [self getNetworkUrl];
    //用网址初始化一个播放器
#warning mark - 这里可以对自动播放的代码优化, 更改它的contentURL
    //貌似播放器的初始化的网址是可以更改的, 我这里播放一个创建一个, 后期代码维护的时候再修改把
    _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:url];
    _moviePlayer.view.frame=self.headerView.bounds;
    
    _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.headerView addSubview:_moviePlayer.view];
    
    NSString *thumStr = [self.movieAry[0] imagePathThumbnails];
    
//    [self.playerView sd_setImageWithURL:[NSURL URLWithString:thumStr]];
    
    [self.playerView sd_setImageWithURL:[NSURL URLWithString:thumStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.thumImage = image;
        
    }];
    
    
    
    [self.headerView bringSubviewToFront:self.playerView];
    
    //如果启动视频播放器的方式是play, 则下面这句代码没用, 视频直接播放, 故使用prepareToPlay启动
    _moviePlayer.shouldAutoplay = NO;
    
    if (playTime == 1) {
        //准备播放, 最开始是暂停状态
        [self.moviePlayer prepareToPlay];
        
    }else {
        //自动播放, 启动时就是播放的
        [self.moviePlayer play];
    }
    //标记为第一次播放结束
    playTime++;
}



-(void)dealloc{
    
    //全局变量, 可不是说这个页面消失的时候这个变量也被销毁了, 它是只有整个程序被销毁的时候它才会被销毁, 所以需要在当前页面消失的时候对其进行重置, 以便下次进入此页面的时候还是初始值
    //这个变量未重置, 第一次进来出去正常, 第二次再进来的时候视频自动播放, 因为再进来的时候playTime已经不是1了, 它是根据上次值叠加的, 已经变成2了, 自然走else 方法, 也就是自动播放(且此时播放的还是第二段的视频)
    //所以使用的时候一定要谨慎, 确保重置和不和其他页面的全局变量重名, 更要注意直接写在代码里的全局变量, 它也是全局的, 不会走第二次
    playTime = 1;
    
    //因为我们这是ARC, 系统处理对象的释放, 但这需要时间, 所以会造成我们点击返回按钮之后视频还会延迟播放两秒左右
    //在对象要销毁之前先将播放器停掉, 这样的话直接就会将正在播放的视频停掉, 而后系统在处理对象的销毁
    [self.moviePlayer stop];
    
    //移除所有通知监控
    //如果不移除的话通知是一直存在的, 这是不正常的
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 私有方法

/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getNetworkUrl{
    
    NSString *urlStr = nil;
    
    if (playTime == 1) {
        if (self.moveArray) {
            urlStr = self.moveArray[0];
        } else {
            urlStr =[self.movieAry[0] materialVideoPath];
        }
        urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        return url;
    } else {
        
        if (self.moveArray) {
            urlStr = self.moveArray[1];
        } else {
            urlStr = [self.movieAry[0] productionProcessPath];
        }
        
        urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr];
        return url;
    }
}



/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    
    //这里直接使用的是系统封装好的消息的名字, 也就是我们不必再发消息了, 当系统检测到有东西触发了封装的这个消息, 就会自动给观察者发送消息
    
    //self监听self.moviePlayer发出的MPMoviePlayerPlaybackStateDidChangeNotification消息, 然后执行mediaPlayerPlaybackStateChange:方法
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    
    //self监听self.moviePlayer发出的MPMoviePlayerPlaybackDidFinishNotification消息, 然后执行mediaPlayerPlaybackFinished:方法
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    
}

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.moviePlayer.playbackState);
            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    
    //只调用一次
    if (playTime == 2) {
        [self addMoviePlayer];
    }
    NSLog(@"播放完成.%li",self.moviePlayer.playbackState);
}





#pragma mark - ***************************懒加载
- (NSMutableArray *)makeModelAry {
    if (!_makeModelAry) {
        self.makeModelAry = [@[] mutableCopy];
    }
    return _makeModelAry;
}

- (NSMutableArray *)materialAry {
    if (!_materialAry) {
        self.materialAry = [@[] mutableCopy];
    }
    return _materialAry;
}


- (NSMutableArray *)movieAry {
    
    if (!_movieAry) {
        self.movieAry = [@[] mutableCopy];
    }
    return _movieAry;
}

- (NSMutableArray *)aboutAry {
    
    if (!_aboutAry) {
        self.aboutAry = [@[] mutableCopy];
    }
    return _aboutAry;
}


- (NSMutableDictionary *)suitAndGramDic {
    
    if (!_suitAndGramDic) {
        self.suitAndGramDic = [@{} mutableCopy];
    }
    return _suitAndGramDic;
}


- (UIImageView *)playerView {
    if (!_playerView) {
        self.playerView = [[UIImageView alloc] initWithFrame:self.headerView.bounds];
        
        [self.headerView addSubview:self.playerView];
        
        //由于imageView的特殊, 会影响加载其视图上的button的交互, 所以需要把图片视图的用户交互打开, 不然button无交互
        self.playerView.userInteractionEnabled = YES;
        
        self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
        
        //but.backgroundColor = [UIColor blueColor];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"PlayButton"] forState:UIControlStateNormal];
        
        self.playButton.center = self.playerView.center;
        
        [self.playerView addSubview:self.playButton];
        
        [self.playButton addTarget:self action:@selector(removeImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playerView;
}


- (void)removeImage {
    [self.playerView removeFromSuperview];
    [self.moviePlayer play];
    
}
#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"cell";
    
    MainTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:str];
    
    cell.height = self.height;
    
    if (!cell) {
        cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    
    
    if (self.makeModelAry.count > 0 && self.movieAry.count > 0 && self.materialAry.count > 0 && self.aboutAry.count > 0 && self.suitAndGramDic.allKeys.count > 0) {
        cell.makeAry = self.makeModelAry;
        
        [self.materialAry[0] setRawContent:[self.movieAry[0] fittingRestriction]];
        
        [self.materialAry[0] setSeasoningContent:[self.movieAry[0] method]];
        cell.materialAry = self.materialAry;
        
        cell.aboutAry = self.aboutAry;
        
        cell.fitAndGramDic = self.suitAndGramDic;
    }
    
    [cell setValue:self forKeyPath:@"scrView.delegate"];
    
    self.scroView = [cell valueForKeyPath:@"scrView"];
    
    return cell;
}


#pragma mark - UITableViewDelegate


//傻逼, 这里的方法每次都会走, 走一次控件都会被重新创建一次, 傻逼
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //因为我在区头视图上放的有控件, 如果不用懒加载, 每次走这个方法, 控件都会被重新创建, 绝逼有问题呀
    return self.sectionHeaderView;
}


- (UIView *)sectionHeaderView {
    if (!_sectionHeaderView) {
        self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        
        self.segment = [[HYSegmentedControl alloc] initWithOriginY:0 Titles:@[@"制作步骤", @"所需材料", @"相关知识", @"相宜相克"] delegate:self];
        
        [self.sectionHeaderView addSubview:self.segment];
    }
    return _sectionHeaderView;
}



#pragma mark - 分段选择器

#pragma mark - 第三方分段选择器方法

- (void)hySegmentedControlSelectAtIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            
        {
            //我们要把更新之后的heigh拿过来, 因为我们用代码改变它的位置的时候, 它是不会走拖拽减速的代理方法的, 所以我们需要在这里更新高度
            self.height = self.makeModelAry.count * (kLabelHeight + kImageHeight);
            
            //更新scrollView的偏移量
            //这里要记住, 虽然偏移之后y的偏移量不变(忽略这里y的特殊需求变化, 一般情况下), 但是我们不能只给x的偏移量, 系统不让给, 所以需同时给contentOffset
            //这就类似于我们更改一个控件的高的时候不能只改变size, 更不能直接改变size.height, 需要更改整个frame
            self.scroView.contentOffset = CGPointMake(0, self.height);
            
            //因为我们scrollView放在cell上, 所以我们在对scrollView做出改变之后要刷新数据, 不然只有滑动之后才能显示出来
            
            self.lineView.frame = CGRectMake(0, 37, kScreenWidth / 4, 2);
            [self.mainTableView reloadData];
        }
            
            break;
        case 1:
            
        {
            self.height = self.materialAry.count * (kImageHeight  + kSpace) + 2 * kLabelHeight + kImageHeight + 30;
            
            self.scroView.contentOffset = CGPointMake(kScreenWidth, self.height);
            self.lineView.frame = CGRectMake( kScreenWidth / 4, 37, kScreenWidth / 4, 2);
            [self.mainTableView reloadData];
            
        }
            break;
        case 2:
        {
            self.height = [MainTableViewCell getSuitHeight] + 50;
            
            self.scroView.contentOffset = CGPointMake(kScreenWidth * 2, self.height);
            
            [self.mainTableView reloadData];
        }
            break;
        case 3:
        {
            
            NSInteger fitNum = [self.suitAndGramDic[@"fitting"] count];
            NSInteger gramNum = [self.suitAndGramDic[@"gram"] count];
            
            self.height = kLastLabel * (fitNum + gramNum + 2) + 20 + 4 * kSpace;
            if (self.height < kScreenHeight - 240) {
                self.height = kScreenHeight - 240;
            }
            self.scroView.contentOffset = CGPointMake(kScreenWidth * 3, self.height);
            [self.mainTableView reloadData];
        }
            break;
        default:
            break;
    }
}



#pragma maek -


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%.f", self.height);
    return self.height;
}


//用plain格式的时候, 这个高度不给显示不出来
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


#pragma mark - 获取数据




#pragma mark - 制作步骤

- (void)getDataFromServer {
    
    //制作步骤
    NSString *urlStr = [NSString stringWithFormat:@"http://121.40.54.242/HandheldKitchen/api/vegetable/tblvegetable!getIntelligentChoice.do?vegetable_id=%@&type=2&phonetype=0&is_traditional=0", self.nameID];
    
    NetworkHelper *helper = [NetworkHelper new];
    helper.delegate = self;
    [helper getDataWithUrlString:urlStr];
}

#pragma mark - 所需材料

- (void)getMaterialData {
    
    //所需材料
    NSString *urlStr = [NSString stringWithFormat:@"http://121.40.54.242/HandheldKitchen/api/vegetable/tblvegetable!getIntelligentChoice.do?vegetable_id=%@&type=1&phonetype=0&is_traditional=0", self.nameID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    //在主线程发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *ary = dic[@"data"];
            NSArray *materialAry = ary[0][@"TblSeasoning"];
            NSString *imagePath = ary[0][@"imagePath"];
            
            NSArray *dataAry = nil;
            if (materialAry.count == 0) {
                dataAry = [ary lastObject][@"TblSeasoning"];
            } else {
                dataAry = materialAry;
            }
            
            for (NSDictionary *dic in dataAry) {
                Material *model = [Material new];
                [model setValuesForKeysWithDictionary:dic];
                //原料的图片BigMaterial
                model.rawImagePath = imagePath;
                [self.materialAry addObject:model];
            }
            
            
            //因为我的Material里面不仅要存放从ary里面解析出来的数据, 还要存放从视频里面以及imagePath
            //但是如果我model为空的话后面这些都加不上, 所以我如果从这里面解析不出来数据, 还是要创造一个model对象, 以便接收后面从其他网址解析出来的数据
#warning mark - 一个model从很多网址拿数据, 而且有部分网址解析不到数据造成数据不显示且程序崩溃的解决办法
            //这也是一个model数据从好多不同网址中解析的一种办法, 也就是说, 如果我这里解析不到数据就会造成数组为空, 所以要自己创造一个model对象, 以便在生成cell的地方能从其他数组里拿到的数据赋值给我的model
            if (self.materialAry.count == 0) {
                Material *model = [Material new];
                
                model.rawImagePath = imagePath;
                [self.materialAry addObject:model];
            }
            
            [self.mainTableView reloadData];
            
        }
    }];
}

#pragma mark - 主页视频

- (void)getMovieData {
    
    //主页视频
    NSString *urlStr = [NSString stringWithFormat:@"http://121.40.54.242:80/HandheldKitchen/api/vegetable/tblvegetable!getTblVegetables.do?vegetable_id=%@&phonetype=2&user_id=&is_traditional=0", self.nameID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    //在主线程发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *ary = dic[@"data"];
            Movie *model = [Movie new];
            [model setValuesForKeysWithDictionary:ary[0]];
            [self.movieAry addObject:model];
            
            //拿到视频数据以后添加播放器
            [self addMoviePlayer];
            
            
            [self addCollect];
            
            //更新数据
            [self.mainTableView reloadData];
        }
    }];
    
}

#pragma mark - 相关知识

- (void)getAboutData {
    
    //相关知识
    NSString *urlStr = [NSString stringWithFormat:@"http://121.40.54.242/HandheldKitchen/api/vegetable/tblvegetable!getIntelligentChoice.do?vegetable_id=%@&type=4&phonetype=0&is_traditional=0", self.nameID];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    //在主线程发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *ary = dic[@"data"];
            About *model = [About new];
            [model setValuesForKeysWithDictionary:ary[0]];
            [self.aboutAry addObject:model];
            
            [self.mainTableView reloadData];
        }
    }];
}







#pragma mark - 相宜相克

- (void)getSuitableData {
    
    //相宜相克
    NSString *urlStr = [NSString stringWithFormat:@"http://121.40.54.242/HandheldKitchen/api/vegetable/tblvegetable!getIntelligentChoice.do?vegetable_id=%@&type=3&phonetype=0&is_traditional=0", self.nameID];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    //在主线程发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (data) {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *ary = dic[@"data"];
            
            BigMaterial *model = [BigMaterial new];
            [model setValuesForKeysWithDictionary:ary[0]];
            
            NSMutableArray *fitAry = [@[] mutableCopy];
            
            for (NSDictionary *dic in ary[0][@"Fitting"])
            {
                Fitting *model = [Fitting new];
                
                [model setValuesForKeysWithDictionary:dic];
                
                [fitAry addObject:model];
            }
            
            NSMutableArray *gramAry = [@[] mutableCopy];
            
            if (ary.count > 1) {
                for (NSDictionary *dic in ary[1][@"Gram"]) {
                    Gram *model = [Gram new];
                    
                    [model setValuesForKeysWithDictionary:dic];
                    
                    [gramAry addObject:model];
                }
            }
            [self.suitAndGramDic setValue:model forKey:@"bigMaterial"];
            [self.suitAndGramDic setValue:fitAry forKey:@"fitting"];
            [self.suitAndGramDic setValue:gramAry forKey:@"gram"];
            [self.mainTableView reloadData];
            
        }
    }];
}








#pragma mark - NetworkHelperDelegate


//当数据成功获取后使用此方法回调
- (void)networkDataIsSuccessful:(NSData *)data {
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *ary = dic[@"data"];
    
    for (NSDictionary *dic in ary) {
        MakeSteps *model = [MakeSteps new];
        [model setValuesForKeysWithDictionary:dic];
        [self.makeModelAry addObject:model];
    }
    
    //因为第一次不会走scrollView的滑动减速的代理方法, 所以第一个高度需要我们自己添加
    self.height = self.makeModelAry.count * (kLabelHeight + kImageHeight);
    
    [self.mainTableView reloadData];
}





//当数据获取失败后使用此方法回调
- (void)networkDataIsFail:(NSError *)error {
    
    
    
    
}




#pragma mark - UIScrollViewDelegate


//当scrollView的frame的高度和其父视图的frame的高度相等的时候, scrollView是不能上下滑动的, 也就是不响应上下的拖拽手势, 这时候tableView就会响应并处理用户的拖拽手势, 所以一定要实时更新scrollView的frame, 让其与父视图的高度相等, 不然当其高度与父视图不等的时候, 例如比父视图小, 这时候我们上下拖拽scrollView的时候, scrollView就会响应上下拖拽的时候, 也就是拦截了上下拖拽手势, 这时候tableView就不会跟着上下移动了


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //这句代码不加, 无法判断, 因为tableview也继承于scrollView, 在滑动的时候tableVoiew也会走这个方法, 所以我们当不是tableView的时候走这个方法
    if (scrollView != self.mainTableView) {
        
        if (scrollView.contentOffset.x == 0) {
            self.height = self.makeModelAry.count * (kLabelHeight + kImageHeight);
            [self.segment changeSegmentedControlWithIndex:0];
            
        } else if (scrollView.contentOffset.x  ==  kScreenWidth) {
            
            self.height = self.materialAry.count * (kImageHeight  + kSpace) + 2 * kLabelHeight + kImageHeight + 30;
            
            [self.segment changeSegmentedControlWithIndex:1];
            
            
        } else if (scrollView.contentOffset.x == kScreenWidth * 2) {
            
            //这里调用cell的类方法, 为了拿到高度, 调用的时候, 我定义的全局变量height已经是计算好的高度了, 因为第一个视图生成的时候, 这个高度就已经计算好了
            self.height = [MainTableViewCell getSuitHeight] + 50;
            
            [self.segment changeSegmentedControlWithIndex:2];
            
            //这里最后一个必须得加上else if , 不能直接用else, 否则出现, 在第一屏用力向右拖拽的时候会跑到最后一屏, 也就是这时候走了下面的方法, 所以不能直接用else, 用else范围太广了
        } else if (scrollView.contentOffset.x == kScreenWidth * 3) {
            
            NSInteger fitNum = [self.suitAndGramDic[@"fitting"] count];
            NSInteger gramNum = [self.suitAndGramDic[@"gram"] count];
            
            self.height = kLastLabel * (fitNum + gramNum + 2) + 20 + 4 * kSpace;
            if (self.height < kScreenHeight - 240) {
                self.height = kScreenHeight - 240;
                
            }
            
            //这句代码要放到if (self.height < kScreenHeight - 240)判断的外面, 不然的会导致这句代码有时走不到, 也就是说我们滑到了最后一页, 但是标签并未跟着走到最后一页
            //要求每走到这个方法里, 这句代码都要执行的, 所以要放到外面
            [self.segment changeSegmentedControlWithIndex:3];
        }
    }
    //拿到高度之后刷新数据
    [self.mainTableView reloadData];
    
}



#pragma mark - 收藏

- (void)addCollect {
    
    UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWidth, 50)];
    
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 15, 10, 30, 30)];
    
    tool.backgroundColor = [UIColor orangeColor];
    
    //but.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:tool];
    [tool addSubview:but];
    
    [but addTarget:self action:@selector(butAction:) forControlEvents:UIControlEventTouchUpInside];
    
    Movie *model = self.movieAry[0];

    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MenuCook"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameID == %@", model.vegetable_id];
    
    [request setPredicate:predicate];
    
    //这里根据结果得到的数组里面只有一个值, 因为我是根据ID取得
    //数据库里面的数据对象不能通过alloc创建, 只能取出, 或者通过创建实体
    NSArray *resultArray = [self.context executeFetchRequest:request error:nil];
    
    if (resultArray.count == 0) {
        
        [but setBackgroundImage:[UIImage imageNamed:@"NoCollect"] forState:UIControlStateNormal];
        
    } else {
        [but setBackgroundImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];

    }
}


- (void)butAction:(UIButton *)sender {

    
    
#warning mark - 通过判断数据库中的数据来更改but的图标样式
    
    //只有将Appdelegate头文件引过来下面代码才会有提示
    
    //创建实体描述对象(在临时数据库中操作, 也就是在内存中)
    NSEntityDescription *menuCookED = [NSEntityDescription entityForName:@"MenuCook" inManagedObjectContext:self.context];
    
    Movie *model = self.movieAry[0];

#warning mark - 先判断数据库中对象是否已经存在
    //查询类
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MenuCook"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameID == %@", model.vegetable_id];
    
    [request setPredicate:predicate];
    
    NSArray *resultArray = [self.context executeFetchRequest:request error:nil];
    
    if (resultArray.count == 0) {
       
        //根据实体描述对象创建实体(在临时数据库中, 也就是内存中)
        MenuCook *menuCook = [[MenuCook alloc] initWithEntity:menuCookED insertIntoManagedObjectContext:self.context];
        
        menuCook.name = model.name;
        
        menuCook.nameID = model.vegetable_id;
        
#warning mark - 数据库存放data数据, 这里后来还需要再改进一下, 如果收藏按钮点击过快, 视频的缓存图片还未加载出来已经点击收藏按钮, 则图片数据没有, 收藏页面的图片就是空的, 可以让它在子线程下载图片, 然后存起来
        
        
//         dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(queue1, ^{
//            menuCook.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.imagePathThumbnails]];
//            
//        });

        
        
        //这里如果用网址重新下载data的话一定要放在子线程, 不然会卡主线程
        menuCook.imageData = UIImageJPEGRepresentation(self.thumImage, 100);
        
        
        //menuCook.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.imagePathThumbnails]];
        
        NSError *error = nil;
        
        [self.context save:&error];
        
        [sender setBackgroundImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
        
        
        
        MyOwnNotification *notification = [[MyOwnNotification alloc] initWithNibName:@"MyOwnNotification"];
        notification.label1.text = @"收藏成功!";
        notification.label2.text = @"您可以到我的页面, 在我的收藏栏目下查看您收藏的食谱";
        notification.delegate = self;
        notification.dismissOnTap = NO;
        [notification showAnimated:YES hideAfter:2];
        
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏成功!" message:@"您可以到我的页面, 在我的收藏栏目下查看您收藏的食谱" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            
//            
//            [alert show];
//        });
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [alert dismissWithClickedButtonIndex:0 animated:YES];
//        });
//        
        
    } else {
        
        MenuCook *model = resultArray[0];
        [self.context deleteObject:model];
        
        NSError *error = nil;
        
        [self.context save:&error];
        
        [sender setBackgroundImage:[UIImage imageNamed:@"NoCollect"] forState:UIControlStateNormal];

    }
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
