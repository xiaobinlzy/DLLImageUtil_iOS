//
//  DLLImageTiltShiftView.m
//  DLLImageUtil
//
//  Created by DLL on 15/8/27.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLImageTiltShiftView.h"
#import "DLLImageTiltShiftMode.h"

/**
 *  调整移轴操作时候显示的图层
 */
@interface DLLImageTiltShiftLayer : CALayer

@property (assign, nonatomic) DLLImageTiltShift tiltShiftMode;

@property (assign, nonatomic) CGFloat radius;


@end

@implementation DLLImageTiltShiftLayer {
    BOOL _hidden;
}

- (void)setRadius:(CGFloat)radius {
    if (_radius != radius) {
        _radius = radius;
        [self resizeSelf];
        [self setNeedsDisplay];
    }
}

- (void)setTiltShiftMode:(DLLImageTiltShift)tiltShiftMode {
    if (_tiltShiftMode != tiltShiftMode) {
        _tiltShiftMode = tiltShiftMode;
        [self resizeSelf];
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGSize size = CGContextGetClipBoundingBox(ctx).size;
    switch (_tiltShiftMode) {
        case DLLImageTiltShiftCircle:
            CGContextSetLineWidth(ctx, 0.5);
            CGContextAddArc(ctx, size.width / 2, size.height / 2, _radius * 3 / 4, 0, M_PI * 2, 1);
            CGContextStrokePath(ctx);
            
            CGContextSetLineWidth(ctx, 4);
            CGContextAddArc(ctx, size.width / 2, size.height / 2, _radius / 4, 0, M_PI * 2, 1);
            CGContextStrokePath(ctx);
            break;
        case DLLImageTiltShiftBand:
            CGContextSetLineWidth(ctx, 0.5);
            CGContextAddRect(ctx, CGRectMake(0, _radius / 4, size.width, _radius * 3 / 2));
            CGContextStrokePath(ctx);
            
            CGContextSetLineWidth(ctx, 4);
            CGContextAddRect(ctx, CGRectMake(0, _radius * 3 / 4, size.width, _radius / 2));
            CGContextStrokePath(ctx);
            
            break;
        default:
            break;
    }
}

- (void)setHidden:(BOOL)hidden {
    if (_hidden != hidden) {
        _hidden = hidden;
        if (hidden) {
            self.affineTransform = CGAffineTransformMakeScale(1.2, 1.2);
            self.opacity = 0;
        } else {
            self.affineTransform = CGAffineTransformMakeScale(1, 1);
            self.opacity = 1;
        }
    }
}

- (void)resizeSelf {
    CGRect bounds = CGRectInfinite;
    switch (_tiltShiftMode) {
        case DLLImageTiltShiftCircle:
            bounds = CGRectMake(0, 0, _radius * 2, _radius * 2);
            break;
        case DLLImageTiltShiftBand:
            bounds = CGRectMake(0, 0, 2000, _radius * 2);
            break;
        default:
            break;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    self.bounds = bounds;
    [CATransaction commit];
}

@end




typedef NS_ENUM(NSInteger, DLLImageTiltShiftViewOperate) {
    DLLImageTiltShiftViewOperateNone,
    DLLImageTiltShiftViewOperateClick,
    DLLImageTiltShiftViewOperatePoint,
    DLLImageTiltShiftViewOperateRadius
};

@implementation DLLImageTiltShiftView {
    DLLImageTiltShiftLayer * _tiltShiftLayer;
    DLLImageTiltShiftViewOperate _operate;
    CGFloat _beginDistance;
    CGFloat _beginRadius;
    CGPoint _beginPoint;
    CGPoint _beginTiltShiftPoint;
    __weak UITouch * _touch;
}

@dynamic tiltShiftMode;

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit {
    _tiltShiftLayer = [[DLLImageTiltShiftLayer alloc] init];
    _tiltShiftLayer.hidden = YES;
    [CATransaction setDisableActions:YES];
    self.userInteractionEnabled = YES;
    [self.layer addSublayer:_tiltShiftLayer];
    self.layer.masksToBounds = YES;
    self.multipleTouchEnabled = YES;
    
    _maxRadius = 1;
    _minRadius = 0.2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _tiltShiftLayer.radius = [self radiusToPixel];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    _tiltShiftLayer.position = [self tiltShiftPointToView:_tiltShiftPoint];
    [CATransaction commit];
}


- (CGFloat)radiusToPixel {
    return _tiltShiftRadius * MIN(self.bounds.size.width, self.bounds.size.height);
}


- (CGPoint)tiltShiftPointToView:(CGPoint)point {
    return CGPointMake(self.bounds.size.width * point.x, self.bounds.size.height * point.y);
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (event.allTouches.count) {
        case 2: {
            _operate = DLLImageTiltShiftViewOperateRadius;
            UITouch * touch1, * touch2;
            NSEnumerator * enumerator = event.allTouches.objectEnumerator;
            touch1 = enumerator.nextObject;
            touch2 = enumerator.nextObject;
            _beginDistance = [self distanceWithTouch:touch1 andAnother:touch2];
            _beginRadius = _tiltShiftRadius;
            _tiltShiftLayer.hidden = NO;
        }
            break;
        case 1:
            _operate = DLLImageTiltShiftViewOperateClick;
            UITouch * touch = [touches anyObject];
            _touch = touch;
            _beginPoint = [touch locationInView:self];
            _beginTiltShiftPoint = _tiltShiftPoint;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                if (_operate == DLLImageTiltShiftViewOperateClick && _touch == touch) {
                    _beginTiltShiftPoint = [self viewPointToTiltShift:_beginPoint];
                    [self pointChanged:_beginPoint];
                }
            });
            break;
    }
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (_operate) {
        case DLLImageTiltShiftViewOperateClick:
            _operate = DLLImageTiltShiftViewOperatePoint;
        case DLLImageTiltShiftViewOperatePoint: {
            CGPoint point = [[touches anyObject] locationInView:self];
            CGPoint beginTiltShiftPoint = [self tiltShiftPointToView:_beginTiltShiftPoint];
            [self pointChanged:CGPointMake(beginTiltShiftPoint.x + point.x - _beginPoint.x, beginTiltShiftPoint.y + point.y - _beginPoint.y)];
        }
            break;
        case DLLImageTiltShiftViewOperateRadius: {
            if (event.allTouches.count == 2) {
                UITouch * touch1, * touch2;
                NSEnumerator * enumerator = event.allTouches.objectEnumerator;
                touch1 = enumerator.nextObject;
                touch2 = enumerator.nextObject;
                
                CGFloat touchDistance = [self distanceWithTouch:touch1 andAnother:touch2];
                CGFloat radius = _beginRadius * touchDistance / _beginDistance;
                self.tiltShiftRadius = radius;
                [self invokeDelegateCallback];
            }
        }
        default:
            break;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (_operate) {
        case DLLImageTiltShiftViewOperateClick: {
            [self pointChanged:_beginPoint];
            [self hideTiltShiftLayerDelay:500 withTouch:[touches anyObject]];
            break;
        }
        case DLLImageTiltShiftViewOperateRadius:
            if (event.allTouches.count > touches.count) {
                break;
            }
        default:
            [self hideTiltShiftLayerDelay:250 withTouch:[touches anyObject]];
            break;
    }
    _operate = DLLImageTiltShiftViewOperateNone;
}

- (void)hideTiltShiftLayerDelay:(NSUInteger)millisecond withTouch:(UITouch *)touch {
    _touch = touch;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, millisecond * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if (_operate == DLLImageTiltShiftViewOperateNone && _touch == touch) {
            _tiltShiftLayer.hidden = YES;
        }
    });

}

- (CGPoint)viewPointToTiltShift:(CGPoint)point {
    point.x /= self.bounds.size.width;
    point.y /= self.bounds.size.height;
    return point;
}


- (void)pointChanged:(CGPoint)point {
    if (point.x < 0) {
        point.x = 0;
    } else if (point.x > self.bounds.size.width) {
        point.x = self.bounds.size.width;
    }
    if (point.y < 0) {
        point.y = 0;
    } else if (point.y > self.bounds.size.height) {
        point.y = self.bounds.size.height;
    }
    
    _tiltShiftPoint = [self viewPointToTiltShift:point];
    _tiltShiftLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    _tiltShiftLayer.position = point;
    [CATransaction commit];
    [self invokeDelegateCallback];
}

- (CGFloat)distanceWithTouch:(UITouch *)touch andAnother:(UITouch *)anotherTouch {
    CGPoint point1 = [touch locationInView:self];
    CGPoint point2 = [anotherTouch locationInView:self];
    
    CGFloat deltaX = point1.x - point2.x;
    CGFloat deltaY = point1.y - point2.y;
    
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}



- (void)invokeDelegateCallback {
    if (_delegate && [_delegate respondsToSelector:@selector(imageTiltShiftViewDidChangedFocus:)]) {
        [_delegate imageTiltShiftViewDidChangedFocus:self];
    }
}

#pragma getters & setters
- (void)setTiltShiftMode:(DLLImageTiltShift)tiltShiftMode {
    if (_tiltShiftLayer.tiltShiftMode != tiltShiftMode) {
        _tiltShiftLayer.tiltShiftMode = tiltShiftMode;
        self.tiltShiftRadius = 0.4;
        self.tiltShiftPoint = CGPointMake(0.5, 0.5);
    }
}

- (DLLImageTiltShift)tiltShiftMode {
    return _tiltShiftLayer.tiltShiftMode;
}

- (void)setTiltShiftPoint:(CGPoint)tiltShiftPoint {
    _tiltShiftPoint = tiltShiftPoint;
    _tiltShiftLayer.position = [self tiltShiftPointToView:_tiltShiftPoint];
}


- (void)setTiltShiftRadius:(CGFloat)tiltShiftRadius {
    if (tiltShiftRadius > _maxRadius) {
        tiltShiftRadius = _maxRadius;
    } else if (tiltShiftRadius < _minRadius) {
        tiltShiftRadius = _minRadius;
    }
    _tiltShiftRadius = tiltShiftRadius;
    _tiltShiftLayer.radius = [self radiusToPixel];
}

- (void)setMaxRadius:(CGFloat)maxRadius {
    _maxRadius = maxRadius;
    if (_tiltShiftRadius > _maxRadius) {
        self.tiltShiftRadius = _maxRadius;
    }
}

- (void)setMinRadius:(CGFloat)minRadius {
    _minRadius = minRadius;
    if (_tiltShiftRadius < _minRadius) {
        self.minRadius = _minRadius;
    }
}


@end
