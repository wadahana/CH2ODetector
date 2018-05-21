//
//  CH2OBLEManager.h
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kBLEManagerNotification           (@"kBLEManagerNotification")
#define kBLEPeripheralDiscoveryNotify     (@"kPeripheralDiscoverNotify")
#define kBLEPeripheralConnectedNotify     (@"kBLEPeripheralConnected")
#define kBLEPeripheralDisconnectNotify    (@"kBLEPeripheralDisconnectedNotify")
#define kBLEPeripheralRecvValueNotify     (@"kBLEPeripheralRecvNotify")
#define kBLESQLiteFileOpenFail            (@"kBLESQLiteFileOpenFail")
@interface CH2OBLEManager : NSObject

@property (nonatomic, assign) double ppaValue;
@property (nonatomic, assign) double volValue;

+ (instancetype)shareInstance;
- (BOOL)start;
- (void)stop;
- (void)connectToPeripheral:(CBPeripheral*)peripheral;
//- (NSArray*)discoverDevList;
//- (NSArray*)connectedDevList;
- (CBPeripheral*)currentPeripheral;
- (void)attachPeripheral:(CBPeripheral *)peripheral;

@end
