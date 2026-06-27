#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZSTouchEngine : NSObject

+ (instancetype)shared;

- (void)startEngine;
- (void)stopEngine;

- (void)beginRecording;
- (void)stopRecording;

- (void)playRecording;

- (void)addTarget:(CGPoint)point;
- (void)clearTargets;

@property (nonatomic, assign) CGFloat playbackSpeed;

- (void)captureTouch:(CGPoint)point;

@end
