//
//  YYDownloadManager.m
//  网络的一些demo
//
//  Created by x on 2017/10/27.
//  Copyright © 2017年 HLB. All rights reserved.
//

//文件在沙河中的路径
#define YYFilePath(key) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:key.md5String]

//已下载文件的大小
#define YYdownloadFileSize(filePath) [[[[NSFileManager defaultManager] attributesOfItemAtPath:YYFilePath(filePath) error:nil] objectForKey:NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define YYTotalLengthFullpath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"totalLength.plist"]

#import "YYDownloadManager.h"
#import "NSString+Hash.h"

typedef void(^YYSessionTaskProgressBlock)(CGFloat progress);

typedef void(^YYSessionTaskCompleteHandleBlock)(NSError *error, NSString *filePath);


@interface YYDownloadManager ()<NSURLSessionDataDelegate>

/** session */
@property (nonatomic, strong) NSURLSession *YYSession;

/** 写文件流 */
@property (nonatomic, strong) NSOutputStream *stream;

/** 文件总长度 */
@property (nonatomic, assign)NSInteger totalLength;

/** 保存当前下载文件的url */
@property (nonatomic, strong) NSString *currentFileURL;

/** 传递下载进度block */
@property (nonatomic,copy) YYSessionTaskProgressBlock progressBlock;

/** 下载完成调用的block */
@property (nonatomic,copy) YYSessionTaskCompleteHandleBlock completeHandleBlock;

/** 下载任务task */
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end

@implementation YYDownloadManager

- (NSURLSession *)YYSession {
    if (!_YYSession) {
        _YYSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];//在那个线程调用代理方法
    }
    return _YYSession;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:YYFilePath(self.currentFileURL) append:YES];
    }
    return _stream;
}

- (NSURLSessionDataTask *)task {
    if (!_task) {
        //0.判断文件有没有下载过
        NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile:YYTotalLengthFullpath][self.currentFileURL.md5String] integerValue];
        
        if (YYdownloadFileSize(self.currentFileURL) == totalLength  && totalLength) {
            NSLog(@"------文件已经下载过了");
            self.progressBlock(1.0);
            self.completeHandleBlock(nil,YYFilePath(self.currentFileURL.md5String));
            return nil;
        }
        
        //1.创建一个请求
        NSURL *fileURL = [NSURL URLWithString:self.currentFileURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
        
        //2.设置文件的请求头,告诉服务器用户需要重文件的那个地方下载
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",YYdownloadFileSize(self.currentFileURL)];
        [request setValue:range  forHTTPHeaderField:@"Range"];
        
        //3.创建一个任务
        _task = [self.YYSession dataTaskWithRequest:request];

    }
    return _task;
}


static YYDownloadManager *_manager;
+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    
    return _manager;
}


#pragma mark -

- (void)download:(NSString *)url progress:(void (^)(CGFloat))progressBlock completeHandle:(void (^)(NSError * _Nullable, NSString * _Nullable))completeBlock {
    
    self.currentFileURL = url;
    self.progressBlock = progressBlock;
    self.completeHandleBlock = completeBlock;
    
    //开始下载
    [self resuemDownload];
}

- (void)resuemDownload {
    [self.task resume];
}

- (void)pauseDownload {
    [self.task suspend];
}
#pragma mark -- <NSURLSessionDataDelegate>

/**
 接受服务器的相应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    //0.开启写入流
    [self.stream open];
    
    //1.获取文件的总长度
    self.totalLength = [[[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Length"] integerValue] + YYdownloadFileSize(self.currentFileURL);
    
    //2.储存文件的总长度
    //2.1首先读取沙河中文件的长度
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:YYTotalLengthFullpath];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionary];
    }
    dic[self.currentFileURL.md5String] = @(self.totalLength);
    
    [dic writeToFile:YYTotalLengthFullpath atomically:YES];
    
    //3.允许接受服务器数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 开始接受数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    //1.往沙河中写入数据
    [self.stream write:data.bytes maxLength:data.length];
    
    CGFloat progress = 1.0 * YYdownloadFileSize(self.currentFileURL) / self.totalLength;
    
    //这个里调用block把进度传出去
    self.progressBlock(progress);
}

/**
 下载完成
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {

    self.completeHandleBlock(error, YYFilePath(self.currentFileURL));
    //1.关闭流
    [self.stream close];
    self.stream = nil;
    
    self.task = nil;
}
@end
