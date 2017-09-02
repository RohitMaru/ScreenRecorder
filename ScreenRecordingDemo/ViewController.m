//
//  ViewController.m
//  ScreenRecordingDemo
//
//  Created by Rohit Marumamula on 9/2/17.
//  Copyright © 2017 Rohit Marumamula. All rights reserved.
//

#import "ViewController.h"
#import "ScreenRecordingManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;

@end

@implementation ViewController

NSTimeInterval interval = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:interval+4 target:self selector:@selector(updateBgView) userInfo:nil repeats:YES];
    
}

- (void)updateLabel {
    self.changeLabel.text = [NSString stringWithFormat:@"current value is %ld", [self getRandomNumber]];
}

- (void)updateBgView {
    [UIView animateWithDuration:interval animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:[self getRandomNumber]/256.0 green:[self getRandomNumber]/256.0 blue:[self getRandomNumber]/256.0 alpha:1];
    }];
}

- (NSInteger)getRandomNumber {
    return arc4random() % 256;
}

- (IBAction)recordBtnAction:(UIButton *)recordBtn {
    ScreenRecordingManager *manager = [ScreenRecordingManager sharedManager];

    if (manager.isRecordingOverlayBeingShown) {
        [manager stopRecordingShowingAlert:YES];
    }
    else {
        [manager startRecording];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
