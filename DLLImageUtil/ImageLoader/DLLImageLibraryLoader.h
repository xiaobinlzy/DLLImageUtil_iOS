//
//  DLLImageGalleryLoader.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLLImageLibraryGroup.h"



@interface DLLImageLibraryLoader : NSObject

+ (instancetype)sharedLoader;

/**
 *  读取相册的组
 *
 *  @param callback 返回结果的回调，数组对象的类型是DLLImageLibraryGroup
 */
- (void)loadAllPhotosLibraries:(DLLImageLibraryGroupCallback)callback;


/**
 *  获相册中的图片
 *
 *  @param offset   从第几张开始。
 *  @param limit    一次获取几张，如果不限制，则传入0。
 *  @param callback 返回结果的回调，数组对象的类型是DLLImageLibraryItem。
 */
- (void)loadCameraPhotosWithOffset:(NSInteger)offset limit:(NSInteger)limit reverse:(BOOL)reverse andCallback:(DLLImageLibraryGroupCallback)callback;

@end
