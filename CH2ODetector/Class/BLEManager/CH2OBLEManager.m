//
//  CH2OBLEManager.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2OBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CH2OBLEManager () <CBCentralManagerDelegate,CBPeripheralDelegate>

@end

@implementation CH2OBLEManager {
  NSMutableArray *_discoverDevList;
  NSMutableArray *_connectedDevList;
  CBCentralManager *_bldManager;
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
  }
  return self;
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
      [central scanForPeripheralsWithServices:nil options:nil];
      break;
    default:
      break;
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
  if (peripheral.state == CBPeripheralStateDisconnected) {
    
  }

}
#pragma mark - CBPeripheralDelegate

@end
