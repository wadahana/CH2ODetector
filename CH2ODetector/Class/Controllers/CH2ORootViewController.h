//
//  CH2ORootViewController.h
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CH2ORootViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel* ppaLabel;
@property (nonatomic, weak) IBOutlet UILabel* volLabel;
@property (nonatomic, weak) IBOutlet UILabel* infoLabel;
@property (nonatomic, weak) IBOutlet UIButton* historyButton;
- (IBAction)onHistory:(id)sender;

@end
