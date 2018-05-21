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
#import "CH2ODBHelper.h"
#import "AppDelegate.h"

@interface CH2ORootViewController ()

@end

@implementation CH2ORootViewController {
  MBProgressHUDManager* _hudManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CH2ODBHelper shareInstance] start];
    self.title = @"实时浓度";
    self.recordButton.titleLabel.text = @"开始记录";
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(onScan:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.historyButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.historyButton.layer.borderWidth = 0.5;
    self.historyButton.layer.cornerRadius = 5;
    
    self.clearButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.clearButton.layer.borderWidth = 0.5;
    self.clearButton.layer.cornerRadius = 5;
    
    self.recordButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.recordButton.layer.borderWidth = 0.5;
    self.recordButton.layer.cornerRadius = 5;
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
  NSDictionary* userInfo = notification.userInfo;
  NSString* type = [userInfo objectForKey:@"type"];
  if ([type isEqual:kBLEPeripheralRecvValueNotify]) {
      NSLog(@"detector value change ..");
      dispatch_async(dispatch_get_main_queue(), ^{
          double ppa = [CH2OBLEManager shareInstance].ppaValue;
          double vol = [CH2OBLEManager shareInstance].volValue;
          if (!isnan(ppa) && !isnan(vol)) {
              self.ppaLabel.text = [NSString stringWithFormat:@"%0.4lf ppm", ppa];
              self.volLabel.text = [NSString stringWithFormat:@"%0.4lf mg/m3", vol];
          }
      });
  } else if ([type isEqual:kBLEPeripheralDisconnectNotify]) {
      dispatch_async(dispatch_get_main_queue(), ^{
          self.ppaLabel.text = @"-/-";
          self.volLabel.text = @"-/-";
          /*
          if (!self.timer) {
              self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
          }
          self.ppaValue = nan(NULL);
          self.volValue = nan(NULL);
          if (self.timer) {
              [self.timer invalidate];
              self.timer = nil;
          }
           */
      });
  }
  return;
}


- (void)onScan:(id)sender {
  [[CH2ONavigationManager shareInstance] navigateToDevListView];
}

- (IBAction)onRecord:(id)sender {
    __weak AppDelegate * appDeleage = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDeleage.recording) {
        [self.recordButton setTitle:@"开始记录" forState:UIControlStateNormal];
        appDeleage.recording = NO;
    } else {
        [self.recordButton setTitle:@"停止记录" forState:UIControlStateNormal];
        appDeleage.recording = YES;
    }
}
- (IBAction)onClear:(id)sender {
    [[CH2ODBHelper shareInstance] removeAllRecords];
}
- (IBAction)onHistory:(id)sender {
  [[CH2ONavigationManager shareInstance] navigateToHistoryView];
}
@end
