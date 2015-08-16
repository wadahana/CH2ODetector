//
//  CH2ONavigationManager.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2ONavigationManager.h"
#import "CH2ORootViewController.h"
#import "CH2OHistoryViewController.h"

@interface CH2ONavigationManager () <UINavigationControllerDelegate>
{
  __weak CH2ONavigationController *_navigationController;
}

@end

@implementation CH2ONavigationManager

+ (instancetype)shareInstance {
  static CH2ONavigationManager *sNavigatorManager = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sNavigatorManager = [[CH2ONavigationManager alloc] init];
  });
  return sNavigatorManager;
}

- (instancetype) init {
  self = [super init];
  if (self) {
  
  }
  return self;
}

- (void)setNavigationController:(CH2ONavigationController*)aController {
  _navigationController = aController;
  _navigationController.delegate = self;
}

- (void)setSupportInterfaceOrientationMaskAll:(BOOL)supported {
  if (supported == NO) {
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
  }
  [_navigationController setSupportInterfaceOrientationMaskAll:supported];
}

- (void)navigateBack {
  [_navigationController popViewControllerAnimated:YES];
}

- (void)navigateToRootAnimated:(BOOL)animated {
  [_navigationController popToRootViewControllerAnimated:animated];
}

- (void)navigateToHistoryView {
  CH2OHistoryViewController *controller = [[CH2OHistoryViewController alloc] initWithNibName:@"CH2OHistoryViewController" bundle:nil];
  [_navigationController pushViewController:controller animated:YES];
}

@end
