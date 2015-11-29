//
//  AboutMeViewController.m
//  ZXCook
//
//  Created by 张祥 on 15/8/17.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "AboutMeViewController.h"



@interface AboutMeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end

@implementation AboutMeViewController




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //得到不同的粒子layer
    self.rootLayer = [self createLayer];
    
    //因为我的下雨的那个的粒子是空, 所以如果这里给消失时间, 就会走消失方法, 就会给粒子的birthRate(出生率)赋值, 然后必崩
    //这里不加判断的话, 下雨那个会崩溃
    
    // 将粒子Layer添加进图层的layer中
    [self.view.layer addSublayer:self.rootLayer];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentLabel.text = @"        无论走到哪里, 是不是总有一些味道让你念念不忘;无论吃过多少美味, 是不是总想念自家餐桌上那熟悉的饭菜?     \n\n       爱美食(LOVE FOOD)是一款美食软件, 它汇聚了各大菜系, 并配以精美的图文介绍和详细的视频操作步骤, 能让你在想吃时不必到处找饭店, 能让你在外奔波时轻易的做出家的味道, 食谱在手, 人人都是大厨师. \n💗Ta, 就给Ta做顿饭吧···";
    
    
    self.emailLabel.text = @"        如果您在使用过程中有任何问题或疑问, 欢迎反馈咨询\n          E-MAIL:960376043@qq.com";
    
    
    //加一个安全判断, 当图片存在的时候
    if ([self getBackgroundImageName]) {
        //创建聊天界面的背景图
        UIImage *image = [UIImage imageNamed:[self getBackgroundImageName]];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.alpha = 0;
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [self.view addSubview:imageView];
    }

    
    self.title = @"关于";
    
}






//当页面将要消失的时候移除粒子
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //如果粒子layer存在
    if (self.rootLayer) {
        //则将粒子layer从图层的layer中移除
        [self.rootLayer removeFromSuperlayer];
    }
}








//调用此方法得到不同的layer参数(下雪, 下雨等)
-(FallLayer *)createLayer{
    return [[[NSClassFromString(@"StarLayer") class] alloc]init];
}


//此方法返回当前详情页的背景图片
-(NSString *)getBackgroundImageName{
    return @"CUSSenderSnowBG.jpg";
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
