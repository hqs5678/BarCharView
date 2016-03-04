//
//  ViewController.m
//  BarChartTest
//
//  Created by hqs on 16/1/15.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "ViewController6.h"
#import "BarChartView.h"
#import "BarRow.h"

@interface ViewController6 () <BarChartViewDelegate>
@property (weak, nonatomic) IBOutlet BarChartView *barChart;

@end

@implementation ViewController6{
    NSMutableArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    self.barChart.maxValue = 200;
    self.barChart.normalBarColor = [UIColor whiteColor]; 
    self.barChart.highlightBarColor = [UIColor lightGrayColor];
    self.barChart.titleStep = 3;
    self.barChart.autoSelectMiddle = NO;
    self.barChart.pagingEnabled = NO;
    self.barChart.selectable = NO;
    
    self.barChart.middleLineColor = [UIColor lightGrayColor];
    
    self.barChart.delegate = self;
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeContactAdd];
    but.frame = CGRectMake(100, 60, 60, 80);
    [self.view addSubview:but];
    [but addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}

- (void) reload{
    [self.barChart reloadData];
}

- (void)initData{
    _data = [NSMutableArray array];
    
    
    for (int i = 0; i<30; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        dict[@"title"] = [NSString stringWithFormat:@"title-%d",i];
        dict[@"value"] = [NSNumber numberWithFloat: arc4random() % 200 + 20];
        
        NSMutableArray *rows = [NSMutableArray array];
        BarRow *row = [[BarRow alloc]init];
        row.highlightColor = [self randomColor];
        row.normalColor = [self randomColor];
        row.height = arc4random() % 30;
        [rows addObject:row];
//        
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
    bar.titleFontSize = 10;
    bar.rows = dict[@"rows"];
    bar.rowSelectable = YES;
    
    return bar;
}
- (void)barChartView:(BarChartView *)barChartView didSelectedItemAt:(NSIndexPath *)indexPath{
    NSLog(@"didSelectedItemAt  %@",indexPath);
}

- (void)barChartView:(BarChartView *)barChartView didDeselectedItemAt:(NSIndexPath *)indexPath{
     NSLog(@"didDeselectedItemAt  %@",indexPath);
}


- (CGFloat)barChartView:(BarChartView *)barChartView titleWidthForBarAtSection:(NSUInteger)section{
    return 70;
}

- (CGFloat)barChartView:(BarChartView *)barChartView widthForBarAtSection:(NSUInteger)section{
    return 20;
}

- (CGFloat)barChartView:(BarChartView *)barChartView paddingForBarAtSection:(NSUInteger)section{
//    if (section == 0) {
//        return self.barChart.frame.size.width * 0.5 - [self barChartView:self.barChart widthForBarAtSection:0];
//    }
//    if (section == _data.count) {
//        return [self barChartView:barChartView paddingForBarAtSection:0];
//    }
    return 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
