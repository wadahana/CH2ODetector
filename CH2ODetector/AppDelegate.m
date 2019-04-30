//
//  AppDelegate.m
//  CH2ODetector
//
//  Created by 吴昕 on 15/8/16.
//  Copyright (c) 2015年 wadahana. All rights reserved.
//

#import "AppDelegate.h"
#import "CH2ONavigationController.h"
#import "CH2ONavigationManager.h"
#import "CH2ORootViewController.h"
#import "CH2OBLEManager.h"
#import "CH2ODBHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) AVAudioPlayer * player;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

@implementation AppDelegate {
    BOOL _recording;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
    CH2ORootViewController *controller = [[CH2ORootViewController alloc] initWithNibName:@"CH2ORootViewController" bundle:nil];
  
    CH2ONavigationController *navigationController = [[CH2ONavigationController alloc] initWithRootViewController:controller];
  
    [[CH2ONavigationManager shareInstance] setNavigationController:navigationController];
  
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    self.timeInterval = 20;
    _recording = NO;
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"beginBackgroundTaskWithExpirationHandler ->");
        if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
    double remainTime = application.backgroundTimeRemaining;
    if (remainTime < 1000000000) {
        NSLog(@"applicationDidEnterBackground -> remain time(%0.3lf)\n", remainTime);
    } else {
        NSLog(@"applicationDidEnterBackground -> remain time(+inf)\n");
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)onTimer:(id)timer {
    double ppa = [CH2OBLEManager shareInstance].ppaValue;
    double vol = [CH2OBLEManager shareInstance].volValue;
    NSLog(@"[AppDelegate onTimer:] -> ppaValue: %0.4lf; volValue: %0.4lf\n", ppa, vol);
    if (![CH2OBLEManager shareInstance].currentPeripheral) {
        [self setRecording:NO];
        [self.player stop];
        return;
    }
    if (_recording && !isnan(ppa) && !isnan(vol)) {
        [[CH2ODBHelper shareInstance] writePpa:ppa
                                     ppaMax:[CH2OBLEManager shareInstance].ppaMax
                                        vol:vol
                                     volMax:[CH2OBLEManager shareInstance].volMax];
    }
    [CH2OBLEManager shareInstance].ppaMax = -1000.0;
    [CH2OBLEManager shareInstance].volMax = -1000.0;
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        NSTimeInterval remainTime = [UIApplication sharedApplication].backgroundTimeRemaining;
        if (remainTime < 1000000000) {
            NSLog(@"[AppDelegate onTimer:] -> remainTime(%0.3lf)\n", remainTime);
        } else {
            NSLog(@"[AppDelegate onTimer:] -> remainTime(+inf)\n");
        }
        if (remainTime < self.timeInterval) {
            [self setRecording:NO];
        }
    }
}


- (BOOL) recording {
    return _recording;
}

- (void) setRecording : (BOOL) recording {
    if (_recording != recording) {
        _recording = recording;
        if (recording) {
            NSLog(@"start record.");
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
            // create recording timer.
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                          target:self
                                                        selector:@selector(onTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
            [self.timer fire];
            [self playBackgroundMusic];
            NSLog(@"recording now, play music to keep app run in background!");
        } else {
            // destory recording timer.
            NSLog(@"stop record.");
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
        }
    }
}

- (void) playBackgroundMusic {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    NSString * resourcePath = [ [NSBundle mainBundle] resourcePath];
    NSString * path = [resourcePath stringByAppendingPathComponent : @"bgm.mp3"];
    NSLog(@"background music file : %@\n", path);
    
    NSError * error = nil;
    NSURL * url = [[NSURL alloc] initWithString : path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (self.player == nil) {
        NSLog(@"[AppDelegate playBackgroundMusic] -> player error : %@", error);
        return;
    }
    [self.player setVolume:1.0];
    self.player.numberOfLoops = -1;
    
    [self.player prepareToPlay];
    [self.player play];
}
@end
