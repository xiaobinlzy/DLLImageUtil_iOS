//
//  DLLImageTiltShiftProcesser.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/26.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageTiltShiftProcesser.h"
#import "UIImage+DLLUtil.h"

@implementation DLLImageTiltShiftProcesser {
    CGPoint _lastPoint;
    CGFloat _lastRadius;
    DLLImageTiltShift _lastMode;
    CGFloat _lastBlurLevel;
    UIImage * _blurImage;
    __weak UIImage * _srcImage;
    
    UIImage * _circleMaskImage;
    UIImage * _bandMaskImage;
}




- (UIImage *)processedImage:(UIImage *)srcImage {
    _lastPoint = self.point;
    _lastRadius = self.radius;
    _lastMode = self.tiltShiftMode;
    CGFloat blurLevel = self.blurLevel;
    if (_srcImage != srcImage || _lastBlurLevel != blurLevel) {
        _blurImage = blurLevel == 0 ? nil : [srcImage gaussBlur:blurLevel];
        _lastBlurLevel = blurLevel;
    }
    UIImage * image = srcImage;
    CGSize size = srcImage.size;
    switch (_tiltShiftMode) {
        case DLLImageTiltShiftCircle: {
            CGFloat radius = _lastRadius * MIN(size.width, size.height);
            image = [srcImage circleBlurImage:_blurImage focusAtRect:CGRectMake(_lastPoint.x * size.width - radius, _lastPoint.y * size.height - radius, 2 * _lastRadius * size.width, 2 * _lastRadius * size.width) andMaskImage:[self circleMaskImage]];
        }
            break;
        case DLLImageTiltShiftBand:
            image = [srcImage bandBlurImage:_blurImage focusAtRect:CGRectMake(0, (_lastPoint.y - _lastRadius) * size.height, size.width, _lastRadius * 2 * size.height) andMaskImage:[self bandMaskImage]];
            break;
        default:
            break;
    }
    _srcImage = srcImage;
    return image;
}

- (BOOL)needProcess {
    return _lastMode != _tiltShiftMode || _lastRadius != _radius || !CGPointEqualToPoint(_lastPoint, _point) || _lastBlurLevel != _blurLevel;
}

- (UIImage *)circleMaskImage {
    if (_circleMaskImage == nil) {
        _circleMaskImage = [UIImage imageWithBundleName:@"DLLImageUtil" imageName:@"circle" andType:@"png"];
    }
    return _circleMaskImage;
}

- (UIImage *)bandMaskImage {
    if (_bandMaskImage == nil) {
        _bandMaskImage = [UIImage imageWithBundleName:@"DLLImageUtil" imageName:@"band" andType:@"png"];
    }
    return _bandMaskImage;
}

@end
