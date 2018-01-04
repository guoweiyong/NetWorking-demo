//
//  DownloadViewController.m
//  网络的一些demo
//
//  Created by x on 2017/10/20.
//  Copyright © 2017年 HLB. All rights reserved.
//

#import "DownloadViewController.h"
#import <AFNetworking.h>
#import "Reachability.h"

/** 图片地址 */
static NSString *const downloadImageURLS = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508390069305&di=f2732d0c03266768599f37d2e832746f&imgtype=0&src=http%3A%2F%2Fpic20.photophoto.cn%2F20110925%2F0010023291781194_b.jpg";

/** 视频地址 */
static NSString *const downloadVideoURLS = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";

@interface DownloadViewController ()<NSURLSessionDownloadDelegate>

/** 下载任务对象 */
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/** 保存上次的下载信息 */
@property (nonatomic, strong) NSData *resumeData;

/** session */
@property (nonatomic, strong) NSURLSession *session;

/** 系统网络监控对象 */
@property (nonatomic, strong) Reachability *reachablity;
@end

@implementation DownloadViewController

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];//在那个线程调用代理方法
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)startDownload:(id)sender {
    [self sessionDelegateDownload];
}

- (IBAction)pauseDownload:(id)sender {
    //[self.task suspend];
    //这是取消任务 一但取消任务是不能够恢复下载的
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeData = resumeData;
        //这个文件中包含这下载的一些信息,如果存到沙河中,下次启动程序可以检测,然后在开始下载 ,这样就可以做到离线下载
    }];
    
}
- (IBAction)resuemDownload:(id)sender {
    //[self.task resume];
    self.task = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.task resume];
}


- (void)sessionDelegateDownload {
    NSURL *url = [NSURL URLWithString:downloadVideoURLS];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];

    //启动线程任务
    [task resume];
    
    self.task = task;
}
#pragma mark -- NSURLSessionDownloadDelegate

/**
 (用于断点下载的方法)数据下载失败会调用这个方法 ,方法中含有已近下载完成的数据 可以缓存起来,下次直接从这个地方下载起
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%s",__FUNCTION__);
}

/**
 每当写入数据到临时文件时,就会调用这个方法
 totalBytesExpectedToWrite: 文件的总大小
 totalBytesWritten: 已近写入到大小
 bytesWritten: 当前的大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"totalBytesExpectedToWrite====%f",1.0 * totalBytesWritten/totalBytesExpectedToWrite);
    
}

/**
 数据下载完成就会调用一次
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"didFinishDownloadingToURL");
    // 文件将来存放的真实路径
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    // 剪切location的临时文件到真实路径
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
}

/**
 任务完成
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"didCompleteWithError");
    //中途事变,保存恢复数据
    self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
}







#pragma mark -- 苹果官方自带检测网络方法
- (void)appleMonting {
    
    //监控网络
    self.reachablity = [Reachability reachabilityForInternetConnection];
    [self.reachablity startNotifier];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(systemDetectionNetwork:) name:kReachabilityChangedNotification object:nil];
}

- (void)systemDetectionNetwork:(NSNotification *)noti {
    NSLog(@"=====%zd   =====%@",[Reachability reachabilityForLocalWiFi].currentReachabilityStatus,noti.object);
    //    Reachability *currentReach = [noti object];
    //    NSParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    if (self.reachablity.currentReachabilityStatus == 1) {
        NSLog(@"是wife");
    }else if (self.reachablity.currentReachabilityStatus == 2) {
        NSLog(@"手机自带网络...");
    }else {
        NSLog(@"网络有问题");
    }
}


- (void)afnDownload {
    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    [manager downloadTaskWithRequest:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    //
    //    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
    //
    //    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
    //
    //    }];
    //
    //    [manager downloadTaskWithResumeData:<#(nonnull NSData *)#> progress:^(NSProgress * _Nonnull downloadProgress) {
    //
    //    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
    //
    //    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
    //
    //    }];
}

#pragma mark -- 使用AFNetWorking来监听网络情况
- (void)DetectionNetwork {
    //1.创建一个网络监听的对象
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    
    //2.调用start方法来开始对网络状态进行监控
    [networkManager startMonitoring];
    
    //3.设置网络变化时调用的block
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                //未知网络
                NSLog(@"未知网络");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                //无法联网
                NSLog(@"无法联网");
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                //手机自带网络
                NSLog(@"当前使用的是2g/3g/4g网络");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //WIFI
                NSLog(@"当前在WIFI网络下");
            }
                
        }
        
    }];
}

- (void)DetectionNetwork1 {
    //1.创建一个网络监听的对象
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    
    //2.调用start方法来开始对网络状态进行监控
    [networkManager startMonitoring];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)netWorkChanged:(NSNotification *)noti {
    NSInteger status = [noti.userInfo[AFNetworkingReachabilityNotificationStatusItem] intValue];
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
        {
            //未知网络
            NSLog(@"未知网络");
        }
            break;
        case AFNetworkReachabilityStatusNotReachable:
        {
            //无法联网
            NSLog(@"无法联网");
        }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            //手机自带网络
            NSLog(@"当前使用的是2g/3g/4g网络");
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            //WIFI
            NSLog(@"当前在WIFI网络下");
        }
            
    }
    
}



@end
