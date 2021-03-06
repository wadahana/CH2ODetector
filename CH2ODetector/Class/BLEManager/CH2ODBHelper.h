//
//  CH2ODBHelper.h
//  CH2ODetector
//
//  Created by 吴昕 on 2018/5/20.
//  Copyright © 2018 wadahana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CH2ODBHelper : NSObject

@property (nonatomic, copy) NSString * dbPath;

+ (instancetype)shareInstance;

- (void) start;

- (BOOL) writePpa:(double) ppa ppaMax:(double) ppaMax vol:(double) vol volMax:(double)volMax;

- (BOOL) removeAllRecords;
@end
