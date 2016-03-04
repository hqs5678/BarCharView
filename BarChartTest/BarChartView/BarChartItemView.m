//
//  BarChartItemView.m
//  BarChartTest
//
//  Created by hqs on 16/1/15.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "BarChartItemView.h"
#import "BarRow.h"
 

@implementation BarChartItemView{
    UIView *_barView;
    UILabel *_titleLabel;
    CALayer *_baseLine;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _value = 0;
        _titleFontSize = 8;
        _titlePadding = 5;
        _titleColor = [UIColor blueColor];
        _barWidth = 10;
        _showTitle = YES;
        _animatable = NO;
        _baseLineHeight = 1;
        _baseLineColor = [UIColor whiteColor];
        _rowSelectable = YES;
        _selectedRowIndex = -1;
        _showBaseLine = NO;
        
        [self setup];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)recognizer{
    if (self.delegate) {
        CGPoint point = [recognizer locationInView:self];
        if (CGRectContainsPoint(_barView.frame, point)) {
            point = [recognizer locationInView:_barView];
            int rowIndex = [self rowIndexwithPoint:point];
            if (self.rows && rowIndex >= 0 && rowIndex < self.rows.count && _rowSelectable && _selectedRowIndex != rowIndex) {
                BarRow * row = (BarRow *) self.rows[rowIndex];
                row.layer.backgroundColor = row.highlightColor.CGColor;
                if (_selectedRowIndex >= 0 && _selectedRowIndex < self.rows.count) {
                    row = (BarRow *)self.rows[_selectedRowIndex];
                    row.layer.backgroundColor = row.normalColor.CGColor;
                }
                _selectedRowIndex = rowIndex;
            }
            [self.delegate barChartItemView:self didClickedAt:[NSIndexPath indexPathForRow:rowIndex inSection:_section]];
        }
    }
}

- (NSUInteger)rowIndexwithPoint:(CGPoint)point{
    if (_rows) {
        CGFloat y = 0;
        NSUInteger i = 0;
        for (BarRow *row in _rows) {
            CGRect frame = CGRectMake(0, y, _barWidth, row.height);
            if (CGRectContainsPoint(frame, point)) {
                return i;
            }
            y = y + row.layer.frame.size.height;
            ++ i;
        }
    }
    return self.rows.count - 1;
}

- (void)setup{
    self.backgroundColor = [UIColor clearColor];
    
    
    CGFloat h = _titleFontSize + _titlePadding * 2;
    CGFloat y = self.frame.size.height - h;
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, y, self.frame.size.width, h)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = _titleColor;
    _titleLabel.font = [_titleLabel.font fontWithSize:_titleFontSize];
    [self addSubview:_titleLabel];
    
    
    
    y = _titleLabel.frame.origin.y - _value;
    CGFloat x = (self.frame.size.width - _barWidth) * 0.5;
    _barView = [[UIView alloc]initWithFrame:CGRectMake(x, y, _barWidth, _value)];
    _barView.layer.anchorPoint = CGPointMake(0, 1);
    _barView.backgroundColor = _barColor;
    _barView.clipsToBounds = YES;
    [self addSubview:_barView];
}

- (void)setShowBaseLine:(BOOL)showBaseLine{
    _showBaseLine = showBaseLine;
    
    if (!_showBaseLine) {
        _baseLine = [[CALayer alloc]init];
        _baseLine.frame = CGRectMake(0, 0, _titleLabel.frame.size.width, _baseLineHeight);
        _baseLine.backgroundColor = _baseLineColor.CGColor;
    }
    if (_showBaseLine) {
        [_titleLabel.layer addSublayer:_baseLine];
    }
    else{
        [_baseLine removeFromSuperlayer];
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (frame.size.width == 0) {
        return;
    }
    CGFloat x = 0;
    CGFloat h = _titleFontSize + _titlePadding * 2;
    __block CGFloat y = self.frame.size.height - h;
    _titleLabel.frame = CGRectMake(x, y, self.frame.size.width, h);
    
    y = _animatable ? _titleLabel.frame.origin.y : _titleLabel.frame.origin.y - _value;
    x = (frame.size.width - _barWidth) * 0.5;
    h = _animatable ? 0 : _value;
    _barView.frame = CGRectMake(x, y, _barWidth, h);
    
    if (_rows) {
        [self removeAllSublayers:_barView];
        y = 0;
        int i = 0;
        for (BarRow *row in _rows) {
            if (row.layer == nil) {
                row.layer = [[CALayer alloc]init];
            }
            [_barView.layer addSublayer:row.layer];
            row.layer.backgroundColor = row.normalColor.CGColor;
            row.layer.frame = CGRectMake(0, y, _barWidth, row.height);
            
            ++ i;
            if (i == self.rows.count) {
                row.layer.frame = CGRectMake(0, y, _barWidth, _value - y);
            }
            else{
                y = y + row.height;
            }
        }
    }
    
    if (_animatable) {
        _titleLabel.alpha = 0;
        [UIView animateWithDuration:1 animations:^{
            y = _titleLabel.frame.origin.y - _value;
            _barView.frame = CGRectMake(x, y, _barWidth, _value);
            _titleLabel.alpha = 1;
        }];
    }
    
    [self resetBaseLine];
}

- (void)setShowTitle:(BOOL)showTitle{
    _showTitle = showTitle;
    if (showTitle) {
        _titleLabel.text = _title;
    }
    else{
        _titleLabel.text = @"";
    }
}

//- (void)setValue:(CGFloat)value{
//    _value = value;
//    if (_animatable) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:1];
//    }
//    CGRect frame = _barView.frame;
//    frame.origin.y = _titleLabel.frame.origin.y - _value;
//    frame.size.height = _value;
//    _barView.frame = frame;
//    if (_animatable) {
//        [UIView commitAnimations];
//    }
//}

- (void)removeAllSublayers:(UIView *)view{
    for (CALayer *layer in view.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}

- (void)setBarColor:(UIColor *)barColor{
    _barColor = barColor;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _barView.backgroundColor = barColor;
    [UIView commitAnimations];
}

- (void)setBaseLineColor:(UIColor *)baseLineColor{
    _baseLineColor = baseLineColor;
    [self resetBaseLine];
}

- (void)setBaseLineHeight:(CGFloat)baseLineHeight{
    _baseLineHeight = baseLineHeight;
    [self resetBaseLine];
}

- (void) resetBaseLine{
    _baseLine.frame = CGRectMake(0, 0, _titleLabel.frame.size.width, _baseLineHeight);
    _baseLine.backgroundColor = _baseLineColor.CGColor;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

- (void)setTitleFontSize:(CGFloat)titleFontSize{
    _titleFontSize = titleFontSize;
    _titleLabel.font = [_titleLabel.font fontWithSize:titleFontSize];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

 
@end

