//
//  DLLImageTextProcesser.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/31.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageProcesser.h"


@interface DLLImageText : NSObject

/**
 *  范围是0-1
 */
@property (assign, nonatomic) CGRect rect;

@property (strong, nonatomic) NSString *text;

/**
 *  字体大小，范围0-1。
 */
@property (assign, nonatomic) CGFloat fontSize;

@property (strong, nonatomic) UIColor *color;

/**
 *  判断两个ImageText是否相等
 *
 *  @param imageText 目标ImageText
 *
 *  @return 是否相等。
 */
- (BOOL)isEqualToImageText:(DLLImageText *)imageText;

- (UIFont *)fontWithWidth:(CGFloat)width;

@end





@interface DLLImageTextProcesser : DLLImageProcesser


@property (strong, nonatomic) NSArray *texts;

@end
