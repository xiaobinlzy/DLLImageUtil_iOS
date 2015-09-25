//
//  DLLImageTextProcesser.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/31.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageTextProcesser.h"

@implementation DLLImageText

- (BOOL)isEqualToImageText:(DLLImageText *)imageText {
    
    return self == imageText || (CGRectEqualToRect(_rect, imageText.rect) && [_text isEqualToString:imageText.text] && _fontSize == imageText.fontSize && CGColorEqualToColor(_color.CGColor, imageText.color.CGColor));
}

- (UIFont *)fontWithWidth:(CGFloat)width {
    return [UIFont systemFontOfSize:_fontSize * width];
}

@end


@implementation DLLImageTextProcesser {
    NSArray *_lastTexts;
    
}

- (BOOL)needProcess {
    BOOL result = NO;
    if (_lastTexts.count == _texts.count) {
        for (int i = 0; i < _texts.count; i++) {
            DLLImageText *imageText = [_texts objectAtIndex:i];
            DLLImageText *lastImageText = [_lastTexts objectAtIndex:i];
            if (![imageText isEqualToImageText:lastImageText]) {
                result = YES;
                break;
            }
        }
    } else {
        result = YES;
    }
    
    return result;
}

- (UIImage *)processedImage:(UIImage *)srcImage {
    _lastTexts = [_texts copy];
    CGSize size = srcImage.size;
    UIGraphicsBeginImageContext(srcImage.size);
    [srcImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    for (DLLImageText * text in _lastTexts) {
        NSDictionary * attributes = [[NSDictionary alloc] initWithObjectsAndKeys:[text fontWithWidth:size.width], NSFontAttributeName, text.color, NSForegroundColorAttributeName, nil];
        [text.text drawInRect:CGRectMake(size.width * text.rect.origin.x, size.height * text.rect.origin.y, size.width * text.rect.size.width, size.height * text.rect.size.height) withAttributes:attributes];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}


@end
