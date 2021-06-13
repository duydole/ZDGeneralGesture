//
//  ViewController.m
//  DemoGestureTeleObjC
//
//  Created by Do Le Duy on 12/28/20.
//

#import "ViewController.h"
#import "TapLongTapOrDoubleTapGestureRecognizer.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIView *greenView;
@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UIButton *button1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(10, 200, self.view.frame.size.width-20, 100)];
    cellView.backgroundColor = UIColor.blackColor;
    cellView.layer.cornerRadius = 12;
    [self.view addSubview:cellView];
    
    CGFloat padding = 10;
    UIButton *button1 = [UIButton new];
    self.button1 = button1;
    button1.backgroundColor = UIColor.redColor;
    [button1 setTitle:@"Button1" forState:UIControlStateNormal];
    [button1 setTintColor:UIColor.whiteColor];
    button1.frame = CGRectMake(padding, padding, 70, 20);
    button1.layer.cornerRadius = 2.0;
    [button1 addTarget:self action:@selector(didTapButton1) forControlEvents:UIControlEventTouchUpInside];
    [cellView addSubview:button1];
    
    self.blueView = [UIView new];
    self.blueView.frame = CGRectMake(button1.frame.size.width + 2*padding, padding, 70, 20);
    self.blueView.backgroundColor = UIColor.blueColor;
    [cellView addSubview:self.blueView];
    
    self.greenView = [UIView new];
    self.greenView.frame = CGRectMake(button1.frame.size.width + 2*padding, 40, 70, 20);
    self.greenView.backgroundColor = UIColor.greenColor;
    [cellView addSubview:self.greenView];

    self.yellowView = [UIView new];
    self.yellowView.frame = CGRectMake(button1.frame.size.width + 2*padding, 70, 70, 20);
    self.yellowView.backgroundColor = UIColor.yellowColor;
    [cellView addSubview:self.yellowView];
    
    /// Add Gesture to RedView
    TapLongTapOrDoubleTapGestureRecognizer *gesture = [[TapLongTapOrDoubleTapGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(tapLongTapOrDoubleTapGesture:)];
    [cellView addGestureRecognizer:gesture];
    gesture.acceptedGestureTypeAtPoint = ^AcceptedGestureType(CGPoint point) {
        
        if (CGRectContainsPoint(self.blueView.frame, point)) {
            return AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
        }
        if (CGRectContainsPoint(self.greenView.frame, point)) {
            return AcceptedGestureTypeSingleAndLongTap;
        }
        if (CGRectContainsPoint(self.yellowView.frame, point)) {
            return AcceptedGestureTypeSingleTapOnly;
        }
        if (CGRectContainsPoint(self.button1.frame, point)) {
            return AcceptedGestureTypeSingleTapOnly;
        }

        return AcceptedGestureTypeSingleAndLongTapAndDoubleTap;
    };
    gesture.didLongPressBlock = ^(CGPoint point, TapLongTapOrDoubleTapGestureRecognizer * _Nonnull recognizer) {
        if (recognizer.lastRecognizedGestureInfo) {
            [self gestureRecognized:GestureTypeLongTap location:recognizer.lastRecognizedGestureInfo.location gesture:recognizer];
        }
    };
    gesture.hoveringAtPointBlock = ^(UIView * _Nonnull view, CGPoint point) {
        NSLog(@"%@: Hovering at point: %@",NSStringFromClass(self.class),NSStringFromCGPoint(point));
    };
    gesture.leaveFingerAtPointBlock = ^(UIView * _Nullable view, CGPoint point) {
        NSLog(@"%@: Leave finger at point: %@",NSStringFromClass(self.class),NSStringFromCGPoint(point));
    };
}

- (void)tapLongTapOrDoubleTapGesture:(TapLongTapOrDoubleTapGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateEnded:
            if (gesture.lastRecognizedGestureInfo) {
                [self gestureRecognized:gesture.lastRecognizedGestureInfo.gestureType
                               location:gesture.lastRecognizedGestureInfo.location gesture:gesture];
            }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognized:(GestureType)gestureType
                 location:(CGPoint)location
                  gesture:(TapLongTapOrDoubleTapGestureRecognizer *)gesture {
    NSString *viewString = [self viewAtPoint:location];
    switch (gestureType) {
        case GestureTypeSingleTap:
            NSLog(@"%@: Did Tap on %@",NSStringFromClass(self.class),viewString);
            break;
        case GestureTypeLongTap:
            NSLog(@"%@: Did Longpress %@",NSStringFromClass(self.class),viewString);
            break;
        case GestureTypeDoubleTap:
            NSLog(@"%@: Did DoubleTap %@",NSStringFromClass(self.class),viewString);
            break;
        default:
            break;
    }
    return YES;
}

- (NSString *)viewAtPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.greenView.frame, point)) {
        return @"GREEN";
    } else if (CGRectContainsPoint(self.yellowView.frame, point)) {
        return @"YELLOW";
    } else if (CGRectContainsPoint(self.blueView.frame, point)) {
        return @"BLUE";
    } else if (CGRectContainsPoint(self.button1.frame, point)) {
        return @"BUTTON 1";
    } else {
        return @"CELL";
    }
}

- (void)didTapButton1 {
    NSLog(@"did tap button 1");
}

@end
