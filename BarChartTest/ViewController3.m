//
//  ViewController1.m
//  BarChartTest
//
//  Created by hqs on 16/1/16.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "ViewController3.h"
#import "BarChartView.h"

@interface ViewController3 () <BarChartViewDelegate>

@property (strong, nonatomic) BarChartView *barChart;

@end

@implementation ViewController3{
    NSMutableArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.width * 0.8;
    
    self.barChart = [[BarChartView alloc]initWithFrame:frame];
    [self.view addSubview: self.barChart];
    self.barChart.center = self.view.center;
    
    
    self.barChart.maxValue = 200;
    self.barChart.normalBarColor = [UIColor whiteColor];
    self.barChart.highlightBarColor = [UIColor lightGrayColor];
    self.barChart.titleStep = 2;
    self.barChart.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
    
    // 自动选中中间
    self.barChart.autoSelectMiddle = YES;
    // 自动调整
    self.barChart.pagingEnabled = YES;
    
    self.barChart.barTitleFontSize = 15;
    self.barChart.showBaseLine = YES;
    self.barChart.baseLineHeight = 2;
    self.barChart.baseLineColor = [UIColor yellowColor];
    
    self.barChart.maxValue = 220;
    
    self.barChart.delegate = self;
}


- (void)initData{
    _data = [NSMutableArray array];
    
    
    for (int i = 0; i<12; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"title"] = [NSString stringWithFormat:@"title-%d",i];
        dict[@"value"] = [NSNumber numberWithFloat: arc4random() % 200 + 20];
        
        [_data addObject:dict];
    }
}

- (UIColor *)randomColor{
    UIColor *color = [UIColor colorWithRed:arc4random()%255 / 255.0f green:arc4random()%255 / 255.0f blue:arc4random()%255 / 255.0f alpha:1];
    return color;
}

- (NSUInteger)numberOfBarChartViewItem:(BarChartView *)barChartView{
    return _data.count;
}


- (BarChartItemView *)barChartView:(BarChartView *)barChartView barAtSection:(NSUInteger)section{
    BarChartItemView *bar = [[BarChartItemView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    NSDictionary *dict = _data[section];
    bar.value = [dict[@"value"] floatValue];
    bar.title = dict[@"title"];
    bar.rows = dict[@"rows"];
    
    return bar;
}
- (void)barChartView:(BarChartView *)barChartView didSelectedItemAt:(NSIndexPath *)indexPath{
    NSLog(@"didSelectedItemAt  %@",indexPath);
}

- (void)barChartView:(BarChartView *)barChartView didDeselectedItemAt:(NSIndexPath *)indexPath{
    NSLog(@"didDeselectedItemAt  %@",indexPath);
}

- (void)barChartView:(BarChartView *)barChartView didClickItemAt:(NSIndexPath *)indexPath{
    NSLog(@"didClickItemAt  %@",indexPath);
}


- (CGFloat)barChartView:(BarChartView *)barChartView titleWidthForBarAtSection:(NSUInteger)section{
    return 70;
}

- (CGFloat)barChartView:(BarChartView *)barChartView widthForBarAtSection:(NSUInteger)section{
    return 30;
}

- (CGFloat)barChartView:(BarChartView *)barChartView paddingForBarAtSection:(NSUInteger)section{
    if (section == 0 || section == _data.count) {
        return self.view.frame.size.width * 0.5;
    }
    return 10;
}


@end
