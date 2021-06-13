//
//  TouchInfo.h
//  DemoGestureTeleObjC
//
//  Created by Do Le Duy on 12/29/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define CREATE_GESTURE_INFO(type,location) [[GestureInfo alloc] initWithGestureType:type location:location]

@class TapLongTapOrDoubleTapGestureRecognizer;

typedef enum : NSUInteger {
    GestureTypeSingleTap,
    GestureTypeDoubleTap,
    GestureTypeLongTap
} GestureType;

typedef enum : NSUInteger {
    AcceptedGestureTypeNone,                        /// None
    AcceptedGestureTypeSingleTapOnly,               /// singleTap
    AcceptedGestureTypeSingleAndLongTap,            /// singleTap + longTap
    AcceptedGestureTypeSingleAndLongTapAndDoubleTap /// singleTap + longTap + doubleTap
} AcceptedGestureType;

@interface TouchInfo : NSObject

- (instancetype)initWithLocation:(CGPoint)location andTimeStamp:(CFTimeInterval)timeStamp;

@property (nonatomic, readonly) CGPoint location;
@property (nonatomic, readonly) CFTimeInterval timeStamp;

@end

@interface GestureInfo : NSObject

- (instancetype)initWithGestureType:(GestureType)gestureType
                           location:(CGPoint)location;

@property (nonatomic, assign, readonly) GestureType gestureType;
@property (nonatomic, assign, readonly) CGPoint location;

@end

NS_ASSUME_NONNULL_END
