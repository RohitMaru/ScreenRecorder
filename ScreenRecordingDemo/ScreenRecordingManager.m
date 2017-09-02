//
//  ScreenRecordingManager.m
//  ScreenRecordingDemo
//
//  Created by Rohit Marumamula on 9/2/17.
//  Copyright © 2017 Rohit Marumamula. All rights reserved.
//

#import "ScreenRecordingManager.h"
@import ReplayKit;

static CGFloat const RecordButtonHeight = 60;
static CGFloat const TapCircleHeight = 30;

@interface DrawingView: UIView
@property (nonatomic) UIImageView *tempDrawImage;
@end

@implementation DrawingView


CGPoint lastPoint;
CGFloat brush;
CGFloat opacity;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.tempDrawImage = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:self.tempDrawImage];
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (![[RPScreenRecorder sharedRecorder] isRecording]) {
        return NO;
    }

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:point radius:(TapCircleHeight/2) startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    UIColor *grayColor = [UIColor lightGrayColor];
    
    CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
    [circleLayer setPath:bezierPath.CGPath];
    [circleLayer setStrokeColor:grayColor.CGColor];
    [circleLayer setFillColor:[UIColor clearColor].CGColor];
    [circleLayer setOpacity:0.3];
    [circleLayer setLineWidth:5];
    
    UIBezierPath *internalBezierPath = [UIBezierPath bezierPath];
    [internalBezierPath addArcWithCenter:point radius:(TapCircleHeight/2) - 5 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    CAShapeLayer *internalCircleLayer = [[CAShapeLayer alloc] init];
    [internalCircleLayer setPath:internalBezierPath.CGPath];
    [internalCircleLayer setFillColor:[UIColor lightGrayColor].CGColor];
    [internalCircleLayer setOpacity:0.3];
    [self.layer addSublayer:internalCircleLayer];
    
    
    [self.layer addSublayer:circleLayer];
    
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:circleLayer.opacity];
    fadeAnim.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnim.duration = 0.6;
    [circleLayer addAnimation:fadeAnim forKey:@"opacity"];
    [internalCircleLayer addAnimation:fadeAnim forKey:@"opacity"];
    circleLayer.opacity = 0;
    internalCircleLayer.opacity = 0;

    return NO;
}
@end


@interface ScreenRecordingRootViewController: UIViewController
@property (nonatomic) UIButton *recordButton;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic, weak) id<ScreenRecordingDelegate> recordDelegate;

- (void)setupRecordingView;
@end

@implementation ScreenRecordingRootViewController

- (void)viewDidLoad {
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backgroundView];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchDown];

    CGRect recordBtnFrame = self.view.frame;
    recordBtnFrame.origin.y = recordBtnFrame.size.height - RecordButtonHeight - 10;
    recordBtnFrame.origin.x = (recordBtnFrame.size.width - RecordButtonHeight)/2;
    recordBtnFrame.size.height = RecordButtonHeight;
    recordBtnFrame.size.width = RecordButtonHeight;
    self.recordButton.frame = recordBtnFrame;
    self.recordButton.backgroundColor = [UIColor clearColor];
    self.recordButton.alpha = 0.6;
    
    [self setupRecordingView];

    [self.view addSubview:self.recordButton];
}

- (void)toggleRecording {
    if (self.recordDelegate) {
        if ([[RPScreenRecorder sharedRecorder] isRecording]) {
            [self.recordDelegate stopRecordingShowingAlert:YES];
        }
        else {
            [self.recordDelegate startRecording];
        }
    }
}

- (void)setupRecordingView {
    //Remove previous sublayers..
    self.recordButton.layer.sublayers = nil;
    //Add layer..
    CGPoint recordBtnPoint = CGPointMake(CGRectGetWidth(self.recordButton.frame)/2, CGRectGetHeight(self.recordButton.frame)/2);
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:recordBtnPoint radius:(RecordButtonHeight/2 - 5) startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    CAShapeLayer *outerCircleLayer = [[CAShapeLayer alloc] init];
    [outerCircleLayer setPath:bezierPath.CGPath];
    [outerCircleLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
    [outerCircleLayer setLineWidth:5];
    [outerCircleLayer setStrokeEnd:1];
    
    if ([RPScreenRecorder sharedRecorder].isRecording) {
        [outerCircleLayer setFillColor:[UIColor clearColor].CGColor];
        CGRect internalStopFrame = CGRectMake(recordBtnPoint.x - 10, recordBtnPoint.y - 10, 20, 20);
        
        UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:internalStopFrame cornerRadius:5];
        CAShapeLayer *roundedRectLayer = [[CAShapeLayer alloc] init];
        [roundedRectLayer setPath:roundedRectPath.CGPath];
        [roundedRectLayer setFillColor:[UIColor redColor].CGColor];
        [self.recordButton.layer addSublayer:roundedRectLayer];
        
    }
    else {
        [outerCircleLayer setFillColor:[UIColor redColor].CGColor];
        
    }
    
    [self.recordButton.layer addSublayer:outerCircleLayer];
    
    if ([RPScreenRecorder sharedRecorder].isAvailable) {
        if ( ![RPScreenRecorder sharedRecorder].isRecording) {
            [self.backgroundView setBackgroundColor:[UIColor grayColor]];
            [self.backgroundView setAlpha:0.2];
        }
        else {
            [self.backgroundView setBackgroundColor:[UIColor clearColor]];
            [self.backgroundView setAlpha:1];
        }
    }

    [self.view layoutSubviews];
}

@end

@interface ScreenRecordingWindow: UIWindow

@end

@implementation ScreenRecordingWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIViewController *rootVC = self.rootViewController;
    if ([rootVC isKindOfClass:[ScreenRecordingRootViewController class]]) {
        ScreenRecordingRootViewController *recordingVC = (ScreenRecordingRootViewController *)rootVC;
        UIView *hitView = [super hitTest:point withEvent:event];
        if (recordingVC.recordButton == hitView) {
            //Its a record button, so respond..
            return hitView;
        }
    }
    return nil;
}

@end

@interface ScreenRecordingManager()<RPPreviewViewControllerDelegate, ScreenRecordingDelegate>

@property (nonatomic) ScreenRecordingWindow *recordingWindow;
@property (nonatomic) ScreenRecordingRootViewController *recordingVC;
@property (nonatomic) DrawingView *touchesView;

@end

@implementation ScreenRecordingManager


+(instancetype)sharedManager {
    static ScreenRecordingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ScreenRecordingManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)setupIfNeeded {
    ScreenRecordingManager *manager = [ScreenRecordingManager sharedManager];
    if (manager.recordingWindow == nil) {
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];

        manager.recordingWindow = [[ScreenRecordingWindow alloc] initWithFrame:mainWindow.frame];
        [manager.recordingWindow setWindowLevel:(UIWindowLevelAlert + 1)];

        self.touchesView = [[DrawingView alloc] initWithFrame:mainWindow.frame];
        [self.touchesView setBackgroundColor:[UIColor clearColor]];
        [mainWindow addSubview:self.touchesView];
    }
    
    if (manager.recordingVC == nil) {
        UIWindow *recordingWindow = manager.recordingWindow;
        manager.recordingVC = [[ScreenRecordingRootViewController alloc] init];
        manager.recordingVC.recordDelegate = manager;
        manager.recordingVC.view.frame = recordingWindow.frame;
        recordingWindow.rootViewController = manager.recordingVC;
    }
    if (!manager.recordingWindow.isKeyWindow) {
        [manager.recordingWindow makeKeyAndVisible];
    }
    
    self.isRecordingOverlayBeingShown = YES;
}

#pragma mark - ScreenRecordingDelegate methods

- (void)startRecording {
    [self setupIfNeeded];
    [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
        //Update button layer..
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //then remove the recording window..
                [self resetRecordingWindow];
            }
            else {
                //Start recording..
                ScreenRecordingManager *manager = [ScreenRecordingManager sharedManager];
                [manager.recordingVC setupRecordingView];
                
                UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
                statusBar.backgroundColor = [UIColor redColor];
                [statusBar layoutSubviews];
            }
        });
    }];
}

- (void)stopRecordingShowingAlert:(BOOL)shouldShowAlert {
    ScreenRecordingManager *manager = [ScreenRecordingManager sharedManager];

    [self resetRecordingWindow];
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.backgroundColor = nil;
    [statusBar layoutSubviews];

    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update button layer..
            [manager.recordingVC setupRecordingView];
        });
        if (shouldShowAlert) {
            //Prompt user with actions..
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Yahoo Mail" message:@"Do you want to view the recording?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"View" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    previewViewController.previewControllerDelegate = self;
                    [[ScreenRecordingManager topMostController] presentViewController:previewViewController animated:YES completion:^{
                    }];
                });
            }];
            UIAlertAction *discardAction = [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[RPScreenRecorder sharedRecorder] discardRecordingWithHandler:^{}];
            }];
            
            [alertController addAction:viewAction];
            [alertController addAction:discardAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ScreenRecordingManager topMostController] presentViewController:alertController animated:YES completion:nil];
            });
        }
    }];
}

- (void)resetRecordingWindow {
    //Deallocate resources..
    ScreenRecordingManager *manager = [ScreenRecordingManager sharedManager];
    [self.touchesView removeFromSuperview];
    self.touchesView = nil;
    [manager.recordingWindow setHidden:YES];
    [manager.recordingWindow resignKeyWindow];
    manager.recordingVC = nil;
    manager.recordingWindow = nil;

    manager.isRecordingOverlayBeingShown = NO;
    
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.backgroundColor = nil;
    [statusBar layoutSubviews];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
@end
