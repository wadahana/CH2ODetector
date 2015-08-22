//
//  CH2ORootViewController.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//
#import "CH2OBLEManager.h"
#import "CH2ORootViewController.h"
#import "CH2ONavigationManager.h"
#import "MBProgressHUDManager.h"

@interface CH2ORootViewController ()

@end

@implementation CH2ORootViewController {
  MBProgressHUDManager* _hudManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"实时浓度";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(onScan:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    _historyButton.layer.borderColor = [UIColor blueColor].CGColor;
    _historyButton.layer.borderWidth = 0.5;
    _historyButton.layer.cornerRadius = 5;
    // Do any additional setup after loading the view from its nib.
  
    [[CH2OBLEManager shareInstance] start];
  
    _hudManager = [[MBProgressHUDManager alloc] initWithView:self.view];
    _hudManager.HUD.margin = 10.f;
    _hudManager.HUD.opacity = 0.6;
    _hudManager.HUD.yOffset = 0;
    _hudManager.HUD.dimBackground = NO;
    
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(onBLEManagerNotification:)
                                                  name:kBLEManagerNotification
                                                object:nil];
    
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

- (void)onBLEManagerNotification : (NSNotification*)notification {
  NSLog(@"onBLEManagerNotification ... ");
  NSDictionary* args = notification.userInfo;
  NSString* type = [args objectForKey:@"type"];
  if ([type isEqual:kBLEPeripheralRecvValueNotify]) {
    NSLog(@"detector value change ..");
  }
  return;
}

- (void)onScan:(id)sender {
  [[CH2ONavigationManager shareInstance] navigateToDevListView];
}

- (IBAction)onHistory:(id)sender {
  [[CH2ONavigationManager shareInstance] navigateToHistoryView];
}
@end
