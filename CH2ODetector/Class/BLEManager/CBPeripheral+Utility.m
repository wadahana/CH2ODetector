//
//  CBPeripheral+Utility.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/22.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "CBPeripheral+Utility.h"
#import "objc/runtime.h"

static char sConnectedBlockKey;

@implementation CBPeripheral (Utility)

@dynamic connectedBlock;

- (ConnectedBlock_t)connectedBlock {
  ConnectedBlock_t block = objc_getAssociatedObject(self, &sConnectedBlockKey);
  return block;
}

- (void)setConnectedBlock:(ConnectedBlock_t)block {
  objc_setAssociatedObject(self, &sConnectedBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
