//
//  ScreenRecordingManager.h
//  ScreenRecordingDemo
//
//  Created by Rohit Marumamula on 9/2/17.
//  Copyright © 2017 Rohit Marumamula. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol ScreenRecordingDelegate

- (void)startRecording;
- (void)stopRecordingShowingAlert:(BOOL)shouldShowAlert;

@end

@interface ScreenRecordingManager : NSObject<ScreenRecordingDelegate>

@property (nonatomic) BOOL isRecordingOverlayBeingShown;

+(instancetype)sharedManager;
- (void)setupIfNeeded;
- (void)resetRecordingWindow;
@end
