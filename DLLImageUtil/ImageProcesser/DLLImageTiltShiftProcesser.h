//
//  DLLImageTiltShiftProcesser.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/26.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageProcesser.h"
#import "DLLImageTiltShiftMode.h"



@interface DLLImageTiltShiftProcesser : DLLImageProcesser

@property (atomic, assign) DLLImageTiltShift tiltShiftMode;

/**
 *  半径，范围0-1，是相对于图片大小的比例
 */
@property (atomic, assign) CGFloat radius;

/**
 *  中心点，范围0-1，是相对于图片大小的比例
 */
@property (atomic, assign) CGPoint point;

@property (atomic, assign) CGFloat blurLevel;

@end
