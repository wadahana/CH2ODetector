//
//  CH2ODBHelper.m
//  CH2ODetector
//
//  Created by 吴昕 on 2018/5/20.
//  Copyright © 2018 wadahana. All rights reserved.
//

#import "CH2ODBHelper.h"
#import "CH2OBLEManager.h"
#import "FMDB.h"

@implementation CH2ODBHelper {
    FMDatabase * _fmdb;
}

+ (instancetype)shareInstance {
    static CH2ODBHelper *sInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sInstance = [[CH2ODBHelper alloc] init];
    });
    return sInstance;
}

- (instancetype) init {
    if (self) {
        NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        self.dbPath = [docPath stringByAppendingPathComponent:@"ch2o.db"];
        NSLog(@"dbPath = %@", self.dbPath);
        _fmdb = [FMDatabase databaseWithPath:self.dbPath];
        if (_fmdb && [_fmdb open]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
            [_fmdb setDateFormat:dateFormatter];
            [self createTable];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBLEManagerNotification
                                                                object:nil
                                                              userInfo:@{@"type":kBLESQLiteFileOpenFail}];
        }
    }
    return self;
}

- (void) start {
    NSLog(@"CH2ODBHelper start!");
}

- (BOOL) removeAllRecords {
    if (_fmdb) {
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ ;", @"ch2o_monitor"];
        [_fmdb executeUpdate:sql];
    }
    return NO;
}

- (BOOL) createTable {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ("
                     "timestamp Date PRIMARY KEY, "
                     "ppa REAL NOT NULL, "
                     "vol REAL NOT NULL, "
                     "ppaMax REAL NOT NULL, "
                     "volMax REAL NOT NULL);", @"ch2o_monitor"];
    if ([_fmdb executeUpdate:sql]) {
        NSLog(@"%@ 建表成功", @"ch2o_monitor");
        return YES;
    } else {
        NSLog(@"%@ 建表失败", @"ch2o_monitor");
        return NO;
    }
}

- (BOOL) writePpa:(double) ppa
           ppaMax:(double) ppaMax
              vol:(double) vol
           volMax:(double)volMax {
    NSDate * now = [NSDate new];
    if (_fmdb) {
        NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT INTO %@",@"ch2o_monitor"];
        NSMutableString *keys = [NSMutableString stringWithFormat:@" ("];
        NSMutableString *values = [NSMutableString stringWithFormat:@" ( "];
        NSMutableArray *arguments = [[NSMutableArray alloc] init];
        
        [keys appendString:@"timestamp,"];
        [values appendString:@"?,"];
        [arguments addObject:now];
        
        [keys appendString:@"ppa,"];
        [values appendString:@"?,"];
        [arguments addObject:@(ppa)];
        
        [keys appendString:@"vol,"];
        [values appendString:@"?,"];
        [arguments addObject:@(vol)];
        
        [keys appendString:@"ppaMax,"];
        [values appendString:@"?,"];
        [arguments addObject:@(ppaMax)];
        
        [keys appendString:@"volMax,"];
        [values appendString:@"?,"];
        [arguments addObject:@(volMax)];
        
        [keys appendString:@")"];
        [values appendString:@")"];
        [query appendFormat:@" %@ VALUES%@",
            [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
            [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
        
        NSLog(@"write timestamp(%@), ppa(%0.4lf), ppaMax(%0.4lf)", now, ppa, ppaMax);
        return [_fmdb executeUpdate:query withArgumentsInArray:arguments];
    }
    return NO;
}

@end
