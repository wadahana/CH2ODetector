//
//  CH2OBLEManager.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2OBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CH2OBLEManager () <CBCentralManagerDelegate,
                              CBPeripheralDelegate>

@end

@implementation CH2OBLEManager {
  NSMutableArray *_discoverDevList;
  NSMutableArray *_connectedDevList;
  CBCentralManager *_bldManager;
  dispatch_queue_t _bleQueue;
  CBPeripheral* _currentPeripheral;
}


+ (instancetype)shareInstance {
  static CH2OBLEManager *sBLEManager = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sBLEManager = [[CH2OBLEManager alloc] init];
  });
  return sBLEManager;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _discoverDevList = [NSMutableArray new];
    _connectedDevList = [NSMutableArray new];
    _currentPeripheral = nil;
    _bleQueue =  dispatch_queue_create("kCH2OBLEQueue", DISPATCH_QUEUE_SERIAL);
    _bldManager = [[CBCentralManager alloc] initWithDelegate:self queue:_bleQueue];
  }
  return self;
}

- (BOOL)start {
  if (_bldManager.state == CBCentralManagerStatePoweredOn) {
    [_bldManager scanForPeripheralsWithServices:nil options:nil];
    return YES;
  }
  return NO;
}

- (void)stop {
  [_bldManager stopScan];
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral {
  [_bldManager connectPeripheral:peripheral options:nil];
}

- (NSArray*)discoverDevList {
  return _discoverDevList;
}

- (NSArray*)connectedDevList {
  return _connectedDevList;
}

- (CBPeripheral*)currentPeripheral {
  return _currentPeripheral;
}

- (void)setCurrentPeripheral:(CBPeripheral *)peripheral {
  _currentPeripheral = peripheral;
}
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  CBCentralManagerState state = [central state];
  switch (state) {
    case CBCentralManagerStateUnknown:
    case CBCentralManagerStateResetting:
    case CBCentralManagerStateUnsupported:
    case CBCentralManagerStateUnauthorized:
    case CBCentralManagerStatePoweredOff:
      break;
    case CBCentralManagerStatePoweredOn:
      [_bldManager scanForPeripheralsWithServices:nil options:nil];
      break;
    default:
      break;
  }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  NSLog(@"discover peripheral: %@", peripheral.identifier);
  if (peripheral.state == CBPeripheralStateDisconnected) { // 未连接
    if ([_connectedDevList containsObject:peripheral]) { // remove from connected list
      [_connectedDevList removeObject:peripheral];
    }
    if (![_discoverDevList containsObject:peripheral]) { // add to discover list
      [_discoverDevList addObject:peripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                        object:nil
                                                      userInfo:@{@"type":@"kDiscoverPeripheral",
                                                           @"peripheral":peripheral}];
  }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  if (peripheral.state == CBPeripheralStateConnected) {
    if ([_discoverDevList containsObject:peripheral]) { // remove from discover list
      [_discoverDevList removeObject:peripheral];
    }
    if (![_connectedDevList containsObject:peripheral]) { // add to connected list
      [_connectedDevList addObject:peripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                        object:nil
                                                      userInfo:@{@"type":@"kDidConnectPeripheral",
                                                           @"peripheral":peripheral}];
  }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  if ([_connectedDevList containsObject:peripheral]) { // remove from connected list
    [_connectedDevList removeObject:peripheral];
  }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  if ([_connectedDevList containsObject:peripheral]) { // remove from connected list
    [_connectedDevList removeObject:peripheral];
  }

}
#pragma mark - CBPeripheralDelegate

@end
