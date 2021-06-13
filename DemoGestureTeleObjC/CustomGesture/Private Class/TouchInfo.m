//
//  TouchInfo.m
//  DemoGestureTeleObjC
//
//  Created by Do Le Duy on 12/29/20.
//

#import "TouchInfo.h"
#import "TapLongTapOrDoubleTapGestureRecognizer.h"

#pragma mark - TouchInfo

@interface TouchInfo()

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CFTimeInterval timeStamp;

@end

@implementation TouchInfo

- (instancetype)initWithLocation:(CGPoint)location
                    andTimeStamp:(CFTimeInterval)timeStamp {
    self = [super init];
    if (self) {
        self.location = location;
        self.timeStamp = timeStamp;
    }
    return self;
}

@end

#pragma mark - GestureInfo

@interface GestureInfo()

@property (nonatomic, assign) GestureType gestureType;
@property (nonatomic, assign) CGPoint location;

@end

@implementation GestureInfo

- (instancetype)initWithGestureType:(GestureType)gestureType
                           location:(CGPoint)location {
    self = [super init];
    if (self) {
        self.gestureType = gestureType;
        self.location = location;
    }
    return self;
}

@end
