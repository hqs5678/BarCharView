//
//  BarChartView.h
//  BarChartTest
//
//  Created by hqs on 16/1/15.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarChartItemView.h"
#import "BarRow.h"

typedef void (^BarChartViewRefreshBlock)(void);

// 刷新状态
enum BarChartViewRefreshState{
    BarChartViewRefreshStateNormal,
    BarChartViewRefreshStateRefreshing,
    BarChartViewRefreshStateDone
};

@class BarChartView;

enum BarChartMiddleLineType{
    BarChartMiddleLineTypeActive,               // 实线
    BarChartMiddleLineTypeDotted                // 虚线
};

@protocol BarChartViewDelegate <NSObject>

- (void)barChartView:(BarChartView *)barChartView didClickItemAt:(NSIndexPath *)indexPath;
// 选中
- (void)barChartView:(BarChartView *)barChartView didSelectedItemAt:(NSIndexPath *)indexPath;
- (void)barChartView:(BarChartView *)barChartView didDeselectedItemAt:(NSIndexPath *)indexPath;

// item 数量
- (NSUInteger)numberOfBarChartViewItem:(BarChartView *)barChartView;

// item
- (BarChartItemView *)barChartView:(BarChartView *)barChartView barAtSection:(NSUInteger)section;

// item's size
- (CGFloat)barChartView:(BarChartView *)barChartView widthForBarAtSection:(NSUInteger)section;

// title width
- (CGFloat)barChartView:(BarChartView *)barChartView titleWidthForBarAtSection:(NSUInteger)section;

// bar padding
- (CGFloat)barChartView:(BarChartView *)barChartView paddingForBarAtSection:(NSUInteger)section;


@end

@interface BarChartView : UIView <UIScrollViewDelegate, BarChartItemViewDelegate>

// delegate
@property (nonatomic,weak) id<BarChartViewDelegate> delegate;
// scroll view
@property (nonatomic,strong,readonly) UIScrollView *scrollView;

@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) UIColor *highlightBarColor;
@property (nonatomic,strong) UIColor *normalBarColor;
@property (nonatomic,assign) CGFloat barTitleFontSize;
@property (nonatomic,assign) CGFloat barTitlePadding;
@property (nonatomic,strong) UIColor *barTitleColor;
@property (nonatomic,assign) BOOL barRowSelectable;
// 动画
@property (nonatomic,assign) BOOL animatable;
// 柱状图的最大高度
@property (nonatomic,assign) CGFloat maxValue;

// 中线颜色
@property (nonatomic,strong) UIColor *middleLineColor;
@property (nonatomic,assign) CGFloat middleLineHeight;
@property (nonatomic,assign) CGRect middleLineFrame;
@property (nonatomic,assign) enum BarChartMiddleLineType middleLineType;
// 显示标题的间隔
@property (nonatomic,assign) int titleStep;
// 显示标题
@property (nonatomic,assign) BOOL showTitle;
// 可选择
@property (nonatomic,assign) BOOL selectable;
// 分页 ; 如果柱状图不在表格中心  自动滚到的表格中心 并选中
@property (nonatomic,assign) BOOL pagingEnabled;
@property (nonatomic,assign) BOOL autoSelectMiddle;


// select item
- (void)selectBarAt:(NSIndexPath *)indexPath;
- (void)selectBarAtSection:(NSUInteger)section;
// deselect item
- (void)deselectBarAt:(NSIndexPath *)indexPath;

- (void)scrollSelectBarToCenter:(BOOL)animate;

// reload data
- (void)reloadData;

@property (nonatomic,assign) enum BarChartViewRefreshState refreshState;

// 懒加载  左滑  右滑 刷新
// 左滑
- (void)setHeaderRefreshingBlock:(BarChartViewRefreshBlock)block;
// 右滑
- (void)setFooterRefreshingBlock:(BarChartViewRefreshBlock)block;

// 配合懒加载的方法,  更新在头部的bars  
- (void)updateBarsAtHeaderWithRange:(int)range;

- (void)updateBarsAtFooterWithRange:(int)range;

@end
