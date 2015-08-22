//
//  CH2OBLEManager.h
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kBLEManagerNotification (@"kBLEManagerNotification")

@interface CH2OBLEManager : NSObject


+ (instancetype)shareInstance;
- (BOOL)start;
- (void)stop;
- (void)connectToPeripheral:(CBPeripheral*)peripheral;
- (NSArray*)discoverDevList;
- (NSArray*)connectedDevList;
- (CBPeripheral*)currentPeripheral;
- (void)setCurrentPeripheral:(CBPeripheral *)peripheral;
@end
