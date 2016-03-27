//
//  CH2ONavigationController.h
//  UOne
//
//  Created by wadahana on 15-4-13.
//  Copyright (c) 2015年 chinanetcenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CH2ONavigationController : UINavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)setSupportInterfaceOrientationMaskAll:(BOOL)flag;

@end
