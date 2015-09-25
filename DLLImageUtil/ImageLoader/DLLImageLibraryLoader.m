//
//  DLLImageGalleryLoader.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageLibraryLoader.h"
#import <AssetsLibrary/AssetsLibrary.h>






@implementation DLLImageLibraryLoader {
    ALAssetsLibrary * _assetsLibrary;
    NSFileManager * _fileNamager;
}

+ (instancetype)sharedLoader {
    static DLLImageLibraryLoader * __loader;
    static dispatch_once_t __token;
    dispatch_once(&__token, ^{
        __loader = [[DLLImageLibraryLoader alloc] init];
    });
    return __loader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _fileNamager = [NSFileManager defaultManager];
    }
    return self;
}





- (void)loadAllPhotosLibraries:(DLLImageLibraryGroupCallback)callback {
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        *stop = group == nil;
        if (!* stop) {
            [array addObject:[[DLLImageLibraryGroup alloc] initWithAssetsGroup:group]];
        } else {
            if (callback) {
                callback(array);
            }
        }
    } failureBlock:NULL];
}


- (void)loadCameraPhotosWithOffset:(NSInteger)offset limit:(NSInteger)limit reverse:(BOOL)reverse andCallback:(DLLImageLibraryGroupCallback)callback {
    [self loadAllPhotosLibraries:^(NSArray *result) {
        for (DLLImageLibraryGroup * group in result) {
            if ([group.name isEqualToString:@"Camera Roll"]) {
                [group loadPhotosWithOffset:offset limit:limit reverse:reverse andCallback:callback];
                break;
            }
        }
    }];
}

@end
