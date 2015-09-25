//
//  DLLImageTiltShiftView.h
//  DLLImageUtil
//
//  Created by DLL on 15/8/27.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLLImageTiltShiftMode.h"


@class DLLImageTiltShiftView;

@protocol DLLImageTiltShiftViewDelegate <NSObject>

- (void)imageTiltShiftViewDidChangedFocus:(DLLImageTiltShiftView *)view;

@end



@interface DLLImageTiltShiftView : UIView

/**
 *  最大半径，默认1
 */
@property (assign, nonatomic) CGFloat maxRadius;

/**
 *  最小半径，默认0.2
 */
@property (assign, nonatomic) CGFloat minRadius;

/**
 *  移轴半径。
 */
@property (assign, nonatomic) CGFloat tiltShiftRadius;

/**
 *  移轴点，x和y的范围是0-1。
 */
@property (assign, nonatomic) CGPoint tiltShiftPoint;


@property (assign, nonatomic) DLLImageTiltShift tiltShiftMode;

@property (weak, nonatomic) id<DLLImageTiltShiftViewDelegate> delegate;



@end
