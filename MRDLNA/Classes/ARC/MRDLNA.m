//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
// 

#import "MRDLNA.h"
#import "StopAction.h"

@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic,copy) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;

@end

@implementation MRDLNA

+ (MRDLNA *)sharedMRDLNAManager{
    static MRDLNA *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 5;
        self.upd.delegate = self;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

/**
 ** DLNA投屏
 */
- (void)startDLNA{
    [self initCLUPnPRendererAndDlnaPlay];
}
/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
-(void)initCLUPnPRendererAndDlnaPlay{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
}
/**
 退出DLNA
 */
- (void)endDLNA{
    [self.render stop];
}

/**
 播放
 */
- (void)dlnaPlay{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause{
    [self.render pause];
}

/**
 搜设备
 */
- (void)startSearch{
    [self.upd start];
}


/**
 获取播放进度
 */
- (void)getPositionInfo{
    [self.render getPositionInfo];
}


/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}


/**
 播放进度条
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}


/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark - 协议

/**搜索回调*/
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(searchDLNAResult:)]) {
        [self.delegate searchDLNAResult:[deviceMarr copy]];
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchEnd {
    if ([self.delegate respondsToSelector:@selector(searchEnd)]) {
          [self.delegate searchEnd];
      }
}

/**搜索错误*/
- (void)upnpSearchErrorWithError:(NSError *)error{
    
}

#pragma mark CLUPnPResponseDelegate

#pragma mark required

/**设置url响应*/
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

/**获取播放状态*/
- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

#pragma mark optional

/**播放响应*/
- (void)upnpPlayResponse{
    if ([self.delegate respondsToSelector:@selector(dlnaStartPlay)]) {
        [self.delegate dlnaStartPlay];
    }
}

/**
 未定义的响应/错误
 
 @param resXML  响应XML
 @param postXML 请求的动作
 */
- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML {
    
}

/**暂停响应*/
- (void)upnpPauseResponse {
    if ([self.delegate respondsToSelector:@selector(upnpPauseResponse)]) {
        [self.delegate upnpPauseResponse];
    }
}

/**停止投屏*/
- (void)upnpStopResponse {
    if ([self.delegate respondsToSelector:@selector(upnpStopResponse)]) {
        [self.delegate upnpStopResponse];
    }
}

/**跳转响应*/
- (void)upnpSeekResponse {
    if ([self.delegate respondsToSelector:@selector(upnpSeekResponse)]) {
        [self.delegate upnpSeekResponse];
    }
}

/**以前的响应*/
- (void)upnpPreviousResponse {
    
}

/**下一个响应*/
- (void)upnpNextResponse {
    
}

/**设置音量响应*/
- (void)upnpSetVolumeResponse {
    if ([self.delegate respondsToSelector:@selector(upnpSetVolumeResponse)]) {
        [self.delegate upnpSetVolumeResponse];
    }
}

/**设置下一个url响应*/
- (void)upnpSetNextAVTransportURIResponse {
    
}

/**获取音频信息*/
- (void)upnpGetVolumeResponse:(NSString *)volume {
    if ([self.delegate respondsToSelector:@selector(upnpGetVolumeResponse:)]) {
        [self.delegate upnpGetVolumeResponse:volume];
    }
}

/**获取播放进度*/
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info {
    if ([self.delegate respondsToSelector:@selector(upnpGetPositionInfoResponse:)]) {
        [self.delegate upnpGetPositionInfoResponse:info];
    }
}

#pragma mark Set&Get
- (void)setSearchTime:(NSInteger)searchTime{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}
@end
