//
//  CH2OHistoryViewController.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2OHistoryViewController.h"
#import "CH2OLineChartTableViewCell.h"

@interface CH2OHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation CH2OHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史数据";
    self.navigationItem.leftBarButtonItem.title = @"返回";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"kLineChartCell";
    
    CH2OLineChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
      [tableView registerNib:[UINib nibWithNibName:@"CH2OLineChartTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
      cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 30);
  UILabel *label = [[UILabel alloc]initWithFrame:frame];
  label.font = [UIFont systemFontOfSize:30];
  label.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3];
  label.text = section ? @"Bar":@"Line";
  label.textColor = [UIColor colorWithRed:0.257 green:0.650 blue:0.478 alpha:1.000];
  label.textAlignment = NSTextAlignmentCenter;
  return label;
}


@end
