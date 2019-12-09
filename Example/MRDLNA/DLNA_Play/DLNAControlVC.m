//
//  DLNAControlVC.m
//  YSTThirdSDK_Example
//
//  Created by MccRee on 2018/2/11.
//  Copyright © 2018年 MQL9011. All rights reserved.
//

#import "DLNAControlVC.h"
#import <MRDLNA/MRDLNA.h>


//屏幕高度
#define H [UIScreen mainScreen].bounds.size.height
#define W [UIScreen mainScreen].bounds.size.width


@interface DLNAControlVC ()<DLNADelegate>
{
     BOOL _isPlaying;
}

@property(nonatomic,strong) MRDLNA *dlnaManager;

@end

@implementation DLNAControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
    [self.dlnaManager startDLNA];

     _isPlaying = YES;
}

#pragma mark -播放控制

- (IBAction)getjjjjj:(id)sender {
    [self.dlnaManager getPositionInfo];
}
/**
 退出
 */
- (IBAction)closeAction:(id)sender {
    [self.dlnaManager endDLNA];
}


/**
 播放/暂停
 */
- (IBAction)playOrPause:(id)sender {
    if (_isPlaying) {
        [self.dlnaManager dlnaPause];
    }else{
        [self.dlnaManager dlnaPlay];
    }
    _isPlaying = !_isPlaying;
}


/**
 进度条
 */
- (IBAction)seekChanged:(UISlider *)sender{
    NSInteger sec = sender.value * 60 * 60;
    NSLog(@"播放进度条======>: %zd",sec);
    [self.dlnaManager seekChanged:sec];
}

/**
 音量
 */
- (IBAction)volumeChange:(UISlider *)sender {
    NSString *vol = [NSString stringWithFormat:@"%.f",sender.value * 100];
    NSLog(@"音量========>: %@",vol);
    [self.dlnaManager volumeChanged:vol];
}


/**
 切集
 */
- (IBAction)playNext:(id)sender {
    NSString *testVideo = @"http://huoke-private-1254282420.cos.ap-chengdu.myqcloud.com/2019/09/16/08a6b3bd-4d2c-40e2-99c8-926eb57bb5da.mp4?sign=q-sign-algorithm%3Dsha1%26q-ak%3DAKIDCJG2e67TN6kR3mA5fDve2X0Ndnwz5mV8%26q-sign-time%3D1575279842%3B1575351842%26q-key-time%3D1575279842%3B1575351842%26q-header-list%3D%26q-url-param-list%3D%26q-signature%3Deb42fc67c0767daa74e552c408908bb66f4119e7";
    [self.dlnaManager playTheURL:testVideo];
}

#pragma mark - 代理

- (void)upnpPauseResponse {
    NSLog(@"暂停了");
}

- (void)dlnaStartPlay{
    NSLog(@"投屏成功 开始播放");
}

/**停止投屏*/
- (void)upnpStopResponse {
    NSLog(@"停止投屏");
}

/**跳转响应*/
- (void)upnpSeekResponse {
    NSLog(@"跳转响应");
}

/**设置音量响应*/
- (void)upnpSetVolumeResponse {
    NSLog(@"设置音量响应");
}

/**获取音频信息*/
- (void)upnpGetVolumeResponse:(NSString *)volume {
    NSLog(@"%@", volume);
}

/**获取播放进度*/
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info {
    NSLog(@"进度进度==========");
    NSLog(@"relTime===%f",info.relTime);
    NSLog(@"absTime===%f",info.absTime);
    NSLog(@"trackDuration===%f",info.trackDuration);
    NSLog(@"进度进度==========");
}


@end
