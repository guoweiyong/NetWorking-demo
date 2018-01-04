//
//  YYDownloadManager.h
//  网络的一些demo
//
//  Created by x on 2017/10/27.
//  Copyright © 2017年 HLB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface YYDownloadManager : NSObject

/**
 创建一个下载对象

 @return <#return value description#>
 */
+ (instancetype)shareInstance;


/**
 提供一个URL下载文件(支持断点下载,离线下载)

 @param url 文件的url
 @param progressBlock 文件的下载进度block
 @param completeBlock 文件下载完成的block
 */
- (void)download:(NSString *)url progress:(nullable void (^)(CGFloat progress))progressBlock completeHandle:(nullable void (^)(NSError * _Nullable error, NSString * _Nullable filePath))completeBlock;


/**
 恢复下载
 */
- (void)resuemDownload;


/**
 暂停下载
 */
- (void)pauseDownload;

@end
