//
//  DLLImageProcesser.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/26.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLLImageProcesser : NSObject {
    UIImage * _image;
}

@property (assign, nonatomic) DLLImageProcesser * processer;


+ (instancetype)processerWithImage:(UIImage *)image;

/**
 *  获取image对象
 *
 *  @return 处理过的image
 */
- (UIImage *)image;

/**
 *  子类重写这个方法，用来处理图片。
 *
 *  @param srcImage 要处理的原图
 *
 *  @return 处理过的图片
 */
- (UIImage *)processedImage:(UIImage *)srcImage;

/**
 *  子类重写这个方法，用来检查是否需要重新处理图片。
 *
 *  @return 是否需要重新处理图片
 */
- (BOOL)needProcess;

@end
