//
//  ToolsViewController.m
//  网络的一些demo
//
//  Created by x on 2017/10/27.
//  Copyright © 2017年 HLB. All rights reserved.
//

#import "ToolsViewController.h"
#import "YYDownloadManager.h"


/** 视频地址 */
static NSString *const downloadVideoURLS = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";


@interface ToolsViewController ()

@end

@implementation ToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)startDownload:(id)sender {
    [[YYDownloadManager shareInstance] download:downloadVideoURLS progress:^(CGFloat progress) {
        NSLog(@"xiazaijindu=======%f",progress);
    } completeHandle:^(NSError * _Nullable error, NSString * _Nullable filePath) {
        NSLog(@"xiazaiwancheng=========%@",filePath);
    }];
}

- (IBAction)pauseDownload:(id)sender {
    [[YYDownloadManager shareInstance] pauseDownload];
}

- (IBAction)resuemDownload:(id)sender {
    [[YYDownloadManager shareInstance] resuemDownload];
}

@end
