//
//  CBPeripheral+Utility.h
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/22.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^ConnectedBlock_t)();

@interface CBPeripheral (Utility)
@property (nonatomic, strong) ConnectedBlock_t connectedBlock;


@end
