//
//  TableViewCell.m
//  TwoTableView
//
//  Created by 张祥 on 15/8/13.
//  Copyright (c) 2015年 张祥. All rights reserved.
//

#import "MainTableViewCell.h"
#import "MakeSteps.h"
#import "UIImageView+WebCache.h"
#import "Material.h"
#import "About.h"
#import "Fitting.h"
#import "Gram.h"
#import "BigMaterial.h"

//全局变量如果在代码中, 则程序运行过程中只会走一次, 如果在这里的话则可以全局访问
//正是由于它的这种性质, 在使用的时候一定要当心, 在哪个页面用到全局变量的话, 要在当前页面对象销毁的时候将变量值归为初始值, 不然当你再次进入这个页面的时候它的值是依据上次的值叠加的, 不会再初始化
static NSInteger viewNumber = 1000;
static CGFloat height = 0;

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




@interface MainTableViewCell ()

@property (nonatomic, strong) UIScrollView *scrView;

@end

@implementation MainTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //init方法只走一次, 返回的修改高度的值不会在这里修改, 所以要在以后的代码里修改我们初始化的控件的值
        
        //scrollView的fram初始值一定不能为0, 为0的话显示不出来
        //按说这个frame的高度值是scrollView在屏幕上显示的区域, 后期需要更改, 不然屏幕上只显示这里所给的值的大小区域
        self.scrView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        //scrollView的contentSize, 后期也需要更改
        self.scrView.contentSize = CGSizeMake(kScreenWidth * 4, self.height);
        
        self.scrView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.949 alpha:1.000];
        
        self.scrView.pagingEnabled = YES;
        
        for (int i = 0; i < 4; i++)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0 + kScreenWidth * i, 0, kScreenWidth, 1000)];
            
            view.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.949 alpha:1.000];
            
            view.tag = viewNumber;
            viewNumber++;
            [self.scrView addSubview:view];
            NSLog(@"%ld", view.tag);
        }
        [self addSubview:self.scrView];
        
    }
    return self;
}




- (void)setMakeAry:(NSArray *)makeAry {
    
    _makeAry = makeAry;
    
    //必须由对象调用, 对于调用方法的对象, 影响找到的结果, 先对此对象检查, 看tag值是否相符, 如果是则返回, 如果不是则找其所有子视图, 对其进行tag值的一一比对, 找到则返回, 如果没有找到则返回NULL.
    
    UIView *view = [self.scrView viewWithTag:1000];
    
    //更新scrollView的frame
    self.scrView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    //更新scrollView的contentSize
    self.scrView.contentSize = CGSizeMake(kScreenWidth * 4, self.height);
    
    //更新view的frame,, 这句代码应该写不写都行
    view.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    
    //此句代码不加, 内存瞬间飚到上百兆
    //因为我们刷新数据之后, 程序会走这里面的setter方法, 就会导致方法里面的所有空间都被重新创建, 并完全覆盖在原来的控件上, 会发现我们创建的label上的字体很粗
    //于是我们根据这个视图上是否存在子视图来判断控件的添加
    
    if (view.subviews.count == 0) {
        
        
        for (int i = 0; i < _makeAry.count; i++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0 + (kImageHeight + kLabelHeight) * i, kScreenWidth - 60, kImageHeight)];
            
            //图片下面文本
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(imgView.frame), kScreenWidth - 60, kLabelHeight)];
            MakeSteps *model = _makeAry[i];
            [imgView sd_setImageWithURL:[NSURL URLWithString:model.imagePath]];
            
            NSMutableAttributedString *colorStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"0%d %@", i + 1, model.describe]];
            [colorStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000] range:NSMakeRange(0, 2)];
            label.attributedText = colorStr;
            
            [view addSubview:imgView];
            [view addSubview:label];
            label.numberOfLines = 0;
            label.font = [UIFont systemFontOfSize:14];
        }
    }
}




- (void)setMaterialAry:(NSArray *)materialAry {
    
    _materialAry = materialAry;
    UIView *view2 = [self.scrView viewWithTag:1001];
    
    self.scrView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    self.scrView.contentSize = CGSizeMake(kScreenWidth * 4, self.height);
    
    view2.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.height);
    
    if (view2.subviews.count == 0) {
        
        //原料文本
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, kScreenWidth - 60, kLabelHeight + 20)];
        
        //原料图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(label1.frame), kScreenWidth - 60, kImageHeight)];
        
        //调料文本
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(imgView.frame), kScreenWidth - 60, kLabelHeight)];
        
        
        NSMutableAttributedString *colorStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"原料: %@", [self.materialAry[0] rawContent]]];
        [colorStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000] range:NSMakeRange(0, 3)];
        label1.attributedText = colorStr;
        
        NSMutableAttributedString *colorStr2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"调料: %@", [self.materialAry[0] seasoningContent]]];
        [colorStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000] range:NSMakeRange(0, 3)];
        label2.attributedText = colorStr2;
        
        [imgView sd_setImageWithURL:[NSURL URLWithString:[self.materialAry[0] rawImagePath]]];
        
        label1.numberOfLines = 0;
        label2.numberOfLines = 0;
        
        label1.font = [UIFont systemFontOfSize:14];
        label2.font = [UIFont systemFontOfSize:14];
        
        [view2 addSubview:label1];
        [view2 addSubview:imgView];
        [view2 addSubview:label2];
        
        for (int i = 0; i < self.materialAry.count; i++)
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(label2.frame) + (kImageHeight + kSpace) * i, kScreenWidth - 60, kImageHeight)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, kLittleLabelHeight)];
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:[self.materialAry[i] imagePath]]];
            
            label.text = [self.materialAry[i] name];
            
            label.font = [UIFont systemFontOfSize:15];
            [view2 addSubview:imgView];
            
            [imgView addSubview:label];
        }
    }
}



- (void)setAboutAry:(NSArray *)aboutAry {
    
    _aboutAry = aboutAry;
    
    UIView *view3 = [self.scrView viewWithTag:1002];
    
    self.scrView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    self.scrView.contentSize = CGSizeMake(kScreenWidth * 4, self.height);
    
    view3.frame = CGRectMake(kScreenWidth * 2, 0, kScreenWidth, self.height);
    
    if (view3.subviews.count == 0) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, kScreenWidth - 60, kImageHeight)];
        //第一段文本
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(imgView.frame) + kSpace, kScreenWidth - 40, 10)];
        
        NSString *suitStr = [_aboutAry[0] nutritionAnalysis];
        
        NSDictionary *dic = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        
        CGRect rect = [suitStr boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
        
        label.frame = CGRectMake(20, CGRectGetMaxY(imgView.frame) + kSpace, kScreenWidth - 40, rect.size.height + 30);
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame) + 20, 80, 30)];
        
        
        UILabel *label2 = [[UILabel  alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label1.frame) + kSpace, kScreenWidth - 40, 0)];
        
        
        
        
        NSString *suitStr2 = [NSString stringWithFormat:@"    %@", [_aboutAry[0] productionDirection]];

        
        //本想label2不做自适应了, 直接给一个较高的高度就好了
        //默认的UILabel是垂直居中对齐的，如果你的UILabel高度有多行，当内容少的时候，会自动垂直居中, 也就是说label显示的文本此时会很靠下, 看起来很难看
        //比较郁闷的是，UILabel并不提供设置其垂直对齐方式的选项。所以如果你想让你的文字顶部对齐，那么就需要自己想办法了。没办法, 只能做自适应喽
        CGRect rect2 = [suitStr2 boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
        
        label2.frame = CGRectMake(20, CGRectGetMaxY(label1.frame) + kSpace, kScreenWidth - 40, rect2.size.height);
        
        [imgView sd_setImageWithURL:[NSURL URLWithString:[_aboutAry[0] imagePath]]];
        
        
        NSMutableAttributedString *styleStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [_aboutAry[0] nutritionAnalysis]]];
        [styleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, 1)];
        [styleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(1, [[_aboutAry[0] nutritionAnalysis] length] - 1)];
        label.attributedText = styleStr;
        
        
        label2.text = suitStr2;
        
        label1.text = @"制作指导";
        label1.backgroundColor = [UIColor colorWithRed:1.000 green:0.500 blue:0.000 alpha:0.270];
        label1.textColor = [UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000];
        label1.textAlignment = NSTextAlignmentCenter;
        
        label.numberOfLines = 0;
        label2.numberOfLines = 0;
        
        //这里设置字体, 我前面设置字体的大小就没用了
        //label.font = [UIFont systemFontOfSize:14];
        label2.font = [UIFont systemFontOfSize:14];
        
        label.textColor = [UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000];
        label2.textColor = [UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:1.000];
        
        [view3 addSubview:imgView];
        [view3 addSubview:label];
        [view3 addSubview:label1];
        [view3 addSubview:label2];
        
        height = kImageHeight + rect.size.height + 250;
    }
}



+ (CGFloat)getSuitHeight {
    return height;
}



- (void)setFitAndGramDic:(NSDictionary *)fitAndGramDic {
    _fitAndGramDic = fitAndGramDic;
    
    UIView *view4 = [self.scrView viewWithTag:1003];
    
    self.scrView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    self.scrView.contentSize = CGSizeMake(kScreenWidth * 4, self.height);
    
    view4.frame = CGRectMake(kScreenWidth * 3, 0, kScreenWidth, self.height);
    
    if (view4.subviews.count == 0) {
        
        UILabel *labelLeft = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 50, kLastLabel)];
        
        UILabel *labelMiddle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelLeft.frame), 20, kScreenWidth - 180, kLastLabel)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelMiddle.frame), 20, 50, kLastLabel)];
        
        
        labelLeft.text = @"相宜";
        labelLeft.backgroundColor = [UIColor colorWithRed:0.133 green:0.459 blue:0.024 alpha:1.000];
        labelLeft.textColor = [UIColor whiteColor];
        labelLeft.textAlignment = NSTextAlignmentCenter;
        labelLeft.font = [UIFont systemFontOfSize:20];
        
        
        NSString *nameStr = [_fitAndGramDic[@"bigMaterial"] materialName];
        labelMiddle.text = [NSString stringWithFormat:@"%@与下列食物相宜", nameStr];
        labelMiddle.textAlignment = NSTextAlignmentCenter;
        labelMiddle.backgroundColor = [UIColor whiteColor];
        labelMiddle.textColor = [UIColor colorWithRed:0.133 green:0.459 blue:0.024 alpha:1.000];
        labelMiddle.font = [UIFont systemFontOfSize:15];
        labelMiddle.textAlignment = NSTextAlignmentCenter;
        
        NSString *str1 = [_fitAndGramDic[@"bigMaterial"] imageName];
        [imgView sd_setImageWithURL:[NSURL URLWithString:str1]];
        

        [view4 addSubview:labelLeft];
        [view4 addSubview:labelMiddle];
        [view4 addSubview:imgView];
        
        
        if ([_fitAndGramDic[@"fitting"] count] == 0) {
            labelMiddle.text = @"无相宜内容";
        }
        
        
        
        
        for (int i = 0; i < [_fitAndGramDic[@"fitting"] count]; i++)
        {
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(labelMiddle.frame) + kSpace - 10 + (kLastLabel + 3) * i, 50, kLastLabel)];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgView1.frame), CGRectGetMinY(imgView1.frame), 60, kLastLabel)];
            
            UILabel *labelRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), CGRectGetMinY(imgView1.frame), kScreenWidth - 190, kLastLabel)];
            
            
            
            NSString *imgStr = [_fitAndGramDic[@"fitting"][i] imageName];
            [imgView1 sd_setImageWithURL:[NSURL URLWithString:imgStr]];
            
            
            NSString *fittingStr = [_fitAndGramDic[@"fitting"][i] materialName];
            label.text = fittingStr;
            label.backgroundColor = [UIColor whiteColor];
            label.textColor = [UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:0.760];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            if (fittingStr.length > 3) {
                label.font = [UIFont systemFontOfSize:12];
            }
            
            
            labelRight.text = [_fitAndGramDic[@"fitting"][i] contentDescription];
            labelRight.backgroundColor = [UIColor colorWithRed:0.403 green:0.125 blue:0.134 alpha:0.290];
            labelRight.font = [UIFont systemFontOfSize:13];
            labelRight.numberOfLines = 0;
            
            
            [view4 addSubview:imgView1];
            [view4 addSubview:label];
            [view4 addSubview:labelRight];
        }
        
        
        NSInteger num = [_fitAndGramDic[@"fitting"] count];
        UILabel *labelLeft2 = [[UILabel alloc] initWithFrame:CGRectMake(40, num * 50 + 50 + kSpace * 2 + 15, 50, kLastLabel)];
        
        UILabel *labelMiddle2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelLeft2.frame), CGRectGetMinY(labelLeft2.frame), kScreenWidth - 180, kLastLabel)];
        
        UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelMiddle2.frame), CGRectGetMinY(labelLeft2.frame), 50, kLastLabel)];
        
        

        
        labelLeft2.text = @"相克";
        labelLeft2.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.620];
        labelLeft2.textAlignment = NSTextAlignmentCenter;
        labelLeft2.textColor = [UIColor whiteColor];
        labelLeft2.font = [UIFont systemFontOfSize:20];
        
        
        labelMiddle2.text = [NSString stringWithFormat:@"%@与下列食物相克", nameStr];
        labelMiddle2.backgroundColor = [UIColor whiteColor];
        labelMiddle2.textColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.620];
        labelMiddle2.font = [UIFont systemFontOfSize:15];
        labelMiddle2.textAlignment = NSTextAlignmentCenter;
        
        
        NSString *str2 = [_fitAndGramDic[@"bigMaterial"] imageName];
        [imgView2 sd_setImageWithURL:[NSURL URLWithString:str2]];
        
        
        [view4 addSubview:labelLeft2];
        [view4 addSubview:labelMiddle2];
        [view4 addSubview:imgView2];
        
        
        
        if (nameStr.length > 2) {
            labelMiddle.font = [UIFont systemFontOfSize:14];
            labelMiddle2.font = [UIFont systemFontOfSize:14];
        }
        
        
        if ([_fitAndGramDic[@"gram"] count] == 0) {
            labelMiddle2.text = @"无相克内容";
        }
        
        
        
        
        for (int i = 0; i < [_fitAndGramDic[@"gram"] count]; i++)
        {
            
            UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(labelMiddle2.frame) + kSpace - 10 + (kLastLabel + 3) * i, 50, kLastLabel)];
            
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgView3.frame), CGRectGetMinY(imgView3.frame), 50, kLastLabel)];
            
            UILabel *labelRight3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label3.frame), CGRectGetMinY(imgView3.frame), kScreenWidth - 180, kLastLabel)];
            
            NSString *imgStr3 = [_fitAndGramDic[@"gram"][i] imageName];
            [imgView3 sd_setImageWithURL:[NSURL URLWithString:imgStr3]];
            
            
            NSString *gramContent = [_fitAndGramDic[@"gram"][i] materialName];
            label3.text = gramContent;
            label3.backgroundColor = [UIColor whiteColor];
            label3.textColor = [UIColor colorWithRed:0.392 green:0.220 blue:0.125 alpha:0.760];
            label3.numberOfLines = 0;
            if (gramContent.length > 3) {
                label3.font = [UIFont systemFontOfSize:12];
            }
            
            
            
            

            
            labelRight3.text = [_fitAndGramDic[@"gram"][i] contentDescription];
            labelRight3.backgroundColor = [UIColor colorWithRed:0.403 green:0.125 blue:0.134 alpha:0.290];
            labelRight3.font = [UIFont systemFontOfSize:13];
            labelRight3.numberOfLines = 0;
            
            [view4 addSubview:imgView3];
            [view4 addSubview:label3];
            [view4 addSubview:labelRight3];
        }
    }
    
}




- (void)dealloc
{
    //将全局变量值初始化
    //这个bug浪费了一下午时间😢😢😢😢😢
    //因为未重置全局变量的初始值, 所以导致我在用[self.scrView viewWithTag:1003]取相应的view的时候是取不到的, 那些view已经被销毁(ARC自动销毁), 所以生成的控件(label和imgView)肯定是加不上的
    height = 0;
    viewNumber = 1000;
    
}





- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
