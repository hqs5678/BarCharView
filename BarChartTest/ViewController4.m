//
//  ViewController1.m
//  BarChartTest
//
//  Created by hqs on 16/1/16.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "ViewController4.h"
#import "BarChartView.h"

@interface ViewController4 () <BarChartViewDelegate>

@property (strong, nonatomic) BarChartView *barChart;

@end

@implementation ViewController4{
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
    self.barChart.pagingEnabled = NO;
    
    self.barChart.barTitleFontSize = 8;
    self.barChart.showBaseLine = NO;
    self.barChart.baseLineHeight = 2;
    self.barChart.baseLineColor = [UIColor yellowColor];
    self.barChart.maxValue = 220;
    
    self.barChart.showTitle = false;
    
    self.barChart.delegate = self;
    
    
    [self addTimeTitle];
}
- (void)addTimeTitle{
    // bar中的title不适用 添加新的bar title
    
    CGRect frame = CGRectZero;
    frame.origin.x = [self barChartView:self.barChart paddingForBarAtSection:0]-15;
    frame.origin.y = CGRectGetMaxY(self.barChart.baseLineFrame);
    frame.size.width = self.barChart.scrollView.contentSize.width;
    frame.size.height = self.barChart.frame.size.height - frame.origin.y;
    UIView *barTitleView = [[UIView alloc]initWithFrame:frame];
    [self.barChart.scrollView addSubview:barTitleView];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 30;
    CGFloat h = barTitleView.frame.size.height;
    for (int i = 0; i<=24; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(x , y, w , h )];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:self.barChart.barTitleFontSize];
        label.text = [NSString stringWithFormat:@"%02d:%02d",(i + 40)/2%24,i%2 == 0 ? 0 : 30];
        label.textColor = [self.barChart barTitleColor];
        [barTitleView addSubview:label];
        x += w;
    }
}


- (void)initData{
    _data = [NSMutableArray array];
    
    
    for (int i = 0; i<12; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"title"] = [NSString stringWithFormat:@"title-%d",i];
        dict[@"value"] = [NSNumber numberWithFloat: 200];
        dict[@"width"] = [NSNumber numberWithFloat:arc4random() % 100 + 5];
        
        BarRow *row = [[BarRow alloc]init];
        row.highlightColor = [UIColor whiteColor];
        int rand = i % 2;
        if (rand) {
            row.normalColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
        }
        else{
            row.normalColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
        }
        NSArray *rows = [NSArray arrayWithObject:row];
        dict[@"rows"] = rows;
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
    return 300;
}

- (CGFloat)barChartView:(BarChartView *)barChartView widthForBarAtSection:(NSUInteger)section{
    return [_data[section][@"width"] floatValue];
}

- (CGFloat)barChartView:(BarChartView *)barChartView paddingForBarAtSection:(NSUInteger)section{
    if (section == 0 || section == _data.count) {
        return self.view.frame.size.width * 0.5;
    }
    return 0;
}


@end
