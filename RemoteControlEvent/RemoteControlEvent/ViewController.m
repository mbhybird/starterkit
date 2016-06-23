//
//  ViewController.m
//  RemoteControlEvent
//
//  Created by Buzz on 22/6/16.
//  Copyright © 2016 Buzz. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioPlayerDelegate>
@property(nonatomic, strong) AVAudioPlayer *audioPlayer; //播放器
@end

@implementation ViewController

- (void)viewDidLoad {
  //[self downloadFile];
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  //[self.audioPlayer play];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
 *  播放音频
 */
- (void)play {
  if (![self.audioPlayer isPlaying]) {
    [self.audioPlayer play];
  }
}

/**
 *  暂停播放
 */
- (void)pause {
  if ([self.audioPlayer isPlaying]) {
    [self.audioPlayer pause];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
  [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
  [self resignFirstResponder];
  [super viewWillDisappear:animated];
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

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:AVAudioSessionRouteChangeNotification
              object:nil];
}

#pragma mark - 播放器代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
  NSLog(@"音乐播放完成...");
  //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
  //[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)downloadFile {
  NSURL *url = [NSURL
      URLWithString:@"http://arts.things.buzz/download/mah/audio/f03_cc.mp3"];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [session
      dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response,
                            NSError *error) {
          // 输出返回的状态码，请求成功的话为200
          [self showResponseCode:response];
          NSArray *pathForDirectories = NSSearchPathForDirectoriesInDomains(
              NSDocumentDirectory, NSUserDomainMask, YES);
          NSString *documentPath = [pathForDirectories objectAtIndex:0];
          NSString *fileName =
              [documentPath stringByAppendingPathComponent:@"f03_cc.mp3"];
          [data writeToFile:fileName atomically:YES];
        }];
  // 使用resume方法启动任务
  [dataTask resume];
}

/* 输出http响应的状态码 */
- (void)showResponseCode:(NSURLResponse *)response {
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  NSInteger responseStatusCode = [httpResponse statusCode];
  NSLog(@"%s", __FUNCTION__);
  NSLog(@"%d", responseStatusCode);
}

@end
