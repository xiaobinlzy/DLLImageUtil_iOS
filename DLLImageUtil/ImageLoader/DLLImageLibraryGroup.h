//
//  DLLImageLibraryGroup.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DLLImageLibraryItem.h"

typedef void (^DLLImageLibraryGroupCallback) (NSArray * result);

@interface DLLImageLibraryGroup : NSObject

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group;


@property (readonly) UIImage * postImage;

@property (readonly) NSString * name;

@property (readonly) NSUInteger number;

@property (readonly) NSURL * url;

/**
 *  获取该组中的图片
 *
 *  @param offset   从第几张开始。
 *  @param limit    一次获取几张，如果不限制，则传入0。
 *  @param callback 返回结果的回调。
 */
- (void)loadPhotosWithOffset:(NSInteger)offset limit:(NSInteger)limit reverse:(BOOL)reverse andCallback:(DLLImageLibraryGroupCallback)callback;

@end
