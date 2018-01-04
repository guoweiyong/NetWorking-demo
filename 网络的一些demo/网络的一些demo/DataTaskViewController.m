//
//  DataTaskViewController.m
//  网络的一些demo
//
//  Created by x on 2017/10/26.
//  Copyright © 2017年 HLB. All rights reserved.
//

#define GYFilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.mp4"]

//获取当前下载文件的长度
#define downloadLegth [[[[NSFileManager defaultManager] attributesOfItemAtPath:GYFilePath error:nil] objectForKey:NSFileSize] integerValue]

#import "DataTaskViewController.h"


/** 图片地址 */
static NSString *const downloadImageURLS = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508390069305&di=f2732d0c03266768599f37d2e832746f&imgtype=0&src=http%3A%2F%2Fpic20.photophoto.cn%2F20110925%2F0010023291781194_b.jpg";

/** 视频地址 */
static NSString *const downloadVideoURLS = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";


@interface DataTaskViewController ()<NSURLSessionDataDelegate>

/** session */
@property (nonatomic, strong) NSURLSession *session;

/** 下载任务对象 */
@property (nonatomic, strong) NSURLSessionDataTask *task;

/** 写文件流 */
@property (nonatomic, strong) NSOutputStream *stream;

/** 文件总长度 */
@property (nonatomic, assign)NSInteger totalLength;

@end

@implementation DataTaskViewController


- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];//在那个线程调用代理方法
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:GYFilePath append:YES];
    }
    return _stream;
}


- (void)sessionDelegateDownload {
    NSURL *url = [NSURL URLWithString:downloadVideoURLS];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //设置请求头告诉服务器 ,我们从哪里下载数据
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",downloadLegth];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    
    //启动线程任务
    [task resume];
    
    self.task = task;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"-=====%@ ======%zd",GYFilePath,downloadLegth);
    //[[NSFileManager defaultManager] removeItemAtPath:GYFilePath error:nil];
}

- (IBAction)startDownload:(id)sender {
    [self sessionDelegateDownload];
}

- (IBAction)pauseDownload:(id)sender {
    [self.task suspend];
}

- (IBAction)resuemDownload:(id)sender {
    [self.task resume];
}

#pragma mark -- <NSURLSessionDataDelegate>

/**
 接受服务器的响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"====%@ =====%@",response,[NSThread currentThread]);
    
    
    //1.准备接受数据,开启写入流
    [self.stream open];
    
    //2.获取文件总长度
    self.totalLength = [[[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Length"] integerValue] + downloadLegth;
    
    //允许接受服务器的数据(开始接受数据)
    completionHandler(NSURLSessionResponseAllow);
}

/**
 接收到服务器的数据(可能被调用很多次)
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    //收到数据之后写入数据
    [self.stream write:[data bytes] maxLength:data.length];
    
    
    NSLog(@"download----- %f",1.0 * downloadLegth / self.totalLength);
}

/**
 请求成功或则失败(如果失败,error有值)
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s ======%@",__FUNCTION__,[NSThread currentThread]);
    
    [self.stream close];
}

@end
