//
//  UIImage+Util.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/21.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "UIImage+DLLUtil.h"
#import <CoreImage/CoreImage.h>
#import <Accelerate/Accelerate.h>


CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

CGFloat radiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}


@implementation UIImage (DLLUtil)


- (UIImage*)imageWithScaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (CGRect)transformRect:(CGRect)rect {
    CGAffineTransform rectTransform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), self.size.width, 0);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    
    return CGRectApplyAffineTransform(rect, rectTransform);
    
}


- (UIImage *)imageWithBright:(CGFloat)brightness {
    if (brightness == 0) {
        return self;
    }
    
    UIImage * result = nil;
    CIContext * context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
    CIImage * inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter * filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, inputImage, nil];
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:kCIInputEVKey];
    
    CIImage * outputImage = filter.outputImage;
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[inputImage extent]];
    result = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgImage);
    return result;
}


- (UIImage *)maskedImage:(UIImage *)maskImage {
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskImage.CGImage), CGImageGetHeight(maskImage.CGImage), CGImageGetBitsPerComponent(maskImage.CGImage), CGImageGetBitsPerPixel(maskImage.CGImage), CGImageGetBytesPerRow(maskImage.CGImage), CGImageGetDataProvider(maskImage.CGImage), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
    
    UIImage *result = [UIImage imageWithCGImage:masked scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(mask);
    CGImageRelease(masked);
    
    return result;
}

- (UIImage *)blurImage:(UIImage *)blurImage andMask:(UIImage *)maskImage {
    UIImage * temp = [self maskedImage:maskImage];
    UIGraphicsBeginImageContext(blurImage.size);
    [blurImage drawAtPoint:CGPointZero];
    [temp drawInRect:CGRectMake(0, 0, blurImage.size.width, blurImage.size.height)];
    temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return temp;
}


- (UIImage *)circleBlurImage:(UIImage *)blurImage focusAtRect:(CGRect)rect andMaskImage:(UIImage *)maskImage {
    rect = [self transformRect:rect];
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    [maskImage drawInRect:rect];
    maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self blurImage:blurImage andMask:maskImage];
}

- (UIImage*)gaussBlur:(CGFloat)blurLevel {
    if (blurLevel == 0) {
        return self;
    }
    
    blurLevel = MIN(1.0, MAX(0.0, blurLevel));
    
    int boxSize = (int)(blurLevel * 0.1 * MIN(self.size.width, self.size.height));
    boxSize = boxSize - (boxSize % 2) + 1;
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage decode:self], 1);
    UIImage *tmpImage = [UIImage imageWithData:imageData];
    
    CGImageRef img = tmpImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    NSInteger windowR = boxSize/2;
    CGFloat sig2 = windowR / 3.0;
    if(windowR>0){ sig2 = -1/(2*sig2*sig2); }
    
    int16_t *kernel = (int16_t*)malloc(boxSize*sizeof(int16_t));
    int32_t  sum = 0;
    for(NSInteger i=0; i<boxSize; ++i){
        kernel[i] = 255*exp(sig2*(i-windowR)*(i-windowR));
        sum += kernel[i];
    }
    
    // convolution
    error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, kernel, boxSize, 1, sum, NULL, kvImageEdgeExtend)?:
    vImageConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, kernel, 1, boxSize, sum, NULL, kvImageEdgeExtend);
    outBuffer = inBuffer;
    
    free(kernel);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}


+ (UIImage*)decode:(UIImage*)image
{
    if(image==nil){  return nil; }
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    {
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}



- (UIImage *)rotateDegrees:(CGFloat)degrees {
    if (degrees == 0) {
        return self;
    }
    
    CGFloat angle = degreesToRadians(degrees);
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGSize rotatedSize = CGRectApplyAffineTransform(rect, t).size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, angle);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:newImage.CGImage scale:newImage.scale orientation:self.imageOrientation];
}


- (UIImage *)clipImageWithRect:(CGRect)rect {
    rect = [self transformRect:rect];
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect bounds = CGRectMake(0, 0, CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, bounds, imgRef);
    UIImage * result = [UIImage imageWithCGImage:imgRef scale:self.scale orientation:self.imageOrientation];
    UIGraphicsEndImageContext();
    CGImageRelease(imgRef);
    return result;
}

- (UIImage *)bandBlurImage:(UIImage *)blurImage focusAtRect:(CGRect)rect andMaskImage:(UIImage *)maskImage {
    rect = [self transformRect:rect];
    maskImage = [UIImage imageWithCGImage:maskImage.CGImage scale:maskImage.scale orientation:self.imageOrientation];
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    [maskImage drawInRect:rect];
    maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self blurImage:blurImage andMask:maskImage];
}


- (UIImage *)imageOverlayWithImage:(UIImage *)overlayImage alpha:(CGFloat)alpha {
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointZero];
    [overlayImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)imageShadowCornerWithAlpha:(CGFloat)alpha andMaskImage:(UIImage *)maskImage {
    if (alpha == 0) {
        return self;
    }
    return [self imageOverlayWithImage:maskImage alpha:alpha];
}


+ (UIImage *)imageWithBundleName:(NSString *)bundleName imageName:(NSString *)imageName andType:(NSString *)type {
    NSString * path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle * bundle = [NSBundle bundleWithPath:path];
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:type]];
}
@end
