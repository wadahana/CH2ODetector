//
//  CH2ONavigationController.m
//  UOne
//
//  Created by wadahana on 15-4-13.
//  Copyright (c) 2015年 chinanetcenter. All rights reserved.
//


#import "CH2ONavigationController.h"

@interface CH2ONavigationController ()

@end

@implementation CH2ONavigationController
{
  BOOL _supportInterfaceOrientationMaskAll;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
  
  if (self = [super initWithRootViewController:rootViewController]) {
    _supportInterfaceOrientationMaskAll = NO;
  }
  return self;
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  if (_supportInterfaceOrientationMaskAll) {
    return UIInterfaceOrientationMaskAll;
  } else {
    return UIInterfaceOrientationMaskPortrait;
  }
}

- (void)setSupportInterfaceOrientationMaskAll:(BOOL)flag {
  _supportInterfaceOrientationMaskAll = flag;
}

@end