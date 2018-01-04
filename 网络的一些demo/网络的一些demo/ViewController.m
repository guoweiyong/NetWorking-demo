//
//  ViewController.m
//  网络的一些demo
//
//  Created by x on 2017/10/19.
//  Copyright © 2017年 HLB. All rights reserved.
//

#import "ViewController.h"

static NSString *const downloadImageURLS = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508390069305&di=f2732d0c03266768599f37d2e832746f&imgtype=0&src=http%3A%2F%2Fpic20.photophoto.cn%2F20110925%2F0010023291781194_b.jpg";

static NSString *const downlaodLargeImageURLS = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508394009873&di=8aac48696748c685676742f64656c386&imgtype=0&src=http%3A%2F%2Fpic12.nipic.com%2F20101220%2F2055056_173707019175_2.jpg";

static NSString *const downloadVideoURLS = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";

#define GYFilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"minion_01.mp4"]
@interface ViewController ()<NSURLConnectionDataDelegate>

/** 图片显示 */
@property (nonatomic, strong) UIImageView *imageView;

/** 文件data */
@property (nonatomic, strong) NSMutableData *fileData;

/** 进度条 */
@property (nonatomic, strong) UISlider *slider;

/** 文件总长度 */
@property (nonatomic, assign)NSInteger fileLength;

/** 文件对象 */
@property (nonatomic, strong) NSFileHandle *handle;

/** 文件的当前长度 */
@property (nonatomic, assign) NSInteger currrentlenght;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(50, 50, 100, 100);
    [self.view addSubview:self.imageView];
    
    self.slider = [[UISlider alloc] init];
    self.slider.frame = CGRectMake(20, 200, 200, 40);
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1.0;
    self.slider.value = 0;
    [self.view addSubview:self.slider];
    
    
    /** 使用NSdata的方式来下载小图片,确定是不能赞停*/
    //[self downloadToData];
    
    /** 使用NSURLConnention来下载小图片,(已近被弃用了)*/
    //[self downloadToConnention];
    //[self downloadToConnention1];
    
#if TARGET_OS_IPHONE  //  TARGET_OS_IPHONE
    
#endif
}

- (void)downloadToData {
    NSURL *url = [NSURL URLWithString:downloadImageURLS];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"data====%zd",data.length);

    self.imageView.image = [UIImage imageWithData:data];
}

- (void)downloadToConnention {
    NSURL *url = [NSURL URLWithString:downloadImageURLS];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSLog(@"data====%zd   ====%@",data.length,[NSThread currentThread]);
        self.imageView.image = [UIImage imageWithData:data];
    }];
}

- (void)downloadToConnention1 {
    NSURL *url = [NSURL URLWithString:downloadVideoURLS];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -- NSURLConnectionDataDelegate
/**
 小文件的下载
 
 //接收到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    NSLog(@"response===%@",response.allHeaderFields);
    self.fileData = [NSMutableData data];
    self.fileLength = [[response.allHeaderFields objectForKey:@"Content-Length"] integerValue];
}

// 开始接受数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"data.length====%zd",data.length);
    [self.fileData appendData:data];
    NSLog(@"已下载: %.2f%%",(1.0 * self.fileData.length/self.fileLength) * 100);
    self.slider.value =  1.0 * self.fileData.length/self.fileLength;
}

// 数据下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"图片下载完成...");
    //self.imageView.image = [UIImage imageWithData:self.fileData];
    
    //将文件写在沙河中(文件写入cachs中  写入home中是不允许上线的)
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:@"1.png"];
    [self.fileData writeToFile:filePath atomically:YES];
    
    NSLog(@"文件写入---------成功----%@",filePath);
    self.fileData = nil;
}
*/

/** 
 大文件的下载  实现下载一点就写入一点到缓存中
 */

//接收到响应的时候,创建一个空的文件
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    
    //获得文件的总长度
    self.fileLength = [[response.allHeaderFields objectForKey:@"Content-Length"] integerValue];
    //创建一个空的文件
    [[NSFileManager defaultManager]createFileAtPath:GYFilePath contents:nil attributes:nil];
    
    //打开一个文件准备写入
    self.handle = [NSFileHandle fileHandleForWritingAtPath:GYFilePath];
}

//把接受的数据写入一开始创建好的文件
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"data======%zd",data.length);
    //指定文件的写入位置
    [self.handle seekToEndOfFile];
    
    //写入数据
    [self.handle writeData:data];
    
    self.currrentlenght += data.length;
    self.slider.value = 1.0 * self.currrentlenght / self.fileLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"---下载完毕----%@",GYFilePath);
    //当你使用handle之后必须要关闭对文件的操作
    [self.handle closeFile];
    self.handle = nil;
}


#pragma mark -- 文件上传

- (void)uploadFile {
    
    //1.上传文件,第一不是设置请求头(遵循http协议)
    // 创建请求
    NSURL *url = [NSURL URLWithString:@"http://120.25.226.186:32812/upload"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //设置是post请求
    request.HTTPMethod = @"POST";
    
    //设置请求头(告诉服务器这是一个文件上传的请求)
    //[request setValue:<#(nullable NSString *)#> forHTTPHeaderField:<#(nonnull NSString *)#>]

}















@end
