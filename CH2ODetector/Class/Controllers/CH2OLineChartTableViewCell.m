//
//  CH2OLineChartTableViewCell.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2OLineChartTableViewCell.h"
#import "ELineChart.h"
#import "ELineChartDataModel.h"

@interface CH2OLineChartTableViewCell() <ELineChartDataSource, ELineChartDelegate>

@end

@implementation CH2OLineChartTableViewCell {
    ELineChart *_chartView;
    NSMutableArray *_data;
}

- (void)awakeFromNib {
    // Initialization code
    _data = [NSMutableArray new];
    for (int i = 0 ; i < 300; i++) {
        int number = arc4random() % 100;
        ELineChartDataModel *eLineChartDataModel = [[ELineChartDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%d", i] value:number index:i unit:@"kWh"];
        [_data addObject:eLineChartDataModel];
    }
    CGRect frame = self.contentView.frame;
    _chartView = [[ELineChart alloc] initWithFrame:frame];
    [_chartView setDelegate:self];
    [_chartView setDataSource:self];
    [self.contentView addSubview:_chartView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - ELineChartDataSource

- (NSInteger) numberOfPointsInELineChart:(ELineChart *) eLineChart {
    return [_data count];
}

- (NSInteger) numberOfPointsPresentedEveryTime:(ELineChart *) eLineChart {
    return 20;
}


- (ELineChartDataModel*)highestValueELineChart:(ELineChart *) eLineChart {
    ELineChartDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (ELineChartDataModel *dataModel in _data) {
        if (dataModel.value > maxValue) {
            maxValue = dataModel.value;
          maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

- (ELineChartDataModel*)eLineChart:(ELineChart *) eLineChart valueForIndex:(NSInteger)index {
    if (index >= [_data count] || index < 0) {
        return nil;
    }
    return [_data objectAtIndex:index];
}

#pragma mark- ELineChartDelegate

- (void)eLineChartDidReachTheEnd:(ELineChart *)eLineChart {
    NSLog(@"Did reach the end");
}

- (void)eLineChart:(ELineChart *)eLineChart
     didTapAtPoint:(ELineChartDataModel *)eLineChartDataModel {
  NSLog(@"%d %f", eLineChartDataModel.index, eLineChartDataModel.value);
}

- (void)eLineChart:(ELineChart *)eLineChart
 didHoldAndMoveToPoint:(ELineChartDataModel *)eLineChartDataModel {
  
}

- (void)fingerDidLeaveELineChart:(ELineChart *)eLineChart {
  
}

- (void)eLineChart:(ELineChart *)eLineChart didZoomToScale:(float)scale {

}

@end
