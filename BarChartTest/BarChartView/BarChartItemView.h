//
//  BarChartItemView.h
//  BarChartTest
//
//  Created by hqs on 16/1/15.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BarChartItemView;

@protocol BarChartItemViewDelegate <NSObject>

- (void)barChartItemView:(BarChartItemView *)barChartItemView didClickedAt:(NSIndexPath *)indexPath;

@end

@interface BarChartItemView : UIView

@property (nonatomic,assign) CGFloat value;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) CGFloat titleFontSize;
@property (nonatomic,assign) CGFloat titlePadding;
@property (nonatomic,strong) UIColor *barColor;
@property (nonatomic,assign) CGFloat barWidth;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic,assign) BOOL showTitle;
@property (nonatomic,assign) BOOL animatable;
@property (nonatomic,strong) UIColor *baseLineColor;
@property (nonatomic,assign) CGFloat baseLineHeight;
@property (nonatomic,assign) CGFloat paddingOfRow;
@property (nonatomic,strong) NSArray *rows;
@property (nonatomic,assign) NSUInteger section;
@property (nonatomic,assign) BOOL rowSelectable;
@property (nonatomic,assign) int selectedRowIndex;
@property (nonatomic,assign) BOOL showBaseLine;

@property (nonatomic,weak) id<BarChartItemViewDelegate> delegate;
- (void)tap:(UITapGestureRecognizer *)recognizer;

@end


