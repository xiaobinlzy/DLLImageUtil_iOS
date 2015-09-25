//
//  DLLImageUtil.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/20.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageUtil.h"


@implementation DLLImageUtil {
    dispatch_queue_t _queue;
    BOOL _inProcess;
    BOOL _needOneProcess;
    UIImage * _image;
    
    DLLImageProcesser * _imageProcesser;
    
    DLLImageBrightProcesser * _brightProcesser;
    
    DLLImageTiltShiftProcesser * _tiltShiftProcesser;
    
    DLLImageShadowCornerProcesser * _shadowCornerProcesser;
    
    DLLImageProcesser __unsafe_unretained * _topProcesser;
    
    NSLock * _lock;
}

@synthesize image = _image;

@dynamic brightness;
@dynamic blurLevel;
@dynamic tiltShiftRadius;
@dynamic tiltShiftMode;
@dynamic tiltShiftPoint;
@dynamic shadowCorner;

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("DLLImageUtilQueue", NULL);
    }
    return self;
}


- (instancetype)initWithImage:(UIImage *)image {
    self = [self init];
    if (self) {
        _image = image;
        
        _imageProcesser = [DLLImageProcesser processerWithImage:_image];
        _brightProcesser = [DLLImageBrightProcesser new];
        _tiltShiftProcesser = [DLLImageTiltShiftProcesser new];
        _shadowCornerProcesser = [DLLImageShadowCornerProcesser new];
        
        _brightProcesser.processer = _imageProcesser;
        _tiltShiftProcesser.processer = _brightProcesser;
        _shadowCornerProcesser.processer = _tiltShiftProcesser;
        
        _topProcesser = _shadowCornerProcesser;
        
        _lock = [[NSLock alloc] init];
    }
    return self;
}

#pragma mark - process control
- (void)updateImage {
    if (_inProcess) {
        _needOneProcess = YES;
        return;
    }
    _inProcess = YES;
    dispatch_async(_queue, ^{
        [self process];
    });
}



- (void)process {
    double currentTime = CACurrentMediaTime();
    [_lock lock];
    UIImage * image = [_topProcesser image];
    [_lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_callback != NULL) {
            _callback(image, CACurrentMediaTime() - currentTime);
        }
        _inProcess = NO;
        if (_needOneProcess) {
            _needOneProcess = NO;
            [self updateImage];
        }
        
    });
}

- (void)setTopProcesser:(DLLImageProcesser *)processer {
    if (_topProcesser != processer) {
        [_lock lock];
        DLLImageProcesser * currentProcesser = _topProcesser;
        while (currentProcesser.processer) {
            if (currentProcesser.processer == processer) {
                currentProcesser.processer = processer.processer;
                processer.processer = _topProcesser;
                _topProcesser = processer;
                break;
            } else {
                currentProcesser = currentProcesser.processer;
            }
        }
        [_lock unlock];
    }
}



#pragma mark - getters & setters
- (void)setBrightness:(CGFloat)brightness {
    _brightProcesser.brightness = brightness;
    [self setTopProcesser:_brightProcesser];
    [self updateImage];
}


- (CGFloat)brightness {
    return _brightProcesser.brightness;
}

- (void)setTiltShiftRadius:(CGFloat)radius {
    _tiltShiftProcesser.radius = radius;
    [self setTopProcesser:_tiltShiftProcesser];
    [self updateImage];
}

- (CGFloat)tiltShiftRadius {
    return _tiltShiftProcesser.radius;
}

- (void)setBlurLevel:(CGFloat)blurLevel {
    _tiltShiftProcesser.blurLevel = blurLevel;
    [self setTopProcesser:_tiltShiftProcesser];
    [self updateImage];
}

- (CGFloat)blurLevel {
    return _tiltShiftProcesser.blurLevel;
}

- (void)setTiltShiftPoint:(CGPoint)tiltShiftPoint {
    _tiltShiftProcesser.point = tiltShiftPoint;
    [self setTopProcesser:_tiltShiftProcesser];
    [self updateImage];
}


- (void)setTiltShiftMode:(DLLImageTiltShift)tiltShiftMode {
    _tiltShiftProcesser.tiltShiftMode = tiltShiftMode;
    [self setTopProcesser:_tiltShiftProcesser];
    [self updateImage];
}

- (DLLImageTiltShift)tiltShiftMode {
    return _tiltShiftProcesser.tiltShiftMode;
}

- (CGFloat)shadowCorner {
    return _shadowCornerProcesser.alpha;
}

- (void)setShadowCorner:(CGFloat)shadowCorner {
    _shadowCornerProcesser.alpha = shadowCorner;
    [self setTopProcesser:_shadowCornerProcesser];
    [self updateImage];
}

- (void)setImage:(UIImage *)image {
    DLLImageProcesser *imageProcesser = [DLLImageProcesser processerWithImage:image];
    DLLImageProcesser *currentProcesser = _topProcesser;
    while (currentProcesser.processer != nil) {
        if (currentProcesser.processer == _imageProcesser) {
            currentProcesser.processer = imageProcesser;
            break;
        } else {
            currentProcesser = currentProcesser.processer;
        }
    }
    if (currentProcesser.processer == imageProcesser) {
        _image = image;
        _imageProcesser = imageProcesser;
        [self updateImage];
    }
}

@end
