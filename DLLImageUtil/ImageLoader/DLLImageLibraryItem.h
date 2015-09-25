//
//  DLLImageLibraryItem.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^DLLImageLibraryImageCallback) (UIImage * image);

@interface DLLImageLibraryItem : NSObject

- (instancetype)initWithAssets:(ALAsset *)asset;

@property (readonly) UIImage * squareImage;

@property (readonly) UIImage * aspectRatioImage;

@property (readonly) NSURL * url;

/**
 *  将资源库中的图片复制到沙盒，并获取UIImage
 *
 *  @param fileName 保存的文件名
 *  @param callback 返回回调
 */
- (void)imageWithFileName:(NSString *)fileName andCallback:(DLLImageLibraryImageCallback)callback;

@end
