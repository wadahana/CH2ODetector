//
//  CH2ODevListViewController.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/22.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2ODevListViewController.h"
#import "CH2OBLEManager.h"
#import "CH2ONavigationManager.h"
#import "MBProgressHUDManager.h"

@interface CH2ODevListViewController ()

@end

@implementation CH2ODevListViewController {
  NSArray* _connectedDevList;
  NSArray* _discoverDevList;
  MBProgressHUDManager* _hudManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"传感器列表";
    self.navigationItem.leftBarButtonItem.title = @"返回";
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _hudManager = [[MBProgressHUDManager alloc] initWithView:self.view];
    _hudManager.HUD.margin = 10.f;
    _hudManager.HUD.opacity = 0.6;
    _hudManager.HUD.yOffset = 0;
    _hudManager.HUD.dimBackground = NO;
  
  
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(onBLEManagerNotification:)
                                                  name:kBLEManagerNotification
                                                object:nil];
  
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
  [_hudManager showIndeterminateWithMessage:@"加载中...\n" duration:-1];
  _connectedDevList = [[CH2OBLEManager shareInstance] connectedDevList];
  _discoverDevList = [[CH2OBLEManager shareInstance] discoverDevList];
  [self.tableView reloadData];
  [_hudManager hide];
}

- (void)onBLEManagerNotification : (NSNotification*)notification {
  NSLog(@"onBLEManagerNotification ... ");
  [_hudManager hide];
  NSDictionary* args = notification.userInfo;
  NSString* type = [args objectForKey:@"type"];
  if ([type isEqual:kBLEPeripheralDiscoveryNotify] ||
      [type isEqual:kBLEPeripheralConnectedNotify] ||
      [type isEqual:kBLEPeripheralDisconnectNotify]) {
    [self.tableView reloadData];
  }
  return;
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"已发现传感器:";
  }
  return @"已连接传感器:";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
  if (section == 0) {
    return _discoverDevList.count;
  }
  return _connectedDevList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger row = indexPath.row;
  NSInteger section = indexPath.section;
  
  if (section == 0) { // discover sensor
    NSString* cellIdentifier = @"kDiscoverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    CBPeripheral* peripheral = _discoverDevList[row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
  } else { // connection sensor
    NSString* cellIdentifier = @"kConnectedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    CBPeripheral* peripheral = _connectedDevList[row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
  }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"didSelectRowAtIndexPath");
  NSInteger row = indexPath.row;
  NSInteger section = indexPath.section;
  if (section == 0) { // discover sensor
    CBPeripheral* peripheral = _discoverDevList[row];
    if (peripheral.state == CBPeripheralStateDisconnected) {
      [[CH2OBLEManager shareInstance] connectToPeripheral:peripheral];
      [_hudManager showIndeterminateWithMessage:@"正在连接传感器" duration:15 complection:^(void){
        NSLog(@"");
      }];
    }
  } else {
    CBPeripheral* peripheral = _connectedDevList[row];
    [[CH2OBLEManager shareInstance] setCurrentPeripheral:peripheral];
    NSString* msg = [NSString stringWithFormat:@"选择传感器:%@", peripheral.name];
    [_hudManager showMessage:msg duration:1 complection:^{
      [[CH2ONavigationManager shareInstance] navigateBack];
    }];

  }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
