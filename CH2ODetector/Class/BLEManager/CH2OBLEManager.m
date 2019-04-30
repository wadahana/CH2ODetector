//
//  CH2OBLEManager.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CH2OBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

const static NSString* kUartServiceUUID = @"FFE0";

@interface CH2OBLEManager () <CBCentralManagerDelegate,
                              CBPeripheralDelegate>

@property (nonatomic, strong) NSMutableArray * connectedDevList;
@property (nonatomic, strong) CBCentralManager * bleManager;
@property (nonatomic, strong) CBPeripheral * currentPeripheral;

@end

@implementation CH2OBLEManager {
    
    dispatch_queue_t  _bleQueue;

    void (^_connectedCompleteBlock)(BOOL success);
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
    //_discoverDevList = [NSMutableArray new];
    //_connectedDevList = [NSMutableArray new];
      self.currentPeripheral = nil;
      self.ppaValue = nan(NULL);
      self.volValue = nan(NULL);
      self.ppaMax = -100000.0;
      self.volMax = -100000.0;
      _bleQueue =  dispatch_queue_create("kCH2OBLEQueue", DISPATCH_QUEUE_SERIAL);
      self.bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:_bleQueue];
  }
  return self;
}

- (BOOL)start {
  if (self.bleManager.state == CBCentralManagerStatePoweredOn) {
    [self.bleManager scanForPeripheralsWithServices:nil options:nil];
    return YES;
  }
  return NO;
}

- (void)stop {
    [self.bleManager stopScan];
    self.ppaValue = nan(NULL);
    self.volValue = nan(NULL);
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral {
    [self.bleManager connectPeripheral:peripheral options:nil];
}

- (void) detachPeripheral {
    if (self.currentPeripheral) {
        self.currentPeripheral.delegate = nil;
    }
    self.currentPeripheral = nil;
    self.ppaValue = nan(NULL);
    self.volValue = nan(NULL);
}

- (void) attachPeripheral:(CBPeripheral *)peripheral {
    self.currentPeripheral = peripheral;
    self.currentPeripheral.delegate = self;
    CBUUID * uuid = [CBUUID UUIDWithString:kUartServiceUUID];
    NSArray * services = @[uuid];
    [self.currentPeripheral discoverServices: services];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBCentralManagerState state = [central state];
    NSLog(@"centerManagerDidUpdateState -> state (%ld)\n", (long)state);
    switch (state) {
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnsupported:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStatePoweredOff:
            break;
        case CBCentralManagerStatePoweredOn: {
            //CBUUID * uuid = [CBUUID UUIDWithString:@"FFE0"];
            [self.bleManager scanForPeripheralsWithServices:nil options:nil];
            break;
        }
        default:
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"discover peripheral: %@ uuid:%@", peripheral.name, peripheral.identifier);
    if (peripheral.state == CBPeripheralStateDisconnected) { // 未连接

        [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                            object:nil
                                                          userInfo:@{@"type":kBLEPeripheralDiscoveryNotify,
                                                               @"peripheral":peripheral}];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state == CBPeripheralStateConnected) {
        if ([peripheral.name containsString:@"TAv22u"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                                object:nil
                                                              userInfo:@{@"type":kBLEPeripheralConnectedNotify,
                                                                         @"peripheral":peripheral}];
            [self attachPeripheral:peripheral];
        } else {
            [central cancelPeripheralConnection: peripheral];
        }
        
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self detachPeripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                        object:nil
                                                      userInfo:@{@"type":kBLEPeripheralDisconnectNotify,
                                                           @"peripheral":peripheral}];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

    [self detachPeripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                        object:nil
                                                      userInfo:@{@"type":kBLEPeripheralDisconnectNotify,
                                                           @"peripheral":peripheral}];
}


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices -> error:%@", error);
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@", service.UUID);
        [peripheral discoverCharacteristics:nil
                                      forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService error: %@", error ? error.localizedDescription : @"null");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Service UUID: %@; Characteristic found with UUID: %@\n", service.UUID, characteristic.UUID);
        //[peripheral readValueForCharacteristic:characteristic];
        [peripheral setNotifyValue: YES forCharacteristic: characteristic] ;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"update value, error: %@", error ? error.localizedDescription : @"null");
    }
    NSData * data = characteristic.value;
    if (data && data.length == 9) {
     //   NSLog(@"%@", data);
        uint8_t * ptr = (uint8_t *)data.bytes;
        if (ptr[0] == 0xff && ptr[1] == 0x17) {
            uint16_t value = (ptr[4] << 8) | ptr[5];
            NSLog(@"value: %d", value);
            self.ppaValue = ((double)value) / 1000.0;
            self.volValue = self.ppaValue * 30.0 / 22.4;
            if (self.ppaValue > self.ppaMax) {
                self.ppaMax = self.ppaValue;
            }
            if (self.volValue > self.volMax) {
                self.volMax = self.volValue;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                                object:nil
                                                              userInfo:@{@"type":kBLEPeripheralRecvValueNotify,
                                                                         @"peripheral":peripheral,
                                                                         @"value":@(value)
                                                                         }];
        }
    }
}

@end
