//
//  CH2ONavigationManager.h
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CH2ONavigationController.h"

@interface CH2ONavigationManager : NSObject

+ (instancetype)shareInstance;

- (void)setNavigationController:(CH2ONavigationController*)aController;

- (void)setSupportInterfaceOrientationMaskAll:(BOOL)supported;

- (void)navigateBack;

- (void)navigateToRootAnimated:(BOOL)animated;

- (void)navigateToHistoryView;

- (void)navigateToDevListView;

@end
