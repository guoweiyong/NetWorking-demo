//
//  URLSessionViewController.m
//  网络的一些demo
//
//  Created by x on 2017/10/20.
//  Copyright © 2017年 HLB. All rights reserved.
//

#import "URLSessionViewController.h"

/** 图片地址 */
static NSString *const downloadImageURLS = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508390069305&di=f2732d0c03266768599f37d2e832746f&imgtype=0&src=http%3A%2F%2Fpic20.photophoto.cn%2F20110925%2F0010023291781194_b.jpg";

/** 视频地址 */
static NSString *const downloadVideoURLS = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";

@interface URLSessionViewController ()<NSURLSessionDataDelegate>

@end

@implementation URLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self sessionDownload];
    [self sessionDelegate];
}

- (void)sessionDownload {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:downloadVideoURLS];
    
//    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//    }];
    NSURLSessionDownloadTask *task  =[session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"-----文件下载完毕----%@",location);
        // 文件将来存放的真实路径
        NSString *file = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        
        // 剪切location的临时文件到真实路径
        NSFileManager *mgr = [NSFileManager defaultManager];
        [mgr moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
        
        NSLog(@"file=======%@",file);
    }];
    
    //启动任务
    [task resume];
}


- (void)sessionDelegate {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];//在那个线程调用代理方法
    NSURL *url = [NSURL URLWithString:downloadImageURLS];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    //启动线程任务
    [task resume];
}

#pragma mark -- <NSURLSessionDataDelegate>

/**
 接受服务器的响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"====%@ =====%@",response.suggestedFilename,[NSThread currentThread]);
    completionHandler(NSURLSessionResponseAllow);
}

/**
 接收到服务器的数据(可能被调用很多次)
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%s   =====%@",__func__,[NSThread currentThread]);
}

/**
 请求成功或则失败(如果失败,error有值)
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s ======%@",__FUNCTION__,[NSThread currentThread]);
}


@end
