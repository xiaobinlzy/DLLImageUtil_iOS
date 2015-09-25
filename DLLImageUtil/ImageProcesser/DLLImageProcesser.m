//
//  DLLImageProcesser.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/26.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageProcesser.h"

@implementation DLLImageProcesser {
    UIImage * _srcImage;
    
}

+ (instancetype)processerWithImage:(UIImage *)image {
    DLLImageProcesser * processer = [[self alloc] initWithImage:image];
    return processer;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        _image = image;
    }
    return self;
}


- (UIImage *)image {
    UIImage * srcImage = nil;
    if (_processer) {
        srcImage = [_processer image];
    }
    if ([self needProcess] || srcImage != _srcImage) {
        _srcImage = srcImage;
        _image = [self processedImage:srcImage];
    }
    return _image;
}

- (UIImage *)processedImage:(UIImage *)srcImage {
    return srcImage;
}

- (BOOL)needProcess {
    return NO;
}
@end
