//
//  DLLImageLibraryItem.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageLibraryItem.h"

@implementation DLLImageLibraryItem {
    ALAsset * _asset;
}

- (instancetype)initWithAssets:(ALAsset *)asset {
    self = [self init];
    if (self) {
        _asset = asset;
        _squareImage = [UIImage imageWithCGImage:asset.thumbnail];
        _aspectRatioImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        _url = [_asset valueForProperty:ALAssetPropertyURLs];
    }
    return self;
}



- (void)imageWithFileName:(NSString *)fileName andCallback:(DLLImageLibraryImageCallback)callback {
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetRepresentation * rep = [_asset defaultRepresentation];
        Byte * buffer = (Byte *) malloc((unsigned long)rep.size);
        NSUInteger bufferLength = [rep getBytes:buffer fromOffset:0 length:(unsigned long)rep.size error:nil];
        NSData * data = [[NSData alloc] initWithBytesNoCopy:buffer length:bufferLength freeWhenDone:YES];
        [data writeToFile:filePath atomically:YES];
        if (callback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback([UIImage imageWithData:data]);
            });
        }
    });
}

@end
