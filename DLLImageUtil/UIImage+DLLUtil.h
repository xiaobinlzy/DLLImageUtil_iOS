//
//  UIImage+Util.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/21.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DLLUtil)

/**
 *  裁剪图片
 *
 *  @param rect 目标区域
 *
 *  @return 裁剪之后的图片
 */
- (UIImage *)clipImageWithRect:(CGRect)rect;

/**
 *  调整图片的亮度
 *
 *  @param brightness 亮度偏移量
 *
 *  @return 亮度调整之后的图片
 */
- (UIImage *)imageWithBright:(CGFloat)brightness;


/**
 *  径向移轴
 *
 *  @param blurImage 模糊图
 *  @param rect      焦点区域
 *  @param maskImage 遮罩图
 *
 *  @return 移轴之后的图片
 */
- (UIImage *)circleBlurImage:(UIImage *)blurImage focusAtRect:(CGRect)rect andMaskImage:(UIImage *)maskImage;

/**
 *  高斯模糊
 *
 *  @param blurLevel 模糊度
 *
 *  @return 模糊之后的图片
 */
- (UIImage *)gaussBlur:(CGFloat)blurLevel;



/**
 *  旋转一定的角度
 *
 *  @param degrees 旋转多少度
 *
 *  @return 旋转之后的图片
 */
- (UIImage *)rotateDegrees:(CGFloat)degrees;

/**
 *  水平移轴
 *
 *  @param blurImage 模糊图
 *  @param rect      焦点区域
 *  @param maskImage 遮罩图
 *
 *  @return 移轴之后的图片
 */
- (UIImage *)bandBlurImage:(UIImage *)blurImage focusAtRect:(CGRect)rect andMaskImage:(UIImage *)maskImage;


/**
 *  图片缩放，缩放到指定大小
 *
 *  @param newSize 要缩放的大小
 *
 *  @return 缩放之后的图片
 */
- (UIImage *)imageWithScaledToSize:(CGSize)newSize;

/**
 *  图片重叠
 *
 *  @param overlayImage 重叠的图片
 *  @param alpha        透明度
 *
 *  @return 处理之后的图片
 */
- (UIImage *)imageOverlayWithImage:(UIImage *)overlayImage alpha:(CGFloat)alpha;


/**
 *  生成暗角图片
 *
 *  @param alpha 暗角透明度
 *  @param maskImage 遮罩图
 *
 *  @return 生成的暗角图片
 */
- (UIImage *)imageShadowCornerWithAlpha:(CGFloat)alpha andMaskImage:(UIImage *)maskImage;


+ (UIImage *)imageWithBundleName:(NSString *)bundleName imageName:(NSString *)imageName andType:(NSString *)type;

@end
