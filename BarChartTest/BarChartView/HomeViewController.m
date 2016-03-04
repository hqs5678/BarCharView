//
//  HomeViewController.m
//  BarChartTest
//
//  Created by hqs on 16/3/4.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "HomeViewController.h"

#import "CellModel.h"

@interface HomeViewController()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation HomeViewController{
    UITableView *_tableView;
    NSMutableArray *data;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title =  @"主页";
    
    [self setup];
    [self initData];
}

- (void)setup{
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
   
}

- (void)initData{
    data = [NSMutableArray array];
    
    
    CellModel *model = [[CellModel alloc]init];
    model.title = @"1. 普通柱状图";
    model.vc = @"ViewController1";
    
    [data addObject:model];
    
    model = [[CellModel alloc]init];
    model.title = @"2. 懒加载";
    model.vc = @"ViewController2";
    
    [data addObject:model];
    
    model = [[CellModel alloc]init];
    model.title = @"3. 自动选中中间且调整位置";
    model.vc = @"ViewController3";
    
    [data addObject:model];
}




-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [data[indexPath.row] title];
    
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Class c = NSClassFromString([data[indexPath.row] vc]);
    UIViewController *vc = [[c alloc]init];
    vc.title = [data[indexPath.row] title];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
