//
//  ViewController.m
//  ZDGeneralGesture
//
//  Created by Do Le Duy on 13/06/2021.
//

#import "ViewController.h"
#import "TapLongTapOrDoubleTapGestureRecognizer.h"

@interface ViewController ()

@property (nonatomic, strong) UIView    *bigView;
@property (nonatomic, strong) UIView    *blueView;
@property (nonatomic, strong) UIView    *greenView;
@property (nonatomic, strong) UIView    *yellowView;
@property (nonatomic, strong) UIButton  *button1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// BigView
    self.bigView = [[UIView alloc] initWithFrame:CGRectMake(10, 200, self.view.frame.size.width-20, 100)];
    self.bigView.backgroundColor = UIColor.blackColor;
    self.bigView.layer.cornerRadius = 12;
    [self.view addSubview:self.bigView];
    
    /// Button1
    CGFloat padding = 10;
    UIButton *button1 = [UIButton new];
    self.button1 = button1;
    button1.backgroundColor = UIColor.redColor;
    [button1 setTitle:@"Button1" forState:UIControlStateNormal];
    [button1 setTintColor:UIColor.whiteColor];
    button1.frame = CGRectMake(padding, padding, 70, 20);
    button1.layer.cornerRadius = 2.0;
    [button1 addTarget:self action:@selector(didTapButton1) forControlEvents:UIControlEventTouchUpInside];
    [self.bigView addSubview:button1];
    
    /// BlueView
    self.blueView = [UIView new];
    self.blueView.frame = CGRectMake(button1.frame.size.width + 2*padding, padding, 70, 20);
    self.blueView.backgroundColor = UIColor.blueColor;
    [self.bigView addSubview:self.blueView];
    
    /// GreenView
    self.greenView = [UIView new];
    self.greenView.frame = CGRectMake(button1.frame.size.width + 2*padding, 40, 70, 20);
    self.greenView.backgroundColor = UIColor.greenColor;
    [self.bigView addSubview:self.greenView];

    /// YellowView
    self.yellowView = [UIView new];
    self.yellowView.frame = CGRectMake(button1.frame.size.width + 2*padding, 70, 70, 20);
    self.yellowView.backgroundColor = UIColor.yellowColor;
    [self.bigView addSubview:self.yellowView];
    
    [self setupGesture];
}

// MARK: ZDGenericGesture

- (void)setupGesture {
    /// Add Gesture to BigView
    TapLongTapOrDoubleTapGestureRecognizer *gesture = [[TapLongTapOrDoubleTapGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(tapLongTapOrDoubleTapGesture:)];
    [self.bigView addGestureRecognizer:gesture];
    
    /// Setup what of GestureType of each point in BigView
    gesture.acceptedGestureTypeAtPoint = ^AcceptedGestureType(CGPoint point) {
        
        /// BlueView accept SingleTap and LongTap
        if (CGRectContainsPoint(self.blueView.frame, point)) {
            return AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
        }
        
        /// GreenView accept SingleTap and LongTap
        if (CGRectContainsPoint(self.greenView.frame, point)) {
            return AcceptedGestureTypeSingleAndLongTap;
        }
        
        /// YellowView accept SingleTap
        if (CGRectContainsPoint(self.yellowView.frame, point)) {
            return AcceptedGestureTypeSingleTapOnly;
        }
        
        /// Button1 accept SingleTap
        if (CGRectContainsPoint(self.button1.frame, point)) {
            return AcceptedGestureTypeSingleTapOnly;
        }

        /// The rest of BigView accept: SingTap + LongTap + DoubleTap
        return AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
    };
    
    /// Receive LongTap action
    gesture.didLongPressBlock = ^(CGPoint point, TapLongTapOrDoubleTapGestureRecognizer * _Nonnull recognizer) {
        if (recognizer.lastRecognizedGestureInfo) {
            [self gestureRecognized:GestureTypeLongTap location:recognizer.lastRecognizedGestureInfo.location gesture:recognizer];
        }
    };
    gesture.hoveringAtPointBlock = ^(UIView * _Nonnull view, CGPoint point) {
        NSLog(@"Hovering at point: %@",NSStringFromCGPoint(point));
    };
    gesture.leaveFingerAtPointBlock = ^(UIView * _Nullable view, CGPoint point) {
        NSLog(@"Leave finger at point: %@",NSStringFromCGPoint(point));
    };
}

- (void)tapLongTapOrDoubleTapGesture:(TapLongTapOrDoubleTapGestureRecognizer *)gesture {
    /// @selector received SingleTap + DoubleTap action
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded:
            if (gesture.lastRecognizedGestureInfo) {
                [self gestureRecognized:gesture.lastRecognizedGestureInfo.gestureType
                               location:gesture.lastRecognizedGestureInfo.location
                                gesture:gesture];
            }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognized:(GestureType)gestureType
                 location:(CGPoint)location
                  gesture:(TapLongTapOrDoubleTapGestureRecognizer *)gesture {
    /// Function handle all gesture type
    NSString *viewString = [self viewStringAtPoint:location];
    switch (gestureType) {
        case GestureTypeSingleTap:
            NSLog(@"Did SingeTap on %@",viewString);
            break;
        case GestureTypeLongTap:
            NSLog(@"Did Longpress on %@",viewString);
            break;
        case GestureTypeDoubleTap:
            NSLog(@"Did DoubleTap on %@",viewString);
            break;
        default:
            break;
    }
    return YES;
}

// MARK: Other

- (NSString *)viewStringAtPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.greenView.frame, point)) {
        return @"GREEN";
    } else if (CGRectContainsPoint(self.yellowView.frame, point)) {
        return @"YELLOW";
    } else if (CGRectContainsPoint(self.blueView.frame, point)) {
        return @"BLUE";
    } else if (CGRectContainsPoint(self.button1.frame, point)) {
        return @"BUTTON 1";
    } else {
        return @"BIG VIEW";
    }
}

- (void)didTapButton1 {
    NSLog(@"Did tap button 1");
}

@end
