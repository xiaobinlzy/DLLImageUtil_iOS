//
//  DLLCameraView.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/21.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLCameraView.h"
#import "UIImage+DLLUtil.h"

@implementation DLLCameraView {
    AVCaptureSession * _session;
    AVCaptureDeviceInput * _videoInput;
    AVCaptureStillImageOutput * _stillImageOutput;
    AVCaptureVideoPreviewLayer * _previewLayer;
    AVCaptureDevice * _device;
    AVCaptureConnection * _captureConn;
    BOOL _running;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    _tapFocusEnabled = YES;
    _session = [[AVCaptureSession alloc] init];
    _device = [self backCamera];
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:nil];
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    _stillImageOutput.outputSettings = outputSettings;
    if ([_session canAddInput:_videoInput]) {
        [_session addInput:_videoInput];
    }
    if ([_session canAddOutput:_stillImageOutput]) {
        [_session addOutput:_stillImageOutput];
    }
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:gesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oritationChangedNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)oritationChangedNotification:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGAffineTransform t;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            t = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            t = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            t = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        default:
            t = CGAffineTransformIdentity;
            break;
    }
    if (_previewLayer != nil) {
        _previewLayer.affineTransform = t;
    }
}

- (void)startRunning {
    if (_running) {
        return;
    }
    _running = YES;
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        self.layer.masksToBounds = YES;
        _previewLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.layer addSublayer:_previewLayer];
        [self oritationChangedNotification:nil];
    }
    [_session startRunning];
    _captureConn = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([_captureConn respondsToSelector:@selector(setPreferredVideoStabilizationMode:)]) {
        [_captureConn setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeStandard];
    } else {
        [_captureConn setEnablesVideoStabilizationWhenAvailable:YES];
    }
}

- (void)stopRunning {
    if (!_running) {
        return;
    }
    _running = NO;
    [_session stopRunning];
    _captureConn = nil;
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (void)takePhoto:(void (^)(UIImage *))callback {
    if (!_captureConn) {
        if (callback) {
            callback(nil);
        }
        return;
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:_captureConn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            if (callback) {
                callback(nil);
            }
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        if (callback) {
            callback([self clicpImage:image]);
        }
    }];
}

- (UIImage *)clicpImage:(UIImage *)srcImage {
    CGFloat widthRate = srcImage.size.width / self.bounds.size.width;
    CGFloat heightRate = srcImage.size.height / self.bounds.size.height;
    CGRect rect;
    if (widthRate > heightRate) {
        CGFloat width = self.bounds.size.width * heightRate;
        rect = CGRectMake((srcImage.size.width - width) / 2, 0, width, srcImage.size.height);
    } else {
        CGFloat height = self.bounds.size.height * widthRate;
        rect = CGRectMake(0, (srcImage.size.height - height) / 2, srcImage.size.width, height);
    }
    return [srcImage clipImageWithRect:rect];
    
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


- (void)tap:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:self];
    if (_tapCallback) {
        _tapCallback(self, touchPoint);
    }
    if (!_tapFocusEnabled) {
        return;
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGPoint focusPoint = CGPointMake((touchPoint.x + (screenSize.width - self.bounds.size.width) / 2) / screenSize.width , (touchPoint.y + (screenSize.height - self.bounds.size.height) / 2) / screenSize.height);
    if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [_device isFocusPointOfInterestSupported]) {
        if ([_device lockForConfiguration:nil]) {
            [_device setFocusPointOfInterest:focusPoint];
            
            [_device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            [_device unlockForConfiguration];
        }
    }
}

@end
