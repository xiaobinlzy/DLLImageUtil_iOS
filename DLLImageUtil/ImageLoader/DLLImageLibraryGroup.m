//
//  DLLImageLibraryGroup.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/28.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageLibraryGroup.h"

@implementation DLLImageLibraryGroup {
    ALAssetsGroup * _group;
}


- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group {
    self = [self init];
    if (self) {
        _group = group;
        _postImage = [UIImage imageWithCGImage:group.posterImage];
        _number = group.numberOfAssets;
        _name = [group valueForProperty:ALAssetsGroupPropertyName];
        _url = [group valueForProperty:ALAssetsGroupPropertyURL];
    }
    return self;
}


- (void)loadPhotosWithOffset:(NSInteger)offset limit:(NSInteger)limit reverse:(BOOL)reverse andCallback:(DLLImageLibraryGroupCallback)callback {
    if (limit == 0 || limit + offset > _number) {
        limit = _number - offset;
    }
    if (reverse) {
        offset = _number - limit - offset;
    }
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSIndexSet * indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(offset, limit)];
    [_group enumerateAssetsAtIndexes:indexSet options:reverse ? NSEnumerationReverse : NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        *stop = result == nil;
        if (!*stop) {
            [array addObject:[[DLLImageLibraryItem alloc] initWithAssets:result]];
        } else {
            if (callback) {
                callback(array);
            }
        }
    }];
}

@end
