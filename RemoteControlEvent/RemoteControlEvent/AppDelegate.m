//
//  AppDelegate.m
//  RemoteControlEvent
//
//  Created by Buzz on 22/6/16.
//  Copyright © 2016 Buzz. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate () <AVAudioPlayerDelegate>
@property(nonatomic, strong) AVAudioPlayer *audioPlayer; //播放器
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  /*
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];

  MainViewController *vc =
      [[MainViewController alloc] initWithNibName:@"MainViewController"
                                           bundle:nil];
  self.window.rootViewController = vc;
  [self.window makeKeyAndVisible];
  */

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.

  //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  //[self becomeFirstResponder];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.

  //[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  //[self resignFirstResponder];

  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [self becomeFirstResponder];
  [self play];
  [self stop];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (void)routeChange:(NSNotification *)notification {
  NSDictionary *dic = notification.userInfo;
  int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
  //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
  if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
    AVAudioSessionRouteDescription *routeDescription =
        dic[AVAudioSessionRouteChangePreviousRouteKey];
    AVAudioSessionPortDescription *portDescription =
        [routeDescription.outputs firstObject];

    NSLog(@"port:%@", portDescription.portType);
    //原设备为耳机则暂停
    if ([portDescription.portType isEqualToString:@"Headphones"]) {
      [self pause];
    }
  }
}

/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
- (AVAudioPlayer *)audioPlayer {
  if (!_audioPlayer) {
    /*下载文件目录*/
    // NSArray *pathForDirectories =
    // NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    // NSUserDomainMask, YES);
    // NSString *documentPath = [pathForDirectories objectAtIndex:0];
    // NSString *urlStr = [documentPath
    // stringByAppendingString:@"/f03_cc.mp3"];

    //程序资源目录
    NSString *resourceBundle =
        [[NSBundle mainBundle] pathForResource:@"myBundle" ofType:@"bundle"];
    NSString *urlStr =
        [[NSBundle bundleWithPath:resourceBundle] pathForResource:@"app"
                                                           ofType:@"mp3"
                                                      inDirectory:@"mp3"];

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    NSError *error = nil;
    //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
    _audioPlayer =
        [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //设置播放器属性
    _audioPlayer.numberOfLoops = 0; //设置为0不循环
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay]; //加载音频文件到缓存
    if (error) {
      NSLog(@"初始化播放器过程发生错误,错误信息:%@",
            error.localizedDescription);
      return nil;
    }
    //设置后台播放模式
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    //添加通知，拔出耳机后暂停播放
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(routeChange:)
               name:AVAudioSessionRouteChangeNotification
             object:nil];
  }
  return _audioPlayer;
}

/**
 *  play
 */
- (void)play {
  if (![self.audioPlayer isPlaying]) {
    [self.audioPlayer play];
  }
}

/**
 *  pause
 */
- (void)pause {
  if ([self.audioPlayer isPlaying]) {
    [self.audioPlayer pause];
  }
}

/**
 *  stop
 */
- (void)stop {
  if ([self.audioPlayer isPlaying]) {
    [self.audioPlayer stop];
  }
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
  NSLog(@"received event!");
  if (event.type == UIEventTypeRemoteControl) {
    switch (event.subtype) {
    case UIEventSubtypeRemoteControlTogglePlayPause: {
      NSLog(@"TooglePlayPause");
      if ([_audioPlayer isPlaying]) {
        NSLog(@"pause");
        [self pause];
      } else {
        NSLog(@"play");
        [self play];
      }
      break;
    }
    case UIEventSubtypeRemoteControlPlay: {
      NSLog(@"Play");
      break;
    }
    case UIEventSubtypeRemoteControlPause: {
      NSLog(@"Pause");
      break;
    }
    default:
      break;
    }
  }
}

#pragma mark - 播放器代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
  NSLog(@"playing finished...");
  //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
  //[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

@end
