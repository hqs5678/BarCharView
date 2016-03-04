//
//  BarRow.h
//  BarChartTest
//
//  Created by hqs on 16/1/16.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarRow : NSObject

@property (nonatomic,strong) UIColor *normalColor;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,strong) UIColor *highlightColor;
@property (nonatomic,strong) CALayer *layer;

@end 
