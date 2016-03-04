//
//  BarChartView.m
//  BarChartTest
//
//  Created by hqs on 16/1/15.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "BarChartView.h"
#import "BarRow.h"

#define kBarTag 10000

@implementation BarChartView{
    NSMutableArray *_barChartItemViews;
    CALayer *_middleLineLayer;
    CALayer *_baseLine;
    // 用于优化性能   _barOffset 中保持 CGRect 数组  x: offset.x    y: bar middle x   width:padding   height:bar width
    NSMutableDictionary *_barOffset;
    BarChartViewRefreshBlock headerRefreshBlock;
    BarChartViewRefreshBlock footerRefreshBlock;
    CGFloat kRefreshWidth;
    // 柱状图的实际最大高度
    CGFloat maxHeight;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    _barChartItemViews = [[NSMutableArray alloc]init];
    _animatable = YES;
    _selectable = YES;
    _maxValue = self.frame.size.height * 0.85;
    maxHeight = _maxValue;
    _selectedIndexPath = nil;
    _normalBarColor = [UIColor lightGrayColor];
    _highlightBarColor = [UIColor grayColor];
    _titleStep = 3;
    _pagingEnabled = YES;
    _autoSelectMiddle = YES;
    _middleLineColor = [UIColor clearColor];
    _middleLineLayer = [[CALayer alloc]init];
    _middleLineType = BarChartMiddleLineTypeDotted;
    _middleLineHeight = 0.4;
    _barTitleFontSize = 8;
    _barTitlePadding = 3;
    _showTitle = YES;
    _barRowSelectable = YES;
    _barTitleColor = [UIColor blueColor];
    _barOffset  = [NSMutableDictionary dictionary];
    _refreshState = BarChartViewRefreshStateNormal;
    kRefreshWidth = self.frame.size.width * 0.1;
    
    CGRect frame = self.frame;
    frame.size.width = kRefreshWidth;
    
    [self setupMiddleLine];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_scrollView addGestureRecognizer:gestureRecognizer];
    
    [self setBaseLine];
}

- (void)setBaseLine{
    if (_baseLine) {
        [_baseLine removeFromSuperlayer];
    }
    if (!_baseLine) {
        _baseLine = [[CALayer alloc]init];
        CGFloat h = 0.5;
        _baseLine.frame = CGRectMake(0, self.frame.size.height - self.barTitlePadding * 2 - self.barTitleFontSize - h, self.frame.size.width, h);
        _baseLine.backgroundColor = [UIColor whiteColor].CGColor;
    }
    [self.layer insertSublayer:_baseLine atIndex:0];
}

- (void)setupMiddleLine{
    if (_middleLineLayer) {
        [_middleLineLayer removeFromSuperlayer];
    }
    CGFloat y = self.frame.size.height - (maxHeight + _barTitlePadding * 2 + _barTitleFontSize) + maxHeight * 0.5;
    if (self.middleLineType == BarChartMiddleLineTypeDotted) {
        CAShapeLayer *_middleDottedLineLayer = [CAShapeLayer layer];
        [_middleDottedLineLayer setFrame:CGRectMake(0, y, self.frame.size.width, _middleLineHeight)];
        [_middleDottedLineLayer setFillColor:_middleLineColor.CGColor];
        // 设置虚线颜色为blackColor
        [_middleDottedLineLayer setStrokeColor:_middleLineColor.CGColor];
        // 3.0f设置虚线的宽度
        [_middleDottedLineLayer setLineWidth:_middleLineHeight];
        [_middleDottedLineLayer setLineJoin:kCALineJoinRound];
        // 3=线的宽度 1=每条线的间距
        [_middleDottedLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:3], [NSNumber numberWithInt:1],nil]];
        // Setup the path
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0, _middleLineHeight * 0.5);
        CGPathAddLineToPoint(path, NULL, self.frame.size.width,_middleLineHeight * 0.5);
        _middleDottedLineLayer.masksToBounds = YES;
        [_middleDottedLineLayer setPath:path];
        CGPathRelease(path);
        _middleLineLayer = _middleDottedLineLayer;
    }
    else{
        _middleLineLayer.frame = CGRectMake(0, y, self.frame.size.width, _middleLineHeight);
        _middleLineLayer.backgroundColor = _middleLineColor.CGColor;
    }
    [self.layer insertSublayer:_middleLineLayer atIndex:0]; 
}

- (void)tap:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:_scrollView];
    CGPoint indexP = [self indexOfOffsetX:point.x];
    int index = (int)indexP.x;
    if (index >=0 && index < _barChartItemViews.count) {
        BarChartItemView *item = _barChartItemViews[index];
        [item tap:recognizer];
    }
}

- (void)selectBarAt:(NSIndexPath *)indexPath{
    
    if (!(_selectable && _barRowSelectable)) {
        return;
    }
    if (_selectedIndexPath && _selectedIndexPath.row == indexPath.row && _selectedIndexPath.section == indexPath.section) {
        return;
    }
    int section = (int)indexPath.section;
    
    int row = (int)indexPath.row;
    if (section >= 0 && section < _barChartItemViews.count) {
        [self deselectBarAt:_selectedIndexPath];
        if (row < 0) {
            [self selectBarAtSection:section];
            _selectedIndexPath = indexPath;
        }
        else{
            
            BarChartItemView *bar = _barChartItemViews[section];
            if (row >= 0 && row < bar.rows.count) {
                [self selectBarAtSection:section];
                BarRow *br = bar.rows[row];
                br.layer.backgroundColor = br.highlightColor.CGColor;
                _selectedIndexPath = indexPath;
            }
            [self.delegate barChartView:self didSelectedItemAt:indexPath];
        }
        
    }
}

- (void)selectBarAtSection:(NSUInteger)section{
//    NSLog(@"%d",section);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:-1 inSection:section];
    
    if (!(_selectable && _barRowSelectable)) {
        return;
    }
    
    if (_selectedIndexPath && _selectedIndexPath.section == section) {
        return;
    }
 
    if (section < _barChartItemViews.count) {
        BarChartItemView *bar = _barChartItemViews[section];
        
        [bar setBarColor:self.highlightBarColor];
        if (_selectedIndexPath.section >= 0 && _selectedIndexPath.section < _barChartItemViews.count) {
            bar = [_barChartItemViews objectAtIndex:_selectedIndexPath.section];
            [self deselectBarAt:_selectedIndexPath];
            [_delegate barChartView:self didDeselectedItemAt:indexPath];
        }
        [_delegate barChartView:self didSelectedItemAt:indexPath];
        _selectedIndexPath = indexPath;
    }
}

- (void)scrollSelectBarToCenter:(BOOL)animate{
    if (animate && _autoSelectMiddle) {
        _autoSelectMiddle = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _autoSelectMiddle = YES;
        });
    }
    CGFloat x = [self barCenterXOfSection:(int)self.selectedIndexPath.section] - _scrollView.frame.size.width * 0.5;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:animate];
}

// deselecte
- (void)deselectBarAt:(NSIndexPath *)indexPath{
    if (!indexPath) {
        return;
    }
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    if (section >= 0 && section < _barChartItemViews.count) {
        BarChartItemView *bar = _barChartItemViews[section];
        if (row < 0) {
            bar.barColor = self.normalBarColor;
            [_delegate barChartView:self didDeselectedItemAt:indexPath];
        }
        else{
            if (row >=0 && row < bar.rows.count) {
                bar.barColor = self.normalBarColor;
                BarRow *barRow = (BarRow *)bar.rows[row];
                barRow.layer.backgroundColor = barRow.normalColor.CGColor;
                [_delegate barChartView:self didDeselectedItemAt:indexPath];
            }
        }
        _selectedIndexPath = nil;
    }
}

- (void)removeAllSubviews:(UIView *)view withTags:(int)tag{
    NSArray *subViews = view.subviews;
    int count = (int)subViews.count;
    if (count > 0) {
        for (int i = 0; i<count; i++) {
            UIView *view = subViews[i];
            if (view.tag >= tag) {
                [view removeFromSuperview];
            }
        }
    }
}

- (void)removeAllSubviews:(UIView *)view{
    [self removeAllSubviews:view withTags:-999];
}

- (void)reloadData{
    // content size
    if (!self.delegate) {
        return;
    }
    [_scrollView setContentSize:[self genContentSize]];
    [self removeAllSubviews:_scrollView withTags:kBarTag];
    [_barChartItemViews removeAllObjects];
    
    // add items
    int count = (int)[_delegate numberOfBarChartViewItem:self];
    CGFloat w = 0;
    BarChartItemView *item;
    CGRect frame;
    
    for (int i=0; i<count; i++) {
        item = [_delegate barChartView:self barAtSection:i];
        item.tag = kBarTag + i;
        item.barWidth = [_delegate barChartView:self widthForBarAtSection:i];
        item.animatable = self.animatable;
        item.value = [self trueValue:item.value];
        item.baseLineHeight = 0.5;
        item.titleColor = _barTitleColor;
        item.rowSelectable = _barRowSelectable;
        item.titleFontSize = _barTitleFontSize;
        item.titlePadding = _barTitlePadding;
        item.baseLineColor = [UIColor whiteColor];
        item.showBaseLine = _showBaseLine;
        item.baseLineColor = _baseLineColor;
        item.baseLineHeight = _baseLineHeight;
        w = [_delegate barChartView:self titleWidthForBarAtSection:i];
        frame = item.frame;
        frame.size.height = _scrollView.frame.size.height;
        frame.origin.x =  [self genOriginX:i];
        frame.origin.y = 0;//_scrollView.frame.size.height - frame.size.height;
        frame.size.width = w;
        item.section = i;
        item.barColor = [self normalBarColor];
        item.frame = frame;
        [_scrollView addSubview:item];
        [item setDelegate:self];
        [_barChartItemViews addObject: item];
        if (_showTitle) {
            if (_titleStep <= 1) {
                item.showTitle = YES;
            }
            else if (i % _titleStep == 1) {
                item.showTitle = YES;
            }
            else{
                item.showTitle = NO;
            }
        }
        else{
            item.showTitle = NO;
        }
        
    }
    if (_autoSelectMiddle) {
        [self selectMiddle];
    }
}

- (CGFloat)trueValue:(CGFloat)value{
    if (maxHeight == _maxValue) {
        return value > maxHeight ? maxHeight : value;
    }
    else{
        return value * (maxHeight/_maxValue);
    }
}

- (CGFloat)genOriginX:(int)index{
    CGFloat x = 0;
    
    for (int i = 0; i<=index; i++) {
        x += [_delegate barChartView:self paddingForBarAtSection:i];
        x += [_delegate barChartView:self widthForBarAtSection:i];
    }
    CGFloat tw = [_delegate barChartView:self titleWidthForBarAtSection:index];
    CGFloat bw = [_delegate barChartView:self widthForBarAtSection:index];
    x = x - bw;
    x = x - (tw - bw) * 0.5;
    return x;
}


- (CGSize)genContentSize{
    CGSize size = CGSizeZero;
    
    size.height = self.frame.size.height;
    
    NSUInteger count = [_delegate numberOfBarChartViewItem:self];
    for (int i = 0; i < count; i ++) {
        size.width += [_delegate barChartView:self widthForBarAtSection:i];
        size.width += [_delegate barChartView:self paddingForBarAtSection:i];
    }
    size.width += [_delegate barChartView:self paddingForBarAtSection:count ];
    return size;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_autoSelectMiddle) {
        [self selectMiddle];
        if (_pagingEnabled) {
            [self adjustPaging];
        }
    } 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGPoint point = scrollView.contentOffset;
    if (point.x < 0 && - point.x > kRefreshWidth && _refreshState == BarChartViewRefreshStateNormal) {
        self.refreshState = BarChartViewRefreshStateRefreshing;
    }
    else if(point.x + scrollView.frame.size.width > scrollView.contentSize.width + kRefreshWidth && _refreshState == BarChartViewRefreshStateNormal){
        self.refreshState = BarChartViewRefreshStateRefreshing;
    }
    else if (_autoSelectMiddle) {
        [self selectMiddle];
        if (_pagingEnabled && !decelerate) {
            [self adjustPaging];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 禁用y轴方向的bounce
    CGPoint point = scrollView.contentOffset;
    if (point.y < 0) {
        point.y = 0;
        scrollView.contentOffset = point;
    }
    else if(point.y + scrollView.frame.size.height > scrollView.contentSize.height){
        point.y = scrollView.contentSize.height - scrollView.frame.size.height;
        scrollView.contentOffset = point;
    }
    
    if (_autoSelectMiddle) {
        if (_selectedIndexPath) {
            int section = (int)_selectedIndexPath.section;
            NSString *index = [NSString stringWithFormat:@"%d",section];
            NSString *str = _barOffset[index];
            if (str) {
                CGRect rect = CGRectFromString(str);
                if (fabs(rect.origin.y - scrollView.contentOffset.x - scrollView.frame.size.width * 0.5) < rect.size.height) {
                    return;
                }
            }
        }
        [self selectMiddle];
    }
}

- (void)selectMiddle{
    CGFloat x = _scrollView.contentOffset.x;
    CGFloat cx = self.frame.size.width * 0.5;
    CGPoint p = [self indexOfOffsetX:x + cx];
    
    if (self.selectedIndexPath && self.selectedIndexPath.section == p.x) {
        return;
    }
   
    if ( p.x >=0 && p.x < _barChartItemViews.count && [_barChartItemViews[(int)p.x] rows] && [[_barChartItemViews[(int)p.x] rows] count] == 1) {
        [self selectBarAt:[NSIndexPath indexPathForRow:0 inSection:p.x]];
    }
    else{
        [self selectBarAtSection:p.x];
    }
}

- (void)adjustPaging{
    if (_pagingEnabled) {
        CGFloat x = _scrollView.contentOffset.x;
        CGFloat cx = self.frame.size.width * 0.5;
        CGFloat sx = x + cx;
        CGPoint p = [self indexOfOffsetX:sx];
        int index = p.x;
        
        if (index >= 0) {
            if (index >= _barChartItemViews.count) {
                index = (int)_barChartItemViews.count - 1;
            }
            [self selectBarAtSection:index];
            p.x = p.y - cx;
            p.y = 0;
            if (index == 0 || index == _barChartItemViews.count - 1) {
                x = [self barCenterXOfSection:index];
                p.x = x - self.frame.size.width * 0.5;
            }
            [_scrollView setContentOffset:p animated:YES];
            //NSLog(@"---adjustPaging--- %@", NSStringFromCGPoint(p));
        }
    }
}

// 根据 横坐标 获取bar 的index
- (CGPoint)indexOfOffsetX:(int)sx{
    CGFloat x = 0;
    CGFloat bw,pw;
    NSUInteger count = [_delegate numberOfBarChartViewItem:self];
    int i = 0;
    if (_selectedIndexPath) {
        i = (int)_selectedIndexPath.section - 4;
        if (i < 0) {
            i = 0;
        }
    }
    
    for ( ; i<count; i++) {
        NSString *index = [NSString stringWithFormat:@"%d",i];
        NSString *str = _barOffset[index];
        if (str) {
            CGRect rect = CGRectFromString(str);
            pw = rect.size.width;
            bw = rect.size.height;
            x = rect.origin.x;
        }
        else{
            pw = [_delegate barChartView:self paddingForBarAtSection:i];
            bw = [_delegate barChartView:self widthForBarAtSection:i];
            x += bw + pw;
            CGRect rect = CGRectMake(x, 0, pw, bw);
            rect.origin.y = x - bw * 0.5;
            _barOffset[index] = NSStringFromCGRect(rect);
        }
        
        
        if (x > sx) {
            if (x - sx - pw * 0.5 - bw > 0 && i > 0) {
                return CGPointMake(i - 1, x - bw - pw - [_delegate barChartView:self widthForBarAtSection:i - 1] * 0.5);
            }
            
            return CGPointMake(i, x - bw * 0.5);
        }
    }
    
    return CGPointMake(--i, -1);
}

// 根据section 求bar 的中心X值
- (CGFloat)barCenterXOfSection:(int)section{
    CGFloat x = 0;
    CGFloat bw = 0;
    CGFloat pw = 0;
    for (int i = 0; i<= section; i++) {
        NSString *index = [NSString stringWithFormat:@"%d",i];
        NSString *str = _barOffset[index];
        if (str) {
            CGRect rect = CGRectFromString(str);
            pw = rect.size.width;
            bw = rect.size.height;
            x = rect.origin.x;
            rect.origin.y = x - bw * 0.5;
            _barOffset[index] = NSStringFromCGRect(rect);
        }
        else{
            pw = [_delegate barChartView:self paddingForBarAtSection:i];
            bw = [_delegate barChartView:self widthForBarAtSection:i];
            x += bw + pw;
            CGRect rect = CGRectMake(x, 0, pw, bw);
            rect.origin.y = x - bw * 0.5;
            _barOffset[index] = NSStringFromCGRect(rect);
        }
    }
    return x - bw * 0.5;
}

- (void)barChartItemView:(BarChartItemView *)barChartItemView didClickedAt:(NSIndexPath *)indexPath{
    if (_selectable && _barRowSelectable) {
        if (indexPath.row == -1) {
            [self selectBarAtSection:indexPath.section];
        }
        else{
            [self selectBarAt:indexPath];
        }
    }
    
    [self.delegate barChartView:self didClickItemAt:indexPath];
}

- (void)setDelegate:(id<BarChartViewDelegate>)delegate{
    _delegate = delegate;
    if (_delegate) {
        [self reloadData];
    }
}
 
- (void)setMiddleLineColor:(UIColor *)middleLineColor{
    _middleLineColor = middleLineColor;
    [self setupMiddleLine];
}

- (void)setMiddleLineHeight:(CGFloat)middleLineHeight{
    _middleLineHeight = middleLineHeight;
    [self setupMiddleLine];
}

- (void)setMiddleLineType:(enum BarChartMiddleLineType)middleLineType{
    _middleLineType = middleLineType;
    [self setupMiddleLine];
}

- (void)setMiddleLineFrame:(CGRect)middleLineFrame{
    _middleLineFrame = middleLineFrame;
    if (!_middleLineLayer) {
        [self setupMiddleLine];
    }
    _middleLineLayer.frame = _middleLineFrame;
}

- (void)setBarTitleFontSize:(CGFloat)barTitleFontSize{
    _barTitleFontSize = barTitleFontSize;
    [self setBaseLine];
}

- (void)setBarTitlePadding:(CGFloat)barTitlePadding{
    _barTitlePadding = barTitlePadding;
    [self setBaseLine];
}

- (void)setMaxValue:(CGFloat)maxValue{
    if (maxValue > 0) {
        _maxValue = maxValue;
    } 
}

- (void)setHeaderRefreshingBlock:(BarChartViewRefreshBlock)block{
    headerRefreshBlock = block;
}

- (void)setFooterRefreshingBlock:(BarChartViewRefreshBlock)block{
    footerRefreshBlock = block;
}

- (void)setRefreshState:(enum BarChartViewRefreshState)refreshState{
    _refreshState = refreshState;
    [self refreshStateChanged];
}


// range  = update_count - 1
- (void)updateBarsAtHeaderWithRange:(int)range{
    while (_scrollView.isDragging || _scrollView.isDecelerating) {
        [NSThread sleepForTimeInterval:0.5];
        continue;
    }
    // content size
    if (!self.delegate) {
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_scrollView setContentSize:[self genContentSize]];
        long tag = kBarTag + _barChartItemViews.count + 1;
        CGFloat w = 0;
        BarChartItemView *item;
        CGRect frame;
        
        // 调整subView的frame
        long count = _barChartItemViews.count;
        for(int i=0;i<count;i++){
            item = _barChartItemViews[i];
            frame = item.frame;
            frame.origin.x = [self genOriginX:i+range];
            item.animatable = NO;
            item.frame = frame;
            item.section = range + i;
        }
        
        [_barOffset removeAllObjects];
        
        // add items
        for (int i=range - 1; i>=0; i--) {
            item = [_delegate barChartView:self barAtSection:i];
            item.tag = tag + i;
            item.barWidth = [_delegate barChartView:self widthForBarAtSection:i];
            item.animatable = self.animatable;
            item.value = [self trueValue:item.value];
            item.baseLineHeight = 0.5;
            item.titleColor = _barTitleColor;
            item.rowSelectable = _barRowSelectable;
            item.titleFontSize = _barTitleFontSize;
            item.titlePadding = _barTitlePadding;
            item.showBaseLine = _showBaseLine;
            item.baseLineColor = _baseLineColor;
            item.baseLineHeight = _baseLineHeight;
            w = [_delegate barChartView:self titleWidthForBarAtSection:i];
            frame = item.frame;
            frame.size.height = _scrollView.frame.size.height;
            frame.origin.x =  [self genOriginX:i];
            frame.origin.y = 0;//_scrollView.frame.size.height - frame.size.height;
            frame.size.width = w;
            item.section = i;
            item.barColor = [self normalBarColor];
            item.frame = frame;
            [_scrollView addSubview:item];
            [item setDelegate:self];
            [_barChartItemViews insertObject:item atIndex:0];
            if (_showTitle) {
                if (_titleStep <= 1) {
                    item.showTitle = YES;
                }
                else if (i % _titleStep == 1) {
                    item.showTitle = YES;
                }
                else{
                    item.showTitle = NO;
                }
            }
            else{
                item.showTitle = NO;
            }
        }
        
        CGFloat offset = [self barCenterXOfSection:range] - [_delegate barChartView:self widthForBarAtSection:range] * 0.5;
        offset -= _scrollView.frame.size.width * 0.5;
        
        CGPoint point = _scrollView.contentOffset;
        point.x = offset;
        [_scrollView setContentOffset:point animated:NO];
    });
}

- (void)updateBarsAtFooterWithRange:(int)range{
    while (_scrollView.isDragging || _scrollView.isDecelerating) {
        [NSThread sleepForTimeInterval:0.5];
        continue;
    }
    // content size
    if (!self.delegate) {
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_scrollView setContentSize:[self genContentSize]];
        int tag =(int)( kBarTag + _barChartItemViews.count + 1);
        CGFloat w = 0;
        BarChartItemView *item;
        CGRect frame;
        
        int count = (int)_barChartItemViews.count + range;
        // add items
        for (int i=(int)_barChartItemViews.count; i < count; i++) {
            item = [_delegate barChartView:self barAtSection:i];
            item.tag = tag + i;
            item.barWidth = [_delegate barChartView:self widthForBarAtSection:i];
            item.animatable = self.animatable;
            item.value = [self trueValue:item.value];
            item.baseLineHeight = 0.5;
            item.titleColor = _barTitleColor;
            item.rowSelectable = _barRowSelectable;
            item.titleFontSize = _barTitleFontSize;
            item.titlePadding = _barTitlePadding;
            item.showBaseLine = _showBaseLine;
            item.baseLineColor = _baseLineColor;
            item.baseLineHeight = _baseLineHeight;
            w = [_delegate barChartView:self titleWidthForBarAtSection:i];
            frame = item.frame;
            frame.size.height = _scrollView.frame.size.height;
            frame.origin.x =  [self genOriginX:i];
            frame.origin.y = 0;//_scrollView.frame.size.height - frame.size.height;
            frame.size.width = w;
            item.section = i;
            item.barColor = [self normalBarColor];
            item.frame = frame;
            [_scrollView addSubview:item];
            [item setDelegate:self];
            [_barChartItemViews addObject:item];
            if (_showTitle) {
                if (_titleStep <= 1) {
                    item.showTitle = YES;
                }
                else if (i % _titleStep == 1) {
                    item.showTitle = YES;
                }
                else{
                    item.showTitle = NO;
                }
            }
            else{
                item.showTitle = NO;
            }
        }
    });
}



- (void)refreshStateChanged{
    if (_refreshState == BarChartViewRefreshStateRefreshing) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_scrollView.contentOffset.x < 0) {
                if(headerRefreshBlock){
                    headerRefreshBlock();
                }
            }
            else if(_scrollView.contentOffset.x + _scrollView.frame.size.width > _scrollView.contentSize.width){
                if (footerRefreshBlock) {
                    footerRefreshBlock();
                }
            }
            while (YES) {
                if (_refreshState == BarChartViewRefreshStateDone && _scrollView.isDragging == NO && _scrollView.isDecelerating == NO) {
                    _refreshState = BarChartViewRefreshStateNormal;
                    break;
                }
                [NSThread sleepForTimeInterval:0.5];
            }
            
            
        });
    }
}


@end
