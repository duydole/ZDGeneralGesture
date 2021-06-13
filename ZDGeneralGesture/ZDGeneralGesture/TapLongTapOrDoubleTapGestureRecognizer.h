//
//  TapLongTapOrDoubleTapGestureRecognizer.h
//  DemoGestureTeleObjC
//
//  Created by Do Le Duy on 12/28/20.
//

#import <UIKit/UIKit.h>
#import "TouchInfo.h"

@class TapLongTapOrDoubleTapGestureRecognizer;

NS_ASSUME_NONNULL_BEGIN

@interface TapLongTapOrDoubleTapGestureRecognizer : UIGestureRecognizer

/// Info about last RecognizedGesture
@property (nonatomic, readonly) GestureInfo *lastRecognizedGestureInfo;

/// Support SingleTap/DoubleTap/LongTap
@property (nonatomic, copy, nullable) AcceptedGestureType (^acceptedGestureTypeAtPoint)(CGPoint point);
@property (nonatomic, copy, nullable) void (^didLongPressBlock)(CGPoint point, TapLongTapOrDoubleTapGestureRecognizer *recognizer);

/// Support action move finger after LongTap
@property (nonatomic, copy, nullable) void (^hoveringAtPointBlock)(UIView * _Nullable view, CGPoint point);
@property (nonatomic, copy, nullable) void (^leaveFingerAtPointBlock)(UIView * _Nullable view, CGPoint point);

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
