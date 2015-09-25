//
//  DLLImageUtil.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/20.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLLCameraView.h"
#import "DLLImageTiltShiftProcesser.h"
#import "DLLImageBrightProcesser.h"
#import "DLLImageShadowCornerProcesser.h"
#import "DLLImageTiltShiftMode.h"
#import "DLLImageLibraryLoader.h"
#import "UIImage+DLLUtil.h"

typedef void (^DLLImageUtilCallback) (UIImage * image, NSTimeInterval duration);

@interface DLLImageUtil : NSObject

- (instancetype)initWithImage:(UIImage *)image;

/**
 *  亮度，默认为0。
 */
@property (assign, nonatomic) CGFloat brightness;

@property (strong, nonatomic) UIImage * image;

@property (assign, nonatomic) CGFloat blurLevel;

@property (assign, nonatomic) CGFloat tiltShiftRadius;

@property (assign, nonatomic) CGPoint tiltShiftPoint;

@property (assign, nonatomic) CGFloat shadowCorner;

@property (assign, nonatomic) DLLImageTiltShift tiltShiftMode;

/**
 *  执行回调，会在主线程中回调，用来修改图片。
 */
@property (copy, nonatomic) DLLImageUtilCallback callback;


@end
