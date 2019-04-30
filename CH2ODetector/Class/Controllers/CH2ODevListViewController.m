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
@property (nonatomic, strong) CBPeripheral * connectedPeripheral;
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> * discoverPeripheraArray;
@property (nonatomic, strong) MBProgressHUDManager * hudManager;
@end

@implementation CH2ODevListViewController {

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"传感器列表";
    self.navigationItem.leftBarButtonItem.title = @"返回";
    self.connectedPeripheral = nil;
    [[CH2OBLEManager shareInstance] start];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.hudManager = [[MBProgressHUDManager alloc] initWithView:self.view];
    self.hudManager.HUD.margin = 10.f;
    self.hudManager.HUD.opacity = 0.6;
    self.hudManager.HUD.yOffset = 0;
    self.hudManager.HUD.dimBackground = NO;
  
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
    self.discoverPeripheraArray = [NSMutableArray new];
    [self.tableView reloadData];
    [_hudManager hide];
}

- (void)onBLEManagerNotification : (NSNotification*)notification {
    NSLog(@"onBLEManagerNotification ... ");

    NSDictionary* useinfo = notification.userInfo;
    NSString* type = [useinfo objectForKey:@"type"];
    NSLog(@"notificaiton type: %@", type);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hudManager hide];
        if ([type isEqual:kBLEPeripheralDiscoveryNotify]) {
            CBPeripheral * peripheral = [useinfo objectForKey:@"peripheral"];
            if (peripheral) {
                if (![self.discoverPeripheraArray containsObject:peripheral]) {
                    [self.discoverPeripheraArray addObject:peripheral];
                    [self.tableView reloadData];
                }
            }
        } else if ([type isEqual:kBLEPeripheralConnectedNotify]) {
            CBPeripheral * peripheral = [useinfo objectForKey:@"peripheral"];
            if (peripheral) {
                [self.discoverPeripheraArray removeObject:peripheral];
            }
            [self.hudManager showMessage:@"链接成功!" duration:1];
           
        } else if ([type isEqual:kBLEPeripheralDisconnectNotify]) {
            [self.hudManager showMessage:@"链接失败" duration:1];
        }
        [self.tableView reloadData];
    });
    
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
        return self.discoverPeripheraArray.count;
    }
    self.connectedPeripheral = [CH2OBLEManager shareInstance].currentPeripheral;
    if (self.connectedPeripheral) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
  
    if (section == 0) {
        // discover sensor
        NSString* cellIdentifier = @"kDiscoverCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        CBPeripheral * peripheral = self.discoverPeripheraArray[row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.identifier.UUIDString;
        return cell;
    
    } else {
        // connected sensor
        NSString* cellIdentifier = @"kConnectedCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.text = self.connectedPeripheral.name;
        cell.detailTextLabel.text = self.connectedPeripheral.identifier.UUIDString;
        return cell;
    }
    return nil;
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
        CBPeripheral * peripheral = self.discoverPeripheraArray[row];
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [[CH2OBLEManager shareInstance] connectToPeripheral:peripheral];
            [_hudManager showIndeterminateWithMessage:@"正在连接传感器" duration:-1];
        }
    }
    return;
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
