//
//  BarRow.m
//  BarChartTest
//
//  Created by hqs on 16/1/16.
//  Copyright © 2016年 hqs. All rights reserved.
//

#import "BarRow.h"

@implementation BarRow

- (instancetype)init{
    self = [super init];
    if (self) {
        self.highlightColor = [UIColor lightGrayColor];
        self.normalColor = [UIColor grayColor];
        self.height = 10;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"height:%f",_height];
}

@end
