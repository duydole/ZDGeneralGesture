//
//  TapLongTapOrDoubleTapGestureRecognizer.m
//  DemoGestureTeleObjC
//
//  Created by Do Le Duy on 12/28/20.
//

#import "TapLongTapOrDoubleTapGestureRecognizer.h"
#import "TapLongTapOrDoubleTapGestureRecognizer+Private.h"

#define kWaitForDoubleTapDuration           0.2
#define kWaitForTriggerLongPressDuration    0.3

#pragma mark - _TapLongTapOrDoubleTapGestureRecognizerTimerTarget

@interface _TapLongTapOrDoubleTapGestureRecognizerTimerTarget : NSObject

@property (nonatomic, weak) TapLongTapOrDoubleTapGestureRecognizer *delegateGesture;

- (instancetype)initWithTarget:(TapLongTapOrDoubleTapGestureRecognizer *)target;

@end

@implementation _TapLongTapOrDoubleTapGestureRecognizerTimerTarget

- (instancetype)initWithTarget:(TapLongTapOrDoubleTapGestureRecognizer *)target {
    self = [super init];
    if (self) {
        self.delegateGesture = target;
    }
    return self;
}

- (void)longTapEvent {
    if (self.delegateGesture) {
        [self.delegateGesture _didLongTap];
    }
}

- (void)tapEvent {
    if (self.delegateGesture) {
        [self.delegateGesture _didSingleTap];
    }
}

@end

#pragma mark - TapLongTapOrDoubleTapGestureRecognizer

@interface TapLongTapOrDoubleTapGestureRecognizer()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) GestureInfo *lastRecognizedGestureInfo;
@property (nonatomic, strong) TouchInfo *currentTouchInFo;
@property (nonatomic, assign) NSInteger touchCount;
@property (nonatomic, assign) NSInteger tapCount;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL recognizedLongTap;

@end

@implementation TapLongTapOrDoubleTapGestureRecognizer

#pragma mark - Initialize

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - Override

- (void)reset {
    [self _invalidateTimer];
    self.currentTouchInFo = nil;
    self.tapCount = 0;
    self.touchCount = 0;
    self.recognizedLongTap = NO;
    self.hoveringAtPointBlock = nil;
    self.leaveFingerAtPointBlock = nil;
    
    [super reset];
}

#pragma mark - Public

- (void)cancel {
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark - Private Extension

- (void)_didLongTap {
    [self _invalidateTimer];
    
    if (self.currentTouchInFo) {
        CGPoint location = self.currentTouchInFo.location;
        self.lastRecognizedGestureInfo = CREATE_GESTURE_INFO(GestureTypeLongTap, location);
        
        if (self.didLongPressBlock) {
            if (self.view && self.view.window) {
                [self.class cancelOtherGesturesWithCurrentGesture:self onView:self.view.window];
            }
            self.recognizedLongTap = YES;
            self.state = UIGestureRecognizerStateBegan;
            self.didLongPressBlock(location, self);
            return;
        }
    } else {
        self.lastRecognizedGestureInfo = nil;
    }
    
    [self _endProcessOfDetectGestureType];
}

- (void)_didSingleTap {
    [self _invalidateTimer];
    
    if (self.currentTouchInFo) {
        CGPoint location = self.currentTouchInFo.location;
        self.lastRecognizedGestureInfo = CREATE_GESTURE_INFO(GestureTypeSingleTap, location);
    } else {
        self.lastRecognizedGestureInfo = nil;
    }
    
    [self _endProcessOfDetectGestureType];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.lastRecognizedGestureInfo = nil;
    [super touchesBegan:touches withEvent:event];
    self.touchCount += touches.count;

    UITouch *touch = touches.allObjects.firstObject;
    if (touch) {
        /// If touched on UIButton, then do nothing
        CGPoint touchedLocation = [touch locationInView:self.view];
        UIView *touchedView = [self.view hitTest:touchedLocation withEvent:event];
        if (touchedView && [touchedView isKindOfClass:UIButton.class]) {
            self.state = UIGestureRecognizerStateFailed;
            return;
        }
        
        self.tapCount +=1;
        BOOL isDoubleTap = self.tapCount == 2 && self.touchCount == 1;
        if (isDoubleTap) {
            
            /// Finally, this is DoubleTap
            [self _invalidateTimer];
            CGPoint location = [self locationInView:self.view];
            self.lastRecognizedGestureInfo = CREATE_GESTURE_INFO(GestureTypeDoubleTap, location);
            [self _endProcessOfDetectGestureType];
        } else {
            /// Flow of first Tap, save info about firstTap
            CGPoint touchedPoint = [touch locationInView:self.view];
            self.currentTouchInFo = [[TouchInfo alloc] initWithLocation:touchedPoint andTimeStamp:CACurrentMediaTime()];

            /// Get acceptedGesture at touchPoint
            AcceptedGestureType acceptedGestureType = AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
            if (self.acceptedGestureTypeAtPoint) {
                acceptedGestureType = self.acceptedGestureTypeAtPoint(touchedPoint);
            }
            
            switch (acceptedGestureType) {
                case AcceptedGestureTypeSingleTapOnly:
                    break;
                case AcceptedGestureTypeSingleAndLongTap:
                case AcceptedGestureTypeSingleAndLongTapAndDoubleTap:
                {
                    /// Fire longTapEvent  if not end this gesture in 0.3s
                    [self _invalidateTimer];
                    _TapLongTapOrDoubleTapGestureRecognizerTimerTarget *target = [[_TapLongTapOrDoubleTapGestureRecognizerTimerTarget alloc] initWithTarget:self];
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kWaitForTriggerLongPressDuration
                                                                      target:target
                                                                    selector:@selector(longTapEvent)
                                                                    userInfo:nil
                                                                     repeats:NO];
                    self.timer = timer;
                    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
                    break;
                }
                case AcceptedGestureTypeNone:
                    [self _endProcessOfDetectGestureType];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = touches.allObjects.firstObject;
    if (!touch) return;
    
    /// If did longpress and move finger
    /// Pass current location through 'hoveringAtPointBlock'
    if (self.recognizedLongTap && self.hoveringAtPointBlock) {
        CGPoint location = [touch locationInView:self.view];
        self.hoveringAtPointBlock(self.view, location);
        return;
    }
    
    /// Optimize: Just cancel if not has any block handle flow hovering finger
    if (touch && self.currentTouchInFo) {
        CGPoint touchLocation = self.currentTouchInFo.location;
        CGPoint location = [touch locationInView:self.view];
        CGPoint distance = CGPointMake(location.x - touchLocation.x, location.y - touchLocation.y);
        if (distance.x*distance.x + distance.y*distance.y > 4.0) {
            self.state = UIGestureRecognizerStateCancelled;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.touchCount -= touches.count;
    [self.timer invalidate];
    
    /// Handle flow leave finger after LongTap and Pan Finger on Screen.
    BOOL leaveFingerAfterLongTapAndPan = self.lastRecognizedGestureInfo
                                            && self.lastRecognizedGestureInfo.gestureType == GestureTypeLongTap
                                            && self.recognizedLongTap == YES;
    if (leaveFingerAfterLongTapAndPan) {
        if (self.leaveFingerAtPointBlock) {
            self.leaveFingerAtPointBlock(self.view, self.lastRecognizedGestureInfo.location);
        }
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }
    
    if (self.tapCount == 1 && self.currentTouchInFo) {
        
        AcceptedGestureType acceptedGestureType = AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
        if (self.acceptedGestureTypeAtPoint) {
            acceptedGestureType = self.acceptedGestureTypeAtPoint(self.currentTouchInFo.location);
        }
        
        switch (acceptedGestureType) {
            case AcceptedGestureTypeSingleTapOnly:
            case AcceptedGestureTypeSingleAndLongTap:
            {
                CGPoint location = self.currentTouchInFo.location;
                self.lastRecognizedGestureInfo = CREATE_GESTURE_INFO(GestureTypeSingleTap, location);
                [self _endProcessOfDetectGestureType];
                break;
            }
            case AcceptedGestureTypeSingleAndLongTapAndDoubleTap:
            {
                /// Waiting for next tap to detect DoubleTap
                self.state = UIGestureRecognizerStateBegan;
                _TapLongTapOrDoubleTapGestureRecognizerTimerTarget *target = [[_TapLongTapOrDoubleTapGestureRecognizerTimerTarget alloc] initWithTarget:self];
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kWaitForDoubleTapDuration
                                                                  target:target
                                                                selector:@selector(tapEvent)
                                                                userInfo:nil
                                                                 repeats:NO];
                self.timer = timer;
                [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
                break;
            }
            case AcceptedGestureTypeNone:
            {
                [self _endProcessOfDetectGestureType];
                break;
            }
            default:
                break;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.touchCount -= touches.count;
    if (self.leaveFingerAtPointBlock) {
        self.leaveFingerAtPointBlock(nil, CGPointZero);
    }

    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark - Helper

- (void)_invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)_endProcessOfDetectGestureType {
    self.state = UIGestureRecognizerStateEnded;
}

+ (void)cancelOtherGesturesWithCurrentGesture:(TapLongTapOrDoubleTapGestureRecognizer *)currentGesture onView:(UIView *)view {
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
        if ([gesture isKindOfClass:TapLongTapOrDoubleTapGestureRecognizer.class] && gesture != currentGesture) {
            [(TapLongTapOrDoubleTapGestureRecognizer *)gesture cancel];
        }
    }
    
    for (UIView *subView in view.subviews) {
        [self cancelOtherGesturesWithCurrentGesture:currentGesture onView:subView];
    }
}

@end
