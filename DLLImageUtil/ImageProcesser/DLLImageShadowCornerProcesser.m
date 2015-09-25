//
//  DLLImageShadowCornerProcesser.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/31.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageShadowCornerProcesser.h"
#import "UIImage+DLLUtil.h"

@implementation DLLImageShadowCornerProcesser {
    CGFloat _lastAlpha;
    UIImage * _maskImage;
}


- (BOOL)needProcess {
    return _lastAlpha != _alpha;
}

- (UIImage *)processedImage:(UIImage *)srcImage {
    _lastAlpha = _alpha;
    return [srcImage imageShadowCornerWithAlpha:_lastAlpha andMaskImage:[self maskImage]];
}

- (UIImage *)maskImage {
    if (_maskImage == nil) {
        _maskImage = [UIImage imageWithBundleName:@"DLLImageUtil" imageName:@"shadowcorner" andType:@"png"];
    }
    return _maskImage;
}

@end
