//
//  DLLCameraView.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/21.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class DLLCameraView;
typedef void (^DLLCameraTapCallback) (DLLCameraView * view, CGPoint point);

/**
 *  显示镜头的view
 */
@interface DLLCameraView : UIView

/**
 *  是否支持点击对焦，默认为YES。
 */
@property (assign, nonatomic) BOOL tapFocusEnabled;

/**
 *  当被点击时回调。
 */
@property (copy, nonatomic) DLLCameraTapCallback tapCallback;

/**
 *  开启镜头
 */
- (void)startRunning;

/**
 *  关闭镜头
 */
- (void)stopRunning;

/**
 *  拍照
 *
 *  @param callback 获取照片之后的回调
 */
- (void)takePhoto:(void(^)(UIImage * picture))callback;

@end
