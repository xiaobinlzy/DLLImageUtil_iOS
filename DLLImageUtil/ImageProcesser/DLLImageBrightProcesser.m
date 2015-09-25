//
//  DLLImageBrightProcesser.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/26.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageBrightProcesser.h"
#import "UIImage+DLLUtil.h"

@implementation DLLImageBrightProcesser {
    CGFloat _lastBrightness;
}


- (UIImage *)processedImage:(UIImage *)srcImage {
    _lastBrightness = self.brightness;
    return [srcImage imageWithBright:_lastBrightness];
}

- (BOOL)needProcess {
    return _lastBrightness != _brightness;
}

@end
